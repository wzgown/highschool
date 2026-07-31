// tools/get_score_trend.go - 单校分数线多年趋势
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getScoreTrendTool struct {
	repo repository.AgentDataRepository
}

// NewGetScoreTrendTool 分数线趋势（v_school_score_trend）
func NewGetScoreTrendTool(repo repository.AgentDataRepository) agent.Tool {
	return &getScoreTrendTool{repo: repo}
}

type getScoreTrendArgs struct {
	SchoolName   string `json:"school_name"`
	Batch        string `json:"batch"`
	DistrictName string `json:"district_name"`
}

func (t *getScoreTrendTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_score_trend",
		Description: "查询某高中某批次的多年录取分数线与同比涨跌，用于判断「这学校线稳不稳」。" +
			"batch 必填且分制固定（到区/到校 800 制，平行志愿 750 制）。例：「华二到区线这几年涨了吗」。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_name":   strProp("高中名称，支持简称"),
			"batch":         batchProp(true),
			"district_name": strProp("可选，限定录取区（到区/平行志愿按区出线的场景建议传）"),
		}, []string{"school_name", "batch"}),
	}
}

func (t *getScoreTrendTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getScoreTrendArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	schoolName, err := trimRequired(args.SchoolName, "school_name")
	if err != nil {
		return nil, err
	}
	batch, err := trimRequired(args.Batch, "batch")
	if err != nil {
		return nil, err
	}
	batch, err = checkBatch(batch)
	if err != nil {
		return nil, err
	}
	districtID, districtName, err := resolveDistrict(ctx, t.repo, args.DistrictName)
	if err != nil {
		return nil, err
	}

	school, err := t.repo.FindSchoolByName(ctx, schoolName, districtID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, fmt.Errorf("找不到高中 %q，请确认学校名称", schoolName)
		}
		return nil, err
	}

	rows, err := t.repo.GetScoreTrend(ctx, school.ID, batch, districtID, 0)
	if err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return nil, fmt.Errorf("%s 在 %s 批次无分数线数据", school.FullName, batch)
	}

	records := make([]trendRecord, 0, len(rows))
	for _, row := range rows {
		records = append(records, toTrendRecord(row))
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"school": map[string]any{
			"school_id":     school.ID,
			"school_name":   school.FullName,
			"district_name": school.DistrictName,
		},
		"batch":       batch,
		"score_scale": batchScale(batch),
		"records":     records,
	}
	if districtName != "" {
		payload["district_filter"] = districtName
	}

	cards := []agent.SchoolCard{schoolCard(school.ID, school.FullName, school.DistrictName, "score_trend", map[string]any{
		"batch":   batch,
		"records": records,
	})}
	summary := fmt.Sprintf("查询 %s %s 分数线趋势（%d 年）", school.FullName, batch, len(records))
	return buildResult(payload, cards, summary)
}
