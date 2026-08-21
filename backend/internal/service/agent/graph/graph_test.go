package graph

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"testing"

	"highschool-backend/internal/service/agent"
)

// ---------- mocks ----------

type fakeLLM struct {
	responses  map[string]string // 按节点关键字匹配 system prompt
	lastPrompt string            // 最近一次 user prompt（断言 planner/router 输入用）
}

func (f *fakeLLM) Chat(ctx context.Context, p agent.ChatParams) (*agent.ChatResult, error) {
	if len(p.Messages) > 0 {
		f.lastPrompt = p.Messages[len(p.Messages)-1].Content
	}
	for key, resp := range f.responses {
		if strings.Contains(p.Messages[0].Content, key) {
			return &agent.ChatResult{Content: resp, PromptTokens: 10, CompletionTokens: 5}, nil
		}
	}
	return &agent.ChatResult{Content: "默认回答"}, nil
}

type fakeTools struct {
	called []string
}

func (f *fakeTools) Specs() []agent.ToolSpec {
	return []agent.ToolSpec{{Name: "get_admission_scores", Description: "查分数线"}}
}

func (f *fakeTools) Execute(ctx context.Context, name string, args json.RawMessage) (*agent.ToolResult, error) {
	f.called = append(f.called, name)
	return &agent.ToolResult{
		ForLLM:  `{"school":"上海市第二中学","scores":[{"year":2024,"min_score":683.5},{"year":2025,"min_score":682.5},{"year":2026,"min_score":689.5}]}`,
		Summary: "查询近三年分数线",
	}, nil
}

type fakeStore struct {
	checkpoints int
	traces      int
	traceErr    error // 非空时 AppendTrace 返回该错误，验证留痕失败不阻断主流程
}

func (f *fakeStore) CreateSession(ctx context.Context, d string, a *int64) (int64, error) {
	return 1, nil
}
func (f *fakeStore) GetSession(ctx context.Context, id int64) (*agent.Session, error) {
	return &agent.Session{ID: id, DeviceID: "dev"}, nil
}
func (f *fakeStore) UpdateSessionCAS(ctx context.Context, s *agent.Session) error { return nil }
func (f *fakeStore) SaveCheckpoint(ctx context.Context, sid int64, seq int, node string, st *agent.State) (int64, error) {
	f.checkpoints++
	return int64(seq), nil
}
func (f *fakeStore) LatestCheckpoint(ctx context.Context, sid int64) (int, string, *agent.State, error) {
	return 0, "", nil, nil
}
func (f *fakeStore) AppendMessage(ctx context.Context, sid int64, m agent.Message, node string, u *agent.ChatResult) error {
	return nil
}
func (f *fakeStore) ListMessages(ctx context.Context, sid int64, limit int) ([]agent.Message, error) {
	return nil, nil
}
func (f *fakeStore) AppendTrace(ctx context.Context, rec *agent.TraceRecord) (int64, error) {
	f.traces++
	return 1, f.traceErr
}
func (f *fakeStore) CountTodayUserMessages(ctx context.Context, d string) (int, error) { return 0, nil }

// ---------- tests ----------

func newTestState() *agent.State {
	return &agent.State{
		SessionID:   1,
		DeviceID:    "dev",
		Slots:       map[string]any{},
		StepBudget:  12,
		UserMessage: "市二中学近三年平行志愿多少分？",
	}
}

func TestGraph_DataQueryFlow(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"意图识别器": `{"intent":"data_query","confidence":0.95,"slots":{"school_names":["上海市第二中学"],"district_name":"徐汇区","batch":"UNIFIED_1_15"}}`,
		"任务规划器": `{"steps":[{"tool_name":"get_admission_scores","args":{"school_name":"上海市第二中学","district_name":"徐汇区"}}]}`,
		"折桂登高":  "市二中学在徐汇区平行志愿线：2024年683.5、2025年682.5、2026年689.5（750分制）。",
	}}
	tools := &fakeTools{}
	store := &fakeStore{}
	g := NewGraph(llm, tools, store, Config{MaxReplan: 2, StepBudget: 12})

	s, err := g.Run(context.Background(), newTestState())
	if err != nil {
		t.Fatalf("run failed: %v", err)
	}
	if s.Intent != agent.IntentDataQuery {
		t.Fatalf("intent = %s, want data_query", s.Intent)
	}
	if len(tools.called) != 1 || tools.called[0] != "get_admission_scores" {
		t.Fatalf("tools called = %v", tools.called)
	}
	if !strings.Contains(s.Reply, "689.5") {
		t.Fatalf("reply missing score: %s", s.Reply)
	}
	if store.checkpoints == 0 {
		t.Fatal("no checkpoints saved")
	}
	if store.traces == 0 {
		t.Fatal("no traces saved")
	}
}

