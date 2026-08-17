// tools/tools_test.go - 参数校验与 JSON 组装单测（repository 用手写 fake，不连库）
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"testing"
	"time"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

// ---------- fake repository ----------

type fakeRepo struct {
	school         *repository.SchoolRef
	schoolErr      error
	district       *repository.DistrictRef
	middle         *repository.MiddleSchoolRef
	trend          []repository.ScoreTrendRow
	profile        *repository.SchoolProfileRow
	msProfile      *repository.MiddleSchoolProfileRow
	quotaTrend     []repository.QuotaTrendRow
	districtPlan   []repository.QuotaDistrictRow
	schoolPlan     []repository.QuotaSchoolRow
	controlScores  []repository.ControlScoreRow
	located        []repository.LocatedSchoolRow
	lastLocateArgs struct {
		districtID int32
		batch      string
		score      float64
	}
	lastTrendArgs struct {
		schoolID   int32
		batch      string
		districtID int32
		minYear    int
	}
}

func (f *fakeRepo) FindDistrictByName(ctx context.Context, name string) (*repository.DistrictRef, error) {
	if f.district != nil {
		return f.district, nil
	}
	return &repository.DistrictRef{ID: 12, Name: "浦东新区"}, nil
}

// TopSchoolNamesByDistrict Clarify 动态选项数据源（工具测试不涉及，桩实现）
func (f *fakeRepo) TopSchoolNamesByDistrict(ctx context.Context, districtID int32, districtName string, limit int) ([]string, error) {
	return nil, nil
}

func (f *fakeRepo) FindSchoolByName(ctx context.Context, name string, districtID int32) (*repository.SchoolRef, error) {
	if f.schoolErr != nil {
		return nil, f.schoolErr
	}
	if f.school != nil {
		return f.school, nil
	}
	return &repository.SchoolRef{ID: 101, Code: "101001", FullName: "示例中学", ShortName: "示例", DistrictID: 12, DistrictName: "浦东新区"}, nil
}

func (f *fakeRepo) SearchSchools(ctx context.Context, keyword string, districtID int32, limit int) ([]repository.SchoolRef, error) {
	return []repository.SchoolRef{
		{ID: 101, Code: "101001", FullName: "示例中学", ShortName: "示例", DistrictID: 12, DistrictName: "浦东新区"},
	}, nil
}

func (f *fakeRepo) FindMiddleSchoolByName(ctx context.Context, name string, districtID int32) (*repository.MiddleSchoolRef, error) {
	if f.middle != nil {
		return f.middle, nil
	}
	return &repository.MiddleSchoolRef{ID: 201, Name: "示例初级中学", DistrictID: 12, DistrictName: "浦东新区"}, nil
}

func (f *fakeRepo) GetScoreTrend(ctx context.Context, schoolID int32, batch string, districtID int32, minYear int) ([]repository.ScoreTrendRow, error) {
	f.lastTrendArgs.schoolID = schoolID
	f.lastTrendArgs.batch = batch
	f.lastTrendArgs.districtID = districtID
	f.lastTrendArgs.minYear = minYear
	var out []repository.ScoreTrendRow
	for _, t := range f.trend {
		if batch != "" && t.Batch != batch {
			continue
		}
		out = append(out, t)
	}
	return out, nil
}

func (f *fakeRepo) GetQuotaSchoolScoresByMiddle(ctx context.Context, middleSchoolName string, districtID int32, highSchoolID int32, minYear int) ([]repository.ScoreTrendRow, error) {
	return f.trend, nil
}

func (f *fakeRepo) GetSchoolProfile(ctx context.Context, schoolID int32) (*repository.SchoolProfileRow, error) {
	if f.profile != nil {
		return f.profile, nil
	}
	return &repository.SchoolProfileRow{SchoolID: schoolID, Code: "101001", FullName: "示例中学", DistrictName: "浦东新区"}, nil
}

