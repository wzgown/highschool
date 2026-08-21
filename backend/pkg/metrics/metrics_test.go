// metrics_test.go 用 ManualReader 验证指标值与标签（OTel SDK 双 reader 行为的单侧锁定）
package metrics

import (
	"context"
	"sort"
	"strings"
	"testing"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/metric/metricdata"
)

// findSum 在收集结果里找指定指标名，返回 规范化属性键->累计值
func findSum(t *testing.T, rm metricdata.ResourceMetrics, name string) map[string]int64 {
	t.Helper()
	out := map[string]int64{}
	for _, sm := range rm.ScopeMetrics {
		for _, m := range sm.Metrics {
			if m.Name != name {
				continue
			}
			sum, ok := m.Data.(metricdata.Sum[int64])
			if !ok {
				t.Fatalf("%s 不是 Sum: %T", name, m.Data)
			}
			for _, dp := range sum.DataPoints {
				pairs := make([]string, 0, len(dp.Attributes.ToSlice()))
				for _, kv := range dp.Attributes.ToSlice() {
					pairs = append(pairs, string(kv.Key)+"="+kv.Value.AsString())
				}
				sort.Strings(pairs)
				out[strings.Join(pairs, ",")+","] = dp.Value
			}
		}
	}
	return out
}

// attrKey 规范化属性键（排序后拼接，与 attribute.Set 的迭代序无关）
func attrKey(kvs ...string) string {
	pairs := make([]string, 0, len(kvs)/2)
	for i := 0; i+1 < len(kvs); i += 2 {
		pairs = append(pairs, kvs[i]+"="+kvs[i+1])
	}
	sort.Strings(pairs)
	return strings.Join(pairs, ",") + ","
}

func TestObserveLLMCall_CacheCounters(t *testing.T) {
	// 先设 provider，再触发懒加载绑定（inst 的 sync.Once 进程内仅一次）
	reader := metric.NewManualReader()
	mp := metric.NewMeterProvider(metric.WithReader(reader))
	otel.SetMeterProvider(mp)
	defer mp.Shutdown(context.Background())

	ObserveLLMCall("deepseek-chat", "synthesizer", "success", 1000, 200, 800, 200, 1.5)
	ObserveLLMCall("deepseek-chat", "router", "success", 300, 50, 0, 300, 0.2)

	var rm metricdata.ResourceMetrics
	if err := reader.Collect(context.Background(), &rm); err != nil {
		t.Fatalf("collect: %v", err)
	}

	cache := findSum(t, rm, "agent_llm_cache_tokens_total")
	if got := cache[attrKey("model", "deepseek-chat", "node", "synthesizer", "kind", "hit")]; got != 800 {
		t.Fatalf("synthesizer hit = %d, want 800", got)
	}
	if got := cache[attrKey("model", "deepseek-chat", "node", "synthesizer", "kind", "miss")]; got != 200 {
		t.Fatalf("synthesizer miss = %d, want 200", got)
	}
	if got := cache[attrKey("model", "deepseek-chat", "node", "router", "kind", "miss")]; got != 300 {
		t.Fatalf("router miss = %d, want 300", got)
	}
	if _, ok := cache[attrKey("model", "deepseek-chat", "node", "router", "kind", "hit")]; ok {
		t.Fatal("router 不应产生 hit 序列（cacheHit=0 时跳过）")
	}

	tokens := findSum(t, rm, "agent_llm_tokens_total")
	if got := tokens[attrKey("model", "deepseek-chat", "kind", "prompt")]; got != 1300 {
		t.Fatalf("prompt tokens = %d, want 1300", got)
	}
	if got := tokens[attrKey("model", "deepseek-chat", "kind", "completion")]; got != 250 {
		t.Fatalf("completion tokens = %d, want 250", got)
	}

	calls := findSum(t, rm, "agent_llm_calls_total")
	if got := calls[attrKey("model", "deepseek-chat", "status", "success")]; got != 2 {
		t.Fatalf("llm calls = %d, want 2", got)
	}
}
