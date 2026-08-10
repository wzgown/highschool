// tracing.go Agent 链路 OTel span 辅助
// tracing 关闭时全局为 noop provider，span 零开销，埋点可安全常开。
package graph

import (
	"context"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

// tracer Agent 内部埋点用 Tracer
var tracer = otel.Tracer("highschool-agent")

// startSpan 从 ctx 开启 span 并附带属性
func startSpan(ctx context.Context, name string, attrs ...attribute.KeyValue) (context.Context, trace.Span) {
	return tracer.Start(ctx, name, trace.WithAttributes(attrs...))
}
