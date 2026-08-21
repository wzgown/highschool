// Package metrics OTel 指标（agent 链路）。
// 双 reader：OTLP/HTTP 周期推送 OpenObserve（主链路，与 traces 同端点同认证），
// 以及 Prometheus 文本格式 /metrics（仅本地调试，生产不依赖拉取）。
// 指标名与历史 Prometheus 版保持一致，OpenObserve 侧查询无需变更。
package metrics

import (
	"context"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp"
	promexp "go.opentelemetry.io/otel/exporters/prometheus"
	otelmetric "go.opentelemetry.io/otel/metric"
	"go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.26.0"
)

// Config OTLP 推送配置（与 tracing.Config 同构，指向同一 OpenObserve）
type Config struct {
	Enabled      bool
	ServiceName  string
	OTLPEndpoint string // host:port，如 openobserve:5080
	URLPath      string // 如 /api/default/v1/metrics
	Headers      string // "k=v,k2=v2"，OpenObserve 需 Authorization: Basic ...
	IntervalSec  int    // 推送周期秒，默认 60
}

var (
	mp              *metric.MeterProvider
	promReg         *prometheus.Registry
	initOnce        sync.Once
	instrumentsInst *agentMetrics
)

// agentMetrics agent 链路全部指标仪器（经全局 MeterProvider 绑定）
type agentMetrics struct {
	chatRequests otelmetric.Int64Counter
	llmCalls     otelmetric.Int64Counter
	llmTokens    otelmetric.Int64Counter
	llmCache     otelmetric.Int64Counter
	llmDuration  otelmetric.Float64Histogram
	toolCalls    otelmetric.Int64Counter
	toolDuration otelmetric.Float64Histogram
}

func newAgentMetrics() *agentMetrics {
	m := otel.Meter("highschool.agent")
	am := &agentMetrics{}
	var err error
	// 任一仪器创建失败即整体禁用（no-op），不拖垮服务
	if am.chatRequests, err = m.Int64Counter("agent_chat_requests_total",
		otelmetric.WithDescription("AI 顾问对话请求总数")); err != nil {
		return nil
	}
	if am.llmCalls, err = m.Int64Counter("agent_llm_calls_total",
		otelmetric.WithDescription("LLM 调用次数")); err != nil {
		return nil
	}
	if am.llmTokens, err = m.Int64Counter("agent_llm_tokens_total",
		otelmetric.WithDescription("LLM token 消耗")); err != nil {
		return nil
	}
	if am.llmCache, err = m.Int64Counter("agent_llm_cache_tokens_total",
		otelmetric.WithDescription("LLM prefix cache 命中/未命中 token（kind=hit|miss，未命中全价、命中约1/10价）")); err != nil {
		return nil
	}
	if am.llmDuration, err = m.Float64Histogram("agent_llm_duration_seconds",
		otelmetric.WithDescription("LLM 调用耗时")); err != nil {
		return nil
	}
	if am.toolCalls, err = m.Int64Counter("agent_tool_calls_total",
		otelmetric.WithDescription("工具调用次数")); err != nil {
		return nil
	}
	if am.toolDuration, err = m.Float64Histogram("agent_tool_duration_seconds",
		otelmetric.WithDescription("工具执行耗时")); err != nil {
		return nil
	}
	return am
}

// inst 懒加载指标仪器（首次 Observe 时绑定全局 MeterProvider；
// 未 Init 时为 no-op，业务零依赖）
func inst() *agentMetrics {
	initOnce.Do(func() { instrumentsInst = newAgentMetrics() })
	return instrumentsInst
}

// parseHeaders 解析 "k=v,k2=v2" 形式的 header 串（与 tracing 同款）
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

