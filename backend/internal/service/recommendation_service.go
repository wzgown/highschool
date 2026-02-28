// service/recommendation_service.go - 志愿推荐业务逻辑层
package service

import (
	"context"
	"fmt"
	"sort"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
	"highschool-backend/pkg/logger"
)

// RecommendationService 志愿推荐服务接口
type RecommendationService interface {
	// GetVolunteerRecommendations 获取志愿推荐
	GetVolunteerRecommendations(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest) (*highschoolv1.GetVolunteerRecommendationsResponse, error)
}

// recommendationService 实现
type recommendationService struct {
	repo       repository.RecommendationRepository
	schoolRepo repository.SchoolRepository
}

// NewRecommendationService 创建志愿推荐服务
func NewRecommendationService() RecommendationService {
	return &recommendationService{
		repo:       repository.NewRecommendationRepository(),
		schoolRepo: repository.NewSchoolRepository(),
	}
}

// GetVolunteerRecommendations 获取志愿推荐
func (s *recommendationService) GetVolunteerRecommendations(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest) (*highschoolv1.GetVolunteerRecommendationsResponse, error) {
	// 1. 获取数据年份
	year := req.Year
	if year == nil || *year == 0 {
		latestYear, err := s.repo.GetLatestScoreYear(ctx)
		if err != nil {
			return nil, fmt.Errorf("获取分数线年份失败: %w", err)
		}
		year = &latestYear
	}

	// 2. 获取区信息
	district, err := s.repo.GetDistrictByID(ctx, req.DistrictId)
	if err != nil {
		return nil, fmt.Errorf("获取区信息失败: %w", err)
	}

	// 3. 获取区总分映射
	districtTotalScores, err := s.repo.GetDistrictTotalScores(ctx)
	if err != nil {
		logger.Warn(ctx, "获取区总分映射失败", logger.ErrorField(err))
	}

	// 4. 计算分数转换
	scoreConversion, err := s.calculateScoreConversion(ctx, req, district, districtTotalScores, *year)
	if err != nil {
		return nil, fmt.Errorf("分数转换失败: %w", err)
	}

	// 5. 获取各类推荐
	quotaDistrictRecs, err := s.getQuotaDistrictRecommendations(ctx, req, scoreConversion, *year)
	if err != nil {
		logger.Warn(ctx, "获取名额到区推荐失败", logger.ErrorField(err))
	}

	quotaSchoolRecs, err := s.getQuotaSchoolRecommendations(ctx, req, scoreConversion, *year)
	if err != nil {
		logger.Warn(ctx, "获取名额到校推荐失败", logger.ErrorField(err))
	}

	unifiedRecs, err := s.getUnifiedRecommendations(ctx, req, scoreConversion, *year)
	if err != nil {
		logger.Warn(ctx, "获取统一招生推荐失败", logger.ErrorField(err))
	}

	return &highschoolv1.GetVolunteerRecommendationsResponse{
		QuotaDistrictRecommendations: quotaDistrictRecs,
		QuotaSchoolRecommendations:   quotaSchoolRecs,
		UnifiedRecommendations:       unifiedRecs,
		ScoreConversion:              scoreConversion,
		Year:                         *year,
	}, nil
}