func TestGraph_OffTopicShortCircuit(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"意图识别器": `{"intent":"off_topic","confidence":0.99,"slots":{}}`,
	}}
	tools := &fakeTools{}
	g := NewGraph(llm, tools, &fakeStore{}, Config{})

	s, _ := g.Run(context.Background(), newTestState())
	if s.Reply != OffTopicReply {
		t.Fatalf("reply = %s", s.Reply)
	}
	if len(tools.called) != 0 {
		t.Fatal("off_topic should not call tools")
	}
}

func TestGraph_ClarifyOnMissingSlot(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"意图识别器": `{"intent":"recommendation","confidence":0.9,"slots":{"total_score":690}}`,
	}}
	g := NewGraph(llm, &fakeTools{}, &fakeStore{}, Config{})
	s, _ := g.Run(context.Background(), newTestState())
	if s.PendingQ == nil {
		t.Fatal("expected PendingQ for missing district slot")
	}
	if s.PendingQ.Field != "district_name" {
		t.Fatalf("pending field = %s, want district_name", s.PendingQ.Field)
	}
	if len(s.PendingQ.Options) != 16 {
		t.Fatalf("district options = %d, want 16", len(s.PendingQ.Options))
	}
}

func TestGraph_ResumeFromClarify(t *testing.T) {
	s := newTestState()
	s.PendingQ = &agent.PendingQuestion{Question: "哪个区？", Field: "district_name", Options: []string{"徐汇区"}}
	s.PendingAnswer = "徐汇区"
	g := NewGraph(&fakeLLM{responses: map[string]string{}}, &fakeTools{}, &fakeStore{}, Config{})
	// resumeFromClarify 在 Run 开头执行；此处直接验证槽位合并逻辑
	g.resumeFromClarify(s)
	if s.PendingQ != nil {
		t.Fatal("PendingQ should be cleared")
	}
	if s.Slots["district_name"] != "徐汇区" {
		t.Fatalf("slot = %v", s.Slots["district_name"])
	}
}

func TestGraph_ReflectionReplanThenDegrade(t *testing.T) {
	// Synthesizer 永远输出幻觉数字 → Reflection 连续拦截 → 超过 MaxReplan 降级
	llm := &fakeLLM{responses: map[string]string{
		"意图识别器": `{"intent":"data_query","confidence":0.9,"slots":{}}`,
		"任务规划器": `{"steps":[{"tool_name":"get_admission_scores","args":{}}]}`,
		"折桂登高":  "这所学校录取线是999.9分。",
	}}
	g := NewGraph(llm, &fakeTools{}, &fakeStore{}, Config{MaxReplan: 2, StepBudget: 20})
	state := newTestState()
	state.StepBudget = 20 // 每次重规划消耗5个节点步，需预算>15
	s, _ := g.Run(context.Background(), state)
	if s.Reply != DegradedReply {
		t.Fatalf("expected degraded reply, got: %s", s.Reply)
	}
	if s.ReplanCount != 3 {
		t.Fatalf("replan count = %d, want 3", s.ReplanCount)
	}
}

