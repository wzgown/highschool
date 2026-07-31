// tools/get_quota_change.go - 名额同比变化
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getQuotaChangeTool struct {
	repo repository.AgentDataRepository
}

// NewGetQuotaChangeTool 名额同比（v_quota_trend）
func NewGetQuotaChangeTool(repo repository.AgentDataRepository) agent.Tool {
	return &getQuotaChangeTool{repo: repo}
}

type getQuotaChangeArgs struct {
	SchoolName   string `json:"school_name"`
	DistrictName string `json:"district_name"`
}

func (t *getQuotaChangeTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_quota_change",
		Description: "查询某高中名额分配计划（到区/到校）的逐年数量与同比增减，用于回答「今年扩招还是缩招」。" +
			"例：「华二今年在浦东名额变了吗」。只看最新一年计划数用 get_quota_plan。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_name":   strProp("高中名称，支持简称"),
			"district_name": strProp("可选，限定投放区。不传则该校全部区"),
		}, []string{"school_name"}),
	}
}

func (t *getQuotaChangeTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getQuotaChangeArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	schoolName, err := trimRequired(args.SchoolName, "school_name")
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

	rows, err := t.repo.GetQuotaTrend(ctx, school.ID, "", districtID, 0)
	if err != nil {
		return nil, err
	}
	if len(rows) == 0 {
		return nil, fmt.Errorf("%s 无名额分配计划数据", school.FullName)
	}

	records := make([]map[string]any, 0, len(rows))
	for _, q := range rows {
		records = append(records, map[string]any{
			"batch":       q.Batch,
			"year":        q.Year,
			"district_id": q.DistrictID,
			"quota_count": q.QuotaCount,
			"yoy_change":  q.YoyChange,
		})
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"school": map[string]any{
			"school_id":     school.ID,
			"school_name":   school.FullName,
			"district_name": school.DistrictName,
		},
		"note":    "yoy_change 为相对上一年的名额增减（人），null 表示无上年数据",
		"records": records,
	}
	if districtName != "" {
		payload["district_filter"] = districtName
	}

	cards := []agent.SchoolCard{schoolCard(school.ID, school.FullName, school.DistrictName, "quota", map[string]any{
		"records": records,
	})}
	summary := fmt.Sprintf("查询 %s 名额同比（%d 条）", school.FullName, len(records))
	return buildResult(payload, cards, summary)
}