// calculateScoreConversion 计算分数转换
// 使用基于百分位的转换方法，考虑一模/二模与中考的难度差异
func (s *recommendationService) calculateScoreConversion(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest, district *highschoolv1.District, districtTotalScores map[int32]*repository.DistrictTotalScore, year int32) (*highschoolv1.ScoreConversion, error) {
	// 获取区中考人数
	examCount, err := s.repo.GetDistrictExamCount(ctx, req.DistrictId, year)
	if err != nil {
		examCount = 5000 // 默认值
	}

	// 获取该区的一模/二模总分
	var originalTotal float32 = 605 // 默认值（上海常见的一模总分）
	if ts, ok := districtTotalScores[req.DistrictId]; ok {
		if req.ExamType == highschoolv1.ExamType_EXAM_TYPE_FIRST_MOCK {
			originalTotal = float32(ts.FirstMockTotal)
		} else {
			originalTotal = float32(ts.SecondMockTotal)
		}
	}

	// 计算一模/二模得分率
	scoreRate := float64(req.TotalScore / originalTotal)

	// 基于得分率估算百分位
	// 一模/二模的得分率与百分位的映射关系（基于经验数据）
	// 高分段学生密度较高，得分率95%可能对应百分位98%
	var percentile float64
	switch {
	case scoreRate >= 0.98:
		// 得分率98%+ → 百分位99%+
		percentile = 0.99
	case scoreRate >= 0.95:
		// 得分率95-98% → 百分位95-99%
		percentile = 0.95 + (scoreRate-0.95)/0.03*0.04
	case scoreRate >= 0.90:
		// 得分率90-95% → 百分位85-95%
		percentile = 0.85 + (scoreRate-0.90)/0.05*0.10
	case scoreRate >= 0.85:
		// 得分率85-90% → 百分位70-85%
		percentile = 0.70 + (scoreRate-0.85)/0.05*0.15
	case scoreRate >= 0.80:
		// 得分率80-85% → 百分位55-70%
		percentile = 0.55 + (scoreRate-0.80)/0.05*0.15
	case scoreRate >= 0.70:
		// 得分率70-80% → 百分位35-55%
		percentile = 0.35 + (scoreRate-0.70)/0.10*0.20
	case scoreRate >= 0.60:
		// 得分率60-70% → 百分位20-35%
		percentile = 0.20 + (scoreRate-0.60)/0.10*0.15
	default:
		// 得分率<60% → 百分位0-20%
		percentile = scoreRate / 0.60 * 0.20
	}
	if percentile > 0.99 {
		percentile = 0.99
	}
	if percentile < 0.01 {
		percentile = 0.01
	}

	// 基于百分位估算中考等效分（750分制）
	// 使用浦东新区2024年统一招生分数分布作为参考
	var convertedScore750 float32
	switch {
	case percentile >= 0.98:
		// 前2%：710-730分（四校水平）
		convertedScore750 = 710 + float32((percentile-0.98)/0.02*20)
	case percentile >= 0.95:
		// 95%-98%：700-710分（四校分数线附近）
		convertedScore750 = 700 + float32((percentile-0.95)/0.03*10)
	case percentile >= 0.90:
		// 90%-95%：680-700分（市重点水平）
		convertedScore750 = 680 + float32((percentile-0.90)/0.05*20)
	case percentile >= 0.80:
		// 80%-90%：650-680分（区重点水平）
		convertedScore750 = 650 + float32((percentile-0.80)/0.10*30)
	case percentile >= 0.70:
		// 70%-80%：620-650分（普通高中）
		convertedScore750 = 620 + float32((percentile-0.70)/0.10*30)
	case percentile >= 0.50:
		// 50%-70%：560-620分
		convertedScore750 = 560 + float32((percentile-0.50)/0.20*60)
	case percentile >= 0.30:
		// 30%-50%：500-560分
		convertedScore750 = 500 + float32((percentile-0.30)/0.20*60)
	default:
		// 30%以下：450-500分
		convertedScore750 = 450 + float32(percentile/0.30*50)
	}

	// 一模/二模通常比中考难，需要适当加分（约5-15分）
	// 根据得分率调整：高分段加少，低分段加多
	difficultyAdjustment := float32(10 - (scoreRate-0.7)*20)
	if difficultyAdjustment < 0 {
		difficultyAdjustment = 0
	}
	if difficultyAdjustment > 15 {
		difficultyAdjustment = 15
	}
	convertedScore750 += difficultyAdjustment

	// 确保分数在合理范围内
	if convertedScore750 > 745 {
		convertedScore750 = 745
	}
	if convertedScore750 < 400 {
		convertedScore750 = 400
	}

	// 计算转换后的800分制分数（含综合素质50分）
	// 综合素质按平均水平42分估算（满分50）
	convertedScore800 := convertedScore750 + 42

	// 估算区排名
	estimatedRank := int(float64(examCount) * (1 - percentile))
	if estimatedRank < 1 {
		estimatedRank = 1
	}

	return &highschoolv1.ScoreConversion{
		OriginalScore:       req.TotalScore,
		OriginalTotal:       originalTotal,
		ConvertedScore_750:  convertedScore750,
		ConvertedScore_800:  convertedScore800,
		EstimatedRank:       int32(estimatedRank),
		EstimatedPercentile: float32(percentile * 100),
		DistrictName:        district.Name,
		DistrictExamCount:   int32(examCount),
	}, nil
}

