// admin_repository.go 管理后台只读仓储（回放/审计查询）
package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/service/admin"
)

// AdminRepository admin.Store 的 pgx 实现
type AdminRepository struct {
	db *pgxpool.Pool
}

// NewAdminRepository 创建管理后台仓储
func NewAdminRepository() *AdminRepository {
	return &AdminRepository{db: database.GetDB()}
}

var _ admin.Store = (*AdminRepository)(nil)

// ListAgentSessions 分页列出会话（含消息数、累计 LLM token）
func (r *AdminRepository) ListAgentSessions(ctx context.Context, f admin.ListFilter) ([]admin.SessionRow, int32, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.PageSize < 1 || f.PageSize > 100 {
		f.PageSize = 20
	}
	offset := (f.Page - 1) * f.PageSize

	const q = `
		SELECT s.id, s.device_id, s.status, COALESCE(s.intent,''),
		       s.created_at::text, s.last_active_at::text,
		       (SELECT COUNT(*) FROM agent_message m WHERE m.session_id = s.id),
		       COALESCE((SELECT SUM(COALESCE(prompt_tokens,0)+COALESCE(completion_tokens,0))
		                 FROM agent_trace t WHERE t.session_id = s.id AND t.kind='llm'), 0)
		FROM agent_session s
		WHERE ($1 = '' OR s.created_at >= $1::timestamp)
		  AND ($2 = '' OR s.created_at <= $2::timestamp)
		  AND ($3 = '' OR s.device_id = $3)
		  AND ($4 = '' OR s.intent = $4)
		ORDER BY s.created_at DESC
		LIMIT $5 OFFSET $6`
	rows, err := r.db.Query(ctx, q, f.TimeFrom, f.TimeTo, f.DeviceID, f.Intent, f.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("admin list sessions: %w", err)
	}
	defer rows.Close()

	out := make([]admin.SessionRow, 0, f.PageSize)
	for rows.Next() {
		var r2 admin.SessionRow
		if err := rows.Scan(&r2.SessionID, &r2.DeviceID, &r2.Status, &r2.Intent,
			&r2.CreatedAt, &r2.LastActiveAt, &r2.MessageCount, &r2.TotalTokens); err != nil {
			return nil, 0, fmt.Errorf("admin list sessions scan: %w", err)
		}
		out = append(out, r2)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("admin list sessions rows: %w", err)
	}

	var total int32
	const cq = `SELECT COUNT(*) FROM agent_session s
		WHERE ($1='' OR s.created_at >= $1::timestamp)
		  AND ($2='' OR s.created_at <= $2::timestamp)
		  AND ($3='' OR s.device_id = $3)
		  AND ($4='' OR s.intent = $4)`
	if err := r.db.QueryRow(ctx, cq, f.TimeFrom, f.TimeTo, f.DeviceID, f.Intent).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("admin count sessions: %w", err)
	}
	return out, total, nil
}

// GetSessionReplay 取单会话回放全量数据（消息/trace/checkpoint 按时间）
func (r *AdminRepository) GetSessionReplay(ctx context.Context, sessionID int64) (*admin.ReplayBundle, error) {
	b := &admin.ReplayBundle{}

	// 1) 会话元信息
	const sq = `SELECT id, device_id, status, COALESCE(intent,''), created_at::text
	            FROM agent_session WHERE id = $1`
	if err := r.db.QueryRow(ctx, sq, sessionID).Scan(
		&b.Session.SessionID, &b.Session.DeviceID, &b.Session.Status,
		&b.Session.Intent, &b.Session.CreatedAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("admin replay: session %d not found", sessionID)
		}
		return nil, fmt.Errorf("admin replay session: %w", err)
	}

	// 2) 消息
	mrows, err := r.db.Query(ctx, `
		SELECT role, content, COALESCE(node,''), created_at::text, COALESCE(usage::text,'')
		FROM agent_message WHERE session_id = $1 ORDER BY id`, sessionID)
	if err != nil {
		return nil, fmt.Errorf("admin replay messages: %w", err)
	}
	defer mrows.Close()
	for mrows.Next() {
		var m admin.ReplayMessage
		if err := mrows.Scan(&m.Role, &m.Content, &m.Node, &m.CreatedAt, &m.UsageJSON); err != nil {
			return nil, fmt.Errorf("admin replay messages scan: %w", err)
		}
		b.Messages = append(b.Messages, m)
	}
	if err := mrows.Err(); err != nil {
		return nil, fmt.Errorf("admin replay messages: %w", err)
	}

	// 3) trace
	trows, err := r.db.Query(ctx, `
		SELECT kind, COALESCE(name,''), COALESCE(input::text,''), COALESCE(output::text,''),
		       COALESCE(prompt_tokens,0), COALESCE(completion_tokens,0), COALESCE(latency_ms,0), created_at::text
		FROM agent_trace WHERE session_id = $1 ORDER BY id`, sessionID)
	if err != nil {
		return nil, fmt.Errorf("admin replay traces: %w", err)
	}
	defer trows.Close()
	for trows.Next() {
		var t admin.ReplayTrace
		if err := trows.Scan(&t.Kind, &t.Name, &t.InputJSON, &t.OutputJSON,
			&t.PromptTokens, &t.CompletionTokens, &t.LatencyMs, &t.CreatedAt); err != nil {
			return nil, fmt.Errorf("admin replay traces scan: %w", err)
		}
		b.Traces = append(b.Traces, t)
	}
	if err := trows.Err(); err != nil {
		return nil, fmt.Errorf("admin replay traces: %w", err)
	}

	// 4) checkpoint
	crows, err := r.db.Query(ctx, `
		SELECT step_seq, node, COALESCE(state::text,''), created_at::text
		FROM agent_checkpoint WHERE session_id = $1 ORDER BY step_seq`, sessionID)
	if err != nil {
		return nil, fmt.Errorf("admin replay checkpoints: %w", err)
	}
	defer crows.Close()
	for crows.Next() {
		var c admin.ReplayCheckpoint
		if err := crows.Scan(&c.StepSeq, &c.Node, &c.StateJSON, &c.CreatedAt); err != nil {
			return nil, fmt.Errorf("admin replay checkpoints scan: %w", err)
		}
		b.Checkpoints = append(b.Checkpoints, c)
	}
	if err := crows.Err(); err != nil {
		return nil, fmt.Errorf("admin replay checkpoints: %w", err)
	}
	return b, nil
}
