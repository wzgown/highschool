// tools/helpers.go - 参数解析与结果组装公共函数
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

// ---------- 批次枚举与分制 ----------

const (
	BatchQuotaDistrict = "QUOTA_DISTRICT" // 名额分配到区，800 分制
	BatchQuotaSchool   = "QUOTA_SCHOOL"   // 名额分配到校，800 分制
	BatchUnified       = "UNIFIED_1_15"   // 1-15 平行志愿，750 分制
)

// batchScale 批次对应总分制（800 含综评 50；750 为纯学业考）
func batchScale(batch string) int {
	if batch == BatchUnified {
		return 750
	}
	return 800
}

// validBatch 校验批次枚举
func validBatch(batch string) bool {
	switch batch {
	case BatchQuotaDistrict, BatchQuotaSchool, BatchUnified:
		return true
	}
	return false
}

const batchEnumHint = "QUOTA_DISTRICT（名额到区，800分制）/ QUOTA_SCHOOL（名额到校，800分制）/ UNIFIED_1_15（平行志愿，750分制）"

// ---------- data_nature 口径 ----------

const (
	dataNatureOfficial  = "official"  // 官方发布
	dataNatureEstimated = "estimated" // 推算
	dataNatureFolk      = "folk"      // 民间统计/主观评价
)

// ---------- 参数解析 ----------

// parseArgs 解析 LLM 工具参数
func parseArgs(raw json.RawMessage, v any) error {
	if len(raw) == 0 {
		return fmt.Errorf("参数为空")
	}
	if err := json.Unmarshal(raw, v); err != nil {
		return fmt.Errorf("参数 JSON 解析失败: %v", err)
	}
	return nil
}

// missing 必填参数缺失错误（返回给 LLM 让它补问，而非 panic）
func missing(key string) error {
	return fmt.Errorf("缺少必填参数 %q，请先向用户确认", key)
}

func trimRequired(s, key string) (string, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return "", missing(key)
	}
	return s, nil
}

// checkBatch 校验可选批次参数（空 = 全部批次，合法）
func checkBatch(batch string) (string, error) {
	batch = strings.ToUpper(strings.TrimSpace(batch))
	if batch == "" {
		return "", nil
	}
	if !validBatch(batch) {
		return "", fmt.Errorf("非法批次 %q，可选: %s", batch, batchEnumHint)
	}
	return batch, nil
}

// ---------- 名称解析 ----------

// resolveDistrict 可选区名 → districtID（0 = 不限）
func resolveDistrict(ctx context.Context, repo repository.AgentDataRepository, districtName string) (int32, string, error) {
	districtName = strings.TrimSpace(districtName)
	if districtName == "" {
		return 0, "", nil
	}
	d, err := repo.FindDistrictByName(ctx, districtName)
	if err != nil {
		return 0, "", fmt.Errorf("找不到区 %q，请确认区名（如「浦东新区」「徐汇」）", districtName)
	}
	return d.ID, d.Name, nil
}

// ---------- 结果组装 ----------

// buildResult 组装双载荷结果：payload → 紧凑 JSON 给 LLM
func buildResult(payload any, cards []agent.SchoolCard, summary string) (*agent.ToolResult, error) {
	data, err := json.Marshal(payload)
	if err != nil {
		return nil, fmt.Errorf("结果序列化失败: %w", err)
	}
	return &agent.ToolResult{
		ForLLM:  string(data),
		Cards:   cards,
		Summary: summary,
	}, nil
}

// trendRecord 分数线记录（ForLLM 紧凑 JSON）
type trendRecord struct {
	Batch         string   `json:"batch"`
	Year          int32    `json:"year"`
	ScoreScale    int      `json:"score_scale"`
	SchoolName    string   `json:"school_name"`
	MiddleSchool  string   `json:"middle_school_name,omitempty"`
	MinScore      float64  `json:"min_score"`
	YoyChange     *float64 `json:"yoy_change,omitempty"`
	TieCMFSum     *float64 `json:"chinese_math_foreign_sum,omitempty"`
	TieMath       *float64 `json:"math_score,omitempty"`
	TieChinese    *float64 `json:"chinese_score,omitempty"`
	TieIntegrated *float64 `json:"integrated_test_score,omitempty"`
	TieCompQual   *float64 `json:"comprehensive_quality_score,omitempty"`
	TiePreferred  *bool    `json:"is_tie_preferred,omitempty"`
}

