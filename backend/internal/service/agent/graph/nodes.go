// nodes.go 状态图六个节点
package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/codes"
	"go.uber.org/zap"
	"golang.org/x/sync/errgroup"

	"highschool-backend/internal/service/agent"
	"highschool-backend/pkg/logger"
	"highschool-backend/pkg/metrics"
)

// ---------- ① Router 意图识别 ----------
func (g *Graph) routerNode(ctx context.Context, s *agent.State) (string, error) {
	type routerOut struct {
		Intent     string         `json:"intent"`
		Confidence float64        `json:"confidence"`
		Slots      map[string]any `json:"slots"`
		Reason     string         `json:"reason"`
	}
	contextJSON, _ := json.Marshal(map[string]any{"已知槽位": s.Slots})
	msgs := []agent.Message{
		{Role: agent.RoleSystem, Content: RouterSystemPrompt},
		{Role: agent.RoleUser, Content: fmt.Sprintf("%s\n上下文：%s\n用户消息：%s", currentDateContext(), contextJSON, s.UserMessage)},
	}
	result, err := g.callLLM(ctx, s, "router", agent.ChatParams{
		Messages: msgs, MaxTokens: 300, Temperature: 0, ResponseJSON: true,
	})
	if err != nil {
		return "", err
	}
	var out routerOut
	if err := json.Unmarshal([]byte(extractJSON(result.Content)), &out); err != nil {
		// 解析失败：降级为数据查询，让后续工具去尝试
		out = routerOut{Intent: agent.IntentDataQuery, Confidence: 0.5}
	}
	s.Intent = out.Intent
	for k, v := range out.Slots {
		setSlot(s, k, v)
	}
	if s.Intent == agent.IntentOffTopic || out.Confidence < 0.4 {
		s.Reply = OffTopicReply
		return NodeEnd, nil
	}
	return NodePlanner, nil
}

// ---------- ② Planner 任务规划 ----------
func (g *Graph) plannerNode(ctx context.Context, s *agent.State) (string, error) {
	// 推荐类意图：校验必填槽位，缺失转 Clarify
	if s.Intent == agent.IntentRecommendation {
		for _, f := range []string{"district_name", "total_score", "exam_type"} {
			if _, ok := s.Slots[f]; !ok {
				s.NeedClarifyField = f
				return NodeClarify, nil
			}
		}
	}
	specs := g.Tools.Specs()
	specsJSON, _ := json.Marshal(specs)
	payload, _ := json.Marshal(map[string]any{
		"intent": s.Intent, "slots": s.Slots, "message": s.UserMessage,
	})
	msgs := []agent.Message{
		{Role: agent.RoleSystem, Content: PlannerSystemPrompt + "\n\n" + currentDateContext() + "\n\n可用工具：\n" + string(specsJSON)},
		{Role: agent.RoleUser, Content: string(payload)},
	}
	result, err := g.callLLM(ctx, s, "planner", agent.ChatParams{
		Messages: msgs, MaxTokens: 500, Temperature: 0, ResponseJSON: true,
	})
	if err != nil {
		return "", err
	}
	var planOut struct {
		Steps []agent.Step `json:"steps"`
	}
	if err := json.Unmarshal([]byte(extractJSON(result.Content)), &planOut); err != nil {
		planOut.Steps = nil
	}
	// 过滤掉注册表中不存在的工具
	valid := map[string]bool{}
	for _, sp := range specs {
		valid[sp.Name] = true
	}
	steps := make([]agent.Step, 0, len(planOut.Steps))
	for _, st := range planOut.Steps {
		if valid[st.ToolName] {
			steps = append(steps, st)
		}
	}
	s.Plan = steps
	if len(steps) == 0 {
		return NodeSynthesizer, nil
	}
	return NodeExecutor, nil
}

