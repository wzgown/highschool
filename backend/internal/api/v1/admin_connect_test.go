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
			Session: admin.ReplaySession{SessionID: 42, DeviceID: "dev", Status: "done", Intent: "data_query", CreatedAt: "2026-08-10"},
			Messages: []admin.ReplayMessage{{Role: "user", Content: "hi", Node: "entry", CreatedAt: "2026-08-10", UsageJSON: `{"x":1}`}},
			Traces:   []admin.ReplayTrace{{Kind: "llm", Name: "plan", InputJSON: `{"in":1}`, OutputJSON: `{"out":1}`, PromptTokens: 10, CompletionTokens: 20, LatencyMs: 350, CreatedAt: "2026-08-10"}},
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
