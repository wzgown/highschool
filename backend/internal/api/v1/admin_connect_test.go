package v1

import (
	"context"
	"errors"
	"fmt"
	"testing"

	"connectrpc.com/connect"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/service/admin"
)

// fakeAdminStore 内存实现 admin.Store
type fakeAdminStore struct {
	sessions []admin.SessionRow
	replay   *admin.ReplayBundle
	cost     *admin.CostDashboard
	alerts   []admin.Alert
	err      error
}

func (f *fakeAdminStore) ListAgentSessions(ctx context.Context, fl admin.ListFilter) ([]admin.SessionRow, int32, error) {
	if f.err != nil {
		return nil, 0, f.err
	}
	return f.sessions, int32(len(f.sessions)), nil
}
func (f *fakeAdminStore) GetSessionReplay(ctx context.Context, id int64) (*admin.ReplayBundle, error) {
	if f.err != nil {
		return nil, f.err
	}
	return f.replay, nil
}
func (f *fakeAdminStore) GetCostDashboard(ctx context.Context, from, to string) (*admin.CostDashboard, error) {
	if f.err != nil {
		return nil, f.err
	}
	return f.cost, nil
}
func (f *fakeAdminStore) ListAlerts(ctx context.Context, fl admin.AlertFilter) ([]admin.Alert, int32, error) {
	if f.err != nil {
		return nil, 0, f.err
	}
	return f.alerts, int32(len(f.alerts)), nil
}
func (f *fakeAdminStore) AckAlert(ctx context.Context, id int64) error {
	if f.err != nil {
		return f.err
	}
	return nil
}
func (f *fakeAdminStore) InsertAlert(ctx context.Context, a *admin.Alert) (int64, error) {
	if f.err != nil {
		return 0, f.err
	}
	return 0, nil
}
func (f *fakeAdminStore) HasOpenAlert(ctx context.Context, kind string) (bool, error) {
	if f.err != nil {
		return false, f.err
	}
	return false, nil
}
func (f *fakeAdminStore) LLMStatsLastHour(ctx context.Context) (int32, int32, error) {
	if f.err != nil {
		return 0, 0, f.err
	}
	return 0, 0, nil
}
func (f *fakeAdminStore) TraceGapLastHour(ctx context.Context) (int32, int32, error) {
	if f.err != nil {
		return 0, 0, f.err
	}
	return 0, 0, nil
}
func (f *fakeAdminStore) TodayTokenTotal(ctx context.Context) (int64, error) {
	if f.err != nil {
		return 0, f.err
	}
	return 0, nil
}

// TestAdminHandler_ListAgentSessions 通过真实 Connect 方法验证 SessionRow→proto 字段映射（CamelCase 回归守卫）。
func TestAdminHandler_ListAgentSessions(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{
		sessions: []admin.SessionRow{{
			SessionID: 7, DeviceID: "dev", Status: "running", Intent: "data_query",
			CreatedAt: "2026-08-10", LastActiveAt: "2026-08-10", MessageCount: 3, TotalTokens: 1500,
		}},
	})
	resp, err := h.ListAgentSessions(context.Background(), connect.NewRequest(&highschoolv1.ListAgentSessionsRequest{Page: 1, PageSize: 10}))
	if err != nil {
		t.Fatalf("ListAgentSessions: %v", err)
	}
	if resp.Msg.Total != 1 {
		t.Fatalf("Total = %d, want 1", resp.Msg.Total)
	}
	if len(resp.Msg.Items) != 1 {
		t.Fatalf("Items len = %d, want 1", len(resp.Msg.Items))
	}
	got := resp.Msg.Items[0]
	if got.SessionId != 7 {
		t.Errorf("SessionId = %d, want 7", got.SessionId)
	}
	if got.DeviceId != "dev" {
		t.Errorf("DeviceId = %q, want %q", got.DeviceId, "dev")
	}
	if got.Status != "running" {
		t.Errorf("Status = %q, want %q", got.Status, "running")
	}
	if got.Intent != "data_query" {
		t.Errorf("Intent = %q, want %q", got.Intent, "data_query")
	}
	if got.MessageCount != 3 {
		t.Errorf("MessageCount = %d, want 3", got.MessageCount)
	}
	if got.TotalTokens != 1500 {
		t.Errorf("TotalTokens = %d, want 1500", got.TotalTokens)
	}
}