// getQuotaDistrictRecommendations 获取名额到区推荐
func (s *recommendationService) getQuotaDistrictRecommendations(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest, scoreConversion *highschoolv1.ScoreConversion, year int32) ([]*highschoolv1.RecommendedSchool, error) {
	// 获取该区有名额分配到区的学校
	schools, err := s.repo.GetSchoolsWithQuotaDistrict(ctx, req.DistrictId, year)
	if err != nil {
		return nil, err
	}

	// 获取历史分数线
	scores, err := s.repo.GetAdmissionScoresQuotaDistrict(ctx, req.DistrictId, year-1)
	if err != nil {
		logger.Warn(ctx, "获取名额到区历史分数线失败", logger.ErrorField(err))
	}

	// 构建学校分数线映射
	scoreMap := make(map[int32]float32)
	for _, s := range scores {
		scoreMap[s.SchoolID] = float32(s.MinScore)
	}

	// 考生800分制分数
	candidateScore := scoreConversion.ConvertedScore_800

	// 构建推荐列表
	var recommendations []*highschoolv1.RecommendedSchool
	for _, school := range schools {
		estimatedScore := scoreMap[school.Id]
		if estimatedScore == 0 {
			// 如果没有历史分数线，跳过
			continue
		}

		scoreGap := candidateScore - estimatedScore
		confidence := calculateConfidence(float64(scoreGap))
		recType := determineRecommendationType(float64(scoreGap), true)

		// 名额到区只能填1个志愿，选择稳妥档
		if recType == highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET {
			recommendations = append(recommendations, &highschoolv1.RecommendedSchool{
				SchoolId:            school.Id,
				SchoolName:          school.FullName,
				SchoolCode:          school.Code,
				EstimatedScore:      estimatedScore,
				ScoreGap:            scoreGap,
				Confidence:          confidence,
				RecommendationType:  recType,
				RecommendationReason: buildRecommendationReason(recType, float64(scoreGap), "名额到区"),
				QuotaCount:          school.QuotaCount,
			})
		}
	}

	// 如果没有稳妥档，选择最接近的
	if len(recommendations) == 0 && len(schools) > 0 {
		// 按分数线差距排序，选择最接近的
		var allRecs []*highschoolv1.RecommendedSchool
		for _, school := range schools {
			estimatedScore := scoreMap[school.Id]
			if estimatedScore == 0 {
				continue
			}
			scoreGap := candidateScore - estimatedScore
			confidence := calculateConfidence(float64(scoreGap))
			recType := determineRecommendationType(float64(scoreGap), true)
			allRecs = append(allRecs, &highschoolv1.RecommendedSchool{
				SchoolId:            school.Id,
				SchoolName:          school.FullName,
				SchoolCode:          school.Code,
				EstimatedScore:      estimatedScore,
				ScoreGap:            scoreGap,
				Confidence:          confidence,
				RecommendationType:  recType,
				RecommendationReason: buildRecommendationReason(recType, float64(scoreGap), "名额到区"),
				QuotaCount:          school.QuotaCount,
			})
		}
		// 按差距绝对值排序，选择最接近的
		sort.Slice(allRecs, func(i, j int) bool {
			return abs32(allRecs[i].ScoreGap) < abs32(allRecs[j].ScoreGap)
		})
		if len(allRecs) > 0 {
			recommendations = []*highschoolv1.RecommendedSchool{allRecs[0]}
		}
	}

	// 只返回1所
	if len(recommendations) > 1 {
		recommendations = recommendations[:1]
	}

	return recommendations, nil
}

