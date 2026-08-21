// agent_store_repository.go Agent 会话/checkpoint/trace 仓储（ThreadStore 实现）
package repository

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/service/agent"
)

// AgentStoreRepository agent.Store 的 pgx 实现
type AgentStoreRepository struct {
	db *pgxpool.Pool
}

// NewAgentStoreRepository 创建 Agent 仓储
func NewAgentStoreRepository() *AgentStoreRepository {
	return &AgentStoreRepository{db: database.GetDB()}
}

var _ agent.Store = (*AgentStoreRepository)(nil)

// CreateSession 创建会话
func (r *AgentStoreRepository) CreateSession(ctx context.Context, deviceID string, analysisID *int64) (int64, error) {
	var id int64
	err := r.db.QueryRow(ctx,
		`INSERT INTO agent_session (device_id, analysis_id) VALUES ($1, $2) RETURNING id`,
		deviceID, analysisID).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("create agent session: %w", err)
	}
	return id, nil
}

// GetSession 读取会话
func (r *AgentStoreRepository) GetSession(ctx context.Context, id int64) (*agent.Session, error) {
	s := &agent.Session{}
	var slots, pendingQ []byte
	var currentNode, intent *string
	err := r.db.QueryRow(ctx,
		`SELECT id, device_id, status, current_node, intent, slots, pending_question, analysis_id, version
		 FROM agent_session WHERE id = $1`, id).
		Scan(&s.ID, &s.DeviceID, &s.Status, &currentNode, &intent, &slots, &pendingQ, &s.AnalysisID, &s.Version)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, fmt.Errorf("agent session %d not found", id)
	}
	if err != nil {
		return nil, fmt.Errorf("get agent session: %w", err)
	}
	if currentNode != nil {
		s.CurrentNode = *currentNode
	}
	if intent != nil {
		s.Intent = *intent
	}
	if len(slots) > 0 {
		_ = json.Unmarshal(slots, &s.Slots)
	}
	if len(pendingQ) > 0 {
		var pq agent.PendingQuestion
		if err := json.Unmarshal(pendingQ, &pq); err == nil {
			s.PendingQ = &pq
		}
	}
	return s, nil
}

// UpdateSessionCAS 乐观锁更新（Thread Lock）
func (r *AgentStoreRepository) UpdateSessionCAS(ctx context.Context, s *agent.Session) error {
	slots, _ := json.Marshal(s.Slots)
	var pendingQ []byte
	if s.PendingQ != nil {
		pendingQ, _ = json.Marshal(s.PendingQ)
	}
	tag, err := r.db.Exec(ctx,
		`UPDATE agent_session
		 SET status=$1, current_node=$2, intent=$3, slots=$4, pending_question=$5,
		     analysis_id=$6, version=version+1, last_active_at=CURRENT_TIMESTAMP
		 WHERE id=$7 AND version=$8`,
		s.Status, nullStr(s.CurrentNode), nullStr(s.Intent), slots, pendingQ, s.AnalysisID, s.ID, s.Version)
	if err != nil {
		return fmt.Errorf("update agent session: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return agent.ErrSessionConflict
	}
	return nil
}

// SaveCheckpoint 写入节点快照
func (r *AgentStoreRepository) SaveCheckpoint(ctx context.Context, sessionID int64, stepSeq int, node string, state *agent.State) (int64, error) {
	stateJSON, err := json.Marshal(state)
	if err != nil {
		return 0, fmt.Errorf("marshal agent state: %w", err)
	}
	// 注：(session_id, step_seq) 的 UNIQUE 已随迁移 015 移除（Run 每轮 stepSeq 重置，
	// 轮内递增即可）；此处必须纯 INSERT，不可带 ON CONFLICT —— 约束不存在时
	// PostgreSQL 会在 plan 阶段直接报 42P10。
	var id int64
	err = r.db.QueryRow(ctx,
		`INSERT INTO agent_checkpoint (session_id, step_seq, node, state)
		 VALUES ($1, $2, $3, $4)
		 RETURNING id`,
		sessionID, stepSeq, node, stateJSON).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("save agent checkpoint: %w", err)
	}
	return id, nil
}