// TestRouter_ClearsEphemeralSlotsOnIntentChange 锁定契约（P3 / §4 A1）：
// 意图切换时，易变槽位（如旧意图遗留的 school_name）被清除；持久槽位
// （district_name/total_score）保留；当轮新槽位（school_names）正常合并。
func TestRouter_ClearsEphemeralSlotsOnIntentChange(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"意图识别器": `{"intent":"data_query","confidence":0.9,"slots":{"school_names":["新学校"]}}`,
	}}
	g := NewGraph(llm, &fakeTools{}, nil, Config{}) // nil store: routerNode/callLLM 均有 nil 守卫

	s := &agent.State{
		Intent:      agent.IntentRecommendation, // prior intent
		Slots:       map[string]any{"district_name": "徐汇区", "total_score": 690, "school_name": "旧学校"},
		UserMessage: "新学校多少分",
	}
	if _, err := g.routerNode(context.Background(), s); err != nil {
		t.Fatalf("routerNode failed: %v", err)
	}
	// 易变槽位被清除
	if _, ok := s.Slots["school_name"]; ok {
		t.Fatalf("ephemeral slot school_name should be cleared on intent change, got %v", s.Slots["school_name"])
	}
	// 持久槽位保留
	if s.Slots["district_name"] != "徐汇区" {
		t.Fatalf("persistent slot district_name lost: %v", s.Slots["district_name"])
	}
	if s.Slots["total_score"] != 690 {
		t.Fatalf("persistent slot total_score lost: %v", s.Slots["total_score"])
	}
	// 当轮新槽位合并进来
	names, ok := s.Slots["school_names"].([]any)
	if !ok || len(names) != 1 || names[0] != "新学校" {
		t.Fatalf("new slot school_names not merged: %#v", s.Slots["school_names"])
	}
	// 意图已切换
	if s.Intent != agent.IntentDataQuery {
		t.Fatalf("intent = %s, want data_query", s.Intent)
	}
}