// getQuotaSchoolRecommendations 获取名额到校推荐
func (s *recommendationService) getQuotaSchoolRecommendations(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest, scoreConversion *highschoolv1.ScoreConversion, year int32) ([]*highschoolv1.RecommendedSchool, error) {
	// 检查是否有名额到校资格
	if !req.HasQuotaSchoolEligibility {
		return nil, nil
	}

	// 检查是否提供了初中信息
	if req.MiddleSchoolId == nil {
		return nil, nil
	}

	// 获取初中信息
	middleSchool, err := s.repo.GetMiddleSchoolByID(ctx, *req.MiddleSchoolId)
	if err != nil {
		return nil, err
	}

	// 获取该初中有名额分配到校的学校
	schools, err := s.repo.GetSchoolsWithQuotaSchool(ctx, *req.MiddleSchoolId, year)
	if err != nil {
		return nil, err
	}

	// 获取历史分数线
	scores, err := s.repo.GetAdmissionScoresQuotaSchool(ctx, req.DistrictId, middleSchool.Name, year-1)
	if err != nil {
		logger.Warn(ctx, "获取名额到校历史分数线失败", logger.ErrorField(err))
	}

	// 构建学校分数线映射
	scoreMap := make(map[int32]float32)
	for _, s := range scores {
		scoreMap[s.SchoolID] = float32(s.MinScore)
	}

	// 考生800分制分数
	candidateScore := scoreConversion.ConvertedScore_800

	// 构建推荐列表
	var recommendations []*highschoolv1.RecommendedSchool
	for _, school := range schools {
		estimatedScore := scoreMap[school.Id]
		if estimatedScore == 0 {
			continue
		}

		scoreGap := candidateScore - estimatedScore
		confidence := calculateConfidence(float64(scoreGap))
		recType := determineRecommendationType(float64(scoreGap), false)

		recommendations = append(recommendations, &highschoolv1.RecommendedSchool{
			SchoolId:            school.Id,
			SchoolName:          school.FullName,
			SchoolCode:          school.Code,
			EstimatedScore:      estimatedScore,
			ScoreGap:            scoreGap,
			Confidence:          confidence,
			RecommendationType:  recType,
			RecommendationReason: buildRecommendationReason(recType, float64(scoreGap), "名额到校"),
			QuotaCount:          school.QuotaCount,
		})
	}

	// 按分数线差距排序（从高到低）
	sort.Slice(recommendations, func(i, j int) bool {
		return recommendations[i].ScoreGap > recommendations[j].ScoreGap
	})

	// 名额到校推荐2所：1冲刺 + 1稳妥
	var result []*highschoolv1.RecommendedSchool
	var reachAdded, targetAdded bool

	for _, rec := range recommendations {
		if rec.RecommendationType == highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH && !reachAdded {
			result = append(result, rec)
			reachAdded = true
		} else if rec.RecommendationType == highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET && !targetAdded {
			result = append(result, rec)
			targetAdded = true
		}
		if len(result) >= 2 {
			break
		}
	}

	// 如果没有冲刺或稳妥，用保底补充
	if len(result) < 2 && len(recommendations) > 0 {
		for _, rec := range recommendations {
			found := false
			for _, r := range result {
				if r.SchoolId == rec.SchoolId {
					found = true
					break
				}
			}
			if !found {
				result = append(result, rec)
				if len(result) >= 2 {
					break
				}
			}
		}
	}

	return result, nil
}

// getUnifiedRecommendations 获取统一招生推荐
func (s *recommendationService) getUnifiedRecommendations(ctx context.Context, req *highschoolv1.GetVolunteerRecommendationsRequest, scoreConversion *highschoolv1.ScoreConversion, year int32) ([]*highschoolv1.RecommendedSchool, error) {
	// 获取统一招生可选学校
	schools, err := s.repo.GetSchoolsForUnified(ctx, req.DistrictId, year)
	if err != nil {
		return nil, err
	}

	// 获取历史分数线
	scores, err := s.repo.GetAdmissionScoresUnified(ctx, req.DistrictId, year-1)
	if err != nil {
		logger.Warn(ctx, "获取统一招生历史分数线失败", logger.ErrorField(err))
	}

	// 获取控制分数线
	controlScores, err := s.repo.GetControlScores(ctx, year-1)
	if err != nil {
		logger.Warn(ctx, "获取控制分数线失败", logger.ErrorField(err))
	}

	// 获取统一招生控制分数线
	var unifiedControlScore float32 = 500 // 默认值
	for _, cs := range controlScores {
		if cs.AdmissionBatchID == "UNIFIED_1_15" {
			unifiedControlScore = float32(cs.MinScore)
			break
		}
	}

	// 构建学校分数线映射
	scoreMap := make(map[int32]float32)
	for _, s := range scores {
		scoreMap[s.SchoolID] = float32(s.MinScore)
	}

	// 考生750分制分数
	candidateScore := scoreConversion.ConvertedScore_750

	// 构建推荐列表
	var recommendations []*highschoolv1.RecommendedSchool
	for _, school := range schools {
		estimatedScore := scoreMap[school.Id]
		if estimatedScore == 0 {
			continue
		}

		// 过滤掉控制分数线以下的学校（如果考生分数明显不足）
		if candidateScore < unifiedControlScore-30 {
			continue
		}

		scoreGap := candidateScore - estimatedScore

		// 过滤掉差距太大的学校（>30分）
		if scoreGap < -30 {
			continue
		}

		confidence := calculateConfidence(float64(scoreGap))
		recType := determineRecommendationTypeUnified(float64(scoreGap))

		recommendations = append(recommendations, &highschoolv1.RecommendedSchool{
			SchoolId:            school.Id,
			SchoolName:          school.FullName,
			SchoolCode:          school.Code,
			EstimatedScore:      estimatedScore,
			ScoreGap:            scoreGap,
			Confidence:          confidence,
			RecommendationType:  recType,
			RecommendationReason: buildRecommendationReason(recType, float64(scoreGap), "统一招生"),
			IsDistrictSchool:    school.IsDistrictSchool,
		})
	}

	// 按分数线差距排序（从高到低）
	sort.Slice(recommendations, func(i, j int) bool {
		return recommendations[i].ScoreGap > recommendations[j].ScoreGap
	})

	// 按"冲稳保"梯度分布：3冲刺 + 5稳妥 + 7保底 = 15所
	return distributeUnifiedRecommendations(recommendations), nil
}

