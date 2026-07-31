// tools/get_control_scores.go - 最低投档控制分数线
package tools

import (
	"context"
	"encoding/json"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getControlScoresTool struct {
	repo repository.AgentDataRepository
}

// NewGetControlScoresTool 控线查询（默认最新年）
func NewGetControlScoresTool(repo repository.AgentDataRepository) agent.Tool {
	return &getControlScoresTool{repo: repo}
}

type getControlScoresArgs struct {
	Year int `json:"year"`
}

func (t *getControlScoresTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_control_scores",
		Description: "查询上海市最低投档控制分数线（各批次/类别的全市统一控线），默认最新年。" +
			"例：「今年自招控线多少」「名额分配控线」。做分数定位分析时配合 locate_score 使用。",
		ParametersJSON: jsonSchema(map[string]any{
			"year": yearProp(),
		}, nil),
	}
}

func (t *getControlScoresTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getControlScoresArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}

	rows, err := t.repo.GetControlScores(ctx, args.Year)
	if err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return nil, fmt.Errorf("指定年份无控线数据")
	}

	items := make([]map[string]any, 0, len(rows))
	for _, c := range rows {
		item := map[string]any{
			"year":        c.Year,
			"batch":       c.Batch,
			"category":    c.Category,
			"min_score":   c.MinScore,
			"description": c.Description,
		}
		if validBatch(c.Batch) {
			item["score_scale"] = batchScale(c.Batch)
		}
		items = append(items, item)
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"note":        "自主招生/名额分配批次控线为 800 分制口径，1-15 志愿为 750 分制口径",
		"records":     items,
	}
	summary := fmt.Sprintf("查询 %d 年控线（%d 条）", rows[0].Year, len(items))
	return buildResult(payload, nil, summary)
}