func (f *fakeRepo) GetMiddleSchoolProfile(ctx context.Context, middleSchoolID int32) (*repository.MiddleSchoolProfileRow, error) {
	if f.msProfile != nil {
		return f.msProfile, nil
	}
	return &repository.MiddleSchoolProfileRow{MiddleSchoolID: middleSchoolID, Name: "示例初级中学", DistrictName: "浦东新区"}, nil
}

func (f *fakeRepo) GetQuotaTrend(ctx context.Context, schoolID int32, batch string, districtID int32, minYear int) ([]repository.QuotaTrendRow, error) {
	return f.quotaTrend, nil
}

func (f *fakeRepo) GetDistrictQuotaPlan(ctx context.Context, schoolID int32, districtID int32, year int) ([]repository.QuotaDistrictRow, error) {
	return f.districtPlan, nil
}

func (f *fakeRepo) GetSchoolQuotaPlan(ctx context.Context, highSchoolID int32, districtID int32, middleSchoolName string, year int) ([]repository.QuotaSchoolRow, error) {
	return f.schoolPlan, nil
}

func (f *fakeRepo) GetControlScores(ctx context.Context, year int) ([]repository.ControlScoreRow, error) {
	return f.controlScores, nil
}

func (f *fakeRepo) LocateByScore(ctx context.Context, districtID int32, batch string, score float64) ([]repository.LocatedSchoolRow, error) {
	f.lastLocateArgs.districtID = districtID
	f.lastLocateArgs.batch = batch
	f.lastLocateArgs.score = score
	return f.located, nil
}

// ---------- 辅助 ----------

func f64(v float64) *float64 { return &v }
func i32(v int32) *int32     { return &v }

func mustExecute(t *testing.T, tool agent.Tool, args string) *agent.ToolResult {
	t.Helper()
	res, err := tool.Execute(context.Background(), json.RawMessage(args))
	if err != nil {
		t.Fatalf("Execute 失败: %v", err)
	}
	return res
}

func expectErr(t *testing.T, tool agent.Tool, args string, wantSubstr string) {
	t.Helper()
	_, err := tool.Execute(context.Background(), json.RawMessage(args))
	if err == nil {
		t.Fatalf("期望报错（含 %q），实际成功", wantSubstr)
	}
	if !strings.Contains(err.Error(), wantSubstr) {
		t.Fatalf("错误信息 %q 不含 %q", err.Error(), wantSubstr)
	}
}

func decodeForLLM(t *testing.T, res *agent.ToolResult) map[string]any {
	t.Helper()
	var m map[string]any
	if err := json.Unmarshal([]byte(res.ForLLM), &m); err != nil {
		t.Fatalf("ForLLM 非合法 JSON: %v\n%s", err, res.ForLLM)
	}
	return m
}

// ---------- get_admission_scores ----------

func TestGetAdmissionScores_MissingSchoolName(t *testing.T) {
	tool := NewGetAdmissionScoresTool(&fakeRepo{})
	expectErr(t, tool, `{"batch":"UNIFIED_1_15"}`, "school_name")
}

func TestGetAdmissionScores_InvalidBatch(t *testing.T) {
	tool := NewGetAdmissionScoresTool(&fakeRepo{})
	expectErr(t, tool, `{"school_name":"示例","batch":"PARALLEL"}`, "非法批次")
}