// TestAdminHandler_GetSessionReplay 通过真实 Connect 方法验证 ReplayBundle→proto 字段映射。
func TestAdminHandler_GetSessionReplay(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{
		replay: &admin.ReplayBundle{
			Session:     admin.ReplaySession{SessionID: 42, DeviceID: "dev", Status: "done", Intent: "data_query", CreatedAt: "2026-08-10"},
			Messages:    []admin.ReplayMessage{{Role: "user", Content: "hi", Node: "entry", CreatedAt: "2026-08-10", UsageJSON: `{"x":1}`}},
			Traces:      []admin.ReplayTrace{{Kind: "llm", Name: "plan", InputJSON: `{"in":1}`, OutputJSON: `{"out":1}`, PromptTokens: 10, CompletionTokens: 20, LatencyMs: 350, CreatedAt: "2026-08-10"}},
			Checkpoints: []admin.ReplayCheckpoint{{StepSeq: 1, Node: "entry", StateJSON: `{"s":1}`, CreatedAt: "2026-08-10"}},
		},
	})
	resp, err := h.GetSessionReplay(context.Background(), connect.NewRequest(&highschoolv1.GetSessionReplayRequest{SessionId: 42}))
	if err != nil {
		t.Fatalf("GetSessionReplay: %v", err)
	}
	if resp.Msg.Session == nil {
		t.Fatal("Session is nil")
	}
	if resp.Msg.Session.SessionId != 42 {
		t.Errorf("Session.SessionId = %d, want 42", resp.Msg.Session.SessionId)
	}
	if len(resp.Msg.Messages) != 1 {
		t.Fatalf("Messages len = %d, want 1", len(resp.Msg.Messages))
	}
	if resp.Msg.Messages[0].Role != "user" {
		t.Errorf("Messages[0].Role = %q, want %q", resp.Msg.Messages[0].Role, "user")
	}
	if resp.Msg.Messages[0].UsageJson != `{"x":1}` {
		t.Errorf("Messages[0].UsageJson = %q, want {\"x\":1}", resp.Msg.Messages[0].UsageJson)
	}
	if len(resp.Msg.Traces) != 1 {
		t.Fatalf("Traces len = %d, want 1", len(resp.Msg.Traces))
	}
	tr := resp.Msg.Traces[0]
	if tr.Kind != "llm" {
		t.Errorf("Traces[0].Kind = %q, want %q", tr.Kind, "llm")
	}
	if tr.LatencyMs != 350 {
		t.Errorf("Traces[0].LatencyMs = %d, want 350", tr.LatencyMs)
	}
	if len(resp.Msg.Checkpoints) != 1 {
		t.Fatalf("Checkpoints len = %d, want 1", len(resp.Msg.Checkpoints))
	}
	if resp.Msg.Checkpoints[0].StepSeq != 1 {
		t.Errorf("Checkpoints[0].StepSeq = %d, want 1", resp.Msg.Checkpoints[0].StepSeq)
	}
}

// TestAdminHandler_GetSessionReplay_NilBundle 验证 store 返回 nil bundle 时返回 CodeNotFound 而非 panic。
func TestAdminHandler_GetSessionReplay_NilBundle(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{replay: nil})
	_, err := h.GetSessionReplay(context.Background(), connect.NewRequest(&highschoolv1.GetSessionReplayRequest{SessionId: 99}))
	if err == nil {
		t.Fatal("expected CodeNotFound error, got nil")
	}
	if connect.CodeOf(err) != connect.CodeNotFound {
		t.Fatalf("CodeOf(err) = %v, want CodeNotFound", connect.CodeOf(err))
	}
}

