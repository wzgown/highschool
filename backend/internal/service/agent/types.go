// Package agent AI 顾问 Agent 核心类型契约
// 设计文档: docs/agent-mode-plan.md
package agent

import (
	"context"
	"encoding/json"
)

// ---------- 消息角色 ----------
const (
	RoleSystem    = "system"
	RoleUser      = "user"
	RoleAssistant = "assistant"
	RoleTool      = "tool"
)

// ---------- 意图 ----------
const (
	IntentPolicyQA             = "policy_qa"
	IntentDataQuery            = "data_query"
	IntentRecommendation       = "recommendation"
	IntentSimulation           = "simulation"
	IntentResultInterpretation = "result_interpretation"
	IntentOffTopic             = "off_topic"
)

// ---------- 会话状态 ----------
const (
	SessionStatusRunning       = "running"
	SessionStatusWaitingInput  = "waiting_input"
	SessionStatusDone          = "done"
	SessionStatusAborted       = "aborted"
)

// Message 对话消息（同时用于 LLM 上下文与 agent_message 落库）
type Message struct {
	Role       string        `json:"role"`
	Content    string        `json:"content"`
	ToolCalls  []LLMToolCall `json:"tool_calls,omitempty"`   // assistant 消息携带的工具调用
	ToolCallID string        `json:"tool_call_id,omitempty"` // tool 结果消息对应的调用 id
	Name       string        `json:"name,omitempty"`         // tool 结果消息的工具名
}

// LLMToolCall LLM 返回的一次工具调用
type LLMToolCall struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	ArgumentsJSON string `json:"arguments_json"`
}

// ToolSpec 工具描述（注册进 LLM 的 tools 参数）
type ToolSpec struct {
	Name           string         `json:"name"`
	Description    string         `json:"description"` // 写明何时用、与谁组合（中文示例）
	ParametersJSON map[string]any `json:"parameters"`  // JSON Schema
}

// ChatParams LLM 调用参数
type ChatParams struct {
	Messages     []Message
	Tools        []ToolSpec // 空则不传 tools
	MaxTokens    int
	Temperature  float64
	ResponseJSON bool // 强制 JSON 对象输出（Router/Planner 用）
}

// ChatResult LLM 调用结果
type ChatResult struct {
	Content          string
	ToolCalls        []LLMToolCall
	PromptTokens     int
	CompletionTokens int
}

// LLMClient ChatModel 抽象（可插拔 provider，OpenAI 兼容）
type LLMClient interface {
	Chat(ctx context.Context, params ChatParams) (*ChatResult, error)
}

// SchoolCard 结构化学校卡片（前端渲染）
type SchoolCard struct {
	SchoolID     int32          `json:"school_id"`
	SchoolName   string         `json:"school_name"`
	DistrictName string         `json:"district_name"`
	CardType     string         `json:"card_type"` // score_trend / compare / profile / quota / middle_school
	Payload      map[string]any `json:"payload"`
}

// ToolResult 工具执行结果（双载荷）
type ToolResult struct {
	ForLLM  string       `json:"-"`      // 给 LLM 的 JSON 文本
	Cards   []SchoolCard `json:"-"`      // 给前端的卡片
	Summary string       `json:"summary"` // 给人看的工具摘要，如「查询 2024-2026 平行志愿分数线」
}

// Tool 受控工具（ToolRegistry 注册）
type Tool interface {
	Spec() ToolSpec
	Execute(ctx context.Context, args json.RawMessage) (*ToolResult, error)
}

// PendingQuestion HITL 追问
type PendingQuestion struct {
	Question string   `json:"question"`
	Field    string   `json:"field"` // 等待填充的槽位名 / confirm
	Options  []string `json:"options,omitempty"`
}

// Step Planner 产出的一个执行步骤
type Step struct {
	ToolName  string         `json:"tool_name"`
	Args      map[string]any `json:"args"`
	DependsOn []int          `json:"depends_on,omitempty"` // 依赖的步骤下标
}

// ToolCallInfo 返回给前端的工具调用信息
type ToolCallInfo struct {
	Name    string `json:"name"`
	Summary string `json:"summary"`
	Success bool   `json:"success"`
}

// State Agent 状态（checkpoint 全量序列化的就是它）
type State struct {
	SessionID   int64            `json:"session_id"`
	DeviceID    string           `json:"device_id"`
	Messages    []Message        `json:"messages"`
	Intent      string           `json:"intent"`
	Slots       map[string]any   `json:"slots"`
	Plan        []Step           `json:"plan,omitempty"`
	ToolResults []ToolResult     `json:"-"`
	PendingQ    *PendingQuestion `json:"pending_q,omitempty"`
	ReplanCount int              `json:"replan_count"`
	StepBudget  int              `json:"step_budget"`

	// 节点产出
	Reply         string         `json:"reply,omitempty"`
	Cards         []SchoolCard   `json:"cards,omitempty"`
	ToolCallInfos []ToolCallInfo `json:"tool_call_infos,omitempty"`

	// 本次用户输入（不持久化到 checkpoint 语义外）
	UserMessage   string `json:"-"`
	PendingAnswer string `json:"-"`
	// Planner → Clarify 传递的缺失槽位名
	NeedClarifyField string `json:"-"`
}

// ---------- ThreadStore 持久化抽象 ----------

// Session 会话记录
type Session struct {
	ID           int64
	DeviceID     string
	Status       string
	CurrentNode  string
	Intent       string
	Slots        map[string]any
	PendingQ     *PendingQuestion
	AnalysisID   *int64
	Version      int
}

// TraceRecord 一次 LLM/工具/节点调用留痕
type TraceRecord struct {
	SessionID        int64
	CheckpointID     *int64
	Kind             string // llm/tool/node
	Name             string
	Input            json.RawMessage
	Output           json.RawMessage
	PromptTokens     int
	CompletionTokens int
	LatencyMs        int
}

// Store ThreadStore（session + checkpoint + message + trace）
type Store interface {
	// CreateSession 创建会话，返回 session id
	CreateSession(ctx context.Context, deviceID string, analysisID *int64) (int64, error)
	// GetSession 读取会话（含 version）
	GetSession(ctx context.Context, id int64) (*Session, error)
	// UpdateSessionCAS 乐观锁更新会话状态；version 冲突返回 ErrSessionConflict
	UpdateSessionCAS(ctx context.Context, s *Session) error
	// SaveCheckpoint 写入节点快照，返回 checkpoint id
	SaveCheckpoint(ctx context.Context, sessionID int64, stepSeq int, node string, state *State) (int64, error)
	// LatestCheckpoint 读取最新快照
	LatestCheckpoint(ctx context.Context, sessionID int64) (stepSeq int, node string, state *State, err error)
	// AppendMessage 追加消息
	AppendMessage(ctx context.Context, sessionID int64, msg Message, node string, usage *ChatResult) error
	// ListMessages 最近 limit 条（按时间正序）
	ListMessages(ctx context.Context, sessionID int64, limit int) ([]Message, error)
	// AppendTrace 留痕，返回 trace id
	AppendTrace(ctx context.Context, rec *TraceRecord) (int64, error)
	// CountTodayUserMessages device 当日用户消息数（限流用）
	CountTodayUserMessages(ctx context.Context, deviceID string) (int, error)
}

// ErrSessionConflict Thread Lock 冲突
var ErrSessionConflict = errSessionConflict{}

type errSessionConflict struct{}

func (errSessionConflict) Error() string { return "agent: session version conflict" }