func TestGetAdmissionScores_JSONAndScale(t *testing.T) {
	repo := &fakeRepo{trend: []repository.ScoreTrendRow{
		{Batch: BatchUnified, Year: 2022, DistrictID: 12, SchoolName: "示例中学", MinScore: 700},
		{Batch: BatchUnified, Year: 2025, DistrictID: 12, SchoolName: "示例中学", MinScore: 705, YoyChange: f64(5)},
		{Batch: BatchUnified, Year: 2026, DistrictID: 12, SchoolName: "示例中学", MinScore: 702, YoyChange: f64(-3)},
		{Batch: BatchQuotaDistrict, Year: 2026, DistrictID: 12, SchoolName: "示例中学", MinScore: 760, YoyChange: f64(2), MathScore: f64(140)},
	}}
	tool := NewGetAdmissionScoresTool(repo)
	res := mustExecute(t, tool, `{"school_name":"示例"}`)

	out := decodeForLLM(t, res)
	if out["data_nature"] != dataNatureOfficial {
		t.Fatalf("data_nature = %v, 期望 official", out["data_nature"])
	}
	records, ok := out["records"].([]any)
	if !ok || len(records) == 0 {
		t.Fatalf("records 为空: %v", out["records"])
	}
	// 默认近三年：2022 应被过滤
	for _, r := range records {
		rec := r.(map[string]any)
		if rec["year"].(float64) == 2022 {
			t.Fatalf("默认近三年不应包含 2022 年记录: %v", rec)
		}
		scale := rec["score_scale"].(float64)
		switch rec["batch"] {
		case BatchUnified:
			if scale != 750 {
				t.Fatalf("UNIFIED_1_15 分制应为 750，实际 %v", scale)
			}
		case BatchQuotaDistrict:
			if scale != 800 {
				t.Fatalf("QUOTA_DISTRICT 分制应为 800，实际 %v", scale)
			}
		}
	}
	if len(res.Cards) == 0 || res.Cards[0].CardType != "score_trend" {
		t.Fatalf("期望 score_trend 卡片，实际 %+v", res.Cards)
	}
	if res.Summary == "" {
		t.Fatal("Summary 为空")
	}
}

func TestGetAdmissionScores_ExplicitYearPassesMinYear(t *testing.T) {
	repo := &fakeRepo{trend: []repository.ScoreTrendRow{
		{Batch: BatchUnified, Year: 2025, DistrictID: 12, SchoolName: "示例中学", MinScore: 705},
	}}
	tool := NewGetAdmissionScoresTool(repo)
	mustExecute(t, tool, `{"school_name":"示例","year":2025}`)
	if repo.lastTrendArgs.minYear != 2025 {
		t.Fatalf("显式 year 应传给仓储 minYear，实际 %d", repo.lastTrendArgs.minYear)
	}
}

// ---------- locate_score ----------

func TestLocateScore_Validation(t *testing.T) {
	tool := NewLocateScoreTool(&fakeRepo{})
	expectErr(t, tool, `{"score":700,"batch":"UNIFIED_1_15"}`, "district_name")
	expectErr(t, tool, `{"district_name":"浦东","batch":"UNIFIED_1_15"}`, "score")
	expectErr(t, tool, `{"district_name":"浦东","score":700}`, "batch")
	expectErr(t, tool, `{"district_name":"浦东","score":760,"batch":"UNIFIED_1_15"}`, "750")
}

func TestLocateScore_GapAndScale(t *testing.T) {
	repo := &fakeRepo{located: []repository.LocatedSchoolRow{
		{SchoolName: "甲中学", DistrictID: 12, Year: 2026, MinScore: 700, Gap: 5},
		{SchoolName: "乙中学", DistrictID: 12, Year: 2026, MinScore: 690, Gap: 15},
	}}
	tool := NewLocateScoreTool(repo)
	res := mustExecute(t, tool, `{"district_name":"浦东","score":705,"batch":"UNIFIED_1_15"}`)

	if repo.lastLocateArgs.batch != BatchUnified || repo.lastLocateArgs.score != 705 {
		t.Fatalf("仓储参数透传错误: %+v", repo.lastLocateArgs)
	}
	out := decodeForLLM(t, res)
	if out["score_scale"].(float64) != 750 {
		t.Fatalf("UNIFIED_1_15 定位必须标注 750 分制，实际 %v", out["score_scale"])
	}
	schools := out["schools"].([]any)
	first := schools[0].(map[string]any)
	if first["gap"].(float64) != 5 || first["school_name"] != "甲中学" {
		t.Fatalf("gap 排序/计算错误: %v", first)
	}
}

