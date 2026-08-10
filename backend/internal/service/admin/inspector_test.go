package admin

import (
	"context"
	"errors"
	"testing"
)

// fakeInspectorStore 实现 InspectorStore 的 5 个方法，字段可控；记录插入的告警。
type fakeInspectorStore struct {
	llmCalls  int32
	llmErrors int32
	llmErr    error

	traceUserMsgs int32
	traceTraces   int32
	traceErr      error

	tokenTotal int64
	tokenErr   error

	openKinds map[string]bool // 哪些 kind 视为已 open
	openErr   error

	insertErr error
	inserted  []Alert
}

func (f *fakeInspectorStore) LLMStatsLastHour(ctx context.Context) (int32, int32, error) {
	return f.llmCalls, f.llmErrors, f.llmErr
}
func (f *fakeInspectorStore) TraceGapLastHour(ctx context.Context) (int32, int32, error) {
	return f.traceUserMsgs, f.traceTraces, f.traceErr
}
func (f *fakeInspectorStore) TodayTokenTotal(ctx context.Context) (int64, error) {
	return f.tokenTotal, f.tokenErr
}
func (f *fakeInspectorStore) HasOpenAlert(ctx context.Context, kind string) (bool, error) {
	if f.openErr != nil {
		return false, f.openErr
	}
	return f.openKinds[kind], nil
}
func (f *fakeInspectorStore) InsertAlert(ctx context.Context, a *Alert) (int64, error) {
	if f.insertErr != nil {
		return 0, f.insertErr
	}
	f.inserted = append(f.inserted, *a)
	return int64(len(f.inserted)), nil
}

// newTestInspector 构造一个 Inspector，webhook 替换为捕获 fake，返回两者。
func newTestInspector(t *testing.T, store *fakeInspectorStore, budget int64) (*Inspector, *[]string) {
	t.Helper()
	i := NewInspector(store, budget, "https://example.invalid/hook")
	var sent []string
	i.webhook = func(url, markdown string) error {
		sent = append(sent, markdown)
		return nil
	}
	return i, &sent
}

func TestCheckLLMErrorRate_Fires(t *testing.T) {
	store := &fakeInspectorStore{llmCalls: 10, llmErrors: 3} // 30% > 20%, calls>5
	i, sent := newTestInspector(t, store, 1_000_000)
	i.checkLLMErrorRate(context.Background())

	if len(store.inserted) != 1 {
		t.Fatalf("expected 1 inserted alert, got %d", len(store.inserted))
	}
	a := store.inserted[0]
	if a.Kind != "llm_error_rate" || a.Severity != "critical" {
		t.Fatalf("unexpected alert kind/severity: %s/%s", a.Kind, a.Severity)
	}
	if a.Title != "LLM 错误率异常" {
		t.Fatalf("unexpected title: %s", a.Title)
	}
	if len(*sent) != 1 {
		t.Fatalf("expected 1 webhook call, got %d", len(*sent))
	}
}

func TestCheckLLMErrorRate_BelowMinCalls(t *testing.T) {
	store := &fakeInspectorStore{llmCalls: 3, llmErrors: 3} // 100% but calls<=5
	i, sent := newTestInspector(t, store, 1_000_000)
	i.checkLLMErrorRate(context.Background())
	if len(store.inserted) != 0 || len(*sent) != 0 {
		t.Fatalf("should not fire below min calls; inserted=%d webhook=%d", len(store.inserted), len(*sent))
	}
}

func TestCheckLLMErrorRate_LowRate(t *testing.T) {
	store := &fakeInspectorStore{llmCalls: 10, llmErrors: 1} // 10% <= 20%
	i, sent := newTestInspector(t, store, 1_000_000)
	i.checkLLMErrorRate(context.Background())
	if len(store.inserted) != 0 || len(*sent) != 0 {
		t.Fatalf("should not fire at low rate; inserted=%d webhook=%d", len(store.inserted), len(*sent))
	}
}

func TestCheckLLMErrorRate_StoreError(t *testing.T) {
	store := &fakeInspectorStore{llmErr: errors.New("db down")}
	i, sent := newTestInspector(t, store, 1_000_000)
	i.checkLLMErrorRate(context.Background()) // must not panic
	if len(store.inserted) != 0 || len(*sent) != 0 {
		t.Fatalf("store error should suppress fire; inserted=%d", len(store.inserted))
	}
}

func TestDedup_OpenAlertSuppressesFire(t *testing.T) {
	store := &fakeInspectorStore{
		llmCalls: 10, llmErrors: 3,
		openKinds: map[string]bool{"llm_error_rate": true},
	}
	i, sent := newTestInspector(t, store, 1_000_000)
	i.checkLLMErrorRate(context.Background())
	if len(store.inserted) != 0 || len(*sent) != 0 {
		t.Fatalf("open alert must dedup; inserted=%d webhook=%d", len(store.inserted), len(*sent))
	}
}