// TestPlanner_NeedClarifySchool 锁定契约：Planner 声明缺 school_names 槽位 →
// 转 Clarify 追问（HITL）；槽位已存在时 need_clarify 被忽略（防误报）。
// 区未知 → 追问无选项（用户自由输入）；区已知 → 选项由 ClarifyOptions 按区动态给出。
func TestPlanner_NeedClarifySchool(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[],"need_clarify":"school_names"}`,
	}}
	g := NewGraph(llm, &fakeTools{}, nil, Config{})

	// ① 槽位缺失且区未知 → Clarify，无选项（不写死热门校）
	s := &agent.State{Intent: agent.IntentDataQuery, UserMessage: "查一所高中的三年分数线走势"}
	next, err := g.plannerNode(context.Background(), s)
	if err != nil {
		t.Fatalf("plannerNode failed: %v", err)
	}
	if next != NodeClarify || s.NeedClarifyField != "school_names" {
		t.Fatalf("next=%s needClarify=%q, want clarify/school_names", next, s.NeedClarifyField)
	}
	if _, err := g.clarifyNode(context.Background(), s); err != nil {
		t.Fatalf("clarifyNode failed: %v", err)
	}
	if s.PendingQ == nil || s.PendingQ.Field != "school_names" {
		t.Fatalf("PendingQ 应为 school_names：%+v", s.PendingQ)
	}
	if len(s.PendingQ.Options) != 0 {
		t.Fatalf("区未知时校名追问不应有选项：%v", s.PendingQ.Options)
	}

	// ② 槽位缺失但区已知（徐汇）→ 选项来自 ClarifyOptions（按区）
	g.ClarifyOptions = fakeClarifyOptions{"徐汇区": []string{"上海中学", "位育中学", "南洋模范"}}
	s2 := &agent.State{
		Intent:      agent.IntentDataQuery,
		Slots:       map[string]any{"district_name": "徐汇区"},
		UserMessage: "查一所高中的三年分数线走势",
	}
	if _, err := g.plannerNode(context.Background(), s2); err != nil {
		t.Fatalf("plannerNode(2) failed: %v", err)
	}
	if _, err := g.clarifyNode(context.Background(), s2); err != nil {
		t.Fatalf("clarifyNode(2) failed: %v", err)
	}
	if s2.PendingQ == nil || len(s2.PendingQ.Options) != 3 || s2.PendingQ.Options[0] != "上海中学" {
		t.Fatalf("区已知时选项应为按区动态候选：%+v", s2.PendingQ)
	}
	if !strings.Contains(s2.PendingQ.Question, "徐汇") {
		t.Fatalf("追问应提及考生所在区：%q", s2.PendingQ.Question)
	}

	// ③ 槽位已在（如 HITL 回答已并入）→ 忽略 need_clarify，按空计划走 Synthesizer
	s3 := &agent.State{
		Intent:      agent.IntentDataQuery,
		Slots:       map[string]any{"school_names": "华二"},
		UserMessage: "华二三年分数线走势",
	}
	next3, err := g.plannerNode(context.Background(), s3)
	if err != nil {
		t.Fatalf("plannerNode(3) failed: %v", err)
	}
	if next3 != NodeSynthesizer {
		t.Fatalf("槽位已存在时 need_clarify 应被忽略：next=%s, want %s", next3, NodeSynthesizer)
	}
}

// fakeClarifyOptions 按区名返回固定候选
type fakeClarifyOptions map[string][]string

func (f fakeClarifyOptions) TopSchoolNamesByDistrict(ctx context.Context, districtID int32, districtName string, limit int) ([]string, error) {
	if names, ok := f[districtName]; ok {
		return names, nil
	}
	return nil, fmt.Errorf("no district %q", districtName)
}

// schemaTools 带参数 schema 的工具桩（validatePlan 依据 required 列表校验）
type schemaTools struct{ fakeTools }

func (f *schemaTools) Specs() []agent.ToolSpec {
	return []agent.ToolSpec{{
		Name: "get_score_trend", Description: "查趋势",
		ParametersJSON: map[string]any{
			"type":       "object",
			"properties": map[string]any{"school_name": map[string]any{"type": "string"}},
			"required":   []any{"school_name"},
		},
	}}
}

// TestPlanner_PlaceholderArgBecomesClarify 锁定契约（session 59 实证）：
// planner 把参数描述 echo 成值（school_name="学校名称"）时，确定性校验拦截 →
// Clarify 追问校名；真实校名的步骤正常保留。
func TestPlanner_PlaceholderArgBecomesClarify(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{"school_name":"学校名称"}}]}`,
	}}
	g := NewGraph(llm, &schemaTools{}, nil, Config{})

	s := &agent.State{Intent: agent.IntentDataQuery, UserMessage: "查一所高中的三年分数线走势"}
	next, err := g.plannerNode(context.Background(), s)
	if err != nil {
		t.Fatalf("plannerNode failed: %v", err)
	}
	if next != NodeClarify || s.NeedClarifyField != "school_names" {
		t.Fatalf("占位校名应触发 Clarify：next=%s field=%q", next, s.NeedClarifyField)
	}

	// 真实校名 → 步骤保留进入执行
	s2 := &agent.State{Intent: agent.IntentDataQuery, UserMessage: "嘉定一中走势"}
	llm2 := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{"school_name":"嘉定一中"}}]}`,
	}}
	g2 := NewGraph(llm2, &schemaTools{}, nil, Config{})
	next2, err := g2.plannerNode(context.Background(), s2)
	if err != nil {
		t.Fatalf("plannerNode(2) failed: %v", err)
	}
	if next2 != NodeExecutor || len(s2.Plan) != 1 {
		t.Fatalf("真实校名的步骤应保留：next=%s plan=%+v", next2, s2.Plan)
	}
}

// TestGraph_FullFlow_PlaceholderSchoolClarifies 复刻线上 session 59 的失败链：
// router 正确空槽位 + planner 把参数描述 echo 成值（school_name="学校名称"）→
// 确定性校验拦截 → 用户收到友好的校名追问，而非暴露「必填参数 batch」等内部术语。
func TestGraph_FullFlow_PlaceholderSchoolClarifies(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"意图识别器": `{"intent":"data_query","confidence":0.95,"slots":{},"reason":"未指明具体高中"}`,
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{"school_name":"学校名称"}}]}`,
	}}
	g := NewGraph(llm, &schemaTools{}, &fakeStore{}, Config{})
	s := newTestState()
	s.UserMessage = "查一所高中的三年分数线走势"
	s.Intent = agent.IntentDataQuery

	got, err := g.Run(context.Background(), s)
	if err != nil {
		t.Fatalf("Run failed: %v", err)
	}
	if got.PendingQ == nil || got.PendingQ.Field != "school_names" {
		t.Fatalf("应以校名追问收尾：%+v", got.PendingQ)
	}
	for _, banned := range []string{"参数", "batch", "工具", "槽位"} {
		if strings.Contains(got.Reply, banned) {
			t.Fatalf("回复不得暴露内部术语 %q：%s", banned, got.Reply)
		}
	}
	if want := ClarifyQuestions["school_names"].Question; got.Reply != want {
		t.Fatalf("回复应为校名追问模板：got %q want %q", got.Reply, want)
	}
}