// ---------- get_school_detail ----------

func TestGetSchoolDetail_NotFound(t *testing.T) {
	tool := NewGetSchoolDetailTool(&fakeRepo{schoolErr: repository.ErrNotFound})
	expectErr(t, tool, `{"school_name":"不存在中学"}`, "找不到高中")
}

func TestGetSchoolDetail_JSON(t *testing.T) {
	repo := &fakeRepo{profile: &repository.SchoolProfileRow{
		SchoolID: 101, Code: "101001", FullName: "示例中学", DistrictName: "浦东新区",
		UnifiedYear: i32(2026), UnifiedMinScore: f64(702),
	}}
	tool := NewGetSchoolDetailTool(repo)
	res := mustExecute(t, tool, `{"school_name":"示例"}`)
	out := decodeForLLM(t, res)
	profile := out["profile"].(map[string]any)
	if profile["full_name"] != "示例中学" {
		t.Fatalf("profile.full_name 错误: %v", profile["full_name"])
	}
	latest := profile["unified_score_latest"].(map[string]any)
	if latest["score_scale"].(float64) != 750 || latest["min_score"].(float64) != 702 {
		t.Fatalf("unified 最新线错误: %v", latest)
	}
	if len(res.Cards) == 0 || res.Cards[0].CardType != "profile" {
		t.Fatalf("期望 profile 卡片，实际 %+v", res.Cards)
	}
}

// ---------- get_quota_plan ----------

func TestGetQuotaPlan_RequiresScope(t *testing.T) {
	tool := NewGetQuotaPlanTool(&fakeRepo{})
	expectErr(t, tool, `{}`, "至少提供一个")
}

func TestGetQuotaPlan_JSON(t *testing.T) {
	repo := &fakeRepo{
		districtPlan: []repository.QuotaDistrictRow{
			{Year: 2026, SchoolID: 101, SchoolCode: "101001", SchoolName: "示例中学", DistrictID: 12, DistrictName: "浦东新区", QuotaCount: 30},
		},
		schoolPlan: []repository.QuotaSchoolRow{
			{Year: 2026, DistrictID: 12, DistrictName: "浦东新区", HighSchoolID: 101, HighSchoolName: "示例中学", MiddleSchoolName: "示例初级中学", QuotaCount: 2},
		},
	}
	tool := NewGetQuotaPlanTool(repo)
	res := mustExecute(t, tool, `{"school_name":"示例"}`)
	out := decodeForLLM(t, res)
	if len(out["quota_district_plan"].([]any)) != 1 || len(out["quota_school_plan"].([]any)) != 1 {
		t.Fatalf("两类计划都应返回: %v", out)
	}
}

// ---------- get_middle_school_stats ----------

func TestGetMiddleSchoolStats_DataNature(t *testing.T) {
	repo := &fakeRepo{msProfile: &repository.MiddleSchoolProfileRow{
		MiddleSchoolID: 201, Name: "示例初级中学", DistrictName: "浦东新区",
		Tier: strPtr("一梯队"), ExactStudentCount: i32(300), Score700PlusCount: i32(12),
	}}
	tool := NewGetMiddleSchoolStatsTool(repo)
	res := mustExecute(t, tool, `{"middle_school_name":"示例初级"}`)
	out := decodeForLLM(t, res)
	profile := out["profile"].(map[string]any)
	if profile["tier_data_nature"] != dataNatureFolk {
		t.Fatalf("梯队应为 folk 口径，实际 %v", profile["tier_data_nature"])
	}
	if profile["exact_student_count_data_nature"] != dataNatureOfficial {
		t.Fatalf("准确人数应为 official 口径，实际 %v", profile["exact_student_count_data_nature"])
	}
}

func strPtr(s string) *string { return &s }

// ---------- compare_schools ----------

