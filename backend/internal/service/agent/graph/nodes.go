// nodes.go 状态图六个节点
package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
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
	priorIntent := s.Intent
	// P2：带最近若干条历史，帮助解指代 + 更准分类（当前消息已单独传，从历史里去掉最后一条）
	const routerHistoryN = 4
	recent := s.Messages
	if len(recent) > 0 {
		recent = recent[:len(recent)-1]
	}
	if len(recent) > routerHistoryN {
		recent = recent[len(recent)-routerHistoryN:]
	}
	contextJSON, _ := json.Marshal(map[string]any{"已知槽位": s.Slots, "最近对话": recent})
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
	// P3：意图切换 → 清易变槽位（保留持久槽位），避免陈旧槽位污染新意图
	if priorIntent != "" && out.Intent != priorIntent {
		for k := range s.Slots {
			if !agent.IsPersistentSlot(k) {
				delete(s.Slots, k)
			}
		}
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
		Steps       []agent.Step `json:"steps"`
		NeedClarify string       `json:"need_clarify"`
	}
	if err := json.Unmarshal([]byte(extractJSON(result.Content)), &planOut); err != nil {
		planOut.Steps = nil
	}
	// 缺必要槽位 → Clarify 向用户追问（槽位实际已存在则忽略，防 LLM 误报）
	if f := planOut.NeedClarify; f != "" {
		if _, ok := s.Slots[f]; !ok {
			s.NeedClarifyField = f
			return NodeClarify, nil
		}
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
	// 计划校验（确定性兜底，不信任 LLM 自觉）：必填参数为空/占位文字的步骤
	// 视为缺信息——校名缺失且无校名槽位 → Clarify 向用户追问，其余此类步骤丢弃。
	// 背景：session 59 实证 planner 会把参数描述 echo 成值（school_name="学校名称"）。
	steps, clarifyField := validatePlan(specs, steps, s)
	if clarifyField != "" {
		if _, ok := s.Slots[clarifyField]; !ok {
			s.NeedClarifyField = clarifyField
			return NodeClarify, nil
		}
	}
	s.Plan = steps
	if len(steps) == 0 {
		return NodeSynthesizer, nil
	}
	return NodeExecutor, nil
}

// validatePlan 校验步骤必填参数（依据 ToolSpec JSON Schema 的 required 列表）。
// 无 schema 的工具（如测试桩）不校验。返回存活步骤与需追问的槽位名。
func validatePlan(specs []agent.ToolSpec, steps []agent.Step, s *agent.State) ([]agent.Step, string) {
	requiredByTool := make(map[string][]string, len(specs))
	for _, sp := range specs {
		raw, ok := sp.ParametersJSON["required"]
		if !ok {
			continue
		}
		arr, ok := raw.([]any)
		if !ok {
			continue
		}
		req := make([]string, 0, len(arr))
		for _, item := range arr {
			if str, ok := item.(string); ok {
				req = append(req, str)
			}
		}
		requiredByTool[sp.Name] = req
	}
	if len(requiredByTool) == 0 {
		return steps, ""
	}

	clarifyField := ""
	kept := make([]agent.Step, 0, len(steps))
	for _, st := range steps {
		drop := false
		for _, k := range requiredByTool[st.ToolName] {
			v, _ := st.Args[k].(string)
			if !isPlaceholderArg(v) {
				// 非占位但槽位无校名：校名必须与用户消息/历史有依据，
				// 防 planner 凭空编造真实校名（session 60 实证：填了「上海市实验学校」）
				if (k == "school_name" || k == "school_names") && !slotHasSchool(s) && !schoolArgGrounded(v, s) {
					clarifyField = "school_names"
					drop = true
				}
				continue
			}
			if (k == "school_name" || k == "school_names") && !slotHasSchool(s) {
				clarifyField = "school_names"
			}
			drop = true
		}
		if !drop {
			kept = append(kept, st)
		}
	}
	return kept, clarifyField
}

// schoolGenericWords 校名中的通用词（去掉后剩下的才是可判依据的核心字）
var schoolGenericWords = []string{
	"上海市", "上海", "师范", "大学", "附属", "高级", "中学", "高中",
	"校区", "分校", "实验", "学校", "（", "）", "(", ")", " ",
}

