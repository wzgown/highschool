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
			return nil, fmt.Errorf("admin replay: session %d not found: %w", sessionID, admin.ErrNotFound)
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

// GetCostDashboard 读取三张可观测性视图（v_agent_llm_daily / v_agent_tool_daily /
// v_agent_session_daily，定义见 db/migrations/012_agent_observability_views.sql）。
// from/to 为 'YYYY-MM-DD' 含端点；空串表示不限制对应边界。
// 视图列已在迁移中 COALESCE，此处无需再兜底。
func (r *AdminRepository) GetCostDashboard(ctx context.Context, from, to string) (*admin.CostDashboard, error) {
	d := &admin.CostDashboard{}

	// 1) v_agent_llm_daily
	lrows, err := r.db.Query(ctx, `
		SELECT day::text, llm_calls, prompt_tokens, completion_tokens, total_tokens,
		       avg_latency_ms, p95_latency_ms, error_count
		FROM v_agent_llm_daily
		WHERE ($1 = '' OR day >= $1::date) AND ($2 = '' OR day <= $2::date)
		ORDER BY day`, from, to)
	if err != nil {
		return nil, fmt.Errorf("admin cost llm daily: %w", err)
	}
	defer lrows.Close()
	for lrows.Next() {
		var v admin.CostLlmDaily
		if err := lrows.Scan(&v.Day, &v.LlmCalls, &v.PromptTokens, &v.CompletionTokens,
			&v.TotalTokens, &v.AvgLatencyMs, &v.P95LatencyMs, &v.ErrorCount); err != nil {
			return nil, fmt.Errorf("admin cost llm daily scan: %w", err)
		}
		d.LlmDaily = append(d.LlmDaily, v)
	}
	if err := lrows.Err(); err != nil {
		return nil, fmt.Errorf("admin cost llm daily: %w", err)
	}

	// 2) v_agent_tool_daily
	trows, err := r.db.Query(ctx, `
		SELECT day::text, tool_name, calls, failures, avg_latency_ms
		FROM v_agent_tool_daily
		WHERE ($1 = '' OR day >= $1::date) AND ($2 = '' OR day <= $2::date)
		ORDER BY day, calls DESC`, from, to)
	if err != nil {
		return nil, fmt.Errorf("admin cost tool daily: %w", err)
	}
	defer trows.Close()
	for trows.Next() {
		var v admin.CostToolDaily
		if err := trows.Scan(&v.Day, &v.ToolName, &v.Calls, &v.Failures, &v.AvgLatencyMs); err != nil {
			return nil, fmt.Errorf("admin cost tool daily scan: %w", err)
		}
		d.ToolDaily = append(d.ToolDaily, v)
	}
	if err := trows.Err(); err != nil {
		return nil, fmt.Errorf("admin cost tool daily: %w", err)
	}

	// 3) v_agent_session_daily
	srows, err := r.db.Query(ctx, `
		SELECT day::text, active_sessions, messages, user_messages, assistant_messages
		FROM v_agent_session_daily
		WHERE ($1 = '' OR day >= $1::date) AND ($2 = '' OR day <= $2::date)
		ORDER BY day`, from, to)
	if err != nil {
		return nil, fmt.Errorf("admin cost session daily: %w", err)
	}
	defer srows.Close()
	for srows.Next() {
		var v admin.CostSessionDaily
		if err := srows.Scan(&v.Day, &v.ActiveSessions, &v.Messages, &v.UserMessages, &v.AssistantMessages); err != nil {
			return nil, fmt.Errorf("admin cost session daily scan: %w", err)
		}
		d.SessionDaily = append(d.SessionDaily, v)
	}
	if err := srows.Err(); err != nil {
		return nil, fmt.Errorf("admin cost session daily: %w", err)
	}
	return d, nil
}

// ListAlerts 分页列出告警（按 created_at 倒序）。status 为空时不过滤状态。
func (r *AdminRepository) ListAlerts(ctx context.Context, f admin.AlertFilter) ([]admin.Alert, int32, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.PageSize < 1 || f.PageSize > 100 {
		f.PageSize = 20
	}
	offset := (f.Page - 1) * f.PageSize

	const q = `
		SELECT id, created_at::text, kind, severity, title,
		       COALESCE(detail::text,'{}'), status, COALESCE(acked_at::text,'')
		FROM agent_alert
		WHERE ($1 = '' OR status = $1)
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3`
	rows, err := r.db.Query(ctx, q, f.Status, f.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("admin list alerts: %w", err)
	}
	defer rows.Close()

	out := make([]admin.Alert, 0, f.PageSize)
	for rows.Next() {
		var a admin.Alert
		if err := rows.Scan(&a.ID, &a.CreatedAt, &a.Kind, &a.Severity, &a.Title,
			&a.DetailJSON, &a.Status, &a.AckedAt); err != nil {
			return nil, 0, fmt.Errorf("admin list alerts scan: %w", err)
		}
		out = append(out, a)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, fmt.Errorf("admin list alerts rows: %w", err)
	}

	var total int32
	const cq = `SELECT COUNT(*) FROM agent_alert WHERE ($1 = '' OR status = $1)`
	if err := r.db.QueryRow(ctx, cq, f.Status).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("admin count alerts: %w", err)
	}
	return out, total, nil
}