func TestCompareSchools_MinTwo(t *testing.T) {
	tool := NewCompareSchoolsTool(&fakeRepo{})
	expectErr(t, tool, `{"school_names":["示例"]}`, "至少需要 2 所")
}

func TestCompareSchools_JSON(t *testing.T) {
	tool := NewCompareSchoolsTool(&fakeRepo{})
	res := mustExecute(t, tool, `{"school_names":["示例","示例"]}`)
	out := decodeForLLM(t, res)
	if len(out["schools"].([]any)) != 2 {
		t.Fatalf("应返回 2 所学校画像: %v", out["schools"])
	}
	if len(res.Cards) != 2 || res.Cards[0].CardType != "compare" {
		t.Fatalf("期望 2 张 compare 卡片，实际 %+v", res.Cards)
	}
}

// ---------- get_tie_break_detail ----------

func TestGetTieBreakDetail_LatestYearOnly(t *testing.T) {
	repo := &fakeRepo{trend: []repository.ScoreTrendRow{
		{Batch: BatchQuotaDistrict, Year: 2025, DistrictID: 12, SchoolName: "示例中学", MinScore: 755},
		{Batch: BatchQuotaDistrict, Year: 2026, DistrictID: 12, SchoolName: "示例中学", MinScore: 760, MathScore: f64(141), ChineseMathForeignSum: f64(410)},
	}}
	tool := NewGetTieBreakDetailTool(repo)
	res := mustExecute(t, tool, `{"school_name":"示例","batch":"QUOTA_DISTRICT"}`)
	out := decodeForLLM(t, res)
	records := out["records"].([]any)
	if len(records) != 1 {
		t.Fatalf("应只保留最新年记录，实际 %d 条", len(records))
	}
	rec := records[0].(map[string]any)
	if rec["year"].(float64) != 2026 || rec["math_score"].(float64) != 141 {
		t.Fatalf("小分明细错误: %v", rec)
	}
}

// ---------- registry ----------

type panicTool struct{}

func (panicTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{Name: "panic_tool", Description: "x", ParametersJSON: map[string]any{"type": "object"}}
}
func (panicTool) Execute(ctx context.Context, args json.RawMessage) (*agent.ToolResult, error) {
	panic("boom")
}

type slowTool struct{ d time.Duration }

func (slowTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{Name: "slow_tool", Description: "x", ParametersJSON: map[string]any{"type": "object"}}
}
func (s slowTool) Execute(ctx context.Context, args json.RawMessage) (*agent.ToolResult, error) {
	time.Sleep(s.d)
	return &agent.ToolResult{ForLLM: "{}", Summary: "slow"}, nil
}

func TestRegistry_UnknownTool(t *testing.T) {
	r := NewToolRegistry(0)
	_, err := r.Execute(context.Background(), "no_such_tool", nil)
	if err == nil || !strings.Contains(err.Error(), "未注册") {
		t.Fatalf("期望未注册错误，实际 %v", err)
	}
}

func TestRegistry_PanicProtected(t *testing.T) {
	r := NewToolRegistry(0, panicTool{})
	_, err := r.Execute(context.Background(), "panic_tool", json.RawMessage(`{}`))
	if err == nil || !strings.Contains(err.Error(), "panic") {
		t.Fatalf("期望 panic 被 recover 为错误，实际 %v", err)
	}
}

func TestRegistry_Timeout(t *testing.T) {
	r := NewToolRegistry(50*time.Millisecond, slowTool{d: 200 * time.Millisecond})
	_, err := r.Execute(context.Background(), "slow_tool", json.RawMessage(`{}`))
	if err == nil || !strings.Contains(err.Error(), "超时") {
		t.Fatalf("期望超时错误，实际 %v", err)
	}
}

