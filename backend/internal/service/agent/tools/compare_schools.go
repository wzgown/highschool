// tools/compare_schools.go - 多校画像并排对比
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

type compareSchoolsTool struct {
	repo repository.AgentDataRepository
}

// NewCompareSchoolsTool 多校并排对比（v_school_profile）
func NewCompareSchoolsTool(repo repository.AgentDataRepository) agent.Tool {
	return &compareSchoolsTool{repo: repo}
}

type compareSchoolsArgs struct {
	SchoolNames []string `json:"school_names"`
}

func (t *compareSchoolsTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "compare_schools",
		Description: "并排对比多所高中：办别/类型/寄宿/国际班 + 本区最新三类线 + 最新名额合计，一次最多 5 所。" +
			"例：「控江和杨高哪个好」「建平 vs 进才」。需要多年趋势对目标校逐个调 get_score_trend。",
		ParametersJSON: jsonSchema(map[string]any{
			"school_names": map[string]any{
				"type":        "array",
				"items":       map[string]any{"type": "string"},
				"minItems":    2,
				"maxItems":    5,
				"description": "高中名称列表（2-5 所），支持简称",
			},
		}, []string{"school_names"}),
	}
}

func (t *compareSchoolsTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args compareSchoolsArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	if len(args.SchoolNames) < 2 {
		return nil, fmt.Errorf("school_names 至少需要 2 所学校才能对比")
	}
	if len(args.SchoolNames) > 5 {
		return nil, fmt.Errorf("school_names 一次最多对比 5 所学校")
	}

	profiles := make([]map[string]any, 0, len(args.SchoolNames))
	cards := make([]agent.SchoolCard, 0, len(args.SchoolNames))
	names := make([]string, 0, len(args.SchoolNames))
	for _, name := range args.SchoolNames {
		name = strings.TrimSpace(name)
		if name == "" {
			return nil, fmt.Errorf("school_names 中存在空名称")
		}
		school, err := t.repo.FindSchoolByName(ctx, name, 0)
		if err != nil {
			if errors.Is(err, repository.ErrNotFound) {
				return nil, fmt.Errorf("找不到高中 %q，请确认学校名称或换用全称", name)
			}
			return nil, err
		}
		profile, err := t.repo.GetSchoolProfile(ctx, school.ID)
		if err != nil {
			return nil, err
		}
		pp := schoolProfilePayload(profile)
		profiles = append(profiles, pp)
		cards = append(cards, schoolCard(profile.SchoolID, profile.FullName, profile.DistrictName, "compare", pp))
		names = append(names, profile.FullName)
	}

	payload := map[string]any{
		"data_nature": dataNatureOfficial,
		"note":        "到校线为该高中在区内各初中录取线的最低/均值；名额为最新年合计",
		"schools":     profiles,
	}
	summary := fmt.Sprintf("对比 %d 所学校：%s", len(names), strings.Join(names, "、"))
	return buildResult(payload, cards, summary)
}