// ---------- ③ PlanExecutor 工具执行 ----------
func (g *Graph) executorNode(ctx context.Context, s *agent.State) (string, error) {
	results := make([]*agent.ToolResult, len(s.Plan))
	infos := make([]agent.ToolCallInfo, len(s.Plan))
	eg, egCtx := errgroup.WithContext(ctx)
	for i, st := range s.Plan {
		i, st := i, st
		eg.Go(func() error {
			argsJSON, _ := json.Marshal(st.Args)
			toolCtx, span := startSpan(egCtx, "tool."+st.ToolName, attribute.Int64("session_id", s.SessionID))
			start := time.Now()
			tr, err := g.Tools.Execute(toolCtx, st.ToolName, argsJSON)
			cost := time.Since(start)
			span.SetAttributes(
				attribute.Int64("latency_ms", cost.Milliseconds()),
				attribute.Bool("success", err == nil),
			)
			if err != nil {
				span.RecordError(err)
				span.SetStatus(codes.Error, err.Error())
			}
			span.End()
			toolStatus := "success"
			if err != nil {
				toolStatus = "error"
			}
			metrics.ObserveToolCall(st.ToolName, toolStatus, cost.Seconds())
			g.traceTool(ctx, s, st.ToolName, argsJSON, tr, err, cost)
			if err != nil {
				infos[i] = agent.ToolCallInfo{Name: st.ToolName, Summary: "执行失败: " + err.Error(), Success: false}
				results[i] = &agent.ToolResult{ForLLM: fmt.Sprintf(`{"error":%q}`, err.Error()), Summary: "执行失败"}
				return nil // 单步失败降级，不中断
			}
			infos[i] = agent.ToolCallInfo{Name: st.ToolName, Summary: tr.Summary, Success: true}
			results[i] = tr
			return nil
		})
	}
	_ = eg.Wait()
	for _, tr := range results {
		if tr == nil {
			continue
		}
		s.ToolResults = append(s.ToolResults, *tr)
		s.Cards = append(s.Cards, tr.Cards...)
	}
	s.ToolCallInfos = append(s.ToolCallInfos, infos...)
	return NodeSynthesizer, nil
}

// ---------- ④ Clarify/HITL ----------
func (g *Graph) clarifyNode(ctx context.Context, s *agent.State) (string, error) {
	tpl, ok := ClarifyQuestions[s.NeedClarifyField]
	if !ok {
		tpl = ClarifyQuestions["confirm"]
	}
	s.PendingQ = &agent.PendingQuestion{
		Question: tpl.Question,
		Field:    s.NeedClarifyField,
		Options:  tpl.Options,
	}
	s.Reply = tpl.Question
	return NodeEnd, nil
}

// ---------- ⑤ ResultSynthesizer 结果综合 ----------
func (g *Graph) synthesizerNode(ctx context.Context, s *agent.State) (string, error) {
	msgs := make([]agent.Message, 0, len(s.Messages)+3)
	msgs = append(msgs, agent.Message{Role: agent.RoleSystem, Content: SynthesizerSystemPrompt})
	// 历史上下文（最近 N 条，跳过 system）
	start := 0
	if len(s.Messages) > g.Cfg.MaxContextMsgs {
		start = len(s.Messages) - g.Cfg.MaxContextMsgs
	}
	msgs = append(msgs, s.Messages[start:]...)
	// 注入工具结果
	if len(s.ToolResults) > 0 {
		var sb strings.Builder
		sb.WriteString("【工具查询结果（回答的唯一数据来源）】\n")
		for i, tr := range s.ToolResults {
			fmt.Fprintf(&sb, "--- 结果%d ---\n%s\n", i+1, tr.ForLLM)
		}
		msgs = append(msgs, agent.Message{Role: agent.RoleUser, Content: sb.String()})
	}
	result, err := g.callLLM(ctx, s, "synthesizer", agent.ChatParams{
		Messages: msgs, MaxTokens: 800, Temperature: 0.3,
	})
	if err != nil {
		return "", err
	}
	s.Reply = result.Content
	return NodeReflection, nil
}