func TestRegistry_Specs(t *testing.T) {
	r := NewRegistry(&fakeRepo{})
	specs := r.Specs()
	if len(specs) != 12 {
		t.Fatalf("应注册 12 个工具，实际 %d", len(specs))
	}
	for i := 1; i < len(specs); i++ {
		if specs[i-1].Name >= specs[i].Name {
			t.Fatalf("Specs 应按名称排序: %q >= %q", specs[i-1].Name, specs[i].Name)
		}
		if specs[i].Description == "" || specs[i].ParametersJSON["type"] != "object" {
			t.Fatalf("工具 %q spec 不完整: %+v", specs[i].Name, specs[i])
		}
	}
}

// ---------- run_recommendation ----------

type fakeEngine struct {
	resp    *highschoolv1.GetVolunteerRecommendationsResponse
	err     error
	lastReq *highschoolv1.GetVolunteerRecommendationsRequest
}

func (f *fakeEngine) GetVolunteerRecommendations(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest) (*highschoolv1.GetVolunteerRecommendationsResponse, error) {
	f.lastReq = req
	if f.err != nil {
		return nil, f.err
	}
	return f.resp, nil
}

func sampleRecResponse() *highschoolv1.GetVolunteerRecommendationsResponse {
	return &highschoolv1.GetVolunteerRecommendationsResponse{
		Year: 2026,
		QuotaDistrictRecommendations: []*highschoolv1.RecommendedSchool{
			{SchoolId: 101, SchoolName: "甲中学", EstimatedScore: 760, ScoreGap: 5, RecommendationType: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH, Confidence: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_MEDIUM, RecommendationReason: "冲刺", QuotaCount: 3},
		},
		UnifiedRecommendations: []*highschoolv1.RecommendedSchool{
			{SchoolId: 102, SchoolName: "乙中学", EstimatedScore: 700, ScoreGap: 20, RecommendationType: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY, Confidence: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_HIGH, RecommendationReason: "保底"},
		},
		ScoreConversion: &highschoolv1.ScoreConversion{
			OriginalScore: 685, OriginalTotal: 750, ConvertedScore_750: 720, ConvertedScore_800: 765, EstimatedRank: 1200, DistrictExamCount: 20000,
		},
	}
}

func TestRunRecommendation_Validation(t *testing.T) {
	tool := NewRunRecommendationTool(&fakeRepo{}, &fakeEngine{})
	expectErr(t, tool, `{"total_score":685,"exam_type":"一模"}`, "district_name")
	expectErr(t, tool, `{"district_name":"浦东","exam_type":"一模"}`, "total_score")
	expectErr(t, tool, `{"district_name":"浦东","total_score":685}`, "exam_type")
	expectErr(t, tool, `{"district_name":"浦东","total_score":685,"exam_type":"三模"}`, "非法考试类型")
}

func TestRunRecommendation_JSON(t *testing.T) {
	engine := &fakeEngine{resp: sampleRecResponse()}
	tool := NewRunRecommendationTool(&fakeRepo{}, engine)
	res := mustExecute(t, tool, `{"district_name":"浦东","total_score":685,"exam_type":"一模","middle_school_name":"示例初级","has_quota_school_eligibility":true}`)

	// 请求组装：区名→district_id，一模→FIRST_MOCK，初中名→middle_school_id
	req := engine.lastReq
	if req.DistrictId != 12 || req.ExamType != highschoolv1.ExamType_EXAM_TYPE_FIRST_MOCK {
		t.Fatalf("请求组装错误: district=%d exam=%v", req.DistrictId, req.ExamType)
	}
	if req.MiddleSchoolId == nil || *req.MiddleSchoolId != 201 {
		t.Fatalf("初中名应解析为 middle_school_id=201，实际 %v", req.MiddleSchoolId)
	}

	out := decodeForLLM(t, res)
	if out["data_nature"] != dataNatureOfficial {
		t.Fatalf("data_nature 错误: %v", out["data_nature"])
	}
	qd := out["quota_district"].(map[string]any)
	if qd["score_scale"].(float64) != 800 {
		t.Fatalf("到区应为 800 分制: %v", qd["score_scale"])
	}
	school := qd["schools"].([]any)[0].(map[string]any)
	if school["type"] != "冲刺" || school["confidence"] != "中" || school["school_name"] != "甲中学" {
		t.Fatalf("推荐学校字段错误: %v", school)
	}
	un := out["unified"].(map[string]any)
	if un["score_scale"].(float64) != 750 {
		t.Fatalf("平行志愿应为 750 分制: %v", un["score_scale"])
	}
	sc := out["score_conversion"].(map[string]any)
	if sc["converted_score_800"].(float64) != 765 || sc["conversion_data_nature"] != dataNatureEstimated {
		t.Fatalf("分数换算信息错误: %v", sc)
	}
	if len(res.Cards) != 3 {
		t.Fatalf("应给 3 张批次卡片，实际 %d", len(res.Cards))
	}
	for _, c := range res.Cards {
		if c.CardType != "compare" {
			t.Fatalf("卡片类型应为 compare: %+v", c)
		}
	}
}

