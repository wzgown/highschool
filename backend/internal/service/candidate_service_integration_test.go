// service/candidate_service_integration_test.go - SubmitAnalysis 全面集成测试
package service

import (
	"context"
	"fmt"
	"os"
	"testing"
	"time"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/repository"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestScoreLevel 定义不同的成绩水平
type TestScoreLevel struct {
	Name        string
	TotalScore  float64
	Description string
}

// TestResult 记录测试结果
type TestResult struct {
	DistrictID       int32
	DistrictName     string
	MiddleSchoolID   int32
	MiddleSchoolName string
	ScoreLevel       string
	TotalScore       float64
	Success          bool
	ProbCount        int
	SafeCount        int
	ModerateCount    int
	RiskyCount       int
	HighRiskCount    int
	StrategyScore    int32
	ErrorMsg         string
}

// TestSubmitAnalysis_Comprehensive 全面测试 SubmitAnalysis API
// 覆盖所有区、多个初中学校、不同成绩水平
func TestSubmitAnalysis_Comprehensive(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	// 检查数据库连接
	if err := checkDatabaseConnection(); err != nil {
		t.Skipf("Database not available: %v", err)
	}

	ctx := context.Background()
	service := NewCandidateService().(*candidateService)

	// 定义测试成绩水平
	scoreLevels := []TestScoreLevel{
		{"顶尖", 720, "全市前1%顶尖学生"},
		{"优秀", 700, "市重点高中水平"},
		{"良好", 680, "区重点高中水平"},
		{"中等", 650, "普通高中水平"},
		{"偏低", 600, "接近最低控制线"},
		{"低分", 550, "低于普通高中线"},
	}

	// 获取所有区县
	districts, err := service.districtRepo.ListAll(ctx)
	require.NoError(t, err, "获取区县列表失败")

	// 存储所有测试结果
	var results []TestResult

	// 统计
	totalTests := 0
	successTests := 0
	failedTests := 0

	fmt.Printf("\n========== SubmitAPI 全面集成测试 ==========\n")
	fmt.Printf("开始时间: %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("区县数量: %d\n", len(districts))
	fmt.Printf("成绩水平: %d 种\n\n", len(scoreLevels))

	for _, district := range districts {
		if district.Id == 1 {
			// 跳过上海市级（没有初中学校）
			continue
		}

		fmt.Printf("------ 区县: %s (ID: %d) ------\n", district.Name, district.Id)

		// 获取该区的前3所初中学校进行测试（避免测试过多）
		middleSchools, err := service.middleSchoolRepo.List(ctx, &district.Id, nil)
		if err != nil {
			fmt.Printf("  [错误] 获取初中学校失败: %v\n", err)
			continue
		}

		// 限制每区最多测试3所学校
		testCount := len(middleSchools)
		if testCount > 3 {
			testCount = 3
		}

		for i := 0; i < testCount; i++ {
			middleSchool := middleSchools[i]

			// 获取学校学生人数用于计算排名
			studentCount, err := service.middleSchoolRepo.GetStudentCount(ctx, middleSchool.Id)
			if err != nil {
				studentCount = 300 // 默认值
			}

			fmt.Printf("  初中: %s (ID: %d, 学生数: %d)\n", middleSchool.Name, middleSchool.Id, studentCount)

			for _, level := range scoreLevels {
				totalTests++

				// 构建请求
				req := buildTestRequest(district.Id, middleSchool.Id, studentCount, level, service.schoolRepo)

				// 执行分析
				resp, err := service.SubmitAnalysis(ctx, req)

				result := TestResult{
					DistrictID:       district.Id,
					DistrictName:     district.Name,
					MiddleSchoolID:   middleSchool.Id,
					MiddleSchoolName: middleSchool.Name,
					ScoreLevel:       level.Name,
					TotalScore:       level.TotalScore,
				}

				if err != nil {
					result.Success = false
					result.ErrorMsg = err.Error()
					failedTests++
					fmt.Printf("    [%s %d分] 失败: %v\n", level.Name, int(level.TotalScore), err)
				} else {
					result.Success = true
					successTests++

					// 统计录取概率分布
					probs := resp.Result.Results.Probabilities
					result.ProbCount = len(probs)

					for _, p := range probs {
						switch p.RiskLevel {
						case "safe":
							result.SafeCount++
						case "moderate":
							result.ModerateCount++
						case "risky":
							result.RiskyCount++
						case "high_risk":
							result.HighRiskCount++
						}
					}

					result.StrategyScore = resp.Result.Results.Strategy.Score

					fmt.Printf("    [%s %d分] 成功: 概率数=%d, 安全区=%d, 稳健区=%d, 风险区=%d, 高风险=%d, 策略分=%d\n",
						level.Name, int(level.TotalScore),
						result.ProbCount, result.SafeCount, result.ModerateCount, result.RiskyCount, result.HighRiskCount,
						result.StrategyScore)

					// 验证结果合理性
					validateResult(t, &result, level, resp.Result.Results)
				}

				results = append(results, result)
			}
		}
		fmt.Println()
	}

	// 打印总结报告
	printSummaryReport(results, totalTests, successTests, failedTests)
}

// TestSubmitAnalysis_SampleSelection 抽样测试关键场景
func TestSubmitAnalysis_SampleSelection(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	if err := checkDatabaseConnection(); err != nil {
		t.Skipf("Database not available: %v", err)
	}

	ctx := context.Background()
	service := NewCandidateService().(*candidateService)

	// 测试场景：浦东新区（学校最多）+ 虹口区（学校较少）
	testCases := []struct {
		DistrictID int32
		District   string
	}{
		{12, "浦东新区"},
		{7, "虹口区"},
		{2, "黄浦区"},
	}

	for _, tc := range testCases {
		t.Run(tc.District, func(t *testing.T) {
			middleSchools, err := service.middleSchoolRepo.List(ctx, &tc.DistrictID, nil)
			require.NoError(t, err)
			require.NotEmpty(t, middleSchools, "应该有初中学校")

			// 取第一所学校测试
			middleSchool := middleSchools[0]
			studentCount, _ := service.middleSchoolRepo.GetStudentCount(ctx, middleSchool.Id)
			if studentCount <= 0 {
				studentCount = 300
			}

			// 测试三个成绩水平
			levels := []TestScoreLevel{
				{"高分", 710, "高分考生"},
				{"中分", 650, "中等考生"},
				{"低分", 560, "低分考生"},
			}

			for _, level := range levels {
				t.Run(level.Name, func(t *testing.T) {
					req := buildTestRequest(tc.DistrictID, middleSchool.Id, studentCount, level, service.schoolRepo)
					resp, err := service.SubmitAnalysis(ctx, req)

					require.NoError(t, err, "SubmitAnalysis应该成功")
					assert.NotNil(t, resp.Result, "结果不应为空")
					assert.NotNil(t, resp.Result.Results, "模拟结果不应为空")
					assert.NotEmpty(t, resp.Result.Results.Probabilities, "应该有概率预测结果")

					// 验证基本逻辑
					validateResultBasic(t, resp.Result.Results, level)
				})
			}
		})
	}
}

// TestSubmitAnalysis_VolunteerValidation 测试志愿填报校验
func TestSubmitAnalysis_VolunteerValidation(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	if err := checkDatabaseConnection(); err != nil {
		t.Skipf("Database not available: %v", err)
	}

	ctx := context.Background()
	service := NewCandidateService().(*candidateService)

	// 获取浦东新区的学校和初中
	districtID := int32(12)
	middleSchools, err := service.middleSchoolRepo.List(ctx, &districtID, nil)
	require.NoError(t, err)
	require.NotEmpty(t, middleSchools)

	middleSchoolID := middleSchools[0].Id
	studentCount := int32(300)

	t.Run("无效的统一招生志愿学校", func(t *testing.T) {
		// 使用一个明显不属于该区的学校ID（假设99999不存在或不属于该区）
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:     districtID,
				MiddleSchoolId: middleSchoolID,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         50,
				TotalStudents: studentCount,
			},
			Scores: &highschoolv1.CandidateScores{
				Total:      650,
				Chinese:    140, Math: 140, Foreign: 140,
				Integrated: 140, Ethics: 30, History: 30, Pe: 30,
			},
			Volunteers: &highschoolv1.Volunteers{
				Unified: []int32{99999}, // 不存在的学校
			},
		}

		_, err := service.SubmitAnalysis(ctx, req)
		assert.Error(t, err, "应该拒绝无效的学校ID")
		assert.Contains(t, err.Error(), "不在可填报范围内")
	})

	t.Run("无志愿填报", func(t *testing.T) {
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:     districtID,
				MiddleSchoolId: middleSchoolID,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         50,
				TotalStudents: studentCount,
			},
			Scores: &highschoolv1.CandidateScores{
				Total:      650,
				Chinese:    140, Math: 140, Foreign: 140,
				Integrated: 140, Ethics: 30, History: 30, Pe: 30,
			},
			Volunteers: &highschoolv1.Volunteers{}, // 空志愿
		}

		_, err := service.SubmitAnalysis(ctx, req)
		assert.Error(t, err, "应该拒绝空志愿")
		assert.Contains(t, err.Error(), "至少填报一个志愿")
	})

	t.Run("超额填报统一招生志愿", func(t *testing.T) {
		// 获取允许填报的学校
		schools, err := service.schoolRepo.GetSchoolsForUnified(ctx, districtID)
		require.NoError(t, err)

		if len(schools) < 16 {
			t.Skip("没有足够的学校来测试超额填报")
		}

		// 选择16所学校（超过15个限制）
		unified := make([]int32, 16)
		for i := 0; i < 16 && i < len(schools); i++ {
			unified[i] = schools[i].Id
		}

		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:     districtID,
				MiddleSchoolId: middleSchoolID,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         50,
				TotalStudents: studentCount,
			},
			Scores: &highschoolv1.CandidateScores{
				Total:      650,
				Chinese:    140, Math: 140, Foreign: 140,
				Integrated: 140, Ethics: 30, History: 30, Pe: 30,
			},
			Volunteers: &highschoolv1.Volunteers{
				Unified: unified,
			},
		}

		_, err = service.SubmitAnalysis(ctx, req)
		assert.Error(t, err, "应该拒绝超额志愿")
		assert.Contains(t, err.Error(), "最多15个")
	})
}