// schoolArgGrounded planner 给出的校名是否有用户依据：
// 去通用词后的核心字，任意连续 2 字出现在本轮消息或最近历史即算有依据
// （planner 可能把「华二」标准化成全称，故不能要求全名子串命中；
// 反之编造的校名核心字几乎不可能撞上用户原话）。
func schoolArgGrounded(name string, s *agent.State) bool {
	core := name
	for _, w := range schoolGenericWords {
		core = strings.ReplaceAll(core, w, "")
	}
	runes := []rune(core)
	if len(runes) < 2 {
		// 核心字不足 2（如纯「实验学校」类），无法建立依据，交由 Clarify
		return false
	}
	text := s.UserMessage
	history := s.Messages
	if len(history) > 8 {
		history = history[len(history)-8:]
	}
	for _, m := range history {
		text += m.Content
	}
	for i := 0; i+2 <= len(runes); i++ {
		if strings.Contains(text, string(runes[i:i+2])) {
			return true
		}
	}
	return false
}

// isPlaceholderArg 参数值是否为空/占位文字（LLM 可能把 schema 描述 echo 成值）
func isPlaceholderArg(v string) bool {
	v = strings.TrimSpace(v)
	if v == "" {
		return true
	}
	if strings.Contains(v, "支持简称") || strings.Contains(v, "支持全称") {
		return true
	}
	return placeholderArgRe.MatchString(v)
}

var placeholderArgRe = regexp.MustCompile(`^(学校名称|高中名称|学校名|校名|某所高中|一所高中|批次|年份|区县|区名|初中名称|XX|xx|待定|未知|…|\.{3})$`)

// slotHasSchool 槽位里是否已有可用校名（HITL 回答回填或 Router 抽取）
func slotHasSchool(s *agent.State) bool {
	if arr, ok := s.Slots["school_names"].([]any); ok && len(arr) > 0 {
		return true
	}
	for _, k := range []string{"school_names", "school_name"} {
		if v, ok := s.Slots[k].(string); ok && strings.TrimSpace(v) != "" {
			return true
		}
	}
	return false
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
	question, options := tpl.Question, tpl.Options

	// school_names：选项按考生所在区动态取（区内头部校）；区未知则无选项、纯输入
	if s.NeedClarifyField == "school_names" {
		if district := slotString(s.Slots, "district_name"); district != "" {
			if names := g.schoolOptionsByDistrict(ctx, s, district); len(names) > 0 {
				options = names
				question = fmt.Sprintf("你想了解哪所高中？%s的热门高中如下，也可以直接说校名：", strings.TrimSuffix(district, "区"))
			}
		}
	}

	s.PendingQ = &agent.PendingQuestion{
		Question: question,
		Field:    s.NeedClarifyField,
		Options:  options,
	}
	s.Reply = question
	return NodeEnd, nil
}

// schoolOptionsByDistrict 从槽位解析 district_id（前端 context 下来源）辅助查询
func (g *Graph) schoolOptionsByDistrict(ctx context.Context, s *agent.State, districtName string) []string {
	if g.ClarifyOptions == nil {
		return nil
	}
	names, err := g.ClarifyOptions.TopSchoolNamesByDistrict(ctx, slotInt32(s.Slots, "district_id"), districtName, 7)
	if err != nil {
		logger.Warn(ctx, "clarify school options by district failed: "+err.Error())
		return nil
	}
	return names
}

// slotString 读字符串槽位（容错空值）
func slotString(slots map[string]any, key string) string {
	v, _ := slots[key].(string)
	return v
}

// slotInt32 读整型槽位（JSON 反序列化后数字为 float64，兼容 int/int64）
func slotInt32(slots map[string]any, key string) int32 {
	switch n := slots[key].(type) {
	case float64:
		return int32(n)
	case int:
		return int32(n)
	case int64:
		return int32(n)
	}
	return 0
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
		g.appendTrace(ctx, &agent.TraceRecord{
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
	g.appendTrace(ctx, &agent.TraceRecord{
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
	g.appendTrace(ctx, &agent.TraceRecord{
		SessionID: s.SessionID, Kind: "node", Name: "reflection_check", Output: outJSON,
	})
}

// appendTrace 落库一条 LLM/工具/节点留痕。
// 写入失败仅告警（带 session_id/kind/name），不阻断 agent 主流程——
// trace 是可观测旁路，其失败不应影响用户对话。
func (g *Graph) appendTrace(ctx context.Context, rec *agent.TraceRecord) {
	if g.Store == nil {
		return
	}
	if _, err := g.Store.AppendTrace(ctx, rec); err != nil {
		logger.Warn(ctx, "agent trace persist failed",
			logger.Int64("session_id", rec.SessionID),
			logger.String("kind", rec.Kind),
			logger.String("name", rec.Name),
			logger.ErrorField(err),
		)
	}
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
