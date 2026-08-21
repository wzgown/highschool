// tools/get_quota_plan.go - 名额分配招生计划（到区/到校）
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getQuotaPlanTool struct {
	repo repository.AgentDataRepository
}

// NewGetQuotaPlanTool 招生计划查询（默认最新年）
func NewGetQuotaPlanTool(repo repository.AgentDataRepository) agent.Tool {
	return &getQuotaPlanTool{repo: repo}
}

type getQuotaPlanArgs struct {
	SchoolName   string `json:"school_name"`
	DistrictName string `json:"district_name"`
	Batch        string `json:"batch"`
}

func (t *getQuotaPlanTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_quota_plan",
		Description: "查询名额分配招生计划（最新年）。batch=QUOTA_DISTRICT 查到区计划（高中投放到各区的名额），" +
			"batch=QUOTA_SCHOOL 查到校计划（高中投放到各初中的名额），不传则两类都查。" +
			"school_name 与 district_name 至少给一个。例：「华二今年在浦东招几个到区」「控江到校计划」。问名额涨跌改用 get_quota_change。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_name":   strProp("高中名称，支持简称。可选"),
			"district_name": strProp("区名，如「浦东新区」。可选"),
			"batch":         batchProp(false),
		}, nil),
	}
}

func (t *getQuotaPlanTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getQuotaPlanArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	batch, err := checkBatch(args.Batch)
	if err != nil {
		return nil, err
	}

	var schoolID int32
	var school *repository.SchoolRef
	if args.SchoolName != "" {
		school, err = t.repo.FindSchoolByName(ctx, args.SchoolName, 0)
		if err != nil {
			if errors.Is(err, repository.ErrNotFound) {
				return nil, fmt.Errorf("%s", schoolNotFoundMsg(args.SchoolName, err))
			}
			return nil, err
		}
		schoolID = school.ID
	}
	districtID, districtName, err := resolveDistrict(ctx, t.repo, args.DistrictName)
	if err != nil {
		return nil, err
	}
	if schoolID == 0 && districtID == 0 {
		return nil, fmt.Errorf("school_name 与 district_name 至少提供一个，否则查询范围过大")
	}
	if batch == BatchUnified {
		return nil, fmt.Errorf("UNIFIED_1_15 无名额分配计划，请使用 QUOTA_DISTRICT 或 QUOTA_SCHOOL")
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"note":        "计划数单位：人。年份为数据最新年",
	}
	if school != nil {
		payload["school"] = map[string]any{"school_id": school.ID, "school_name": school.FullName, "district_name": school.DistrictName}
	}
	if districtName != "" {
		payload["district_filter"] = districtName
	}

	summary := "查询名额分配计划"
	if school != nil {
		summary = fmt.Sprintf("查询 %s 名额分配计划", school.FullName)
	}

	if batch == "" || batch == BatchQuotaDistrict {
		rows, err := t.repo.GetDistrictQuotaPlan(ctx, schoolID, districtID, 0)
		if err != nil {
			return nil, err
		}
		items := make([]map[string]any, 0, len(rows))
		for _, q := range rows {
			items = append(items, map[string]any{
				"year":          q.Year,
				"school_name":   q.SchoolName,
				"district_name": q.DistrictName,
				"quota_count":   q.QuotaCount,
			})
		}
		payload["quota_district_plan"] = items
	}
	if batch == "" || batch == BatchQuotaSchool {
		rows, err := t.repo.GetSchoolQuotaPlan(ctx, schoolID, districtID, "", 0)
		if err != nil {
			return nil, err
		}
		items := make([]map[string]any, 0, len(rows))
		for _, q := range rows {
			items = append(items, map[string]any{
				"year":               q.Year,
				"high_school_name":   q.HighSchoolName,
				"district_name":      q.DistrictName,
				"middle_school_name": q.MiddleSchoolName,
				"quota_count":        q.QuotaCount,
			})
		}
		payload["quota_school_plan"] = items
	}

	var cards []agent.SchoolCard
	if school != nil {
		cards = []agent.SchoolCard{schoolCard(school.ID, school.FullName, school.DistrictName, "quota", payload)}
	}
	return buildResult(payload, cards, summary)
}