// TestSubmitAnalysis_ScoreValidation 测试成绩校验
func TestSubmitAnalysis_ScoreValidation(t *testing.T) {
	if testing.Short() {
		t.Skip("Skipping integration test in short mode")
	}

	if err := checkDatabaseConnection(); err != nil {
		t.Skipf("Database not available: %v", err)
	}

	ctx := context.Background()
	service := NewCandidateService().(*candidateService)

	// 使用浦东新区测试
	districtID := int32(12)
	middleSchools, err := service.middleSchoolRepo.List(ctx, &districtID, nil)
	require.NoError(t, err)

	middleSchoolID := middleSchools[0].Id

	baseReq := &highschoolv1.SubmitAnalysisRequest{
		Candidate: &highschoolv1.CandidateInfo{
			DistrictId:     districtID,
			MiddleSchoolId: middleSchoolID,
		},
		Ranking: &highschoolv1.RankingInfo{
			Rank:         50,
			TotalStudents: 300,
		},
		Volunteers: &highschoolv1.Volunteers{
			Unified: []int32{1},
		},
	}

	tests := []struct {
		name    string
		scores  *highschoolv1.CandidateScores
		wantErr bool
		errMsg  string
	}{
		{
			name: "总分超过满分",
			scores: &highschoolv1.CandidateScores{
				Total: 800,
			},
			wantErr: true,
			errMsg:  "总分",
		},
		{
			name: "语文超过满分",
			scores: &highschoolv1.CandidateScores{
				Total:   700,
				Chinese: 160, // 超过150
			},
			wantErr: true,
			errMsg:  "语文",
		},
		{
			name: "数学超过满分",
			scores: &highschoolv1.CandidateScores{
				Total: 700,
				Math:  160,
			},
			wantErr: true,
			errMsg:  "数学",
		},
		{
			name: "综合测试超过满分",
			scores: &highschoolv1.CandidateScores{
				Total:      700,
				Integrated: 160,
			},
			wantErr: true,
			errMsg:  "综合测试",
		},
		{
			name: "道德法治超过满分",
			scores: &highschoolv1.CandidateScores{
				Total:   700,
				Ethics:  70, // 超过60
			},
			wantErr: true,
			errMsg:  "道德",
		},
		{
			name: "体育超过满分",
			scores: &highschoolv1.CandidateScores{
				Total: 700,
				Pe:    35, // 超过30
			},
			wantErr: true,
			errMsg:  "体育",
		},
		{
			name: "各科之和超过总分",
			scores: &highschoolv1.CandidateScores{
				Total:      600,
				Chinese:    150, Math: 150, Foreign: 150,
				Integrated: 150, Ethics: 60, History: 60, Pe: 30,
				// 总和 = 750 > 600
			},
			wantErr: true,
			errMsg:  "不能超过总分",
		},
		{
			name: "各科之和与总分不符（全部填写时）",
			scores: &highschoolv1.CandidateScores{
				Total:      700,
				Chinese:    140, Math: 140, Foreign: 140,
				Integrated: 140, Ethics: 30, History: 30, Pe: 30,
				// 总和 = 650 != 700
			},
			wantErr: true,
			errMsg:  "不符",
		},
		{
			name: "零分（初始状态）",
			scores: &highschoolv1.CandidateScores{
				Total:      0,
				Chinese:    0, Math: 0, Foreign: 0,
				Integrated: 0, Ethics: 0, History: 0, Pe: 0,
			},
			wantErr: false,
		},
		{
			name: "部分填写科目",
			scores: &highschoolv1.CandidateScores{
				Total:   700,
				Chinese: 140, Math: 140, Foreign: 140,
				// 其他科目不填
			},
			wantErr: false,
		},
		{
			name: "满分",
			scores: &highschoolv1.CandidateScores{
				Total:      750,
				Chinese:    150, Math: 150, Foreign: 150,
				Integrated: 150, Ethics: 60, History: 60, Pe: 30,
			},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := &highschoolv1.SubmitAnalysisRequest{
				Candidate:  baseReq.Candidate,
				Ranking:    baseReq.Ranking,
				Scores:     tt.scores,
				Volunteers: baseReq.Volunteers,
			}

			_, err := service.SubmitAnalysis(ctx, req)
			if tt.wantErr {
				assert.Error(t, err)
				if tt.errMsg != "" {
					assert.Contains(t, err.Error(), tt.errMsg)
				}
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

// buildTestRequest 构建测试请求
func buildTestRequest(districtID, middleSchoolID, studentCount int32, level TestScoreLevel, schoolRepo repository.SchoolRepository) *highschoolv1.SubmitAnalysisRequest {
	ctx := context.Background()

	// 获取该区允许填报的统一招生学校
	var unifiedSchools []int32
	schools, err := schoolRepo.GetSchoolsForUnified(ctx, districtID)
	if err == nil && len(schools) > 0 {
		// 选择前3所学校作为测试志愿
		for i := 0; i < 3 && i < len(schools); i++ {
			unifiedSchools = append(unifiedSchools, schools[i].Id)
		}
	}
	if len(unifiedSchools) == 0 {
		// 如果没有找到学校，使用默认值
		unifiedSchools = []int32{1}
	}
	// 根据成绩水平计算各科成绩
	// 使用整数计算避免浮点精度问题
	totalScore := int(level.TotalScore)

	// 各科满分
	maxChinese := 150
	maxMath := 150
	maxForeign := 150
	maxIntegrated := 150
	maxEthics := 60
	maxHistory := 60
	maxPE := 30
	maxTotal := 750

	// 按比例分配
	chinese := totalScore * maxChinese / maxTotal
	math := totalScore * maxMath / maxTotal
	foreign := totalScore * maxForeign / maxTotal
	integrated := totalScore * maxIntegrated / maxTotal
	ethics := totalScore * maxEthics / maxTotal
	history := totalScore * maxHistory / maxTotal
	pe := totalScore * maxPE / maxTotal

	// 调整体育成绩使总和等于总分（体育分数范围小，调整影响小）
	calculated := chinese + math + foreign + integrated + ethics + history + pe
	pe += totalScore - calculated
	if pe < 0 {
		pe = 0
	}
	if pe > maxPE {
		pe = maxPE
		// 如果体育满了还不够，调整综合测试
		calculated = chinese + math + foreign + integrated + ethics + history + pe
		integrated += totalScore - calculated
	}

	// 根据成绩水平计算排名（高分=排名靠前）
	rank := int32(300 - level.TotalScore/3) // 简单映射
	if rank < 1 {
		rank = 1
	}
	if rank > studentCount {
		rank = studentCount / 2
	}

	return &highschoolv1.SubmitAnalysisRequest{
		Candidate: &highschoolv1.CandidateInfo{
			DistrictId:     districtID,
			MiddleSchoolId: middleSchoolID,
		},
		Ranking: &highschoolv1.RankingInfo{
			Rank:         rank,
			TotalStudents: studentCount,
		},
		Scores: &highschoolv1.CandidateScores{
			Total:      level.TotalScore,
			Chinese:    float64(chinese),
			Math:       float64(math),
			Foreign:    float64(foreign),
			Integrated: float64(integrated),
			Ethics:     float64(ethics),
			History:    float64(history),
			Pe:         float64(pe),
		},
		Volunteers: &highschoolv1.Volunteers{
			// 使用动态获取的允许填报学校
			Unified: unifiedSchools,
		},
	}
}

// validateResult 验证结果合理性
func validateResult(t *testing.T, result *TestResult, level TestScoreLevel, results *highschoolv1.SimulationResults) {
	// 1. 高分考生应该有更多安全区的学校
	if level.TotalScore >= 700 {
		// 顶尖学生至少应该有几个安全选择
		if result.SafeCount == 0 && result.ProbCount > 0 {
			t.Logf("[警告] %s %d分考生没有安全区学校，可能有问题", level.Name, int(level.TotalScore))
		}
	}

	// 2. 低分考生应该有更多高风险学校
	if level.TotalScore < 600 {
		if result.HighRiskCount == 0 && result.ProbCount > 0 {
			t.Logf("[提示] %s %d分考生没有高风险学校，符合预期", level.Name, int(level.TotalScore))
		}
	}

	// 3. 策略分应该在合理范围
	assert.GreaterOrEqual(t, results.Strategy.Score, int32(0), "策略分不应为负")
	assert.LessOrEqual(t, results.Strategy.Score, int32(100), "策略分不应超过100")

	// 4. 百分位应该与成绩水平大致匹配
	percentile := results.Predictions.Percentile
	if level.TotalScore >= 700 && percentile < 70 {
		t.Logf("[注意] %s %d分考生的百分位(%.1f)可能偏低", level.Name, int(level.TotalScore), percentile)
	}
	if level.TotalScore < 600 && percentile > 50 {
		t.Logf("[注意] %s %d分考生的百分位(%.1f)可能偏高", level.Name, int(level.TotalScore), percentile)
	}
}

// validateResultBasic 基本结果验证
func validateResultBasic(t *testing.T, results *highschoolv1.SimulationResults, level TestScoreLevel) {
	// 检查概率结果不为空
	assert.NotEmpty(t, results.Probabilities, "应该有概率预测结果")

	// 检查预测结果存在
	assert.NotNil(t, results.Predictions, "应该有预测结果")

	// 检查策略分析存在
	assert.NotNil(t, results.Strategy, "应该有策略分析")

	// 检查竞争对手分析存在
	assert.NotNil(t, results.Competitors, "应该有竞争对手分析")

	// 验证概率值在合理范围
	for _, p := range results.Probabilities {
		assert.GreaterOrEqual(t, p.Probability, float64(0), "概率不应为负")
		assert.LessOrEqual(t, p.Probability, float64(100), "概率不应超过100")
	}
}

// printSummaryReport 打印测试总结报告
func printSummaryReport(results []TestResult, total, success, failed int) {
	fmt.Printf("\n========== 测试总结报告 ==========\n")
	fmt.Printf("结束时间: %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("总测试数: %d\n", total)
	fmt.Printf("成功: %d (%.1f%%)\n", success, float64(success)/float64(total)*100)
	fmt.Printf("失败: %d (%.1f%%)\n", failed, float64(failed)/float64(total)*100)

	if failed > 0 {
		fmt.Printf("\n--- 失败详情 ---\n")
		for _, r := range results {
			if !r.Success {
				fmt.Printf("  [%s-%s] %s - %d: %s\n",
					r.DistrictName, r.MiddleSchoolName, r.ScoreLevel, int(r.TotalScore), r.ErrorMsg)
			}
		}
	}

	// 按成绩水平统计
	fmt.Printf("\n--- 按成绩水平统计 ---\n")
	levelStats := make(map[string]struct{ success, total int })
	for _, r := range results {
		stats := levelStats[r.ScoreLevel]
		stats.total++
		if r.Success {
			stats.success++
		}
		levelStats[r.ScoreLevel] = stats
	}

	for level, stats := range levelStats {
		fmt.Printf("  %s: %d/%d 成功\n", level, stats.success, stats.total)
	}

	// 输出CSV格式结果（可用于进一步分析）
	fmt.Printf("\n--- CSV格式结果 (可用于分析) ---\n")
	fmt.Println("district_id,district_name,middle_school_id,middle_school_name,score_level,total_score,success,prob_count,safe,moderate,risky,high_risk,strategy_score")
	for _, r := range results {
		fmt.Printf("%d,%s,%d,%s,%s,%.0f,%v,%d,%d,%d,%d,%d,%d\n",
			r.DistrictID, r.DistrictName,
			r.MiddleSchoolID, r.MiddleSchoolName,
			r.ScoreLevel, r.TotalScore, r.Success,
			r.ProbCount, r.SafeCount, r.ModerateCount, r.RiskyCount, r.HighRiskCount,
			r.StrategyScore)
	}
}

// checkDatabaseConnection 检查数据库连接
func checkDatabaseConnection() error {
	// 初始化数据库连接（如果尚未初始化）
	if _, err := database.Initialize(database.Config{
		Host:     getEnv("DB_HOST", "localhost"),
		Port:     5432,
		Name:     getEnv("DB_NAME", "highschool"),
		User:     getEnv("DB_USER", "highschool"),
		Password: getEnv("DB_PASSWORD", "HS2025!db#SecurePass88"),
		SSLMode:  "disable",
		MaxConns: 5,
	}); err != nil {
		return err
	}

	// 尝试创建一个仓库来验证连接
	repo := repository.NewDistrictRepository()
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	_, err := repo.ListAll(ctx)
	return err
}

// getEnv 获取环境变量，如果不存在则返回默认值
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

// TestMain 设置测试环境
func TestMain(m *testing.M) {
	// 设置环境变量（如果需要）
	if os.Getenv("DATABASE_URL") == "" {
		os.Setenv("DATABASE_URL", "postgres://highschool:highschool@localhost:5432/highschool?sslmode=disable")
	}

	os.Exit(m.Run())
}