func TestCheckTraceMissing_Fires(t *testing.T) {
	store := &fakeInspectorStore{traceUserMsgs: 5, traceTraces: 0}
	i, sent := newTestInspector(t, store, 1_000_000)
	i.checkTraceMissing(context.Background())
	if len(store.inserted) != 1 {
		t.Fatalf("expected 1 inserted alert, got %d", len(store.inserted))
	}
	a := store.inserted[0]
	if a.Kind != "trace_missing" || a.Severity != "critical" {
		t.Fatalf("unexpected alert kind/severity: %s/%s", a.Kind, a.Severity)
	}
	if len(*sent) != 1 {
		t.Fatalf("expected 1 webhook call, got %d", len(*sent))
	}
}

func TestCheckTraceMissing_NoFireWhenTracesExist(t *testing.T) {
	store := &fakeInspectorStore{traceUserMsgs: 5, traceTraces: 2}
	i, sent := newTestInspector(t, store, 1_000_000)
	i.checkTraceMissing(context.Background())
	if len(store.inserted) != 0 || len(*sent) != 0 {
		t.Fatalf("should not fire when traces>0; inserted=%d", len(store.inserted))
	}
}

func TestCheckTraceMissing_NoFireWhenNoUserMsgs(t *testing.T) {
	store := &fakeInspectorStore{traceUserMsgs: 0, traceTraces: 0}
	i, _ := newTestInspector(t, store, 1_000_000)
	i.checkTraceMissing(context.Background())
	if len(store.inserted) != 0 {
		t.Fatalf("should not fire when no user msgs; inserted=%d", len(store.inserted))
	}
}

func TestCheckTokenBudget_Fires(t *testing.T) {
	store := &fakeInspectorStore{tokenTotal: 3_000_000}
	i, sent := newTestInspector(t, store, 2_000_000)
	i.checkTokenBudget(context.Background())
	if len(store.inserted) != 1 {
		t.Fatalf("expected 1 inserted alert, got %d", len(store.inserted))
	}
	a := store.inserted[0]
	if a.Kind != "token_budget" || a.Severity != "warn" {
		t.Fatalf("unexpected alert kind/severity: %s/%s", a.Kind, a.Severity)
	}
	if len(*sent) != 1 {
		t.Fatalf("expected 1 webhook call, got %d", len(*sent))
	}
}

func TestCheckTokenBudget_NoFireUnderBudget(t *testing.T) {
	store := &fakeInspectorStore{tokenTotal: 1_000_000}
	i, sent := newTestInspector(t, store, 2_000_000)
	i.checkTokenBudget(context.Background())
	if len(store.inserted) != 0 || len(*sent) != 0 {
		t.Fatalf("should not fire under budget; inserted=%d", len(store.inserted))
	}
}

func TestRunOnce_RunsAllThreeChecks(t *testing.T) {
	// 三项全部命中：error rate + trace missing + token budget
	store := &fakeInspectorStore{
		llmCalls: 10, llmErrors: 3,
		traceUserMsgs: 5, traceTraces: 0,
		tokenTotal: 3_000_000,
	}
	i, sent := newTestInspector(t, store, 2_000_000)
	i.RunOnce(context.Background())
	if len(store.inserted) != 3 {
		t.Fatalf("expected 3 inserted alerts, got %d", len(store.inserted))
	}
	if len(*sent) != 3 {
		t.Fatalf("expected 3 webhook calls, got %d", len(*sent))
	}
}

func TestRunOnce_ContinuesWhenOneCheckErrors(t *testing.T) {
	// LLM 查询失败，但 trace + token 检查仍应执行并命中。
	store := &fakeInspectorStore{
		llmErr:         errors.New("llm stats down"),
		traceUserMsgs:  5, traceTraces: 0,
		tokenTotal: 3_000_000,
	}
	i, sent := newTestInspector(t, store, 2_000_000)
	i.RunOnce(context.Background())
	if len(store.inserted) != 2 {
		t.Fatalf("expected 2 inserted alerts (trace+token) despite llm error; got %d", len(store.inserted))
	}
	// 校验命中的 kind
	kinds := map[string]bool{}
	for _, a := range store.inserted {
		kinds[a.Kind] = true
	}
	if !kinds["trace_missing"] || !kinds["token_budget"] {
		t.Fatalf("expected trace_missing + token_budget; got %v", kinds)
	}
	if len(*sent) != 2 {
		t.Fatalf("expected 2 webhook calls; got %d", len(*sent))
	}
}

func TestNotify_NoWebhookURLSkips(t *testing.T) {
	store := &fakeInspectorStore{llmCalls: 10, llmErrors: 3}
	i := NewInspector(store, 1_000_000, "") // 空 webhookURL
	called := false
	i.webhook = func(url, markdown string) error {
		called = true
		return nil
	}
	i.checkLLMErrorRate(context.Background())
	if called {
		t.Fatal("webhook must not be called when webhookURL is empty")
	}
	if len(store.inserted) != 1 {
		t.Fatalf("alert should still be inserted even without webhook; got %d", len(store.inserted))
	}
}

func TestDefaultWebhook_RejectsNon2xx(t *testing.T) {
	// 指向一个不存在的地址，应返回 error（连接失败或 DNS）。
	err := defaultWebhook("http://127.0.0.1:1/not-found", "## hi")
	if err == nil {
		t.Fatal("expected error from defaultWebhook against unreachable endpoint")
	}
}