func TestRunRecommendation_EngineError(t *testing.T) {
	tool := NewRunRecommendationTool(&fakeRepo{}, &fakeEngine{err: errors.New("db down")})
	expectErr(t, tool, `{"district_name":"浦东","total_score":685,"exam_type":"MOCK2"}`, "推荐引擎执行失败")
}

func TestRunRecommendation_MiddleSchoolNotFoundDegrades(t *testing.T) {
	engine := &fakeEngine{resp: sampleRecResponse()}
	// fakeRepo.FindMiddleSchoolByName 默认总能找到，这里换成找不到的 repo
	repo := &fakeRepo{}
	tool := NewRunRecommendationTool(repo, engine)
	res := mustExecute(t, tool, `{"district_name":"浦东","total_score":685,"exam_type":"二模"}`)
	// 未传 middle_school_name：不应设置 MiddleSchoolId
	if engine.lastReq.MiddleSchoolId != nil {
		t.Fatalf("未传初中名时不应带 middle_school_id")
	}
	out := decodeForLLM(t, res)
	if _, ok := out["middle_school_name"]; ok {
		t.Fatalf("未传初中名时 payload 不应含 middle_school_name")
	}
}

// ---------- get_analysis_result ----------

type fakeSimRepo struct {
	record *repository.SimulationHistoryRecord
	err    error
	lastID string
}

func (f *fakeSimRepo) GetByID(ctx context.Context, id string) (*repository.SimulationHistoryRecord, error) {
	f.lastID = id
	if f.err != nil {
		return nil, f.err
	}
	return f.record, nil
}

func sampleSimRecord() *repository.SimulationHistoryRecord {
	diff := -3.5
	return &repository.SimulationHistoryRecord{
		ID: 1515,
		CandidateData: &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{DistrictId: 12, MiddleSchoolId: 201, HasQuotaSchoolEligibility: true},
			Scores:    &highschoolv1.CandidateScores{Total: 705, Chinese: 130, Math: 142, Foreign: 138},
		},
		SimulationResult: &highschoolv1.SimulationResults{
			Predictions: &highschoolv1.RankPrediction{DistrictRank: 1200, DistrictRankRangeLow: 900, DistrictRankRangeHigh: 1500, Percentile: 6.5, Confidence: "中"},
			Probabilities: []*highschoolv1.VolunteerProbability{
				// probability 为 0-100 百分数（与 simulation_history 真实口径一致）
				{Batch: "QUOTA_DISTRICT", SchoolId: 101, SchoolName: "甲中学", Probability: 35, VolunteerIndex: 0, ScoreDiff: &diff},
				{Batch: "UNIFIED_1_15", SchoolId: 102, SchoolName: "乙中学", Probability: 92, VolunteerIndex: 0},
			},
			Strategy: &highschoolv1.StrategyAnalysis{
				Score:       80,
				Suggestions: []string{"建议增加保底校"},
				Warnings:    []string{"平行志愿梯度偏大"},
				Gradient:    &highschoolv1.StrategyGradient{Reach: 1, Target: 0, Safety: 1},
			},
		},
	}
}

