package tracing

import (
	"context"
	"time"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
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
	Enabled     bool
	ServiceName string
	OTLPEndpoint string
	SampleRate  float64
}

// Initialize initializes the OpenTelemetry tracing
func Initialize(cfg Config) (func(context.Context) error, error) {
	if !cfg.Enabled {
		// Use no-op tracer when disabled
		tracer = noop.NewTracerProvider().Tracer(cfg.ServiceName)
		return func(ctx context.Context) error { return nil }, nil
	}

	ctx := context.Background()

	// Create gRPC connection to OTLP receiver
	conn, err := grpc.NewClient(cfg.OTLPEndpoint,
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		return nil, err
	}

	// Create OTLP exporter
	exporter, err := otlptracegrpc.New(ctx, otlptracegrpc.WithGRPCConn(conn))
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
