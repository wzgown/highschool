package repository

import (
	"context"
	"testing"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/service/admin"
)

// 集成测试：需要可达的 Postgres（database.GetDB 初始化过）。
// 无 DB 时跳过，不阻断 CI。
func TestAdminRepository_Smoke(t *testing.T) {
	if database.GetDB() == nil {
		t.Skip("database not initialized; skipping admin repository integration test")
	}
	r := NewAdminRepository()
	ctx := context.Background()

	// 列表：取第 1 页（库可能为空，只验不报错）
	rows, total, err := r.ListAgentSessions(ctx, admin.ListFilter{Page: 1, PageSize: 5})
	if err != nil {
		t.Fatalf("ListAgentSessions: %v", err)
	}
	_ = total

	// 若有会话，回放第一条
	if len(rows) > 0 {
		b, err := r.GetSessionReplay(ctx, rows[0].SessionID)
		if err != nil {
			t.Fatalf("GetSessionReplay: %v", err)
		}
		if b.Session.SessionID != rows[0].SessionID {
			t.Fatalf("session mismatch")
		}
	}
}