// distributeUnifiedRecommendations 按"冲稳保"梯度分配统一招生推荐
func distributeUnifiedRecommendations(recommendations []*highschoolv1.RecommendedSchool) []*highschoolv1.RecommendedSchool {
	var reach, target, safety []*highschoolv1.RecommendedSchool

	for _, rec := range recommendations {
		switch rec.RecommendationType {
		case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH:
			reach = append(reach, rec)
		case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET:
			target = append(target, rec)
		case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY:
			safety = append(safety, rec)
		}
	}

	var result []*highschoolv1.RecommendedSchool

	// 3冲刺
	for i := 0; i < 3 && i < len(reach); i++ {
		result = append(result, reach[i])
	}

	// 5稳妥
	for i := 0; i < 5 && i < len(target); i++ {
		result = append(result, target[i])
	}

	// 7保底
	for i := 0; i < 7 && i < len(safety); i++ {
		result = append(result, safety[i])
	}

	// 如果总数不足15，用其他类型补充
	if len(result) < 15 {
		remaining := 15 - len(result)
		for _, rec := range recommendations {
			found := false
			for _, r := range result {
				if r.SchoolId == rec.SchoolId {
					found = true
					break
				}
			}
			if !found {
				result = append(result, rec)
				remaining--
				if remaining <= 0 {
					break
				}
			}
		}
	}

	// 最多返回15所
	if len(result) > 15 {
		result = result[:15]
	}

	return result
}

// calculateConfidence 计算置信度
func calculateConfidence(scoreGap float64) highschoolv1.RecommendationConfidence {
	if scoreGap > 15 {
		return highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_HIGH
	} else if scoreGap >= 5 {
		return highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_MEDIUM
	} else {
		return highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_LOW
	}
}

// determineRecommendationType 确定推荐类型（名额分配）
func determineRecommendationType(scoreGap float64, isQuotaDistrict bool) highschoolv1.RecommendationType {
	if isQuotaDistrict {
		// 名额到区：只推荐稳妥档
		if scoreGap >= 5 && scoreGap <= 20 {
			return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET
		} else if scoreGap > 20 {
			return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY
		} else {
			return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH
		}
	}

	// 名额到校
	if scoreGap > 10 {
		return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY
	} else if scoreGap >= -5 {
		return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET
	} else {
		return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH
	}
}

// determineRecommendationTypeUnified 确定推荐类型（统一招生）
// 基于分数差距判断：冲刺（< -5）、稳妥（-5 ~ +10）、保底（> +10）
func determineRecommendationTypeUnified(scoreGap float64) highschoolv1.RecommendationType {
	if scoreGap > 10 {
		return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY
	} else if scoreGap >= -5 {
		return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET
	} else {
		return highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH
	}
}

// buildRecommendationReason 构建推荐理由
func buildRecommendationReason(recType highschoolv1.RecommendationType, scoreGap float64, batch string) string {
	gapStr := ""
	if scoreGap > 0 {
		gapStr = fmt.Sprintf("高于分数线%.1f分", scoreGap)
	} else if scoreGap < 0 {
		gapStr = fmt.Sprintf("低于分数线%.1f分", -scoreGap)
	} else {
		gapStr = "与分数线持平"
	}

	switch recType {
	case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH:
		return fmt.Sprintf("【冲刺】%s，有一定挑战但值得尝试", gapStr)
	case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET:
		return fmt.Sprintf("【稳妥】%s，录取概率较大", gapStr)
	case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY:
		return fmt.Sprintf("【保底】%s，录取把握很大", gapStr)
	default:
		return gapStr
	}
}

// abs32 返回float32绝对值
func abs32(x float32) float32 {
	if x < 0 {
		return -x
	}
	return x
}