// TestPlanner_FabricatedSchoolBecomesClarify 锁定契约（session 60 实证）：
// 消息无校名时，planner 凭空编造真实校名（「上海市实验学校」）→ 依据校验拦截 → Clarify；
// 消息确有校名（planner 仅做标准化）→ 放行执行。
func TestPlanner_FabricatedSchoolBecomesClarify(t *testing.T) {
	// ① 编造校名：消息是通用趋势问题，无任何校名依据
	llm := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{"school_name":"上海市实验学校"}}]}`,
	}}
	g := NewGraph(llm, &schemaTools{}, nil, Config{})
	s := &agent.State{Intent: agent.IntentDataQuery, UserMessage: "查一所高中的三年分数线走势"}
	next, err := g.plannerNode(context.Background(), s)
	if err != nil {
		t.Fatalf("plannerNode failed: %v", err)
	}
	if next != NodeClarify || s.NeedClarifyField != "school_names" {
		t.Fatalf("编造校名应触发 Clarify：next=%s field=%q", next, s.NeedClarifyField)
	}

	// ② 有依据：用户消息含「格致」，planner 标准化出全称（含括号校区）→ 放行
	llm2 := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{"school_name":"格致中学（奉贤校区）"}}]}`,
	}}
	g2 := NewGraph(llm2, &schemaTools{}, nil, Config{})
	s2 := &agent.State{Intent: agent.IntentDataQuery, UserMessage: "格致中学（奉贤校区）三年分数线走势"}
	next2, err := g2.plannerNode(context.Background(), s2)
	if err != nil {
		t.Fatalf("plannerNode(2) failed: %v", err)
	}
	if next2 != NodeExecutor || len(s2.Plan) != 1 {
		t.Fatalf("有依据的校名应放行执行：next=%s plan=%+v", next2, s2.Plan)
	}

	// ③ 有依据（简称在历史里）：本轮用「它」，上轮说过「嘉定一中」→ 放行
	llm3 := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{"school_name":"嘉定一中"}}]}`,
	}}
	g3 := NewGraph(llm3, &schemaTools{}, nil, Config{})
	s3 := &agent.State{
		Intent:      agent.IntentDataQuery,
		UserMessage: "它近三年走势呢",
		Messages:    []agent.Message{{Role: agent.RoleUser, Content: "嘉定一中分数线"}, {Role: agent.RoleAssistant, Content: "…"}},
	}
	next3, err := g3.plannerNode(context.Background(), s3)
	if err != nil {
		t.Fatalf("plannerNode(3) failed: %v", err)
	}
	if next3 != NodeExecutor || len(s3.Plan) != 1 {
		t.Fatalf("历史有依据的校名应放行：next=%s plan=%+v", next3, s3.Plan)
	}
}

// TestResume_TaskContextRestored 任务连续性（系统性修复①）：
// HITL 恢复轮 UserMessage 只是「嘉定一中」，resumeFromClarify 应从历史
// 找回原始诉求「三年分数线走势」并写入 TaskContext，供 Planner 选对工具。
func TestResume_TaskContextRestored(t *testing.T) {
	g := NewGraph(&fakeLLM{responses: map[string]string{}}, &fakeTools{}, &fakeStore{}, Config{})
	s := &agent.State{
		UserMessage: "嘉定一中",
		PendingQ:    &agent.PendingQuestion{Question: "哪所高中？", Field: "school_names"},
		Messages: []agent.Message{
			{Role: agent.RoleUser, Content: "查一所高中的三年分数线走势"},
			{Role: agent.RoleAssistant, Content: "你想了解哪所高中？"},
			{Role: agent.RoleUser, Content: "嘉定一中"},
		},
	}
	g.resumeFromClarify(s)
	if s.Slots["school_names"] != "嘉定一中" {
		t.Fatalf("槽位应并入回答：%v", s.Slots["school_names"])
	}
	if s.TaskContext != "查一所高中的三年分数线走势" {
		t.Fatalf("TaskContext 应为追问前的原始诉求：%q", s.TaskContext)
	}
}

// TestPlanner_PayloadCarriesTaskAndHistory Planner 输入应携带 task（原始诉求）与最近历史，
// 恢复轮才不至于只对着「嘉定一中」选错工具。
func TestPlanner_PayloadCarriesTaskAndHistory(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{"任务规划器": `{"steps":[]}`}}
	g := NewGraph(llm, &fakeTools{}, nil, Config{})
	s := &agent.State{
		Intent:      agent.IntentDataQuery,
		UserMessage: "嘉定一中",
		TaskContext: "查一所高中的三年分数线走势",
		Messages: []agent.Message{
			{Role: agent.RoleUser, Content: "查一所高中的三年分数线走势"},
			{Role: agent.RoleAssistant, Content: "你想了解哪所高中？"},
			{Role: agent.RoleUser, Content: "嘉定一中"},
		},
	}
	if _, err := g.plannerNode(context.Background(), s); err != nil {
		t.Fatalf("plannerNode failed: %v", err)
	}
	if !strings.Contains(llm.lastPrompt, "三年分数线走势") || !strings.Contains(llm.lastPrompt, "task") {
		t.Fatalf("planner 输入应含原始诉求(task)：%s", llm.lastPrompt)
	}
}

// TestPlanner_InjectsSlotArgs 参数确定性注入（系统性修复②）：
// 槽位已有校名时，planner 输出空 args/占位值 → 代码从 Slots 注入，步骤保留执行。
// 参数组装不再依赖 LLM 自觉（session 59/60 占位与编造的整类根因）。
func TestPlanner_InjectsSlotArgs(t *testing.T) {
	// ① 槽位为字符串（HITL 回答回填形态）+ planner 空 args
	llm := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{}}]}`,
	}}
	g := NewGraph(llm, &schemaTools{}, nil, Config{})
	s := &agent.State{
		Intent:      agent.IntentDataQuery,
		UserMessage: "嘉定一中",
		Slots:       map[string]any{"school_names": "嘉定一中"},
	}
	next, err := g.plannerNode(context.Background(), s)
	if err != nil {
		t.Fatalf("plannerNode failed: %v", err)
	}
	if next != NodeExecutor || len(s.Plan) != 1 || s.Plan[0].Args["school_name"] != "嘉定一中" {
		t.Fatalf("空 args 应由槽位注入 school_name：next=%s plan=%+v", next, s.Plan)
	}

	// ② 槽位为列表（Router 抽取形态）+ planner 占位值 → 同样被注入替换
	llm2 := &fakeLLM{responses: map[string]string{
		"任务规划器": `{"steps":[{"tool_name":"get_score_trend","args":{"school_name":"学校名称"}}]}`,
	}}
	g2 := NewGraph(llm2, &schemaTools{}, nil, Config{})
	s2 := &agent.State{
		Intent:      agent.IntentDataQuery,
		UserMessage: "走势",
		Slots:       map[string]any{"school_names": []any{"上海市嘉定区第一中学"}},
	}
	next2, err := g2.plannerNode(context.Background(), s2)
	if err != nil {
		t.Fatalf("plannerNode(2) failed: %v", err)
	}
	if next2 != NodeExecutor || s2.Plan[0].Args["school_name"] != "上海市嘉定区第一中学" {
		t.Fatalf("占位值应被槽位注入替换：next=%s args=%+v", next2, s2.Plan[0].Args)
	}
}

