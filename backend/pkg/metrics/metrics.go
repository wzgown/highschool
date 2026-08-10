// Package metrics Prometheus 指标（agent 链路）
package metrics

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	chatRequests = promauto.NewCounter(prometheus.CounterOpts{
		Name: "agent_chat_requests_total",
		Help: "AI 顾问对话请求总数",
	})
	llmCalls = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "agent_llm_calls_total",
		Help: "LLM 调用次数",
	}, []string{"model", "status"})
	llmTokens = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "agent_llm_tokens_total",
		Help: "LLM token 消耗",
	}, []string{"model", "kind"})
	llmDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "agent_llm_duration_seconds",
		Help:    "LLM 调用耗时",
		Buckets: prometheus.DefBuckets,
	}, []string{"model"})
	toolCalls = promauto.NewCounterVec(prometheus.CounterOpts{
		Name: "agent_tool_calls_total",
		Help: "工具调用次数",
	}, []string{"tool", "status"})
	toolDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
		Name:    "agent_tool_duration_seconds",
		Help:    "工具执行耗时",
		Buckets: prometheus.DefBuckets,
	}, []string{"tool"})
)

// Handler 返回 /metrics HTTP handler
func Handler() http.Handler { return promhttp.Handler() }

// IncChatRequests 对话请求计数 +1
func IncChatRequests() { chatRequests.Inc() }

// ObserveLLMCall 记录一次 LLM 调用（status 为 success/error，kind 为 prompt/completion）
func ObserveLLMCall(model, status string, promptTokens, completionTokens int, seconds float64) {
	if model == "" {
		model = "unknown"
	}
	llmCalls.WithLabelValues(model, status).Inc()
	if promptTokens > 0 {
		llmTokens.WithLabelValues(model, "prompt").Add(float64(promptTokens))
	}
	if completionTokens > 0 {
		llmTokens.WithLabelValues(model, "completion").Add(float64(completionTokens))
	}
	llmDuration.WithLabelValues(model).Observe(seconds)
}

// ObserveToolCall 记录一次工具执行（status 为 success/error）
func ObserveToolCall(tool, status string, seconds float64) {
	toolCalls.WithLabelValues(tool, status).Inc()
	toolDuration.WithLabelValues(tool).Observe(seconds)
}