func toTrendRecord(t repository.ScoreTrendRow) trendRecord {
	rec := trendRecord{
		Batch:         t.Batch,
		Year:          t.Year,
		ScoreScale:    batchScale(t.Batch),
		SchoolName:    t.SchoolName,
		MinScore:      t.MinScore,
		YoyChange:     t.YoyChange,
		TieCMFSum:     t.ChineseMathForeignSum,
		TieMath:       t.MathScore,
		TieChinese:    t.ChineseScore,
		TieIntegrated: t.IntegratedTestScore,
		TieCompQual:   t.ComprehensiveQualityScore,
		TiePreferred:  t.IsTiePreferred,
	}
	if t.MiddleSchoolName != nil {
		rec.MiddleSchool = *t.MiddleSchoolName
	}
	return rec
}

// filterRecentYears 保留最近 n 个年份的记录（year 未显式指定时用）
func filterRecentYears(rows []repository.ScoreTrendRow, n int) []repository.ScoreTrendRow {
	maxYear := int32(0)
	for _, t := range rows {
		if t.Year > maxYear {
			maxYear = t.Year
		}
	}
	if maxYear == 0 {
		return rows
	}
	cutoff := maxYear - int32(n) + 1
	out := rows[:0]
	for _, t := range rows {
		if t.Year >= cutoff {
			out = append(out, t)
		}
	}
	return out
}

// jsonSchema 便捷构造 JSON Schema
func jsonSchema(props map[string]any, required []string) map[string]any {
	schema := map[string]any{
		"type":       "object",
		"properties": props,
	}
	if len(required) > 0 {
		schema["required"] = required
	}
	return schema
}

func strProp(desc string) map[string]any {
	return map[string]any{"type": "string", "description": desc}
}

func batchProp(required bool) map[string]any {
	desc := "招生批次。QUOTA_DISTRICT=名额到区(800分制)，QUOTA_SCHOOL=名额到校(800分制)，UNIFIED_1_15=1-15平行志愿(750分制)"
	if !required {
		desc += "。不传则查全部批次"
	}
	return map[string]any{
		"type":        "string",
		"enum":        []string{BatchQuotaDistrict, BatchQuotaSchool, BatchUnified},
		"description": desc,
	}
}

func yearProp() map[string]any {
	return map[string]any{"type": "integer", "description": "招生年份，如 2026。不传则默认最近三年/最新年（视工具而定）"}
}

// schoolCard 构造学校卡片
func schoolCard(schoolID int32, schoolName, districtName, cardType string, payload map[string]any) agent.SchoolCard {
	return agent.SchoolCard{
		SchoolID:     schoolID,
		SchoolName:   schoolName,
		DistrictName: districtName,
		CardType:     cardType,
		Payload:      payload,
	}
}

// schoolNotFoundMsg 校名未命中时的用户可读报错（含核心词候选提示）。
// 覆盖 7 个工具的同款分支：口语缩写（如「交大附中嘉定分校」）在仓储层
// 已做变体展开，仍 miss 时带上候选给用户「是不是要找…」的出路。
func schoolNotFoundMsg(query string, err error) string {
	var sne *repository.SchoolNotFoundError
	if errors.As(err, &sne) && len(sne.Candidates) > 0 {
		names := make([]string, 0, len(sne.Candidates))
		for _, c := range sne.Candidates {
			if c.ShortName != "" {
				names = append(names, c.FullName+"（"+c.ShortName+"）")
			} else {
				names = append(names, c.FullName)
			}
		}
		return fmt.Sprintf("没查到 %q，你要找的可能是：%s", query, strings.Join(names, "、"))
	}
	return fmt.Sprintf("找不到高中 %q，请确认学校名称（可用简称，如「华二」「格致」）", query)
}