// TestGraph_TracePersistErrorDoesNotBreakTurn 锁定契约：trace 落库失败（DB 抖动）
// 必须仅告警，不得中断用户对话、不得返回 error。
func TestGraph_TracePersistErrorDoesNotBreakTurn(t *testing.T) {
	llm := &fakeLLM{responses: map[string]string{
		"意图识别器": `{"intent":"data_query","confidence":0.95,"slots":{"school_names":["上海市第二中学"],"district_name":"徐汇区","batch":"UNIFIED_1_15"}}`,
		"任务规划器": `{"steps":[{"tool_name":"get_admission_scores","args":{"school_name":"上海市第二中学","district_name":"徐汇区"}}]}`,
		"折桂登高":  "市二中学在徐汇区平行志愿线：2026年689.5（750分制）。",
	}}
	store := &fakeStore{traceErr: errors.New("db connection refused")}
	g := NewGraph(llm, &fakeTools{}, store, Config{MaxReplan: 2, StepBudget: 12})

	s, err := g.Run(context.Background(), newTestState())
	if err != nil {
		t.Fatalf("trace persist failure must not break the turn: %v", err)
	}
	if !strings.Contains(s.Reply, "689.5") {
		t.Fatalf("reply should still be produced: %s", s.Reply)
	}
	if store.traces == 0 {
		t.Fatal("AppendTrace should still be invoked (and fail loudly) despite db errors")
	}
}
