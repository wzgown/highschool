package tracing

import (
	"context"
	"strings"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
	"go.opentelemetry.io/otel/trace"
	"go.opentelemetry.io/otel/trace/noop"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

var tracerProvider *sdktrace.TracerProvider
var tracer trace.Tracer

// Config holds tracing configuration
type Config struct {
	Enabled      bool
	ServiceName  string
	OTLPEndpoint string
	Protocol     string // grpc（默认，collector）/ http（OpenObserve 直连）
	URLPath      string // http 协议路径，如 /api/default/v1/traces
	Headers      string // "k=v,k2=v2"，OpenObserve 需要 Authorization: Basic ...
	SampleRate   float64
}

// parseHeaders 解析 "k=v,k2=v2" 形式的 header 串
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

// newExporter 按协议创建 OTLP exporter（http 用于 OpenObserve，grpc 用于 collector）
func newExporter(ctx context.Context, cfg Config) (*otlptrace.Exporter, error) {
	if strings.EqualFold(cfg.Protocol, "http") {
		opts := []otlptracehttp.Option{
			otlptracehttp.WithEndpoint(cfg.OTLPEndpoint),
			otlptracehttp.WithInsecure(),
		}
		if cfg.URLPath != "" {
			opts = append(opts, otlptracehttp.WithURLPath(cfg.URLPath))
		}
		if h := parseHeaders(cfg.Headers); len(h) > 0 {
			opts = append(opts, otlptracehttp.WithHeaders(h))
		}
		return otlptracehttp.New(ctx, opts...)
	}

	conn, err := grpc.NewClient(cfg.OTLPEndpoint,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return nil, err
	}
	return otlptracegrpc.New(ctx, otlptracegrpc.WithGRPCConn(conn))
}

// Initialize initializes the OpenTelemetry tracing
func Initialize(cfg Config) (func(context.Context) error, error) {
	if !cfg.Enabled {
		// Use no-op tracer when disabled
		tracer = noop.NewTracerProvider().Tracer(cfg.ServiceName)
		return func(ctx context.Context) error { return nil }, nil
	}

	ctx := context.Background()

	// Create OTLP exporter（连接均为懒建立，接收端不在线不会 panic，仅异步导出失败）
	exporter, err := newExporter(ctx, cfg)
	if err != nil {
		return nil, err
	}

	// Create resource with service info
	res, err := resource.New(ctx,
		resource.WithAttributes(
			semconv.ServiceName(cfg.ServiceName),
		),
	)
	if err != nil {
		return nil, err
	}

	// Determine sampler based on sample rate
	var sampler sdktrace.Sampler
	if cfg.SampleRate >= 1.0 {
		sampler = sdktrace.AlwaysSample()
	} else if cfg.SampleRate <= 0.0 {
		sampler = sdktrace.NeverSample()
	} else {
		sampler = sdktrace.TraceIDRatioBased(cfg.SampleRate)
	}

	// Create tracer provider
	tracerProvider = sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
		sdktrace.WithSampler(sampler),
	)

	// Register tracer provider and propagator
	otel.SetTracerProvider(tracerProvider)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	// Create tracer
	tracer = tracerProvider.Tracer(cfg.ServiceName)

	// Return shutdown function
	return func(ctx context.Context) error {
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		return tracerProvider.Shutdown(ctx)
	}, nil
}

// GetTracer returns the global tracer
func GetTracer() trace.Tracer {
	if tracer == nil {
		return noop.NewTracerProvider().Tracer("highschool-backend")
	}
	return tracer
}

// GetTraceID extracts the trace ID from context
func GetTraceID(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	spanCtx := trace.SpanContextFromContext(ctx)
	if spanCtx.IsValid() {
		return spanCtx.TraceID().String()
	}
	return ""
}

// StartSpan starts a new span from context
func StartSpan(ctx context.Context, name string, opts ...trace.SpanStartOption) (context.Context, trace.Span) {
	return GetTracer().Start(ctx, name, opts...)
}