// TestAdminHandler_GetSessionReplay_NotFound 验证 store 返回 admin.ErrNotFound
// （含被 wrap 的情形，如 repo 的 pgx.ErrNoRows 分支）时映射为 CodeNotFound 而非 CodeInternal。
func TestAdminHandler_GetSessionReplay_NotFound(t *testing.T) {
	// 直接返回哨兵
	h := NewAdminServiceHandler(&fakeAdminStore{err: admin.ErrNotFound})
	_, err := h.GetSessionReplay(context.Background(), connect.NewRequest(&highschoolv1.GetSessionReplayRequest{SessionId: 1234}))
	if err == nil {
		t.Fatal("expected CodeNotFound error, got nil")
	}
	if connect.CodeOf(err) != connect.CodeNotFound {
		t.Fatalf("direct sentinel: CodeOf(err) = %v, want CodeNotFound", connect.CodeOf(err))
	}

	// 被 fmt.Errorf wrap 的情形（与 admin_repository 的 ErrNoRows 分支一致）
	wrapped := fmt.Errorf("admin replay: session %d not found: %w", 1234, admin.ErrNotFound)
	h2 := NewAdminServiceHandler(&fakeAdminStore{err: wrapped})
	_, err2 := h2.GetSessionReplay(context.Background(), connect.NewRequest(&highschoolv1.GetSessionReplayRequest{SessionId: 1234}))
	if err2 == nil {
		t.Fatal("expected CodeNotFound error, got nil")
	}
	if connect.CodeOf(err2) != connect.CodeNotFound {
		t.Fatalf("wrapped sentinel: CodeOf(err) = %v, want CodeNotFound", connect.CodeOf(err2))
	}
}

// TestAdminHandler_StoreError 验证 store 错误经真实 Connect 方法映射为 CodeInternal。
func TestAdminHandler_StoreError(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{err: errors.New("db down")})
	_, err := h.ListAgentSessions(context.Background(), connect.NewRequest(&highschoolv1.ListAgentSessionsRequest{Page: 1}))
	if err == nil {
		t.Fatal("store error must propagate")
	}
	if connect.CodeOf(err) != connect.CodeInternal {
		t.Fatalf("CodeOf(err) = %v, want CodeInternal", connect.CodeOf(err))
	}
}

