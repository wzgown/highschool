// simulation/engine.go - 模拟引擎（领域层）
package simulation

import (
	"context"
	"fmt"
	"sync"
	"time"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
	"highschool-backend/pkg/logger"
)

// Engine 模拟引擎
type Engine struct {
	competitorGenerator *CompetitorGenerator
	volunteerGenerator  VolunteerGenerator
	schoolRepo          repository.SchoolRepository
	quotaRepo           QuotaRepository
	simulationCount     int // 模拟次数
}

// EngineOption 引擎配置选项
type EngineOption func(*Engine)

// WithSchoolRepository 设置学校仓库
func WithSchoolRepo(repo repository.SchoolRepository) EngineOption {
	return func(e *Engine) {
		e.schoolRepo = repo
	}
}

// WithQuotaRepository 设置名额仓库
func WithQuotaRepo(repo QuotaRepository) EngineOption {
	return func(e *Engine) {
		e.quotaRepo = repo
	}
}

// WithSimulationCount 设置模拟次数
func WithSimulationCount(count int) EngineOption {
	return func(e *Engine) {
		e.simulationCount = count
	}
}

// NewEngine 创建模拟引擎
func NewEngine(opts ...EngineOption) *Engine {
	e := &Engine{
		competitorGenerator: NewCompetitorGenerator(),
		schoolRepo:          repository.NewSchoolRepository(),
		simulationCount:     100, // 默认模拟100次（性能考虑）
	}
	for _, opt := range opts {
		opt(e)
	}
	// 初始化志愿生成器（如果schoolRepo已设置）
	if e.schoolRepo != nil {
		e.volunteerGenerator = NewStrategyVolunteerGenerator(e.schoolRepo, 2025)
	}
	return e
}

