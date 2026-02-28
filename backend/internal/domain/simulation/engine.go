// simulation/engine.go - 模拟引擎（领域层）
package simulation

import (
	"context"
	"fmt"
	"math"
	"math/rand"
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
		e.volunteerGenerator = NewStrategyVolunteerGenerator(e.schoolRepo)
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
	competitors, totalCandidates := e.generateCompetitors(ctx, realCandidate, req)
	logger.Info(ctx, "step 4: generated competitors",
		logger.Int("competitor_count", len(competitors)),
		logger.Int("total_candidates", totalCandidates),
		logger.String("duration", time.Since(stepStart).String()),
	)

	// 5. 执行多次模拟，统计录取概率
	stepStart = time.Now()
	probabilities := e.runSimulations(ctx, realCandidate, competitors, totalCandidates, req)
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

	// 7. 生成竞争对手分析报告（使用实际生成的竞争对手）
	stepStart = time.Now()
	competitorAnalysis := e.generateCompetitorAnalysis(competitors)
	logger.Debug(ctx, "step 7: competitor analysis generated",
		logger.Int("competitor_count", len(competitors)),
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

	// 如果没有提供各科分数，基于总分估算（用于统一招生批次750分制计算）
	// 各科满分：语文150、数学150、外语150、综合150、道德法治30、历史30、体育30（共690分，实际满分750分有60分综合测试）
	// 使用典型比例估算
	if c.ChineseScore == 0 && c.MathScore == 0 && req.Scores.Total > 0 {
		total750 := float64(req.Scores.Total) // 750分制
		// 按照各科满分比例分配
		c.ChineseScore = total750 * 150 / 750
		c.MathScore = total750 * 150 / 750
		c.ForeignScore = total750 * 150 / 750
		c.IntegratedScore = total750 * 150 / 750
		c.EthicsScore = total750 * 60 / 750
		c.HistoryScore = total750 * 60 / 750
		c.PEScore = total750 * 30 / 750
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
// 关键优化：只生成排名在考生之前的竞争对手（他们才会抢走名额）
// 竞争对手的志愿按照学校排名和冲稳保策略生成
// 返回：竞争对手列表，全区考生总数
func (e *Engine) generateCompetitors(ctx context.Context, realCandidate *Candidate, req *highschoolv1.SubmitAnalysisRequest) ([]*Candidate, int) {
	// 获取全区考生数量
	districtExamCount := 10000 // 默认值
	if e.quotaRepo != nil {
		count, err := e.quotaRepo.GetDistrictExamCount(ctx, req.Candidate.DistrictId, 2025)
		if err == nil && count > 0 {
			districtExamCount = count
		}
	}

	// 获取预估区内排名
	districtRank := e.estimateDistrictRank(ctx, req)
	if districtRank <= 0 {
		districtRank = 1 // 至少生成0个竞争对手
	}

	// 关键：只生成排名在考生之前的竞争对手
	// 这些人才会抢走考生的名额，排名在考生之后的人不影响录取结果
	competitorCount := int(districtRank) - 1
	if competitorCount <= 0 {
		return []*Candidate{}, districtExamCount // 排名第1，没有竞争对手
	}

	logger.Debug(ctx, "generating competitors",
		logger.Int("district_rank", int(districtRank)),
		logger.Int("district_total", districtExamCount),
		logger.Int("competitor_count", competitorCount),
	)

	// 使用随机分数生成器（加入时间戳确保每次请求的随机性）
	seed := time.Now().UnixNano() + int64(realCandidate.TotalScore*1000)
	gen := NewRandomScoreGenerator(seed)
	rng := rand.New(rand.NewSource(seed)) // 用于志愿生成

	// 预加载区县学校数据（优化性能，避免每个竞争对手都查询数据库）
	if e.volunteerGenerator != nil {
		e.volunteerGenerator.PreloadDistrictData(ctx, realCandidate.DistrictID, realCandidate.MiddleSchoolID)
	}

	// 预加载名额分配数据（优化性能，避免每次录取模拟都查询数据库）
	if e.quotaRepo != nil {
		e.quotaRepo.PreloadCache(ctx, realCandidate.DistrictID, realCandidate.MiddleSchoolID, 2025)
	}

	competitors := make([]*Candidate, competitorCount)

	// 计算同一所初中学校的竞争对手数量
	// 关键修复：对于名额分配到校批次，必须生成所有校内竞争对手
	// 因为名额分配到校是基于校内排名竞争，不能只采样一部分
	// 考生的校排名是 req.Ranking.Rank，所以有 (req.Ranking.Rank - 1) 个校内竞争对手
	sameSchoolCompetitorCount := int(req.Ranking.Rank - 1)
	if sameSchoolCompetitorCount < 0 {
		sameSchoolCompetitorCount = 0
	}
	// 如果同校竞争者数量超过总竞争者数量，需要调整
	// 但这种情况很少见（只有当考生排名非常靠前时）
	if sameSchoolCompetitorCount > competitorCount {
		// 考生校内排名很靠前，同校竞争者数量超过采样的竞争者总数
		// 这种情况下，所有竞争者都来自同校
		sameSchoolCompetitorCount = competitorCount
	}

	// 计算学校比例（用于日志）
	schoolRatio := float64(req.Ranking.TotalStudents) / float64(districtExamCount)

	logger.Debug(ctx, "competitor school distribution",
		logger.Int("total_competitors", competitorCount),
		logger.Int("same_school_competitors", sameSchoolCompetitorCount),
		logger.Int("school_rank", int(req.Ranking.Rank)),
		logger.Float64("school_ratio", schoolRatio),
	)

	for i := 0; i < competitorCount; i++ {
		// 计算该竞争对手的排名位置
		// 关键修复：竞争对手应该均匀分布在 [1, districtRank-1] 范围内
		// 而不是只取前 N 个排名靠前的竞争者
		var competitorRank int
		var competitorSchoolRank, competitorSchoolTotal int32
		var competitorMiddleSchoolID int32

		if i < sameSchoolCompetitorCount {
			// 同校竞争对手：使用校排名（1, 2, 3, ...）
			competitorSchoolRank = int32(i + 1)
			competitorSchoolTotal = req.Ranking.TotalStudents
			competitorMiddleSchoolID = realCandidate.MiddleSchoolID
			// 根据校排名估算区排名
			// 假设学校内排名与区排名成正比
			competitorRank = int(float64(competitorSchoolRank) / float64(req.Ranking.TotalStudents) * float64(districtExamCount))
			if competitorRank < 1 {
				competitorRank = 1
			}
		} else {
			// 其他竞争对手：均匀分布在 [1, districtRank-1] 范围内
			// 使用步长采样，确保竞争者覆盖整个分数范围
			otherCompetitorCount := competitorCount - sameSchoolCompetitorCount
			otherCompetitorIndex := i - sameSchoolCompetitorCount
			// 均匀分布：从区排名 1 到 (districtRank-1) 之间采样
			competitorRank = int(float64(otherCompetitorIndex+1) / float64(otherCompetitorCount+1) * float64(districtRank-1))
			if competitorRank < 1 {
				competitorRank = 1
			}
			// 其他学校的竞争对手不参与名额分配到校竞争
			competitorMiddleSchoolID = realCandidate.MiddleSchoolID + int32(i%100 + 1)
			competitorSchoolRank = int32(competitorRank)
			competitorSchoolTotal = int32(districtExamCount)
		}

		// 分数计算：基于排名的映射
		// 竞争对手是排名在考生之前的人，他们的分数应该普遍高于考生
		// 但分数分布应该更真实：
		// - 排名第1的竞争对手分数约740-750
		// - 排名靠后的竞争对手分数逐渐降低
		// - 考生分数在竞争对手中应该排名靠后
		//
		// 分数范围设计：
		// 高分段（前10%）：700-750
		// 中分段（10%-50%）：620-700
		// 低分段（后50%）：520-620
		maxScore := 750.0
		minCompetitorScore := 520.0 // 最低分（比录取线低很多，确保低排名学校也能录满）

		// 计算分数范围
		rankFraction := float64(competitorRank) / float64(districtExamCount)

		var totalScore750 float64
		if rankFraction <= 0.1 {
			// 前10%：高分段，分数 700-750
			// 使用更陡峭的曲线让顶级考生的分数更高
			localFraction := rankFraction / 0.1 // 0-1
			totalScore750 = maxScore - localFraction*50
		} else if rankFraction <= 0.5 {
			// 10%-50%：中分段，分数 620-700
			localFraction := (rankFraction - 0.1) / 0.4 // 0-1
			totalScore750 = 700 - localFraction*80
		} else {
			// 后50%：低分段，分数 520-620
			localFraction := (rankFraction - 0.5) / 0.5 // 0-1
			totalScore750 = 620 - localFraction*100
		}

		// 添加随机波动（±15分，减少波动范围让分数更稳定）
		totalScore750 += gen.GenerateRandomScore(-15, 15)

		// 确保分数在合理范围内
		totalScore750 = clamp(totalScore750, minCompetitorScore, maxScore)

		// Debug: 只为第一个和最后一个竞争对手打印
		if i == 0 || i == competitorCount-1 {
			fmt.Printf("[DEBUG-V5] i=%d, competitorRank=%d, rankFraction=%.4f, totalScore750=%.2f\n",
				i, competitorRank, rankFraction, totalScore750)
		}

		// 生成各科分数
		chinese, math, foreign, integrated, ethics, history, pe := gen.GenerateCompetitorScores(totalScore750, 30)

		// 计算总分（800分制，包含综合素质评价）
		totalScore800 := chinese + math + foreign + integrated + ethics + history + pe + realCandidate.ComprehensiveQuality

		// 随机决定是否有名额分配到校资格（70%概率）
		hasQuotaSchoolEligible := gen.GenerateRandomScore(0, 1) > 0.3

		competitors[i] = &Candidate{
			ID:                     int32(i + 1),
			IsRealCandidate:        false,
			DistrictID:             realCandidate.DistrictID,
			MiddleSchoolID:         competitorMiddleSchoolID,
			TotalScore:             totalScore800,
			ChineseScore:           chinese,
			MathScore:              math,
			ForeignScore:           foreign,
			IntegratedScore:        integrated,
			EthicsScore:            ethics,
			HistoryScore:           history,
			PEScore:                pe,
			ComprehensiveQuality:   realCandidate.ComprehensiveQuality,
			HasTiePreference:       false,
			SchoolRank:             competitorSchoolRank,
			SchoolTotalStudents:    competitorSchoolTotal,
			HasQuotaSchoolEligible: hasQuotaSchoolEligible,
		}

		// 使用志愿生成器生成符合冲稳保策略的志愿
		// 基于排名而非分数生成志愿
		if e.volunteerGenerator != nil {
			// 生成统一招生志愿（1-15志愿）- 基于区排名
			competitors[i].UnifiedSchoolIDs = e.volunteerGenerator.GenerateUnifiedVolunteers(ctx, competitorRank, districtExamCount, realCandidate.DistrictID, rng)

			// 生成名额分配到区志愿 - 基于区排名
			competitors[i].QuotaDistrictSchoolID = e.volunteerGenerator.GenerateQuotaDistrictVolunteer(ctx, competitorRank, districtExamCount, realCandidate.DistrictID, rng)

			// 生成名额分配到校志愿
			// 对于同校竞争对手，使用校排名生成志愿；对于其他竞争对手，使用区排名
			var quotaSchoolRank, quotaSchoolTotal int
			if i < sameSchoolCompetitorCount {
				// 同校竞争对手：使用校排名（1, 2, 3, ...）和学校人数
				quotaSchoolRank = i + 1 // 校排名从1开始
				quotaSchoolTotal = int(req.Ranking.TotalStudents)
			} else {
				// 其他竞争对手：使用区排名
				quotaSchoolRank = competitorRank
				quotaSchoolTotal = districtExamCount
			}
			competitors[i].QuotaSchoolIDs = e.volunteerGenerator.GenerateQuotaSchoolVolunteers(
				ctx, quotaSchoolRank, quotaSchoolTotal, realCandidate.DistrictID, realCandidate.MiddleSchoolID, hasQuotaSchoolEligible, rng)
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

	return competitors, districtExamCount
}

// runSimulations 执行多次录取模拟
// totalCandidates: 全区考生总数，用于志愿生成时的排名百分位计算
func (e *Engine) runSimulations(ctx context.Context, realCandidate *Candidate, competitors []*Candidate, totalCandidates int, req *highschoolv1.SubmitAnalysisRequest) []*highschoolv1.VolunteerProbability {
	logger.Debug(ctx, "runSimulations started",
		logger.Int("total_simulations", e.simulationCount),
		logger.Int("competitor_count", len(competitors)),
		logger.Int("total_candidates", totalCandidates),
	)

	// 统计各志愿的录取次数
	admissionCounts := make(map[string]int) // key: "批次_学校ID"
	totalSimulations := e.simulationCount

	// 时间种子：确保每次请求的模拟结果不同
	baseSeed := time.Now().UnixNano()
	logger.Debug(ctx, "simulation seeds generated",
		logger.Int64("base_seed", baseSeed),
		logger.Int("simulation_count", totalSimulations),
	)

	// 并发执行模拟
	var wg sync.WaitGroup
	var mu sync.Mutex

	// 限制并发数
	sem := make(chan struct{}, 10) // 最多10个并发

	// 每次模拟使用不同的随机种子（时间种子 + 模拟序号）
	for sim := 0; sim < totalSimulations; sim++ {
		wg.Add(1)
		go func(simIndex int) {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()

			// 种子 = 时间种子 + 模拟序号（确保每次请求、每次模拟都不同）
			seed := int(baseSeed) + simIndex
			candidates := e.cloneCandidates(ctx, realCandidate, competitors, seed, totalCandidates, req)


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

	// 统计录取结果分布
	logger.Info(ctx, "simulation admission results",
		logger.Int("unique_schools", len(admissionCounts)),
		logger.Any("distribution", admissionCounts),
		logger.Float64("original_score", realCandidate.TotalScore),
	)

	logger.Debug(ctx, "runSimulations completed",
		logger.Int("unique_admission_results", len(admissionCounts)),
	)

	// 计算各志愿的概率
	return e.calculateVolunteerProbabilities(ctx, req, admissionCounts, totalSimulations)
}

// cloneCandidates 复制考生数据、添加随机扰动、重新生成志愿
// 志愿的变化是蒙特卡洛模拟的核心不确定因素
// 分数的微小扰动模拟考试发挥的随机性
// totalCandidates: 全区考生总数，用于计算排名百分位
func (e *Engine) cloneCandidates(ctx context.Context, realCandidate *Candidate, competitors []*Candidate, seed int, totalCandidates int, req *highschoolv1.SubmitAnalysisRequest) []*Candidate {
	gen := NewRandomScoreGenerator(int64(seed))
	// 创建用于志愿生成的随机源（使用相同种子确保可重复性）
	rng := rand.New(rand.NewSource(int64(seed)))

	logger.Debug(ctx, "cloneCandidates called",
		logger.Int("seed", seed),
		logger.Int("total_candidates", totalCandidates),
		logger.Bool("has_volunteer_generator", e.volunteerGenerator != nil),
	)

	// 复制真实考生（保持原志愿不变，但分数加入较大扰动）
	// 使用正态分布扰动，标准差12分，与竞争对手一致
	// 这样可以模拟考试发挥的不确定性，产生不同的录取结果
	realCopy := *realCandidate
	scorePerturbation := gen.GenerateNormalScore(0, 12)
	realCopy.TotalScore += scorePerturbation // 正态分布，标准差12分

	// Debug: 验证 IsRealCandidate 被正确复制
	logger.Info(ctx, "cloneCandidates: real candidate cloned",
		logger.Bool("is_real_candidate", realCopy.IsRealCandidate),
		logger.Float64("total_score", realCopy.TotalScore),
		logger.Float64("comprehensive_quality", realCopy.ComprehensiveQuality),
	)

	// 使用 simIndex 来控制日志输出（需要传入）
	// 这里通过 seed 的低位来判断
	simIndex := seed % 1000 // 简单提取 simIndex
	if simIndex < 3 {
		logger.Info(ctx, "score perturbation",
			logger.Int("sim_index", simIndex),
			logger.Float64("perturbation", scorePerturbation),
			logger.Float64("perturbed_score", realCopy.TotalScore),
			logger.Float64("original_score", realCandidate.TotalScore),
		)
	}

	candidates := []*Candidate{&realCopy}

	// 复制竞争对手并重新生成志愿（核心：志愿的不确定性）
	for _, c := range competitors {
		competitorCopy := *c

		// 分数扰动（模拟考试发挥的随机性）
		// 使用较大的标准差以产生更真实的模拟结果
		// 这意味着约68%的考生分数波动在±12分内，约95%在±24分内
		competitorCopy.TotalScore += gen.GenerateNormalScore(0, 12) // 正态分布，标准差12分

		// 重新生成志愿 - 这是蒙特卡洛模拟的关键
		// 基于排名（ID）而非分数生成志愿
		if e.volunteerGenerator != nil {
			// 使用竞争者的ID作为排名（1-indexed）
			competitorRank := int(competitorCopy.ID)
			competitorCopy.UnifiedSchoolIDs = e.volunteerGenerator.GenerateUnifiedVolunteers(ctx, competitorRank, totalCandidates, competitorCopy.DistrictID, rng)
			competitorCopy.QuotaDistrictSchoolID = e.volunteerGenerator.GenerateQuotaDistrictVolunteer(ctx, competitorRank, totalCandidates, competitorCopy.DistrictID, rng)
			// 名额分配到校志愿使用校排名（关键：同校竞争者使用 SchoolRank，其他竞争者使用区排名）
			competitorCopy.QuotaSchoolIDs = e.volunteerGenerator.GenerateQuotaSchoolVolunteers(
				ctx, int(competitorCopy.SchoolRank), int(competitorCopy.SchoolTotalStudents), competitorCopy.DistrictID, competitorCopy.MiddleSchoolID, competitorCopy.HasQuotaSchoolEligible, rng)
		} else {
			// 回退：使用考生的志愿
			if req.Volunteers.QuotaDistrict != nil {
				if gen.GenerateRandomScore(0, 1) > 0.5 {
					competitorCopy.QuotaDistrictSchoolID = req.Volunteers.QuotaDistrict
				} else {
					competitorCopy.QuotaDistrictSchoolID = nil
				}
			}
		}

		candidates = append(candidates, &competitorCopy)
	}

	return candidates
}

// calculateVolunteerProbabilities 计算各志愿录取概率
func (e *Engine) calculateVolunteerProbabilities(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest, admissionCounts map[string]int, totalSimulations int) []*highschoolv1.VolunteerProbability {
	var probabilities []*highschoolv1.VolunteerProbability

	// 考生分数（750分制）= 总分 - 综合素质评价
	// req.Scores.Total 可能是750分制（学业考成绩）或800分制（含综素）
	// 需要减去综合素质分得到750分制成绩，用于统一招生批次风险评估
	candidateScore750 := float64(req.Scores.Total) - float64(req.ComprehensiveQuality)
	if candidateScore750 < 0 {
		candidateScore750 = float64(req.Scores.Total) // 如果减完为负，说明输入已经是750分制
	}

	// 获取学校分数线排名用于风险评估
	rankings, _ := e.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, req.Candidate.DistrictId)
	cutoffMap := make(map[int32]float64)
	for _, r := range rankings {
		cutoffMap[r.ID] = r.CutoffScore
	}

	// 名额分配到区
	if req.Volunteers.QuotaDistrict != nil {
		key := fmt.Sprintf("QUOTA_DISTRICT_%d", *req.Volunteers.QuotaDistrict)
		count := admissionCounts[key]
		prob := float64(count) / float64(totalSimulations) * 100
		schoolName := e.getSchoolName(ctx, *req.Volunteers.QuotaDistrict)
		schoolID := *req.Volunteers.QuotaDistrict
		cutoff := cutoffMap[schoolID]
		riskLevel := getRiskLevelWithScore(prob, candidateScore750, cutoff)

		logger.Debug(ctx, "QuotaDistrict probability calculation",
			logger.Int("school_id", int(schoolID)),
			logger.Float64("candidate_score_750", candidateScore750),
			logger.Float64("cutoff_score", cutoff),
			logger.Float64("score_diff", cutoff-candidateScore750),
			logger.Float64("probability", prob),
			logger.String("risk_level", riskLevel),
		)

		probabilities = append(probabilities, &highschoolv1.VolunteerProbability{
			Batch:          "QUOTA_DISTRICT",
			SchoolId:       schoolID,
			SchoolName:     schoolName,
			Probability:    prob,
			RiskLevel:      riskLevel,
			VolunteerIndex: 1,
		})
	}

	// 名额分配到校
	for i, schoolID := range req.Volunteers.QuotaSchool {
		key := fmt.Sprintf("QUOTA_SCHOOL_%d", schoolID)
		count := admissionCounts[key]
		prob := float64(count) / float64(totalSimulations) * 100
		schoolName := e.getSchoolName(ctx, schoolID)
		cutoff := cutoffMap[schoolID]
		probabilities = append(probabilities, &highschoolv1.VolunteerProbability{
			Batch:          "QUOTA_SCHOOL",
			SchoolId:       schoolID,
			SchoolName:     schoolName,
			Probability:    prob,
			RiskLevel:      getRiskLevelWithScore(prob, candidateScore750, cutoff),
			VolunteerIndex: int32(i + 1),
		})
	}

	// 统一招生
	for i, schoolID := range req.Volunteers.Unified {
		key := fmt.Sprintf("UNIFIED_%d", schoolID)
		count := admissionCounts[key]
		prob := float64(count) / float64(totalSimulations) * 100
		schoolName := e.getSchoolName(ctx, schoolID)
		cutoff := cutoffMap[schoolID]
		probabilities = append(probabilities, &highschoolv1.VolunteerProbability{
			Batch:          "UNIFIED_1_15",
			SchoolId:       schoolID,
			SchoolName:     schoolName,
			Probability:    prob,
			RiskLevel:      getRiskLevelWithScore(prob, candidateScore750, cutoff),
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

// getRiskLevelWithScore 根据概率和分数差距获取风险等级
// 如果考生分数远低于学校分数线，即使模拟概率高也标记为高风险
func getRiskLevelWithScore(prob float64, candidateScore float64, cutoffScore float64) string {
	// 如果没有分数线数据，使用纯概率判断
	if cutoffScore == 0 {
		return getRiskLevel(prob)
	}

	// 计算分数差距（正数表示考生分数低于分数线）
	scoreDiff := cutoffScore - candidateScore

	// 关键规则：如果考生分数低于分数线超过30分，始终标记为高风险
	// 这是因为即使模拟显示高概率（因为竞争者少），实际录取可能性极低
	if scoreDiff > 30 {
		return "high_risk"
	}

	// 如果分数差距在15-30分之间，模拟概率高也只标记为risky
	if scoreDiff > 15 {
		if prob >= 80 {
			return "risky"
		}
		return "high_risk"
	}

	// 其他情况使用纯概率判断
	return getRiskLevel(prob)
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// generateCompetitorAnalysis 根据实际竞争对手生成竞争态势分析
func (e *Engine) generateCompetitorAnalysis(competitors []*Candidate) *highschoolv1.CompetitorAnalysis {
	// 定义分数区间（750分制）
	ranges := []struct {
		min, max float64
		label    string
	}{
		{700, 750, "700-750"},
		{650, 699.5, "650-699.5"},
		{600, 649.5, "600-649.5"},
		{550, 599.5, "550-599.5"},
		{500, 549.5, "500-549.5"},
		{0, 499.5, "<500"},
	}

	counts := make(map[string]int32)
	for _, r := range ranges {
		counts[r.label] = 0
	}

	// 统计各分数区间的人数（使用750分制）
	for _, c := range competitors {
		// 转换为750分制（去掉综合素质评价）
		score750 := c.TotalScore - c.ComprehensiveQuality
		for _, r := range ranges {
			if score750 >= r.min && score750 <= r.max {
				counts[r.label]++
				break
			}
		}
	}

	var distribution []*highschoolv1.ScoreDistributionItem
	for _, r := range ranges {
		distribution = append(distribution, &highschoolv1.ScoreDistributionItem{
			Range: r.label,
			Count: counts[r.label],
		})
	}

	return &highschoolv1.CompetitorAnalysis{
		Count:             int32(len(competitors)),
		ScoreDistribution: distribution,
	}
}

// normalPercentileToZScore 将正态分布的百分位（0-1）转换为Z分数
// 使用Acklam's approximation算法，精度约为0.001
func normalPercentileToZScore(p float64) float64 {
	// 处理边界情况
	if p <= 0 {
		return -4.0 // 对应极低百分位
	}
	if p >= 1 {
		return 4.0 // 对应极高百分位
	}

	// Acklam's approximation for inverse normal distribution
	// 系数
	a1 := -3.969683028665376e+01
	a2 := 2.209460984245205e+02
	a3 := -2.759285104469687e+02
	a4 := 1.383577518672690e+02
	a5 := -3.066479806614716e+01
	a6 := 2.506628277459239e+00

	b1 := -5.447609879822406e+01
	b2 := 1.615858368580409e+02
	b3 := -1.556989798598866e+02
	b4 := 6.680131188771972e+01
	b5 := -1.328068155288572e+01

	c1 := -7.784894002430293e-03
	c2 := -3.223964580411365e-01
	c3 := -2.400758277161838e+00
	c4 := -2.549732539343734e+00
	c5 := 4.374664141464968e+00
	c6 := 2.938163982698783e+00

	const d1 = 7.784695709041462e-03
	const d2 = 3.224671290700398e-01
	const d3 = 2.445134137142996e+00
	const d4 = 3.754408661907416e+00

	const p_low = 0.02425
	const p_high = 1 - p_low

	var q, r, z float64

	if p < p_low {
		// Rational approximation for lower region
		q = math.Sqrt(-2 * math.Log(p))
		z = (((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q + c6) / ((((d1*q+d2)*q+d3)*q+d4)*q + 1)
	} else if p <= p_high {
		// Rational approximation for central region
		q = p - 0.5
		r = q * q
		z = (((((a1*r+a2)*r+a3)*r+a4)*r+a5)*r + a6) * q / (((((b1*r+b2)*r+b3)*r+b4)*r + b5)*r + 1)
	} else {
		// Rational approximation for upper region
		q = math.Sqrt(-2 * math.Log(1-p))
		z = -(((((c1*q+c2)*q+c3)*q+c4)*q+c5)*q + c6) / ((((d1*q+d2)*q+d3)*q+d4)*q + 1)
	}

	return z
}