// ---------- ⑥ Reflection 校验·重规划 ----------
func (g *Graph) reflectionNode(ctx context.Context, s *agent.State) (string, error) {
	_, span := startSpan(ctx, "reflection", attribute.Int64("session_id", s.SessionID))
	defer span.End()
	pass, reason := verifyReply(s.Reply, s.ToolResults)
	// 数据类意图：无工具结果支撑却出现数字，视为幻觉（政策问答/越界除外）
	if pass && len(s.ToolResults) == 0 &&
		(s.Intent == agent.IntentDataQuery || s.Intent == agent.IntentRecommendation ||
			s.Intent == agent.IntentResultInterpretation) {
		for _, n := range extractNumbers(s.Reply) {
			if !isYear(n) && !numberWhitelist[n] {
				pass, reason = false, "数据类问题未调用工具取数却给出数字"
				break
			}
		}
	}
	g.traceReflection(ctx, s, pass, reason)
	// 可选：程序化校验通过后再做一轮 LLM 评测（答非所问/风险承诺）
	if pass && g.Cfg.ReflectionLLMEnabled {
		pass, reason = g.llmReflect(ctx, s)
		g.traceReflection(ctx, s, pass, "llm: "+reason)
	}
	span.SetAttributes(attribute.Bool("passed", pass))
	if pass {
		return NodeEnd, nil
	}
	s.ReplanCount++
	if s.ReplanCount <= g.Cfg.MaxReplan {
		// 回 Router 重规划（携带失败原因，Planner 可换工具/补充取数）
		setSlot(s, "_reflection_note", "上一轮回答未通过校验："+reason+"，请补充查询相关数据后再回答")
		s.ToolResults = nil
		return NodeRouter, nil
	}
	// 连续未通过：降级话术 + 保留卡片
	s.Reply = DegradedReply
	return NodeEnd, nil
}

// ---------- LLM / trace 辅助 ----------

// llmReflect LLM 反思评测（可选开关）：答非所问/无来源数字/风险承诺
func (g *Graph) llmReflect(ctx context.Context, s *agent.State) (bool, string) {
	payload, _ := json.Marshal(map[string]any{
		"user_question": s.UserMessage,
		"reply":         s.Reply,
	})
	result, err := g.callLLM(ctx, s, "reflection_llm", agent.ChatParams{
		Messages: []agent.Message{
			{Role: agent.RoleSystem, Content: ReflectionSystemPrompt},
			{Role: agent.RoleUser, Content: string(payload)},
		},
		MaxTokens: 150, Temperature: 0, ResponseJSON: true,
	})
	if err != nil {
		// 评测失败不阻断主流程
		return true, "llm reflect error: " + err.Error()
	}
	var out struct {
		Pass   bool   `json:"pass"`
		Reason string `json:"reason"`
	}
	if err := json.Unmarshal([]byte(extractJSON(result.Content)), &out); err != nil {
		return true, "llm reflect parse error"
	}
	return out.Pass, out.Reason
}

