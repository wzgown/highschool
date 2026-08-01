// graph.go Agent 状态图 orchestrator
package graph

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"highschool-backend/internal/service/agent"
	"highschool-backend/pkg/logger"
)

// 节点 ID
const (
	NodeRouter      = "router"
	NodePlanner     = "planner"
	NodeExecutor    = "executor"
	NodeClarify     = "clarify"
	NodeSynthesizer = "synthesizer"
	NodeReflection  = "reflection"
	NodeEnd         = "end"
)

// Config 状态图配置
type Config struct {
	MaxReplan            int  // Reflection 未通过的最大重规划次数（默认 2）
	StepBudget           int  // 单次对话全局节点步数预算（默认 12）
	MaxContextMsgs       int  // 带入 LLM 的最近消息数（默认 20）
	ReflectionLLMEnabled bool // 程序化校验后追加 LLM 评测（默认 false，省成本）
}

// ToolRunner 工具执行抽象（避免 graph 直接依赖 tools 包实现细节）
type ToolRunner interface {
	// Specs 返回当前可用工具描述
	Specs() []agent.ToolSpec
	// Execute 执行工具（带超时与 recover）
	Execute(ctx context.Context, name string, args json.RawMessage) (*agent.ToolResult, error)
}

// Graph 状态图
type Graph struct {
	LLM   agent.LLMClient
	Tools ToolRunner
	Store agent.Store
	Cfg   Config
}

// NewGraph 创建状态图
func NewGraph(llm agent.LLMClient, tools ToolRunner, store agent.Store, cfg Config) *Graph {
	if cfg.MaxReplan <= 0 {
		cfg.MaxReplan = 2
	}
	if cfg.StepBudget <= 0 {
		cfg.StepBudget = 12
	}
	if cfg.MaxContextMsgs <= 0 {
		cfg.MaxContextMsgs = 20
	}
	return &Graph{LLM: llm, Tools: tools, Store: store, Cfg: cfg}
}

// Run 从当前 State 推进状态图直至 NodeEnd（或 HITL 断点等待）。
// 每个节点转换后写 checkpoint + trace。
func (g *Graph) Run(ctx context.Context, s *agent.State) (*agent.State, error) {
	node := NodeRouter
	// HITL 恢复：会话处于等待输入状态 → 从 Clarify 的恢复逻辑进 Planner
	if s.PendingQ != nil {
		node = NodePlanner
		g.resumeFromClarify(s)
	}

	stepSeq := 0
	for node != NodeEnd {
		if s.StepBudget <= 0 {
			logger.Warn(ctx, "agent step budget exhausted", logger.Int64("session_id", s.SessionID))
			s.Reply = "这个问题有点复杂，我分几步也没处理完。可以换个更具体的问法再试一次。\n\n数据仅供参考，以上海市教育考试院官方公布为准。"
			return s, nil
		}
		s.StepBudget--
		start := time.Now()
		next, err := g.runNode(ctx, node, s)
		g.traceNode(ctx, s, node, next, err, time.Since(start))
		if err != nil {
			logger.Error(ctx, "agent node failed", err, logger.String("node", node))
			// 节点失败降级：直接给出兜底回答，不中断用户
			s.Reply = "抱歉，处理时出了点问题，请换个问法再试一次。\n\n数据仅供参考，以上海市教育考试院官方公布为准。"
			return s, nil
		}
		stepSeq++
		if cpErr := g.saveCheckpoint(ctx, s, stepSeq, next); cpErr != nil {
			logger.Error(ctx, "agent save checkpoint failed", cpErr, logger.Int64("session_id", s.SessionID))
		}
		node = next
		// Clarify 节点设置 PendingQ 后，本轮直接结束（等待用户输入）
		if node == NodeEnd {
			break
		}
	}
	return s, nil
}

// runNode 节点分发
func (g *Graph) runNode(ctx context.Context, node string, s *agent.State) (string, error) {
	switch node {
	case NodeRouter:
		return g.routerNode(ctx, s)
	case NodePlanner:
		return g.plannerNode(ctx, s)
	case NodeExecutor:
		return g.executorNode(ctx, s)
	case NodeClarify:
		return g.clarifyNode(ctx, s)
	case NodeSynthesizer:
		return g.synthesizerNode(ctx, s)
	case NodeReflection:
		return g.reflectionNode(ctx, s)
	default:
		return NodeEnd, fmt.Errorf("unknown node: %s", node)
	}
}

// resumeFromClarify 把用户对 PendingQ 的回答并入 Slots
func (g *Graph) resumeFromClarify(s *agent.State) {
	answer := s.PendingAnswer
	if answer == "" {
		answer = s.UserMessage
	}
	if s.PendingQ != nil && s.PendingQ.Field != "" && answer != "" {
		setSlot(s, s.PendingQ.Field, answer)
	}
	s.PendingQ = nil
}

// saveCheckpoint 持久化节点快照
func (g *Graph) saveCheckpoint(ctx context.Context, s *agent.State, stepSeq int, node string) error {
	if g.Store == nil {
		return nil
	}
	_, err := g.Store.SaveCheckpoint(ctx, s.SessionID, stepSeq, node, s)
	return err
}

// traceNode 节点级留痕
func (g *Graph) traceNode(ctx context.Context, s *agent.State, node, next string, runErr error, cost time.Duration) {
	if g.Store == nil {
		return
	}
	out := map[string]any{"next": next}
	if runErr != nil {
		out["error"] = runErr.Error()
	}
	outJSON, _ := json.Marshal(out)
	inJSON, _ := json.Marshal(map[string]any{
		"intent": s.Intent, "replan_count": s.ReplanCount, "step_budget": s.StepBudget,
	})
	_, _ = g.Store.AppendTrace(ctx, &agent.TraceRecord{
		SessionID: s.SessionID,
		Kind:      "node",
		Name:      node,
		Input:     inJSON,
		Output:    outJSON,
		LatencyMs: int(cost.Milliseconds()),
	})
}

// currentDateContext 给 Router/Planner 的当前时间上下文（防止 LLM 凭训练记忆把「今年」当成过去年份）
func currentDateContext() string {
	now := time.Now()
	return fmt.Sprintf("当前时间：%d年%d月。今年=%d年，去年=%d年；用户说「今年」指%d年，「去年」指%d年。",
		now.Year(), int(now.Month()), now.Year(), now.Year()-1, now.Year(), now.Year()-1)
}

// setSlot 写入槽位（field 为槽位名；district/exam 做标准化）
func setSlot(s *agent.State, field string, value any) {
	if s.Slots == nil {
		s.Slots = make(map[string]any)
	}
	if str, ok := value.(string); ok {
		value = normalizeSlotValue(field, str)
	}
	s.Slots[field] = value
}

// normalizeSlotValue 槽位值标准化
func normalizeSlotValue(field, v string) any {
	switch field {
	case "exam_type":
		switch v {
		case "一模":
			return "MOCK1"
		case "二模":
			return "MOCK2"
		case "中考":
			return "ZHONGKAO"
		}
	case "district_name":
		if v != "" && !strings.HasSuffix(v, "区") {
			return v + "区"
		}
	}
	return v
}
