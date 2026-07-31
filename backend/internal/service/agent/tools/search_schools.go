// tools/search_schools.go - 高中模糊搜索
package tools

import (
	"context"
	"encoding/json"
	"fmt"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

type searchSchoolsTool struct {
	repo repository.AgentDataRepository
}

// NewSearchSchoolsTool 高中名称模糊搜索
func NewSearchSchoolsTool(repo repository.AgentDataRepository) agent.Tool {
	return &searchSchoolsTool{repo: repo}
}

type searchSchoolsArgs struct {
	Keyword      string `json:"keyword"`
	DistrictName string `json:"district_name"`
}

func (t *searchSchoolsTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "search_schools",
		Description: "按关键词模糊搜索高中（匹配全称/简称），返回候选学校列表。" +
			"当用户说的学校名不确定、或 get_school_detail/get_admission_scores 报找不到学校时，先用它确认准确校名。",
		ParametersJSON: jsonSchema(map[string]any{
			"keyword":       strProp("搜索关键词，校名片段，如「建平」「华二」"),
			"district_name": strProp("可选，限定区，如「浦东新区」"),
		}, []string{"keyword"}),
	}
}

func (t *searchSchoolsTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args searchSchoolsArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	keyword, err := trimRequired(args.Keyword, "keyword")
	if err != nil {
		return nil, err
	}
	districtID, districtName, err := resolveDistrict(ctx, t.repo, args.DistrictName)
	if err != nil {
		return nil, err
	}

	schools, err := t.repo.SearchSchools(ctx, keyword, districtID, 10)
	if err != nil {
		return nil, err
	}
	if len(schools) == 0 {
		return nil, fmt.Errorf("没有匹配 %q 的高中，请更换关键词", keyword)
	}

	items := make([]map[string]any, 0, len(schools))
	for _, s := range schools {
		items = append(items, map[string]any{
			"school_id":     s.ID,
			"code":          s.Code,
			"full_name":     s.FullName,
			"short_name":    s.ShortName,
			"district_name": s.DistrictName,
		})
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"keyword":     keyword,
		"count":       len(items),
		"schools":     items,
	}
	if districtName != "" {
		payload["district_filter"] = districtName
	}

	summary := fmt.Sprintf("搜索高中 %q：命中 %d 所", keyword, len(items))
	return buildResult(payload, nil, summary)
}
