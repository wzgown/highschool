// Package otellog provides a zap → OTLP/HTTP bridge for exporting Go logs to OpenObserve.
package otellog

import (
	"context"
	"fmt"
	"math"
	"os"
	"strings"
	"sync"
	"time"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlplog/otlploghttp"
	"go.opentelemetry.io/otel/log"
	sdklog "go.opentelemetry.io/otel/sdk/log"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
	"go.uber.org/zap/zapcore"
)

var (
	provider   *sdklog.LoggerProvider
	otelLogger log.Logger
	mu         sync.Mutex
	bgCtx      = context.Background()
)

// Config holds OTLP log export configuration.
type Config struct {
	Enabled     bool
	Endpoint    string // host:port (e.g. openobserve:5080)
	URLPath     string // e.g. /api/default/v1/logs
	Headers     string // "k=v,k2=v2" format
	ServiceName string // e.g. highschool-backend
}

// parseHeaders parses "k=v,k2=v2" format into map.
func parseHeaders(s string) map[string]string {
	m := map[string]string{}
	for _, kv := range strings.Split(s, ",") {
		kv = strings.TrimSpace(kv)
		if kv == "" {
			continue
		}
		parts := strings.SplitN(kv, "=", 2)
		if len(parts) == 2 {
			m[strings.TrimSpace(parts[0])] = strings.TrimSpace(parts[1])
		}
	}
	return m
}

// Initialize creates the OTLP log exporter and returns a shutdown func.
// Must be called BEFORE logger.Initialize so the zap core can find the provider.
func Initialize(ctx context.Context, cfg Config) (func(context.Context) error, error) {
	shutdown := func(context.Context) error { return nil }
	if !cfg.Enabled || cfg.Endpoint == "" {
		return shutdown, nil
	}

	opts := []otlploghttp.Option{
		otlploghttp.WithEndpoint(cfg.Endpoint),
		otlploghttp.WithInsecure(),
	}
	if cfg.URLPath != "" {
		opts = append(opts, otlploghttp.WithURLPath(cfg.URLPath))
	}
	if h := parseHeaders(cfg.Headers); len(h) > 0 {
		opts = append(opts, otlploghttp.WithHeaders(h))
	}

	exporter, err := otlploghttp.New(ctx, opts...)
	if err != nil {
		return shutdown, fmt.Errorf("create otlp log exporter: %w", err)
	}

	res := resource.NewWithAttributes(
		semconv.SchemaURL,
		semconv.ServiceName(cfg.ServiceName),
	)

	provider = sdklog.NewLoggerProvider(
		sdklog.WithResource(res),
		sdklog.WithProcessor(sdklog.NewBatchProcessor(exporter)),
	)

	otelLogger = provider.Logger(cfg.ServiceName)

	shutdown = func(ctx context.Context) error {
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		return provider.Shutdown(ctx)
	}

	fmt.Fprintf(os.Stderr, "[otellog] OTLP log exporter initialized: %s%s\n", cfg.Endpoint, cfg.URLPath)
	return shutdown, nil
}

// NewZapCore returns a zapcore.Core that forwards logs to the OTLP exporter.
// Safe to call even if the exporter was not initialized (returns a no-op core).
func NewZapCore(level zapcore.Level) zapcore.Core {
	return &otelCore{level: level}
}

type otelCore struct {
	level zapcore.Level
}

func (c *otelCore) Enabled(lvl zapcore.Level) bool {
	return lvl >= c.level
}

func (c *otelCore) With(fields []zapcore.Field) zapcore.Core {
	return &otelCore{level: c.level}
}

func (c *otelCore) Check(entry zapcore.Entry, ce *zapcore.CheckedEntry) *zapcore.CheckedEntry {
	if c.Enabled(entry.Level) {
		return ce.AddCore(entry, c)
	}
	return ce
}

func (c *otelCore) Write(entry zapcore.Entry, fields []zapcore.Field) error {
	mu.Lock()
	defer mu.Unlock()

	if otelLogger == nil {
		return nil
	}

	var r log.Record
	r.SetTimestamp(entry.Time)
	r.SetSeverity(mapSeverity(entry.Level))
	r.SetBody(attribute.StringValue(entry.Message))

	attrs := []attribute.KeyValue{
		attribute.String("logger", entry.LoggerName),
		attribute.String("caller", entry.Caller.String()),
	}
	for _, f := range fields {
		attrs = append(attrs, fieldToAttr(f))
	}
	r.AddAttributes(attrs...)

	otelLogger.Emit(bgCtx, r)
	return nil
}

func (c *otelCore) Sync() error { return nil }

func mapSeverity(lvl zapcore.Level) log.Severity {
	switch lvl {
	case zapcore.DebugLevel:
		return log.SeverityDebug
	case zapcore.InfoLevel:
		return log.SeverityInfo
	case zapcore.WarnLevel:
		return log.SeverityWarn
	case zapcore.ErrorLevel:
		return log.SeverityError
	case zapcore.FatalLevel, zapcore.PanicLevel:
		return log.SeverityFatal
	default:
		return log.SeverityInfo
	}
}

func fieldToAttr(f zapcore.Field) attribute.KeyValue {
	switch f.Type {
	case zapcore.StringType:
		return attribute.String(f.Key, f.String)
	case zapcore.Int8Type, zapcore.Int16Type, zapcore.Int32Type, zapcore.Int64Type:
		return attribute.Int64(f.Key, f.Integer)
	case zapcore.Uint8Type, zapcore.Uint16Type, zapcore.Uint32Type, zapcore.Uint64Type:
		return attribute.Int64(f.Key, int64(f.Integer))
	case zapcore.Float32Type, zapcore.Float64Type:
		return attribute.Float64(f.Key, math.Float64frombits(uint64(f.Integer)))
	case zapcore.BoolType:
		return attribute.Bool(f.Key, f.Integer == 1)
	case zapcore.ErrorType:
		return attribute.String(f.Key, f.Interface.(error).Error())
	case zapcore.StringerType:
		return attribute.String(f.Key, f.Interface.(fmt.Stringer).String())
	default:
		return attribute.String(f.Key, fmt.Sprintf("%+v", f.Interface))
	}
}