// callLLM 统一 LLM 调用 + 留痕 + span/指标
func (g *Graph) callLLM(ctx context.Context, s *agent.State, node string, params agent.ChatParams) (*agent.ChatResult, error) {
	ctx, span := startSpan(ctx, "llm.call",
		attribute.Int64("session_id", s.SessionID),
		attribute.String("model", g.Cfg.Model),
		attribute.String("node", node),
	)
	defer span.End()
	start := time.Now()
	result, err := g.LLM.Chat(ctx, params)
	cost := time.Since(start)

	var pt, ct int
	hasToolCalls := false
	if result != nil {
		pt, ct = result.PromptTokens, result.CompletionTokens
		hasToolCalls = len(result.ToolCalls) > 0
	}
	span.SetAttributes(
		attribute.Int("prompt_tokens", pt),
		attribute.Int("completion_tokens", ct),
		attribute.Int64("latency_ms", cost.Milliseconds()),
		attribute.Bool("has_tool_calls", hasToolCalls),
	)

	status := "success"
	if err != nil {
		status = "error"
		span.RecordError(err)
		span.SetStatus(codes.Error, err.Error())
		// LLM 调用失败：记 model/状态码/耗时（prompt 不落日志）
		fields := []zap.Field{
			logger.String("model", g.Cfg.Model),
			logger.String("node", node),
			logger.Int64("session_id", s.SessionID),
			logger.Int64("latency_ms", cost.Milliseconds()),
			logger.ErrorField(err),
		}
		var apiErr interface{ HTTPStatus() int }
		if errors.As(err, &apiErr) {
			fields = append(fields, logger.Int("status", apiErr.HTTPStatus()))
		}
		logger.Warn(ctx, "agent llm call failed", fields...)
	} else {
		// 本轮 token 累计（落库到 assistant 消息 usage）
		s.PromptTokens += pt
		s.CompletionTokens += ct
	}
	metrics.ObserveLLMCall(g.Cfg.Model, status, pt, ct, cost.Seconds())

	if g.Store != nil {
		inJSON, _ := json.Marshal(params.Messages)
		var outJSON json.RawMessage
		if result != nil {
			outJSON, _ = json.Marshal(map[string]any{"content": result.Content, "tool_calls": result.ToolCalls})
		}
		var errStr string
		if err != nil {
			errStr = err.Error()
			outJSON, _ = json.Marshal(map[string]any{"error": errStr})
		}
		_, _ = g.Store.AppendTrace(ctx, &agent.TraceRecord{
			SessionID: s.SessionID, Kind: "llm", Name: node,
			Input: inJSON, Output: outJSON,
			PromptTokens: pt, CompletionTokens: ct, LatencyMs: int(cost.Milliseconds()),
		})
	}
	return result, err
}

// traceTool 工具调用留痕
func (g *Graph) traceTool(ctx context.Context, s *agent.State, name string, args json.RawMessage, tr *agent.ToolResult, runErr error, cost time.Duration) {
	if g.Store == nil {
		return
	}
	var outJSON json.RawMessage
	if runErr != nil {
		outJSON, _ = json.Marshal(map[string]any{"error": runErr.Error()})
	} else {
		outJSON, _ = json.Marshal(map[string]any{"summary": tr.Summary, "for_llm": tr.ForLLM})
	}
	_, _ = g.Store.AppendTrace(ctx, &agent.TraceRecord{
		SessionID: s.SessionID, Kind: "tool", Name: name,
		Input: args, Output: outJSON, LatencyMs: int(cost.Milliseconds()),
	})
}

// traceReflection Reflection 结果留痕
func (g *Graph) traceReflection(ctx context.Context, s *agent.State, pass bool, reason string) {
	if g.Store == nil {
		return
	}
	outJSON, _ := json.Marshal(map[string]any{"pass": pass, "reason": reason})
	_, _ = g.Store.AppendTrace(ctx, &agent.TraceRecord{
		SessionID: s.SessionID, Kind: "node", Name: "reflection_check", Output: outJSON,
	})
}

// extractJSON 从 LLM 输出中提取 JSON 对象（容忍 ```json 包裹）
func extractJSON(s string) string {
	s = strings.TrimSpace(s)
	if i := strings.Index(s, "```"); i >= 0 {
		s = strings.TrimPrefix(s[i:], "```json")
		s = strings.TrimPrefix(s, "```")
		if j := strings.LastIndex(s, "```"); j >= 0 {
			s = s[:j]
		}
	}
	start := strings.Index(s, "{")
	end := strings.LastIndex(s, "}")
	if start >= 0 && end > start {
		return s[start : end+1]
	}
	return s
}