// LatestCheckpoint 读取最新快照（按 id 即写入时间序；step_seq 每轮重置，不可作全局序）
func (r *AgentStoreRepository) LatestCheckpoint(ctx context.Context, sessionID int64) (int, string, *agent.State, error) {
	var stepSeq int
	var node string
	var stateJSON []byte
	err := r.db.QueryRow(ctx,
		`SELECT step_seq, node, state FROM agent_checkpoint
		 WHERE session_id = $1 ORDER BY id DESC LIMIT 1`, sessionID).
		Scan(&stepSeq, &node, &stateJSON)
	if errors.Is(err, pgx.ErrNoRows) {
		return 0, "", nil, nil
	}
	if err != nil {
		return 0, "", nil, fmt.Errorf("latest agent checkpoint: %w", err)
	}
	var state agent.State
	if err := json.Unmarshal(stateJSON, &state); err != nil {
		return 0, "", nil, fmt.Errorf("unmarshal agent state: %w", err)
	}
	return stepSeq, node, &state, nil
}

// AppendMessage 追加消息
func (r *AgentStoreRepository) AppendMessage(ctx context.Context, sessionID int64, msg agent.Message, node string, usage *agent.ChatResult) error {
	var toolCalls, usageJSON []byte
	if len(msg.ToolCalls) > 0 {
		toolCalls, _ = json.Marshal(msg.ToolCalls)
	}
	if usage != nil {
		usageJSON, _ = json.Marshal(map[string]int{
			"prompt_tokens": usage.PromptTokens, "completion_tokens": usage.CompletionTokens,
		})
	}
	_, err := r.db.Exec(ctx,
		`INSERT INTO agent_message (session_id, role, content, node, tool_calls, usage)
		 VALUES ($1, $2, $3, $4, $5, $6)`,
		sessionID, msg.Role, msg.Content, nullStr(node), toolCalls, usageJSON)
	if err != nil {
		return fmt.Errorf("append agent message: %w", err)
	}
	return nil
}

// ListMessages 最近 limit 条（正序）
func (r *AgentStoreRepository) ListMessages(ctx context.Context, sessionID int64, limit int) ([]agent.Message, error) {
	if limit <= 0 {
		limit = 50
	}
	rows, err := r.db.Query(ctx,
		`SELECT role, content, tool_calls FROM (
		   SELECT role, content, tool_calls, id FROM agent_message
		   WHERE session_id = $1 ORDER BY id DESC LIMIT $2
		 ) t ORDER BY id`, sessionID, limit)
	if err != nil {
		return nil, fmt.Errorf("list agent messages: %w", err)
	}
	defer rows.Close()
	var msgs []agent.Message
	for rows.Next() {
		var m agent.Message
		var toolCalls []byte
		if err := rows.Scan(&m.Role, &m.Content, &toolCalls); err != nil {
			return nil, err
		}
		if len(toolCalls) > 0 {
			_ = json.Unmarshal(toolCalls, &m.ToolCalls)
		}
		msgs = append(msgs, m)
	}
	return msgs, rows.Err()
}

// AppendTrace 留痕
func (r *AgentStoreRepository) AppendTrace(ctx context.Context, rec *agent.TraceRecord) (int64, error) {
	var id int64
	err := r.db.QueryRow(ctx,
		`INSERT INTO agent_trace (session_id, checkpoint_id, kind, name, input, output,
		                          prompt_tokens, completion_tokens, latency_ms,
		                          prompt_cache_hit_tokens, prompt_cache_miss_tokens)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id`,
		rec.SessionID, rec.CheckpointID, rec.Kind, nullStr(rec.Name), rec.Input, rec.Output,
		rec.PromptTokens, rec.CompletionTokens, rec.LatencyMs,
		rec.PromptCacheHitTokens, rec.PromptCacheMissTokens).Scan(&id)
	if err != nil {
		return 0, fmt.Errorf("append agent trace: %w", err)
	}
	return id, nil
}

// CountTodayUserMessages device 当日用户消息数（限流）
func (r *AgentStoreRepository) CountTodayUserMessages(ctx context.Context, deviceID string) (int, error) {
	var n int
	err := r.db.QueryRow(ctx,
		`SELECT COUNT(*) FROM agent_message m
		 JOIN agent_session s ON s.id = m.session_id
		 WHERE s.device_id = $1 AND m.role = 'user'
		   AND m.created_at >= CURRENT_DATE`, deviceID).Scan(&n)
	if err != nil {
		return 0, fmt.Errorf("count today agent messages: %w", err)
	}
	return n, nil
}

func nullStr(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}