// AckAlert 将告警置为已确认（status='acked', acked_at=now）。
// 未命中时返回 admin.ErrNotFound（handler 据此映射 CodeNotFound）。
func (r *AdminRepository) AckAlert(ctx context.Context, id int64) error {
	ct, err := r.db.Exec(ctx, `UPDATE agent_alert SET status='acked', acked_at=now() WHERE id=$1`, id)
	if err != nil {
		return fmt.Errorf("admin ack alert: %w", err)
	}
	if ct.RowsAffected() == 0 {
		return fmt.Errorf("admin ack alert: id %d not found: %w", id, admin.ErrNotFound)
	}
	return nil
}

// InsertAlert 写入一条告警；返回新 id。detail 字段为 jsonb，pgx 以 text 下发，
// 经 $1::jsonb 显式转换写入（无效 JSON 会在此报错，由调用方保证 DetailJSON 合法）。
func (r *AdminRepository) InsertAlert(ctx context.Context, a *admin.Alert) (int64, error) {
	if a == nil {
		a = &admin.Alert{}
	}
	const q = `INSERT INTO agent_alert (kind, severity, title, detail)
	            VALUES ($1, $2, $3, $4::jsonb) RETURNING id`
	var id int64
	if err := r.db.QueryRow(ctx, q, a.Kind, a.Severity, a.Title, a.DetailJSON).Scan(&id); err != nil {
		return 0, fmt.Errorf("admin insert alert: %w", err)
	}
	return id, nil
}

// HasOpenAlert 判断指定 kind 是否存在 status='open' 的告警（巡检查询引擎去重用）。
func (r *AdminRepository) HasOpenAlert(ctx context.Context, kind string) (bool, error) {
	var exists bool
	const q = `SELECT EXISTS(SELECT 1 FROM agent_alert WHERE kind=$1 AND status='open')`
	if err := r.db.QueryRow(ctx, q, kind).Scan(&exists); err != nil {
		return false, fmt.Errorf("admin has open alert: %w", err)
	}
	return exists, nil
}

// LLMStatsLastHour 返回近 1 小时 LLM trace 调用数与其中失败数（output 含 error key）。
func (r *AdminRepository) LLMStatsLastHour(ctx context.Context) (int32, int32, error) {
	var calls, errs int32
	const q = `SELECT COUNT(*)::int, COUNT(*) FILTER (WHERE output ? 'error')::int
	           FROM agent_trace WHERE kind='llm' AND created_at >= now() - interval '1 hour'`
	if err := r.db.QueryRow(ctx, q).Scan(&calls, &errs); err != nil {
		return 0, 0, fmt.Errorf("admin llm stats last hour: %w", err)
	}
	return calls, errs, nil
}

// TraceGapLastHour 返回近 1 小时用户消息数与 trace 总数（用于 trace 缺失检测）。
func (r *AdminRepository) TraceGapLastHour(ctx context.Context) (int32, int32, error) {
	var userMsgs, traces int32
	const q = `SELECT
		(SELECT COUNT(*)::int FROM agent_message WHERE role='user' AND created_at >= now() - interval '1 hour'),
		(SELECT COUNT(*)::int FROM agent_trace WHERE created_at >= now() - interval '1 hour')`
	if err := r.db.QueryRow(ctx, q).Scan(&userMsgs, &traces); err != nil {
		return 0, 0, fmt.Errorf("admin trace gap last hour: %w", err)
	}
	return userMsgs, traces, nil
}

// TodayTokenTotal 返回今日（CURRENT_DATE 起）LLM trace prompt+completion token 合计。
func (r *AdminRepository) TodayTokenTotal(ctx context.Context) (int64, error) {
	var total int64
	const q = `SELECT COALESCE(SUM(prompt_tokens),0) + COALESCE(SUM(completion_tokens),0)
	           FROM agent_trace WHERE kind='llm' AND created_at >= CURRENT_DATE`
	if err := r.db.QueryRow(ctx, q).Scan(&total); err != nil {
		return 0, fmt.Errorf("admin today token total: %w", err)
	}
	return total, nil
}

// ListAppConfig 列出 app_config 全部开关（按 key 升序）。description 允许 NULL，以 COALESCE 兜底。
func (r *AdminRepository) ListAppConfig(ctx context.Context) ([]admin.AppConfigFlag, error) {
	rows, err := r.db.Query(ctx,
		`SELECT key, value, COALESCE(description,'') FROM app_config ORDER BY key`)
	if err != nil {
		return nil, fmt.Errorf("admin list app_config: %w", err)
	}
	defer rows.Close()

	out := make([]admin.AppConfigFlag, 0)
	for rows.Next() {
		var f admin.AppConfigFlag
		if err := rows.Scan(&f.Key, &f.Value, &f.Description); err != nil {
			return nil, fmt.Errorf("admin list app_config scan: %w", err)
		}
		out = append(out, f)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("admin list app_config rows: %w", err)
	}
	return out, nil
}

// SetAppConfig 新增或更新单个开关（upsert）。已存在行仅更新 value，保留原 description。
func (r *AdminRepository) SetAppConfig(ctx context.Context, key, value string) error {
	const q = `INSERT INTO app_config (key, value) VALUES ($1, $2)
	           ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value`
	if _, err := r.db.Exec(ctx, q, key, value); err != nil {
		return fmt.Errorf("admin set app_config: %w", err)
	}
	return nil
}