// TestAdminHandler_GetCostDashboard 通过真实 Connect 方法验证 CostDashboard→proto 字段映射
// （CamelCase 回归守卫：total_tokens→TotalTokens、p95_latency_ms→P95LatencyMs、
// tool_name→ToolName、active_sessions→ActiveSessions 等）。
func TestAdminHandler_GetCostDashboard(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{
		cost: &admin.CostDashboard{
			LlmDaily: []admin.CostLlmDaily{{
				Day: "2026-08-10", LlmCalls: 12, PromptTokens: 100, CompletionTokens: 200,
				TotalTokens: 300, AvgLatencyMs: 450, P95LatencyMs: 900, ErrorCount: 1,
			}},
			ToolDaily: []admin.CostToolDaily{{
				Day: "2026-08-10", ToolName: "search_school", Calls: 5, Failures: 1, AvgLatencyMs: 120,
			}},
			SessionDaily: []admin.CostSessionDaily{{
				Day: "2026-08-10", ActiveSessions: 3, Messages: 20, UserMessages: 8, AssistantMessages: 12,
			}},
		},
	})
	resp, err := h.GetCostDashboard(context.Background(), connect.NewRequest(&highschoolv1.GetCostDashboardRequest{From: "2026-08-10", To: "2026-08-10"}))
	if err != nil {
		t.Fatalf("GetCostDashboard: %v", err)
	}
	// LLM daily
	if len(resp.Msg.LlmDaily) != 1 {
		t.Fatalf("LlmDaily len = %d, want 1", len(resp.Msg.LlmDaily))
	}
	l := resp.Msg.LlmDaily[0]
	if l.Day != "2026-08-10" {
		t.Errorf("LlmDaily[0].Day = %q, want 2026-08-10", l.Day)
	}
	if l.LlmCalls != 12 {
		t.Errorf("LlmDaily[0].LlmCalls = %d, want 12", l.LlmCalls)
	}
	if l.PromptTokens != 100 {
		t.Errorf("LlmDaily[0].PromptTokens = %d, want 100", l.PromptTokens)
	}
	if l.CompletionTokens != 200 {
		t.Errorf("LlmDaily[0].CompletionTokens = %d, want 200", l.CompletionTokens)
	}
	if l.TotalTokens != 300 {
		t.Errorf("LlmDaily[0].TotalTokens = %d, want 300", l.TotalTokens)
	}
	if l.AvgLatencyMs != 450 {
		t.Errorf("LlmDaily[0].AvgLatencyMs = %d, want 450", l.AvgLatencyMs)
	}
	if l.P95LatencyMs != 900 {
		t.Errorf("LlmDaily[0].P95LatencyMs = %d, want 900", l.P95LatencyMs)
	}
	if l.ErrorCount != 1 {
		t.Errorf("LlmDaily[0].ErrorCount = %d, want 1", l.ErrorCount)
	}
	// Tool daily
	if len(resp.Msg.ToolDaily) != 1 {
		t.Fatalf("ToolDaily len = %d, want 1", len(resp.Msg.ToolDaily))
	}
	tw := resp.Msg.ToolDaily[0]
	if tw.ToolName != "search_school" {
		t.Errorf("ToolDaily[0].ToolName = %q, want search_school", tw.ToolName)
	}
	if tw.Calls != 5 {
		t.Errorf("ToolDaily[0].Calls = %d, want 5", tw.Calls)
	}
	if tw.Failures != 1 {
		t.Errorf("ToolDaily[0].Failures = %d, want 1", tw.Failures)
	}
	if tw.AvgLatencyMs != 120 {
		t.Errorf("ToolDaily[0].AvgLatencyMs = %d, want 120", tw.AvgLatencyMs)
	}
	// Session daily
	if len(resp.Msg.SessionDaily) != 1 {
		t.Fatalf("SessionDaily len = %d, want 1", len(resp.Msg.SessionDaily))
	}
	s := resp.Msg.SessionDaily[0]
	if s.ActiveSessions != 3 {
		t.Errorf("SessionDaily[0].ActiveSessions = %d, want 3", s.ActiveSessions)
	}
	if s.Messages != 20 {
		t.Errorf("SessionDaily[0].Messages = %d, want 20", s.Messages)
	}
	if s.UserMessages != 8 {
		t.Errorf("SessionDaily[0].UserMessages = %d, want 8", s.UserMessages)
	}
	if s.AssistantMessages != 12 {
		t.Errorf("SessionDaily[0].AssistantMessages = %d, want 12", s.AssistantMessages)
	}
}

// TestAdminHandler_GetCostDashboard_Empty 验证 store 返回空 Dashboard 时三个切片均为非 nil 空切片。
func TestAdminHandler_GetCostDashboard_Empty(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{cost: &admin.CostDashboard{}})
	resp, err := h.GetCostDashboard(context.Background(), connect.NewRequest(&highschoolv1.GetCostDashboardRequest{}))
	if err != nil {
		t.Fatalf("GetCostDashboard: %v", err)
	}
	if resp.Msg.LlmDaily == nil {
		t.Error("LlmDaily is nil, want non-nil empty slice")
	}
	if resp.Msg.ToolDaily == nil {
		t.Error("ToolDaily is nil, want non-nil empty slice")
	}
	if resp.Msg.SessionDaily == nil {
		t.Error("SessionDaily is nil, want non-nil empty slice")
	}
}

// TestAdminHandler_GetCostDashboard_Error 验证 store 错误经真实 Connect 方法映射为 CodeInternal。
func TestAdminHandler_GetCostDashboard_Error(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{err: errors.New("db down")})
	_, err := h.GetCostDashboard(context.Background(), connect.NewRequest(&highschoolv1.GetCostDashboardRequest{}))
	if err == nil {
		t.Fatal("store error must propagate")
	}
	if connect.CodeOf(err) != connect.CodeInternal {
		t.Fatalf("CodeOf(err) = %v, want CodeInternal", connect.CodeOf(err))
	}
}

