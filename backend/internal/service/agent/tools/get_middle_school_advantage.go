// tools/get_middle_school_advantage.go - 初中×高中到校机会分析
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getMiddleSchoolAdvantageTool struct {
	repo repository.AgentDataRepository
}

// NewGetMiddleSchoolAdvantageTool 「我的初中走名额到校」交叉分析
func NewGetMiddleSchoolAdvantageTool(repo repository.AgentDataRepository) agent.Tool {
	return &getMiddleSchoolAdvantageTool{repo: repo}
}

type getMiddleSchoolAdvantageArgs struct {
	MiddleSchoolName string `json:"middle_school_name"`
	HighSchoolName   string `json:"high_school_name"`
}

func (t *getMiddleSchoolAdvantageTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_middle_school_advantage",
		Description: "分析某所初中的名额到校机会：最新年到校计划（哪些高中给了几个名额）+ 历年到校录取线（可指定某高中）+ 初中画像。" +
			"例：「我们学校能走华二吗」「张江集团中学到校有哪些名额」。先单独了解初中水平用 get_middle_school_stats。",
		ParametersJSON: jsonSchema(map[string]any{
			"middle_school_name": strProp("初中名称，支持全称或简称"),
			"high_school_name":   strProp("可选，目标高中。传了则只返回该高中的到校计划与历年到校线"),
		}, []string{"middle_school_name"}),
	}
}

func (t *getMiddleSchoolAdvantageTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getMiddleSchoolAdvantageArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	msName, err := trimRequired(args.MiddleSchoolName, "middle_school_name")
	if err != nil {
		return nil, err
	}

	ms, err := t.repo.FindMiddleSchoolByName(ctx, msName, 0)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, fmt.Errorf("找不到初中 %q，请确认学校名称", msName)
		}
		return nil, err
	}

	var highSchoolID int32
	var highSchool *repository.SchoolRef
	if args.HighSchoolName != "" {
		highSchool, err = t.repo.FindSchoolByName(ctx, args.HighSchoolName, 0)
		if err != nil {
			if errors.Is(err, repository.ErrNotFound) {
				return nil, fmt.Errorf("找不到高中 %q，请确认学校名称", args.HighSchoolName)
			}
			return nil, err
		}
		highSchoolID = highSchool.ID
	}

	// 到校计划（最新年）：按初中全名匹配（数据口径即初中全称）
	plans, err := t.repo.GetSchoolQuotaPlan(ctx, highSchoolID, ms.DistrictID, ms.Name, 0)
	if err != nil {
		return nil, err
	}
	// 历年到校线
	scores, err := t.repo.GetQuotaSchoolScoresByMiddle(ctx, ms.Name, ms.DistrictID, highSchoolID, 0)
	if err != nil {
		return nil, err
	}
	// 画像（可能无画像数据，容错不报错）
	profile, _ := t.repo.GetMiddleSchoolProfile(ctx, ms.ID)

	if len(plans) == 0 && len(scores) == 0 {
		return nil, fmt.Errorf("%s（%s）无名额到校计划与到校线数据", ms.Name, ms.DistrictName)
	}

	planItems := make([]map[string]any, 0, len(plans))
	for _, q := range plans {
		planItems = append(planItems, map[string]any{
			"year":             q.Year,
			"high_school_name": q.HighSchoolName,
			"quota_count":      q.QuotaCount,
		})
	}
	scoreRecords := make([]trendRecord, 0, len(scores))
	for _, s := range scores {
		scoreRecords = append(scoreRecords, toTrendRecord(s))
	}

	payload := map[string]any{
		"middle_school": map[string]any{
			"middle_school_id": ms.ID,
			"name":             ms.Name,
			"district_name":    ms.DistrictName,
		},
		"quota_plan_latest": map[string]any{
			"data_nature": dataNatureOfficial,
			"records":     planItems,
		},
		"quota_school_scores": map[string]any{
			"data_nature": dataNatureOfficial,
			"score_scale": 800,
			"records":     scoreRecords,
		},
	}
	if highSchool != nil {
		payload["high_school_filter"] = highSchool.FullName
	}
	if profile != nil {
		payload["middle_school_profile"] = middleSchoolProfilePayload(profile)
	}

	cardPayload := map[string]any{
		"quota_plan": planItems,
		"scores":     scoreRecords,
	}
	cards := []agent.SchoolCard{schoolCard(ms.ID, ms.Name, ms.DistrictName, "middle_school", cardPayload)}
	summary := fmt.Sprintf("分析 %s 到校机会（计划 %d 条、到校线 %d 条）", ms.Name, len(planItems), len(scoreRecords))
	return buildResult(payload, cards, summary)
}
