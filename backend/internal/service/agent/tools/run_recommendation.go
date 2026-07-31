// tools/run_recommendation.go - 志愿填报推荐引擎（P2 引擎型）
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

// RecommendationEngine 推荐引擎抽象，service.NewRecommendationService() 天然满足
type RecommendationEngine interface {
	GetVolunteerRecommendations(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest) (*highschoolv1.GetVolunteerRecommendationsResponse, error)
}

type runRecommendationTool struct {
	repo   repository.AgentDataRepository
	engine RecommendationEngine
}

// NewRunRecommendationTool 三批次志愿推荐
func NewRunRecommendationTool(repo repository.AgentDataRepository, engine RecommendationEngine) agent.Tool {
	return &runRecommendationTool{repo: repo, engine: engine}
}

type runRecommendationArgs struct {
	DistrictName              string  `json:"district_name"`
	TotalScore                float64 `json:"total_score"`
	ExamType                  string  `json:"exam_type"`
	MiddleSchoolName          string  `json:"middle_school_name"`
	HasQuotaSchoolEligibility *bool   `json:"has_quota_school_eligibility"`
}

func (t *runRecommendationTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "run_recommendation",
		Description: "运行三批次志愿填报推荐引擎（名额到区/到校/1-15平行志愿），返回冲稳保推荐学校列表与分数换算。" +
			"前置槽位：district（区）、total_score（一模/二模总分）、exam_type（一模/二模），缺一先向用户补问再调用；" +
			"用户提供了初中时传 middle_school_name 以获得名额到校推荐。" +
			"例：「我浦东一模 685 能报什么」「帮我推荐志愿」。只需查历史分数线用 get_admission_scores/locate_score，不要调本工具。",
		ParametersJSON: jsonSchema(map[string]any{
			"district_name": strProp("考生所在区，如「浦东新区」「徐汇」（必填槽位 district）"),
			"total_score": map[string]any{
				"type":        "number",
				"description": "一模/二模总分（原始分，引擎会自动换算为中考 750/800 分制）",
			},
			"exam_type": map[string]any{
				"type":        "string",
				"enum":        []string{"一模", "二模", "MOCK1", "MOCK2"},
				"description": "考试类型：一模=MOCK1，二模=MOCK2",
			},
			"middle_school_name": strProp("可选，考生初中名称。传了才有名额到校推荐"),
			"has_quota_school_eligibility": map[string]any{
				"type":        "boolean",
				"description": "可选，是否有名额到校资格（不选择生源初中在籍在读满三年）",
			},
		}, []string{"district_name", "total_score", "exam_type"}),
	}
}

// parseExamType 考试类型归一化：一模/MOCK1/EXAM_TYPE_FIRST_MOCK → FIRST_MOCK，二模同理
func parseExamType(s string) (highschoolv1.ExamType, error) {
	switch strings.ToUpper(strings.TrimSpace(s)) {
	case "一模", "MOCK1", "FIRST_MOCK", "EXAM_TYPE_FIRST_MOCK":
		return highschoolv1.ExamType_EXAM_TYPE_FIRST_MOCK, nil
	case "二模", "MOCK2", "SECOND_MOCK", "EXAM_TYPE_SECOND_MOCK":
		return highschoolv1.ExamType_EXAM_TYPE_SECOND_MOCK, nil
	}
	return highschoolv1.ExamType_EXAM_TYPE_UNSPECIFIED, fmt.Errorf("非法考试类型 %q，可选: 一模/二模（或 MOCK1/MOCK2）", s)
}

var recTypeNames = map[highschoolv1.RecommendationType]string{
	highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH:  "冲刺",
	highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET: "稳妥",
	highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY: "保底",
}

var recConfidenceNames = map[highschoolv1.RecommendationConfidence]string{
	highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_HIGH:   "高",
	highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_MEDIUM: "中",
	highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_LOW:    "低",
}

// recommendedSchoolJSON 推荐学校 → 紧凑 JSON
func recommendedSchoolJSON(s *highschoolv1.RecommendedSchool) map[string]any {
	return map[string]any{
		"school_id":       s.SchoolId,
		"school_name":     s.SchoolName,
		"estimated_score": s.EstimatedScore,
		"score_gap":       s.ScoreGap,
		"type":            recTypeNames[s.RecommendationType],
		"reason":          s.RecommendationReason,
		"confidence":      recConfidenceNames[s.Confidence],
		"quota_count":     s.QuotaCount,
	}
}

