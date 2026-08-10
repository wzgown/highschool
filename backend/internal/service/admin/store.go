// Package admin 管理后台业务类型契约（回放/审计只读查询）。
package admin

import (
	"context"
	"errors"
)

// ErrNotFound 哨兵错误：查询的目标资源不存在（如 session id 未命中）。
// Store 实现在 pgx.ErrNoRows 时返回（直接或 wrap），handler 据此映射 connect.CodeNotFound。
var ErrNotFound = errors.New("admin: not found")

// ListAgentSessions 会话列表过滤条件
type ListFilter struct {
	TimeFrom string // 含；空不过滤；RFC3339 或 'YYYY-MM-DD'
	TimeTo   string
	DeviceID string
	Intent   string
	Page     int32 // 从 1 起
	PageSize int32
}

// SessionRow 会话列表行
type SessionRow struct {
	SessionID    int64
	DeviceID     string
	Status       string
	Intent       string
	CreatedAt    string
	LastActiveAt string
	MessageCount int32
	TotalTokens  int64
}

// ReplaySession 回放-会话元信息
type ReplaySession struct {
	SessionID int64
	DeviceID  string
	Status    string
	Intent    string
	CreatedAt string
}

// ReplayMessage 回放-消息
type ReplayMessage struct {
	Role      string
	Content   string
	Node      string
	CreatedAt string
	UsageJSON string // 原始 usage JSON
}

// ReplayTrace 回放-LLM/工具留痕
type ReplayTrace struct {
	Kind             string
	Name             string
	InputJSON        string
	OutputJSON       string
	PromptTokens     int32
	CompletionTokens int32
	LatencyMs        int32
	CreatedAt        string
}

// ReplayCheckpoint 回放-节点快照
type ReplayCheckpoint struct {
	StepSeq   int32
	Node      string
	StateJSON string
	CreatedAt string
}

// ReplayBundle 回放全量数据
type ReplayBundle struct {
	Session     ReplaySession
	Messages    []ReplayMessage
	Traces      []ReplayTrace
	Checkpoints []ReplayCheckpoint
}

// Store 管理后台只读仓储（handler 依赖此接口，便于测试用 fake）
type Store interface {
	ListAgentSessions(ctx context.Context, f ListFilter) ([]SessionRow, int32, error)
	GetSessionReplay(ctx context.Context, sessionID int64) (*ReplayBundle, error)
}
