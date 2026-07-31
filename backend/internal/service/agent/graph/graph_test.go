package graph

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	"highschool-backend/internal/service/agent"
)

// ---------- mocks ----------

type fakeLLM struct {
	responses map[string]string // 按节点关键字匹配 system prompt
}

func (f *fakeLLM) Chat(ctx context.Context, p agent.ChatParams) (*agent.ChatResult, error) {
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
}

func (f *fakeStore) CreateSession(ctx context.Context, d string, a *int64) (int64, error) { return 1, nil }
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
	return 1, nil
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
		"任务规划器":  `{"steps":[{"tool_name":"get_admission_scores","args":{"school_name":"上海市第二中学","district_name":"徐汇区"}}]}`,
		"折桂登高": "市二中学在徐汇区平行志愿线：2024年683.5、2025年682.5、2026年689.5（750分制）。",
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
		"任务规划器":  `{"steps":[{"tool_name":"get_admission_scores","args":{}}]}`,
		"折桂登高": "这所学校录取线是999.9分。",
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
