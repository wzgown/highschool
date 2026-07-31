// tools/get_school_detail.go - 高中画像详情（v_school_profile 全量）
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getSchoolDetailTool struct {
	repo repository.AgentDataRepository
}

// NewGetSchoolDetailTool 高中详情（主档属性 + 最新三类线 + 最新名额合计）
func NewGetSchoolDetailTool(repo repository.AgentDataRepository) agent.Tool {
	return &getSchoolDetailTool{repo: repo}
}

type getSchoolDetailArgs struct {
	SchoolName string `json:"school_name"`
}

func (t *getSchoolDetailTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_school_detail",
		Description: "获取单所高中的完整画像：办别/类型/寄宿/国际班 + 本区最新三类分数线 + 最新年到区/到校名额合计。" +
			"例：「介绍一下控江中学」「这学校能寄宿吗」。需要多年分数趋势改用 get_score_trend，多校对比用 compare_schools。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_name": strProp("高中名称，支持全称或简称"),
		}, []string{"school_name"}),
	}
}

// schoolProfilePayload 画像行 → JSON（compare_schools 复用）
func schoolProfilePayload(p *repository.SchoolProfileRow) map[string]any {
	scoreEntry := func(year *int32, score *float64, scale int) map[string]any {
		if year == nil || score == nil {
			return nil
		}
		return map[string]any{"year": *year, "min_score": *score, "score_scale": scale}
	}
	return map[string]any{
		"school_id":                   p.SchoolID,
		"code":                        p.Code,
		"full_name":                   p.FullName,
		"short_name":                  p.ShortName,
		"district_name":               p.DistrictName,
		"school_type_id":              p.SchoolTypeID,
		"school_nature_id":            p.SchoolNatureID,
		"boarding_type_id":            p.BoardingTypeID,
		"has_international_course":    p.HasInternationalCourse,
		"unified_score_latest":        scoreEntry(p.UnifiedYear, p.UnifiedMinScore, 750),
		"quota_district_score_latest": scoreEntry(p.QuotaDistrictYear, p.QuotaDistrictMinScore, 800),
		"quota_school_score_latest": map[string]any{
			"year":        p.QuotaSchoolYear,
			"min_score":   p.QuotaSchoolMin,
			"avg_score":   p.QuotaSchoolAvg,
			"score_scale": 800,
			"note":        "到校线为该高中在区内各初中录取线的最低/均值",
		},
		"quota_district_total_latest": p.QuotaDistrictTotalLatest,
		"quota_school_total_latest":   p.QuotaSchoolTotalLatest,
	}
}

func (t *getSchoolDetailTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getSchoolDetailArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	schoolName, err := trimRequired(args.SchoolName, "school_name")
	if err != nil {
		return nil, err
	}

	school, err := t.repo.FindSchoolByName(ctx, schoolName, 0)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, fmt.Errorf("找不到高中 %q，请确认学校名称或换用全称", schoolName)
		}
		return nil, err
	}

	profile, err := t.repo.GetSchoolProfile(ctx, school.ID)
	if err != nil {
		return nil, err
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"profile":     schoolProfilePayload(profile),
	}
	cards := []agent.SchoolCard{schoolCard(profile.SchoolID, profile.FullName, profile.DistrictName, "profile", schoolProfilePayload(profile))}
	summary := fmt.Sprintf("查询 %s 学校画像", profile.FullName)
	return buildResult(payload, cards, summary)
}
