// tools/get_middle_school_stats.go - 初中画像统计（v_middle_school_profile）
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getMiddleSchoolStatsTool struct {
	repo repository.AgentDataRepository
}

// NewGetMiddleSchoolStatsTool 初中画像查询（梯队/排名/人数/700+/到校名额）
func NewGetMiddleSchoolStatsTool(repo repository.AgentDataRepository) agent.Tool {
	return &getMiddleSchoolStatsTool{repo: repo}
}

type getMiddleSchoolStatsArgs struct {
	MiddleSchoolName string `json:"middle_school_name"`
	DistrictName     string `json:"district_name"`
}

func (t *getMiddleSchoolStatsTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_middle_school_stats",
		Description: "查询某所初中的画像：所在区、梯队、区内排名、考生人数（官方/推算）、700+人数（民间）、最新年到校名额与到校线聚合。" +
			"例：「我们学校什么水平」「张江集团中学多少人中考」。涉及具体高中的到校机会改用 get_middle_school_advantage。",
		ParametersJSON: jsonSchema(map[string]any{
			"middle_school_name": strProp("初中名称，支持全称或简称，如「张江集团中学」"),
			"district_name":      strProp("可选，限定区（同名初中消歧）"),
		}, []string{"middle_school_name"}),
	}
}

// middleSchoolProfilePayload 初中画像 → JSON（带逐字段口径）
func middleSchoolProfilePayload(p *repository.MiddleSchoolProfileRow) map[string]any {
	return map[string]any{
		"middle_school_id":                    p.MiddleSchoolID,
		"name":                                p.Name,
		"short_name":                          p.ShortName,
		"district_name":                       p.DistrictName,
		"school_nature_id":                    p.SchoolNatureID,
		"is_non_selective":                    p.IsNonSelective,
		"tier":                                p.Tier,
		"tier_data_nature":                    dataNatureFolk,
		"district_rank":                       p.DistrictRank,
		"district_rank_data_nature":           dataNatureFolk,
		"reputation_score":                    p.ReputationScore,
		"reputation_score_data_nature":        dataNatureFolk,
		"exact_student_count":                 p.ExactStudentCount,
		"exact_student_count_data_nature":     dataNatureOfficial,
		"estimated_student_count":             p.EstimatedStudentCount,
		"estimated_student_count_data_nature": dataNatureEstimated,
		"score_700plus_count":                 p.Score700PlusCount,
		"score_700plus_reliability":           p.Score700PlusReliability,
		"score_700plus_data_nature":           dataNatureFolk,
		"quota_total_latest":                  p.QuotaTotalLatest,
		"quota_high_school_count":             p.QuotaHighSchoolCount,
		"quota_school_line_count":             p.QuotaSchoolLineCount,
		"quota_school_min":                    p.QuotaSchoolMin,
		"quota_school_avg":                    p.QuotaSchoolAvg,
		"quota_data_nature":                   dataNatureOfficial,
		"quota_school_score_scale":            800,
	}
}

func (t *getMiddleSchoolStatsTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getMiddleSchoolStatsArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	msName, err := trimRequired(args.MiddleSchoolName, "middle_school_name")
	if err != nil {
		return nil, err
	}
	districtID, _, err := resolveDistrict(ctx, t.repo, args.DistrictName)
	if err != nil {
		return nil, err
	}

	ms, err := t.repo.FindMiddleSchoolByName(ctx, msName, districtID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, fmt.Errorf("找不到初中 %q，请确认学校名称（可加 district_name 消歧）", msName)
		}
		return nil, err
	}

	profile, err := t.repo.GetMiddleSchoolProfile(ctx, ms.ID)
	if err != nil {
		return nil, err
	}

	pp := middleSchoolProfilePayload(profile)
	payload := map[string]any{
		"profile": pp,
		"note":    "梯队/区内排名/声誉分/700+ 为民间口径仅供参考；准确人数为官方，估算人数为推算",
	}
	cards := []agent.SchoolCard{schoolCard(profile.MiddleSchoolID, profile.Name, profile.DistrictName, "middle_school", pp)}
	summary := fmt.Sprintf("查询 %s（%s）初中画像", profile.Name, profile.DistrictName)
	return buildResult(payload, cards, summary)
}
