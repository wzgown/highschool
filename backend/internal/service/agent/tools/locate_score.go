// tools/locate_score.go - 分数定位（线 <= 分的学校列表）
package tools

import (
	"context"
	"encoding/json"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type locateScoreTool struct {
	repo repository.AgentDataRepository
}

// NewLocateScoreTool 分数定位：某区某批次下录取线 <= 考生分数的学校
func NewLocateScoreTool(repo repository.AgentDataRepository) agent.Tool {
	return &locateScoreTool{repo: repo}
}

type locateScoreArgs struct {
	DistrictName string  `json:"district_name"`
	Score        float64 `json:"score"`
	Batch        string  `json:"batch"`
}

func (t *locateScoreTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "locate_score",
		Description: "分数定位：列出某区某批次最新年中，录取最低线不超过考生分数的学校，按差值（gap=分数-线）升序/分数线降序排列，用于冲稳保粗筛。" +
			"batch 必填：UNIFIED_1_15 按 750 分制线匹配，QUOTA_DISTRICT/QUOTA_SCHOOL 按 800 分制线匹配，score 必须与批次分制一致，不可混用。" +
			"例：「浦东 705 平行志愿能去哪」。定位后对目标校调 get_score_trend 看稳定性。",
		ParametersJSON: jsonSchema(map[string]any{
			"district_name": strProp("考生所在区，如「浦东新区」"),
			"score": map[string]any{
				"type":        "number",
				"description": "考生分数。UNIFIED_1_15 传 750 分制分数，其余批次传 800 分制分数",
			},
			"batch": batchProp(true),
		}, []string{"district_name", "score", "batch"}),
	}
}

func (t *locateScoreTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args locateScoreArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	if _, err := trimRequired(args.DistrictName, "district_name"); err != nil {
		return nil, err
	}
	if args.Score <= 0 {
		return nil, fmt.Errorf("缺少必填参数 \"score\" 或分数非法（需为正数）")
	}
	batch, err := trimRequired(args.Batch, "batch")
	if err != nil {
		return nil, err
	}
	batch, err = checkBatch(batch)
	if err != nil {
		return nil, err
	}
	// 分制红线：分数明显超出该批次满分时拒绝，防止 800/750 混用
	scale := batchScale(batch)
	if args.Score > float64(scale) {
		return nil, fmt.Errorf("分数 %.1f 超过 %s 批次满分 %d，请确认分数与批次分制一致（平行志愿 750 制，名额分配 800 制）", args.Score, batch, scale)
	}

	districtID, districtName, err := resolveDistrict(ctx, t.repo, args.DistrictName)
	if err != nil {
		return nil, err
	}

	rows, err := t.repo.LocateByScore(ctx, districtID, batch, args.Score)
	if err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return nil, fmt.Errorf("%s %s 批次下没有录取线 ≤ %.1f 的学校（最新年数据）", districtName, batch, args.Score)
	}

	items := make([]map[string]any, 0, len(rows))
	for _, l := range rows {
		items = append(items, map[string]any{
			"school_name": l.SchoolName,
			"year":        l.Year,
			"min_score":   l.MinScore,
			"gap":         l.Gap,
		})
	}

	payload := map[string]any{
		"data_nature":   dataNatureOfficial,
		"district_name": districtName,
		"batch":         batch,
		"score_scale":   scale,
		"score":         args.Score,
		"note":          "到校批次按该高中在区内各初中的最低到校线统计；gap=考生分数-录取线，gap 越大越稳",
		"schools":       items,
	}
	summary := fmt.Sprintf("%s %.1f 分 %s 定位：%d 所学校达线", districtName, args.Score, batch, len(items))
	return buildResult(payload, nil, summary)
}
