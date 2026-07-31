// tools/get_tie_break_detail.go - 录取同分小分明细
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getTieBreakDetailTool struct {
	repo repository.AgentDataRepository
}

// NewGetTieBreakDetailTool 同分小分明细（语数外/数学/语文/综合/同分优待）
func NewGetTieBreakDetailTool(repo repository.AgentDataRepository) agent.Tool {
	return &getTieBreakDetailTool{repo: repo}
}

type getTieBreakDetailArgs struct {
	SchoolName   string `json:"school_name"`
	DistrictName string `json:"district_name"`
	Batch        string `json:"batch"`
}

func (t *getTieBreakDetailTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_tie_break_detail",
		Description: "查询某高中最新年录取最低分对应的小分明细：语数外合计、数学、语文、综合测试、综合素质评价、是否同分优待，" +
			"用于回答「同分要拼哪科」。例：「压线进控江要数学多少分」。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_name":   strProp("高中名称，支持简称"),
			"district_name": strProp("可选，限定录取区"),
			"batch":         batchProp(false),
		}, []string{"school_name"}),
	}
}

func (t *getTieBreakDetailTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getTieBreakDetailArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	schoolName, err := trimRequired(args.SchoolName, "school_name")
	if err != nil {
		return nil, err
	}
	batch, err := checkBatch(args.Batch)
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
		return nil, fmt.Errorf("%s 无分数线数据", school.FullName)
	}

	// 只保留最新年（各批次各自最新年）
	latestByBatch := map[string]int32{}
	for _, row := range rows {
		if row.Year > latestByBatch[row.Batch] {
			latestByBatch[row.Batch] = row.Year
		}
	}

	records := make([]trendRecord, 0, len(rows))
	for _, row := range rows {
		if row.Year == latestByBatch[row.Batch] {
			records = append(records, toTrendRecord(row))
		}
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"school": map[string]any{
			"school_id":     school.ID,
			"school_name":   school.FullName,
			"district_name": school.DistrictName,
		},
		"note":    "同分排序规则：依次比较语数外合计→数学→语文→综合测试；is_tie_preferred=true 表示该最低分为同分优待录取。UNIFIED_1_15 为 750 分制无综合测试/综评小分",
		"records": records,
	}
	if districtName != "" {
		payload["district_filter"] = districtName
	}

	cards := []agent.SchoolCard{schoolCard(school.ID, school.FullName, school.DistrictName, "score_trend", map[string]any{
		"records": records,
	})}
	summary := fmt.Sprintf("查询 %s 最新年小分明细（%d 条）", school.FullName, len(records))
	return buildResult(payload, cards, summary)
}
