// tools/get_score_trend.go - 单校分数线多年趋势
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

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
			"batch 不传默认查 UNIFIED_1_15（1-15 平行志愿，750 分制）。例：「华二这几年线涨了吗」。" +
			"用户明确问到区/到校时传对应 batch。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_name":   strProp("高中名称，支持简称"),
			"batch":         batchProp(false),
			"district_name": strProp("可选，考生所在区——仅决定到区线取哪条；到校线/平行志愿线按学校所在区出，不受此参数影响"),
		}, []string{"school_name"}),
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
	// 用户问「三年走势」通常不指明批次：缺省平行志愿（1-15），分制固定 750
	batch := strings.ToUpper(strings.TrimSpace(args.Batch))
	if batch == "" {
		batch = BatchUnified
	} else if batch, err = checkBatch(args.Batch); err != nil {
		return nil, err
	}
	districtID, districtName, err := resolveDistrict(ctx, t.repo, args.DistrictName)
	if err != nil {
		return nil, err
	}

	school, err := t.repo.FindSchoolByName(ctx, schoolName, districtID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			return nil, fmt.Errorf("%s", schoolNotFoundMsg(schoolName, err))
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
