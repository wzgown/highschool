// tools/get_admission_scores.go - 查三类录取分数线
package tools

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type getAdmissionScoresTool struct {
	repo repository.AgentDataRepository
}

// NewGetAdmissionScoresTool 查高中录取分数线（三类批次，默认近三年）
func NewGetAdmissionScoresTool(repo repository.AgentDataRepository) agent.Tool {
	return &getAdmissionScoresTool{repo: repo}
}

type getAdmissionScoresArgs struct {
	SchoolName   string `json:"school_name"`
	DistrictName string `json:"district_name"`
	Batch        string `json:"batch"`
	Year         int    `json:"year"`
}

func (t *getAdmissionScoresTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_admission_scores",
		Description: "查询某所高中的录取分数线（名额到区/名额到校/1-15平行志愿三类）。按名称模糊匹配学校；" +
			"batch 不传时返回近三年全部批次，注意 800/750 分制不可混比。" +
			"例：用户问「华二去年多少分」「控江到区线」时用；追问趋势再调 get_score_trend。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_name":   strProp("高中名称，支持全称或简称，如「华东师范大学第二附属中学」「华二」"),
			"district_name": strProp("区名，如「浦东新区」「徐汇」。不传则全市范围匹配学校"),
			"batch":         batchProp(false),
			"year":          yearProp(),
		}, []string{"school_name"}),
	}
}

func (t *getAdmissionScoresTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getAdmissionScoresArgs
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
			return nil, fmt.Errorf("%s", schoolNotFoundMsg(schoolName, err))
		}
		return nil, err
	}

	minYear := 0
	if args.Year > 0 {
		minYear = args.Year
	}
	rows, err := t.repo.GetScoreTrend(ctx, school.ID, batch, districtID, minYear)
	if err != nil {
		return nil, err
	}
	if args.Year <= 0 {
		rows = filterRecentYears(rows, 3)
	}
	if len(rows) == 0 {
		return nil, fmt.Errorf("%s（%s）在指定批次/年份无录取分数线数据", school.FullName, school.DistrictName)
	}

	records := make([]trendRecord, 0, len(rows))
	for _, row := range rows {
		records = append(records, toTrendRecord(row))
	}

	yearRange := fmt.Sprintf("%d-%d", records[0].Year, records[len(records)-1].Year)
	if args.Year > 0 {
		yearRange = fmt.Sprintf("%d", args.Year)
	}
	summary := fmt.Sprintf("查询 %s %s 录取分数线（%d 条）", school.FullName, yearRange, len(records))

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"school": map[string]any{
			"school_id":     school.ID,
			"school_name":   school.FullName,
			"district_name": school.DistrictName,
		},
		"scale_note": "QUOTA_DISTRICT/QUOTA_SCHOOL 为 800 分制（含综评50），UNIFIED_1_15 为 750 分制，两种分制不可直接比较",
		"records":    records,
	}
	if districtName != "" {
		payload["district_filter"] = districtName
	}

	cards := []agent.SchoolCard{schoolCard(school.ID, school.FullName, school.DistrictName, "score_trend", map[string]any{
		"records": records,
	})}
	return buildResult(payload, cards, summary)
}