// batchSection 一个批次的推荐列表（含分制标注与卡片）
func batchSection(recs []*highschoolv1.RecommendedSchool, batch string, scale int) (map[string]any, agent.SchoolCard) {
	items := make([]map[string]any, 0, len(recs))
	for _, s := range recs {
		items = append(items, recommendedSchoolJSON(s))
	}
	section := map[string]any{
		"score_scale": scale,
		"count":       len(items),
		"schools":     items,
	}
	card := agent.SchoolCard{
		SchoolID:   0,
		SchoolName: batchLabel(batch),
		CardType:   "compare",
		Payload:    map[string]any{"batch": batch, "score_scale": scale, "schools": items},
	}
	return section, card
}

func batchLabel(batch string) string {
	switch batch {
	case BatchQuotaDistrict:
		return "名额到区推荐"
	case BatchQuotaSchool:
		return "名额到校推荐"
	default:
		return "1-15 平行志愿推荐"
	}
}

func (t *runRecommendationTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args runRecommendationArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	if _, err := trimRequired(args.DistrictName, "district_name"); err != nil {
		return nil, err
	}
	if args.TotalScore <= 0 {
		return nil, fmt.Errorf("缺少必填参数 \"total_score\" 或分数非法（需为正数），请先向用户确认一模/二模总分")
	}
	if _, err := trimRequired(args.ExamType, "exam_type"); err != nil {
		return nil, err
	}
	examType, err := parseExamType(args.ExamType)
	if err != nil {
		return nil, err
	}
	districtID, districtName, err := resolveDistrict(ctx, t.repo, args.DistrictName)
	if err != nil {
		return nil, err
	}

	req := &highschoolv1.GetVolunteerRecommendationsRequest{
		DistrictId: districtID,
		ExamType:   examType,
		TotalScore: float32(args.TotalScore),
	}
	if args.HasQuotaSchoolEligibility != nil {
		req.HasQuotaSchoolEligibility = *args.HasQuotaSchoolEligibility
	}

	// 初中（名额到校）：限定本区内匹配，找不到不阻断，降级为无到校推荐
	if name := strings.TrimSpace(args.MiddleSchoolName); name != "" {
		ms, err := t.repo.FindMiddleSchoolByName(ctx, name, districtID)
		if err != nil {
			if !errors.Is(err, repository.ErrNotFound) {
				return nil, err
			}
		} else {
			id := ms.ID
			req.MiddleSchoolId = &id
		}
	}

	resp, err := t.engine.GetVolunteerRecommendations(ctx, req)
	if err != nil {
		return nil, fmt.Errorf("推荐引擎执行失败: %v", err)
	}

	qdSection, qdCard := batchSection(resp.QuotaDistrictRecommendations, BatchQuotaDistrict, 800)
	qsSection, qsCard := batchSection(resp.QuotaSchoolRecommendations, BatchQuotaSchool, 800)
	unSection, unCard := batchSection(resp.UnifiedRecommendations, BatchUnified, 750)

	payload := map[string]any{
		"data_nature":    dataNatureOfficial,
		"district_name":  districtName,
		"year":           resp.Year,
		"scale_note":     "名额到区/到校推荐基于 800 分制换算分，平行志愿基于 750 分制换算分",
		"quota_district": qdSection,
		"quota_school":   qsSection,
		"unified":        unSection,
	}
	if sc := resp.ScoreConversion; sc != nil {
		payload["score_conversion"] = map[string]any{
			"original_score":         sc.OriginalScore,
			"original_total":         sc.OriginalTotal,
			"converted_score_750":    sc.ConvertedScore_750,
			"converted_score_800":    sc.ConvertedScore_800,
			"estimated_rank":         sc.EstimatedRank,
			"estimated_percentile":   sc.EstimatedPercentile,
			"district_exam_count":    sc.DistrictExamCount,
			"conversion_data_nature": dataNatureEstimated,
		}
	}
	if req.MiddleSchoolId != nil {
		payload["middle_school_name"] = strings.TrimSpace(args.MiddleSchoolName)
	}

	cards := []agent.SchoolCard{qdCard, qsCard, unCard}
	summary := fmt.Sprintf("推荐引擎：%s %.1f 分（%s）→ 到区 %d / 到校 %d / 平行 %d 所",
		districtName, args.TotalScore, args.ExamType,
		len(resp.QuotaDistrictRecommendations), len(resp.QuotaSchoolRecommendations), len(resp.UnifiedRecommendations))
	return buildResult(payload, cards, summary)
}
