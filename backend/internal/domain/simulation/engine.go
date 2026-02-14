// simulation/engine.go - 模拟引擎（领域层）
package simulation

import (
	"context"
	"fmt"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
)

// Engine 模拟引擎
type Engine struct {
	competitorGenerator *CompetitorGenerator
	schoolRepo          repository.SchoolRepository
}

// EngineOption 引擎配置选项
type EngineOption func(*Engine)

// WithSchoolRepository 设置学校仓库
func WithSchoolRepo(repo repository.SchoolRepository) EngineOption {
	return func(e *Engine) {
		e.schoolRepo = repo
	}
}

// NewEngine 创建模拟引擎
func NewEngine(opts ...EngineOption) *Engine {
	e := &Engine{
		competitorGenerator: NewCompetitorGenerator(),
		schoolRepo:          repository.NewSchoolRepository(),
	}
	for _, opt := range opts {
		opt(e)
	}
	return e
}

// Run 执行模拟分析
func (e *Engine) Run(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults {
	// 1. 计算百分位
	percentile := float64(req.Ranking.TotalStudents-req.Ranking.Rank) / float64(req.Ranking.TotalStudents) * 100

	// 2. 预测区内排名（简化计算）
	districtRank := int32(float64(req.Ranking.Rank) * 12.5)

	predictions := &highschoolv1.RankPrediction{
		DistrictRank:          districtRank,
		DistrictRankRangeLow:  districtRank - 100,
		DistrictRankRangeHigh: districtRank + 100,
		Confidence:            e.calculateConfidence(percentile),
		Percentile:            percentile,
	}

	// 3. 计算各志愿概率
	probabilities := e.calculateProbabilities(ctx, req)

	// 4. 策略分析
	strategy := e.analyzeStrategy(probabilities)

	// 5. 生成竞争对手分析
	competitors := e.competitorGenerator.Generate(req, 100)

	return &highschoolv1.SimulationResults{
		Predictions:   predictions,
		Probabilities: probabilities,
		Strategy:      strategy,
		Competitors:   competitors,
	}
}

// calculateConfidence 计算置信度
func (e *Engine) calculateConfidence(percentile float64) string {
	if percentile >= 30 && percentile <= 70 {
		return "high"
	}
	if percentile >= 15 && percentile <= 85 {
		return "medium"
	}
	return "low"
}

// calculateProbabilities 计算各志愿录取概率
func (e *Engine) calculateProbabilities(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) []*highschoolv1.VolunteerProbability {
	var probabilities []*highschoolv1.VolunteerProbability

	// 名额分配到区
	if req.Volunteers.QuotaDistrict != nil {
		prob := e.calculateProbability(req.Scores.Total, 700)
		schoolName := e.getSchoolName(ctx, *req.Volunteers.QuotaDistrict)
		probabilities = append(probabilities, &highschoolv1.VolunteerProbability{
			Batch:          "QUOTA_DISTRICT",
			SchoolId:       *req.Volunteers.QuotaDistrict,
			SchoolName:     schoolName,
			Probability:    prob,
			RiskLevel:      getRiskLevel(prob),
			VolunteerIndex: 1,
		})
	}

	// 名额分配到校
	for i, schoolID := range req.Volunteers.QuotaSchool {
		prob := e.calculateProbability(req.Scores.Total, 680)
		schoolName := e.getSchoolName(ctx, schoolID)
		probabilities = append(probabilities, &highschoolv1.VolunteerProbability{
			Batch:          "QUOTA_SCHOOL",
			SchoolId:       schoolID,
			SchoolName:     schoolName,
			Probability:    prob,
			RiskLevel:      getRiskLevel(prob),
			VolunteerIndex: int32(i + 1),
		})
	}

	// 统一招生
	for i, schoolID := range req.Volunteers.Unified {
		baseScore := 650 - int32(i)*10
		prob := e.calculateProbability(req.Scores.Total, baseScore)
		schoolName := e.getSchoolName(ctx, schoolID)
		probabilities = append(probabilities, &highschoolv1.VolunteerProbability{
			Batch:          "UNIFIED_1_15",
			SchoolId:       schoolID,
			SchoolName:     schoolName,
			Probability:    prob,
			RiskLevel:      getRiskLevel(prob),
			VolunteerIndex: int32(i + 1),
		})
	}

	return probabilities
}

// getSchoolName 从数据库获取学校名称
func (e *Engine) getSchoolName(ctx context.Context, id int32) string {
	school, err := e.schoolRepo.GetByID(ctx, id)
	if err != nil || school == nil {
		return fmt.Sprintf("学校%d", id)
	}
	return school.FullName
}

// calculateProbability 计算单个志愿的录取概率
func (e *Engine) calculateProbability(candidateScore int32, schoolBaseScore int32) float64 {
	diff := candidateScore - schoolBaseScore
	if diff >= 30 {
		return 95.0
	}
	if diff >= 10 {
		return 80.0
	}
	if diff >= -10 {
		return 60.0
	}
	if diff >= -30 {
		return 35.0
	}
	return 15.0
}

// analyzeStrategy 分析志愿策略
func (e *Engine) analyzeStrategy(probabilities []*highschoolv1.VolunteerProbability) *highschoolv1.StrategyAnalysis {
	gradient := &highschoolv1.StrategyGradient{}
	for _, p := range probabilities {
		switch p.RiskLevel {
		case "safe":
			gradient.Safety++
		case "moderate":
			gradient.Target++
		default:
			gradient.Reach++
		}
	}

	score := int32(60)
	if gradient.Safety >= 2 {
		score += 20
	}
	if gradient.Target >= 3 {
		score += 15
	}
	if gradient.Reach <= 3 {
		score += 5
	}

	var suggestions []string
	var warnings []string

	if gradient.Safety < 2 {
		suggestions = append(suggestions, "建议增加保底志愿，避免滑档风险")
		warnings = append(warnings, "当前保底志愿不足")
	}
	if gradient.Reach > 5 {
		suggestions = append(suggestions, "建议减少冲刺志愿数量")
	}

	return &highschoolv1.StrategyAnalysis{
		Score:       score,
		Gradient:    gradient,
		Suggestions: suggestions,
		Warnings:    warnings,
		VolunteerRationality: &highschoolv1.VolunteerRationality{
			HasSafetySchool:       gradient.Safety >= 2,
			IsGradientReasonable:  gradient.Target >= 2,
			HasDuplicateOrInvalid: false,
		},
	}
}

// getRiskLevel 根据概率获取风险等级
func getRiskLevel(prob float64) string {
	if prob >= 80 {
		return "safe"
	}
	if prob >= 50 {
		return "moderate"
	}
	if prob >= 20 {
		return "risky"
	}
	return "high_risk"
}