// TestAdminHandler_ListAlerts 通过真实 Connect 方法验证 Alert→proto 字段映射（CamelCase 回归守卫：
// detail_json→DetailJson、acked_at→AckedAt、created_at→CreatedAt）以及分页字段。
func TestAdminHandler_ListAlerts(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{
		alerts: []admin.Alert{{
			ID: 101, CreatedAt: "2026-08-10T10:00:00", Kind: "llm_error_rate",
			Severity: "warn", Title: "LLM 错误率过高", DetailJSON: `{"rate":0.5}`,
			Status: "open", AckedAt: "",
		}},
	})
	resp, err := h.ListAlerts(context.Background(), connect.NewRequest(&highschoolv1.ListAlertsRequest{
		Status: "open", Page: 1, PageSize: 10,
	}))
	if err != nil {
		t.Fatalf("ListAlerts: %v", err)
	}
	if resp.Msg.Total != 1 {
		t.Fatalf("Total = %d, want 1", resp.Msg.Total)
	}
	if len(resp.Msg.Items) != 1 {
		t.Fatalf("Items len = %d, want 1", len(resp.Msg.Items))
	}
	got := resp.Msg.Items[0]
	if got.Id != 101 {
		t.Errorf("Id = %d, want 101", got.Id)
	}
	if got.CreatedAt != "2026-08-10T10:00:00" {
		t.Errorf("CreatedAt = %q, want 2026-08-10T10:00:00", got.CreatedAt)
	}
	if got.Kind != "llm_error_rate" {
		t.Errorf("Kind = %q, want llm_error_rate", got.Kind)
	}
	if got.Severity != "warn" {
		t.Errorf("Severity = %q, want warn", got.Severity)
	}
	if got.Title != "LLM 错误率过高" {
		t.Errorf("Title = %q, want LLM 错误率过高", got.Title)
	}
	if got.DetailJson != `{"rate":0.5}` {
		t.Errorf("DetailJson = %q, want {\"rate\":0.5}", got.DetailJson)
	}
	if got.Status != "open" {
		t.Errorf("Status = %q, want open", got.Status)
	}
	if got.AckedAt != "" {
		t.Errorf("AckedAt = %q, want empty", got.AckedAt)
	}
}

// TestAdminHandler_AcknowledgeAlert_NotFound 验证 store 返回 admin.ErrNotFound
// （含被 wrap 的情形）时映射为 CodeNotFound 而非 CodeInternal。
func TestAdminHandler_AcknowledgeAlert_NotFound(t *testing.T) {
	// 直接返回哨兵
	h := NewAdminServiceHandler(&fakeAdminStore{err: admin.ErrNotFound})
	_, err := h.AcknowledgeAlert(context.Background(), connect.NewRequest(&highschoolv1.AcknowledgeAlertRequest{Id: 9999}))
	if err == nil {
		t.Fatal("expected CodeNotFound error, got nil")
	}
	if connect.CodeOf(err) != connect.CodeNotFound {
		t.Fatalf("direct sentinel: CodeOf(err) = %v, want CodeNotFound", connect.CodeOf(err))
	}

	// 被 fmt.Errorf wrap 的情形（与 admin_repository.AckAlert 的 RowsAffected()==0 分支一致）
	wrapped := fmt.Errorf("admin ack alert: id %d not found: %w", 9999, admin.ErrNotFound)
	h2 := NewAdminServiceHandler(&fakeAdminStore{err: wrapped})
	_, err2 := h2.AcknowledgeAlert(context.Background(), connect.NewRequest(&highschoolv1.AcknowledgeAlertRequest{Id: 9999}))
	if err2 == nil {
		t.Fatal("expected CodeNotFound error, got nil")
	}
	if connect.CodeOf(err2) != connect.CodeNotFound {
		t.Fatalf("wrapped sentinel: CodeOf(err) = %v, want CodeNotFound", connect.CodeOf(err2))
	}
}
