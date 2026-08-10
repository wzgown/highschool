package v1

import (
	"context"
	"errors"
	"testing"

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

func TestAdminHandler_ListSessions(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{
		sessions: []admin.SessionRow{{SessionID: 7, DeviceID: "dev", Intent: "data_query"}},
	})
	out, total, err := h.listSessions(context.Background(), admin.ListFilter{Page: 1, PageSize: 10})
	if err != nil {
		t.Fatalf("listSessions: %v", err)
	}
	if total != 1 || out[0].SessionID != 7 {
		t.Fatalf("unexpected: %v total=%d", out, total)
	}
}

func TestAdminHandler_StoreError(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{err: errors.New("db down")})
	if _, _, err := h.listSessions(context.Background(), admin.ListFilter{Page: 1}); err == nil {
		t.Fatal("store error must propagate")
	}
}