// Run 执行模拟分析
// 按照设计意图：
// 1. 将考生信息转换为内部Candidate模型
// 2. 生成虚拟竞争对手
// 3. 执行N次录取模拟（按批次顺序：名额分配到区 → 名额分配到校 → 统一招生）
// 4. 统计录取概率
// 5. 分析志愿策略
func (e *Engine) Run(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults {
	startTime := time.Now()
	logger.Debug(ctx, "Engine.Run started")

	// 1. 计算百分位
	stepStart := time.Now()
	percentile := float64(req.Ranking.TotalStudents-req.Ranking.Rank) / float64(req.Ranking.TotalStudents) * 100
	logger.Debug(ctx, "step 1: calculated percentile",
		logger.Float64("percentile", percentile),
		logger.String("duration", time.Since(stepStart).String()),
	)

	// 2. 预测区内排名（基于校排名和全区中考人数估算）
	stepStart = time.Now()
	districtRank := e.estimateDistrictRank(ctx, req)
	logger.Debug(ctx, "step 2: estimated district rank",
		logger.Int("district_rank", int(districtRank)),
		logger.String("duration", time.Since(stepStart).String()),
	)

	predictions := &highschoolv1.RankPrediction{
		DistrictRank:          districtRank,
		DistrictRankRangeLow:  districtRank - 100,
		DistrictRankRangeHigh: districtRank + 100,
		Confidence:            e.calculateConfidence(percentile),
		Percentile:            percentile,
	}

	// 3. 转换考生信息为内部模型
	stepStart = time.Now()
	realCandidate := e.convertToCandidate(req)
	logger.Debug(ctx, "step 3: converted to candidate model",
		logger.Float64("total_score", realCandidate.TotalScore),
		logger.Bool("has_quota_eligibility", realCandidate.HasQuotaSchoolEligible),
		logger.String("duration", time.Since(stepStart).String()),
	)

	// 4. 生成竞争对手（基于排名和分数分布）
	stepStart = time.Now()
	competitors := e.generateCompetitors(ctx, realCandidate, req)
	logger.Info(ctx, "step 4: generated competitors",
		logger.Int("competitor_count", len(competitors)),
		logger.String("duration", time.Since(stepStart).String()),
	)

	// 5. 执行多次模拟，统计录取概率
	stepStart = time.Now()
	probabilities := e.runSimulations(ctx, realCandidate, competitors, req)
	logger.Info(ctx, "step 5: simulations completed",
		logger.Int("simulation_count", e.simulationCount),
		logger.Int("probabilities_count", len(probabilities)),
		logger.String("duration", time.Since(stepStart).String()),
	)

	// 6. 策略分析
	stepStart = time.Now()
	strategy := e.analyzeStrategy(probabilities)
	logger.Debug(ctx, "step 6: strategy analysis completed",
		logger.Int("strategy_score", int(strategy.Score)),
		logger.Int("safety_count", int(strategy.Gradient.Safety)),
		logger.Int("target_count", int(strategy.Gradient.Target)),
		logger.Int("reach_count", int(strategy.Gradient.Reach)),
		logger.String("duration", time.Since(stepStart).String()),
	)

	// 7. 生成竞争对手分析报告
	stepStart = time.Now()
	competitorAnalysis := e.competitorGenerator.Generate(req, 100)
	logger.Debug(ctx, "step 7: competitor analysis generated",
		logger.String("duration", time.Since(stepStart).String()),
	)

	logger.Info(ctx, "Engine.Run completed",
		logger.String("total_duration", time.Since(startTime).String()),
		logger.String("confidence", predictions.Confidence),
	)

	return &highschoolv1.SimulationResults{
		Predictions:   predictions,
		Probabilities: probabilities,
		Strategy:      strategy,
		Competitors:   competitorAnalysis,
	}
}

// convertToCandidate 将请求转换为内部Candidate模型
func (e *Engine) convertToCandidate(req *highschoolv1.SubmitAnalysisRequest) *Candidate {
	c := &Candidate{
		ID:                     0, // 真实考生ID为0
		IsRealCandidate:        true,
		DistrictID:             req.Candidate.DistrictId,
		MiddleSchoolID:         req.Candidate.MiddleSchoolId,
		TotalScore:             float64(req.Scores.Total) + float64(req.ComprehensiveQuality), // 名额分配批次用800分制
		ChineseScore:           float64(req.Scores.Chinese),
		MathScore:              float64(req.Scores.Math),
		ForeignScore:           float64(req.Scores.Foreign),
		IntegratedScore:        float64(req.Scores.Integrated),
		EthicsScore:            float64(req.Scores.Ethics),
		HistoryScore:           float64(req.Scores.History),
		PEScore:                float64(req.Scores.Pe),
		ComprehensiveQuality:   float64(req.ComprehensiveQuality),
		HasTiePreference:       req.IsTiePreferred,
		SchoolRank:             req.Ranking.Rank,
		SchoolTotalStudents:    req.Ranking.TotalStudents,
		HasQuotaSchoolEligible: req.Candidate.HasQuotaSchoolEligibility,
	}

	// 设置志愿
	if req.Volunteers.QuotaDistrict != nil {
		c.QuotaDistrictSchoolID = req.Volunteers.QuotaDistrict
	}
	c.QuotaSchoolIDs = req.Volunteers.QuotaSchool
	c.UnifiedSchoolIDs = req.Volunteers.Unified

	return c
}

// generateCompetitors 生成虚拟竞争对手
// 竞争对手的志愿按照学校排名和冲稳保策略生成
func (e *Engine) generateCompetitors(ctx context.Context, realCandidate *Candidate, req *highschoolv1.SubmitAnalysisRequest) []*Candidate {
	// 获取全区考生数量
	districtExamCount := 10000 // 默认值
	if e.quotaRepo != nil {
		count, err := e.quotaRepo.GetDistrictExamCount(ctx, req.Candidate.DistrictId, 2025)
		if err == nil && count > 0 {
			districtExamCount = count
		}
	}

	// 生成竞争对手数量（基于区内排名预测）
	competitorCount := min(districtExamCount/10, 500) // 最多500个竞争对手

	// 使用随机分数生成器
	gen := NewRandomScoreGenerator(int64(realCandidate.TotalScore * 1000))

	competitors := make([]*Candidate, competitorCount)
	for i := 0; i < competitorCount; i++ {
		// 生成分数（以考生分数为中心，正态分布）
		scoreVariation := 50.0 // 标准差50分
		totalScore := gen.GenerateNormalScore(realCandidate.TotalScore, scoreVariation)

		// 生成各科分数
		chinese, math, foreign, integrated, ethics, history, pe := gen.GenerateCompetitorScores(totalScore-realCandidate.ComprehensiveQuality, scoreVariation)

		// 随机决定是否有名额分配到校资格（70%概率）
		hasQuotaSchoolEligible := gen.GenerateRandomScore(0, 1) > 0.3

		competitors[i] = &Candidate{
			ID:                     int32(i + 1),
			IsRealCandidate:        false,
			DistrictID:             realCandidate.DistrictID,
			MiddleSchoolID:         realCandidate.MiddleSchoolID,
			TotalScore:             chinese + math + foreign + integrated + ethics + history + pe + realCandidate.ComprehensiveQuality,
			ChineseScore:           chinese,
			MathScore:              math,
			ForeignScore:           foreign,
			IntegratedScore:        integrated,
			EthicsScore:            ethics,
			HistoryScore:           history,
			PEScore:                pe,
			ComprehensiveQuality:   realCandidate.ComprehensiveQuality,
			HasTiePreference:       false,
			HasQuotaSchoolEligible: hasQuotaSchoolEligible,
		}

		// 使用志愿生成器生成符合冲稳保策略的志愿
		if e.volunteerGenerator != nil {
			// 生成统一招生志愿（1-15志愿）
			competitors[i].UnifiedSchoolIDs = e.volunteerGenerator.GenerateUnifiedVolunteers(ctx, totalScore, realCandidate.DistrictID)

			// 生成名额分配到区志愿
			competitors[i].QuotaDistrictSchoolID = e.volunteerGenerator.GenerateQuotaDistrictVolunteer(ctx, totalScore, realCandidate.DistrictID)

			// 生成名额分配到校志愿
			competitors[i].QuotaSchoolIDs = e.volunteerGenerator.GenerateQuotaSchoolVolunteers(
				ctx, totalScore, realCandidate.DistrictID, realCandidate.MiddleSchoolID, hasQuotaSchoolEligible)
		} else {
			// 回退到旧的逻辑：使用考生的志愿
			if req.Volunteers.QuotaDistrict != nil {
				// 竞争对手有一定概率填报相同学校
				if gen.GenerateRandomScore(0, 1) > 0.5 {
					competitors[i].QuotaDistrictSchoolID = req.Volunteers.QuotaDistrict
				}
			}
		}
	}

	return competitors
}

// runSimulations 执行多次录取模拟
func (e *Engine) runSimulations(ctx context.Context, realCandidate *Candidate, competitors []*Candidate, req *highschoolv1.SubmitAnalysisRequest) []*highschoolv1.VolunteerProbability {
	logger.Debug(ctx, "runSimulations started",
		logger.Int("total_simulations", e.simulationCount),
		logger.Int("competitor_count", len(competitors)),
	)

	// 统计各志愿的录取次数
	admissionCounts := make(map[string]int) // key: "批次_学校ID"
	totalSimulations := e.simulationCount

	// 并发执行模拟
	var wg sync.WaitGroup
	var mu sync.Mutex

	// 限制并发数
	sem := make(chan struct{}, 10) // 最多10个并发

	// 每次模拟使用不同的随机种子
	for sim := 0; sim < totalSimulations; sim++ {
		wg.Add(1)
		go func(seed int) {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()

			// 复制考生数据（避免并发修改）
			candidates := e.cloneCandidates(realCandidate, competitors, seed)

			// 创建模拟器并执行
			simulator := NewSimulator(e.quotaRepo, 2025)
			results := simulator.Run(ctx, candidates)

			// 统计真实考生的录取结果
			if result, ok := results[realCandidate.ID]; ok && result != nil {
				key := fmt.Sprintf("%s_%d", result.AdmittedBatch, *result.AdmittedSchoolID)
				mu.Lock()
				admissionCounts[key]++
				mu.Unlock()
			}
		}(sim)
	}
	wg.Wait()

	logger.Debug(ctx, "runSimulations completed",
		logger.Int("unique_admission_results", len(admissionCounts)),
	)

	// 计算各志愿的概率
	return e.calculateVolunteerProbabilities(ctx, req, admissionCounts, totalSimulations)
}

// cloneCandidates 复制考生数据并添加随机扰动
func (e *Engine) cloneCandidates(realCandidate *Candidate, competitors []*Candidate, seed int) []*Candidate {
	gen := NewRandomScoreGenerator(int64(seed))

	// 复制真实考生
	realCopy := *realCandidate
	// 添加小扰动模拟分数波动
	realCopy.TotalScore += gen.GenerateRandomScore(-5, 5)

	candidates := []*Candidate{&realCopy}

	// 复制竞争对手
	for _, c := range competitors {
		competitorCopy := *c
		competitorCopy.TotalScore += gen.GenerateRandomScore(-5, 5)
		candidates = append(candidates, &competitorCopy)
	}

	return candidates
}

// calculateVolunteerProbabilities 计算各志愿录取概率
func (e *Engine) calculateVolunteerProbabilities(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest, admissionCounts map[string]int, totalSimulations int) []*highschoolv1.VolunteerProbability {
	var probabilities []*highschoolv1.VolunteerProbability

	// 名额分配到区
	if req.Volunteers.QuotaDistrict != nil {
		key := fmt.Sprintf("QUOTA_DISTRICT_%d", *req.Volunteers.QuotaDistrict)
		count := admissionCounts[key]
		prob := float64(count) / float64(totalSimulations) * 100
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
		key := fmt.Sprintf("QUOTA_SCHOOL_%d", schoolID)
		count := admissionCounts[key]
		prob := float64(count) / float64(totalSimulations) * 100
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
		key := fmt.Sprintf("UNIFIED_%d", schoolID)
		count := admissionCounts[key]
		prob := float64(count) / float64(totalSimulations) * 100
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

// estimateDistrictRank 预测区内排名
func (e *Engine) estimateDistrictRank(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) int32 {
	// 基于校内排名和学校类型估算区内排名
	// 简化计算：假设学校水平相近，直接按比例换算
	if req.Ranking.TotalStudents <= 0 {
		return 0
	}

	// 获取全区中考人数
	districtTotal := 10000 // 默认值
	if e.quotaRepo != nil {
		count, err := e.quotaRepo.GetDistrictExamCount(ctx, req.Candidate.DistrictId, 2025)
		if err == nil && count > 0 {
			districtTotal = count
		}
	}

	// 区内排名 = 校内排名 / 校内总人数 * 区内总人数
	ratio := float64(req.Ranking.Rank) / float64(req.Ranking.TotalStudents)
	return int32(ratio * float64(districtTotal))
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

// getSchoolName 从数据库获取学校名称
func (e *Engine) getSchoolName(ctx context.Context, id int32) string {
	school, err := e.schoolRepo.GetByID(ctx, id)
	if err != nil || school == nil {
		return fmt.Sprintf("学校%d", id)
	}
	return school.FullName
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

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
