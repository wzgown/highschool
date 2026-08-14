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
	ID        int64 // 主键：一轮多个快照 created_at 同秒，前端 key 靠它保证唯一
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

// CostLlmDaily 成本看板-按天 LLM 聚合行（对应 v_agent_llm_daily）
type CostLlmDaily struct {
	Day              string
	LlmCalls         int64
	PromptTokens     int64
	CompletionTokens int64
	TotalTokens      int64
	AvgLatencyMs     int64
	P95LatencyMs     int64
	ErrorCount       int64
}

// CostToolDaily 成本看板-按天 × 工具聚合行（对应 v_agent_tool_daily）
type CostToolDaily struct {
	Day          string
	ToolName     string
	Calls        int64
	Failures     int64
	AvgLatencyMs int64
}

// CostSessionDaily 成本看板-按天会话/消息聚合行（对应 v_agent_session_daily）
type CostSessionDaily struct {
	Day               string
	ActiveSessions    int64
	Messages          int64
	UserMessages      int64
	AssistantMessages int64
}

// CostDashboard 成本看板全量数据（三张视图的并集）
type CostDashboard struct {
	LlmDaily     []CostLlmDaily
	ToolDaily    []CostToolDaily
	SessionDaily []CostSessionDaily
}

// Alert agent_alert 行（P3 巡检引擎写入，handler 读取）
type Alert struct {
	ID         int64
	CreatedAt  string
	Kind       string
	Severity   string
	Title      string
	DetailJSON string // 原始 detail(jsonb) 文本
	Status     string
	AckedAt    string
}

// AlertFilter 告警列表过滤/分页
type AlertFilter struct {
	Status   string // open|acked|resolved；空=不过滤
	Page     int32  // 从 1 起
	PageSize int32
}

// AppConfigFlag app_config 表行：管理后台可读写的远程开关
type AppConfigFlag struct {
	Key         string
	Value       string
	Description string
}

// Store 管理后台只读仓储（handler 依赖此接口，便于测试用 fake）
type Store interface {
	ListAgentSessions(ctx context.Context, f ListFilter) ([]SessionRow, int32, error)
	GetSessionReplay(ctx context.Context, sessionID int64) (*ReplayBundle, error)
	GetCostDashboard(ctx context.Context, from, to string) (*CostDashboard, error)

	// 告警数据层（P3）：handler 直读 + 后续巡检查询引擎写入/判定。
	ListAlerts(ctx context.Context, f AlertFilter) ([]Alert, int32, error)
	AckAlert(ctx context.Context, id int64) error
	InsertAlert(ctx context.Context, a *Alert) (int64, error)
	HasOpenAlert(ctx context.Context, kind string) (bool, error)
	LLMStatsLastHour(ctx context.Context) (calls int32, errors int32, err error)
	TraceGapLastHour(ctx context.Context) (userMsgs int32, traces int32, err error)
	TodayTokenTotal(ctx context.Context) (int64, error)

	// 应用开关（P4）：读写 app_config 表。
	ListAppConfig(ctx context.Context) ([]AppConfigFlag, error)
	SetAppConfig(ctx context.Context, key, value string) error
}
