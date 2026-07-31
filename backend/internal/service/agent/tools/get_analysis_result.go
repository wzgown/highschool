// tools/get_analysis_result.go - 模拟结果解读（P2 引擎型）
package tools

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"highschool-backend/internal/repository"
	"highschool-backend/internal/service/agent"
)

// SimulationHistoryReader 模拟历史读取抽象，repository.NewSimulationHistoryRepository() 天然满足
type SimulationHistoryReader interface {
	GetByID(ctx context.Context, id string) (*repository.SimulationHistoryRecord, error)
}

type getAnalysisResultTool struct {
	simRepo SimulationHistoryReader
}

// NewGetAnalysisResultTool 解读已完成的志愿模拟分析结果
func NewGetAnalysisResultTool(simRepo SimulationHistoryReader) agent.Tool {
	return &getAnalysisResultTool{simRepo: simRepo}
}

type getAnalysisResultArgs struct {
	AnalysisID int64 `json:"analysis_id"`
}

func (t *getAnalysisResultTool) Spec() agent.ToolSpec {
	return agent.ToolSpec{
		Name: "get_analysis_result",
		Description: "读取并解读用户此前的志愿模拟分析结果：考生输入摘要、逐批次逐志愿录取概率与风险分级、策略分析要点。" +
			"前置槽位：analysis_id（用户做过模拟后才有）。例：「我的结果怎么样」「上次模拟的第三志愿稳吗」。" +
			"用户还没做过模拟时引导其先做，不要用本工具猜。",
		ParametersJSON: jsonSchema(map[string]any{
			"analysis_id": map[string]any{
				"type":        "integer",
				"description": "模拟分析记录 ID（会话槽位 analysis_id）",
			},
		}, []string{"analysis_id"}),
	}
}

// riskBand 按概率分级：>80% 稳 / 40-80% 中 / <40% 险
func riskBand(probability float64) string {
	switch {
	case probability > 0.8:
		return "稳"
	case probability >= 0.4:
		return "中"
	default:
		return "险"
	}
}

func (t *getAnalysisResultTool) Execute(ctx context.Context, raw json.RawMessage) (*agent.ToolResult, error) {
	var args getAnalysisResultArgs
	if err := parseArgs(raw, &args); err != nil {
		return nil, err
	}
	if args.AnalysisID <= 0 {
		return nil, fmt.Errorf("缺少必填参数 \"analysis_id\"（正整数），请先确认用户要解读哪次模拟结果")
	}

	record, err := t.simRepo.GetByID(ctx, strconv.FormatInt(args.AnalysisID, 10))
	if err != nil {
		return nil, fmt.Errorf("找不到模拟记录 %d，请确认 analysis_id 是否正确（记录可能已删除）", args.AnalysisID)
	}
	if record.SimulationResult == nil {
		return nil, fmt.Errorf("模拟记录 %d 尚无结果数据", args.AnalysisID)
	}

	payload := map[string]any{
		"data_nature": dataNatureEstimated,
		"analysis_id": args.AnalysisID,
		"note":        "录取概率为引擎推算值（estimated），仅供参考；志愿批次线 800/750 分制见各批 score_scale",
	}

	// 考生输入摘要
	if cd := record.CandidateData; cd != nil {
		candidate := map[string]any{}
		if cd.Candidate != nil {
			candidate["district_id"] = cd.Candidate.DistrictId
			candidate["middle_school_id"] = cd.Candidate.MiddleSchoolId
			candidate["has_quota_school_eligibility"] = cd.Candidate.HasQuotaSchoolEligibility
		}
		if cd.Scores != nil {
			candidate["scores"] = map[string]any{
				"total":       cd.Scores.Total,
				"chinese":     cd.Scores.Chinese,
				"math":        cd.Scores.Math,
				"foreign":     cd.Scores.Foreign,
				"integrated":  cd.Scores.Integrated,
				"ethics":      cd.Scores.Ethics,
				"history":     cd.Scores.History,
				"pe":          cd.Scores.Pe,
				"score_scale": 750,
			}
		}
		payload["candidate"] = candidate
	}

	// 排名预测
	if pred := record.SimulationResult.Predictions; pred != nil {
		payload["rank_prediction"] = map[string]any{
			"district_rank":            pred.DistrictRank,
			"district_rank_range_low":  pred.DistrictRankRangeLow,
			"district_rank_range_high": pred.DistrictRankRangeHigh,
			"percentile":               pred.Percentile,
			"confidence":               pred.Confidence,
		}
	}

	// 逐批次逐志愿概率
	volunteers := make([]map[string]any, 0, len(record.SimulationResult.Probabilities))
	for _, p := range record.SimulationResult.Probabilities {
		// simulation_history.probability 为 0-100 百分数（与结果页展示口径一致）
		prob01 := p.Probability / 100
		item := map[string]any{
			"batch":           p.Batch,
			"score_scale":     batchScale(strings.ToUpper(p.Batch)),
			"volunteer_index": p.VolunteerIndex,
			"school_id":       p.SchoolId,
			"school_name":     p.SchoolName,
			"probability_pct": p.Probability,
			"risk_band":       riskBand(prob01),
		}
		if p.RiskLevel != "" {
			item["engine_risk_level"] = p.RiskLevel
		}
		if p.ScoreDiff != nil {
			item["score_diff"] = *p.ScoreDiff
		}
		volunteers = append(volunteers, item)
	}
	payload["volunteers"] = volunteers

	// 策略分析要点
	if st := record.SimulationResult.Strategy; st != nil {
		strategy := map[string]any{
			"score":       st.Score,
			"suggestions": st.Suggestions,
			"warnings":    st.Warnings,
		}
		if st.Gradient != nil {
			strategy["gradient"] = map[string]any{
				"reach":  st.Gradient.Reach,
				"target": st.Gradient.Target,
				"safety": st.Gradient.Safety,
			}
		}
		if st.VolunteerRationality != nil {
			strategy["rationality"] = map[string]any{
				"has_safety_school":        st.VolunteerRationality.HasSafetySchool,
				"is_gradient_reasonable":   st.VolunteerRationality.IsGradientReasonable,
				"has_duplicate_or_invalid": st.VolunteerRationality.HasDuplicateOrInvalid,
			}
		}
		payload["strategy"] = strategy
	}

	card := agent.SchoolCard{
		SchoolID:   0,
		SchoolName: fmt.Sprintf("模拟结果 #%d", args.AnalysisID),
		CardType:   "profile",
		Payload: map[string]any{
			"volunteers":      volunteers,
			"rank_prediction": payload["rank_prediction"],
			"strategy":        payload["strategy"],
		},
	}
	summary := fmt.Sprintf("解读模拟结果 #%d（%d 个志愿）", args.AnalysisID, len(volunteers))
	return buildResult(payload, []agent.SchoolCard{card}, summary)
}