// Init 初始化指标：OTLP/HTTP 周期推送 OpenObserve + Prometheus /metrics 调试端点。
// 返回 shutdown（进程退出时调用以 flush 末批数据）。
func Init(ctx context.Context, cfg Config) (func(context.Context) error, error) {
	promReg = prometheus.NewRegistry()
	promReader, err := promexp.New(promexp.WithRegisterer(promReg))
	if err != nil {
		return nil, err
	}

	opts := []metric.Option{
		metric.WithResource(resource.NewWithAttributes(
			semconv.SchemaURL, semconv.ServiceName(cfg.ServiceName))),
		metric.WithReader(promReader),
	}

	if cfg.Enabled {
		expOpts := []otlpmetrichttp.Option{
			otlpmetrichttp.WithEndpoint(cfg.OTLPEndpoint),
			otlpmetrichttp.WithInsecure(),
		}
		if cfg.URLPath != "" {
			expOpts = append(expOpts, otlpmetrichttp.WithURLPath(cfg.URLPath))
		}
		if h := parseHeaders(cfg.Headers); len(h) > 0 {
			expExp := otlpmetrichttp.WithHeaders(h)
			expOpts = append(expOpts, expExp)
		}
		exporter, err := otlpmetrichttp.New(ctx, expOpts...)
		if err != nil {
			return nil, err
		}
		interval := time.Duration(cfg.IntervalSec) * time.Second
		if interval <= 0 {
			interval = 60 * time.Second
		}
		// OTLP 推送失败仅异步重试/丢弃（OpenObserve 未启动不影响服务），与 traces 同契约
		opts = append(opts, metric.WithReader(metric.NewPeriodicReader(exporter,
			metric.WithInterval(interval))))
	}

	mp = metric.NewMeterProvider(opts...)
	otel.SetMeterProvider(mp)
	return mp.Shutdown, nil
}

// Handler 返回 /metrics HTTP handler（Prometheus 文本格式，本地调试用）
func Handler() http.Handler {
	if promReg == nil {
		promReg = prometheus.NewRegistry()
	}
	return promhttp.HandlerFor(promReg, promhttp.HandlerOpts{})
}

// IncChatRequests 对话请求计数 +1
func IncChatRequests() {
	if am := inst(); am != nil {
		am.chatRequests.Add(context.Background(), 1)
	}
}

// ObserveLLMCall 记录一次 LLM 调用（status=success|error；cacheHit/cacheMiss 为
// prefix cache 命中拆分；node 为调用节点 router/planner/synthesizer…）
func ObserveLLMCall(model, node, status string, promptTokens, completionTokens, cacheHit, cacheMiss int, seconds float64) {
	am := inst()
	if am == nil {
		return
	}
	if model == "" {
		model = "unknown"
	}
	ctx := context.Background()
	am.llmCalls.Add(ctx, 1, otelmetric.WithAttributes(
		attribute.String("model", model), attribute.String("status", status)))
	if promptTokens > 0 {
		am.llmTokens.Add(ctx, int64(promptTokens), otelmetric.WithAttributes(
			attribute.String("model", model), attribute.String("kind", "prompt")))
	}
	if completionTokens > 0 {
		am.llmTokens.Add(ctx, int64(completionTokens), otelmetric.WithAttributes(
			attribute.String("model", model), attribute.String("kind", "completion")))
	}
	if cacheHit > 0 {
		am.llmCache.Add(ctx, int64(cacheHit), otelmetric.WithAttributes(
			attribute.String("model", model), attribute.String("node", node), attribute.String("kind", "hit")))
	}
	if cacheMiss > 0 {
		am.llmCache.Add(ctx, int64(cacheMiss), otelmetric.WithAttributes(
			attribute.String("model", model), attribute.String("node", node), attribute.String("kind", "miss")))
	}
	am.llmDuration.Record(ctx, seconds, otelmetric.WithAttributes(attribute.String("model", model)))
}

// ObserveToolCall 记录一次工具执行（status=success|error）
func ObserveToolCall(tool, status string, seconds float64) {
	am := inst()
	if am == nil {
		return
	}
	ctx := context.Background()
	am.toolCalls.Add(ctx, 1, otelmetric.WithAttributes(
		attribute.String("tool", tool), attribute.String("status", status)))
	am.toolDuration.Record(ctx, seconds, otelmetric.WithAttributes(attribute.String("tool", tool)))
}