func TestGetAnalysisResult_Validation(t *testing.T) {
	tool := NewGetAnalysisResultTool(&fakeSimRepo{})
	expectErr(t, tool, `{}`, "analysis_id")
	expectErr(t, tool, `{"analysis_id":-1}`, "analysis_id")
}

func TestGetAnalysisResult_NotFound(t *testing.T) {
	tool := NewGetAnalysisResultTool(&fakeSimRepo{err: errors.New("record not found")})
	expectErr(t, tool, `{"analysis_id":9999}`, "找不到模拟记录 9999")
}

func TestGetAnalysisResult_JSON(t *testing.T) {
	sim := &fakeSimRepo{record: sampleSimRecord()}
	tool := NewGetAnalysisResultTool(sim)
	res := mustExecute(t, tool, `{"analysis_id":1515}`)

	if sim.lastID != "1515" {
		t.Fatalf("analysis_id 应转字符串传给仓储，实际 %q", sim.lastID)
	}
	out := decodeForLLM(t, res)
	if out["data_nature"] != dataNatureEstimated {
		t.Fatalf("概率为推算口径: %v", out["data_nature"])
	}
	candidate := out["candidate"].(map[string]any)
	if candidate["district_id"].(float64) != 12 {
		t.Fatalf("考生摘要缺区: %v", candidate)
	}
	scores := candidate["scores"].(map[string]any)
	if scores["total"].(float64) != 705 || scores["math"].(float64) != 142 {
		t.Fatalf("考生成绩摘要错误: %v", scores)
	}
	vols := out["volunteers"].([]any)
	if len(vols) != 2 {
		t.Fatalf("应有 2 个志愿概率，实际 %d", len(vols))
	}
	v0 := vols[0].(map[string]any)
	if v0["risk_band"] != "险" || v0["probability_pct"].(float64) != 35 || v0["score_scale"].(float64) != 800 {
		t.Fatalf("概率35分应为 险 + 800 制: %v", v0)
	}
	v1 := vols[1].(map[string]any)
	if v1["risk_band"] != "稳" || v1["score_scale"].(float64) != 750 {
		t.Fatalf("概率92分应为 稳 + 750 制: %v", v1)
	}
	strategy := out["strategy"].(map[string]any)
	if strategy["score"].(float64) != 80 || len(strategy["suggestions"].([]any)) != 1 {
		t.Fatalf("策略分析要点缺失: %v", strategy)
	}
	if len(res.Cards) != 0 {
		t.Fatalf("解读结果不应下发卡片（前端兜底渲染会暴露原始 JSON）: %+v", res.Cards)
	}
}

func TestGetAnalysisResult_NoResultData(t *testing.T) {
	sim := &fakeSimRepo{record: &repository.SimulationHistoryRecord{ID: 1, CandidateData: &highschoolv1.SubmitAnalysisRequest{}}}
	tool := NewGetAnalysisResultTool(sim)
	expectErr(t, tool, `{"analysis_id":1}`, "尚无结果数据")
}

// ---------- NewRegistryWithEngine ----------

func TestNewRegistryWithEngine_Specs(t *testing.T) {
	r := NewRegistryWithEngine(&fakeRepo{}, &fakeEngine{}, &fakeSimRepo{})
	specs := r.Specs()
	if len(specs) != 14 {
		t.Fatalf("应注册 14 个工具，实际 %d", len(specs))
	}
	names := map[string]bool{}
	for _, s := range specs {
		names[s.Name] = true
	}
	if !names["run_recommendation"] || !names["get_analysis_result"] {
		t.Fatalf("引擎型工具未注册: %v", names)
	}
	// NewRegistry 保持 12 个（签名不变）
	if len(NewRegistry(&fakeRepo{}).Specs()) != 12 {
		t.Fatal("NewRegistry 应保持 12 个工具")
	}
}
