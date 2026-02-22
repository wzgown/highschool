// simulation/volunteer_generator.go - 志愿生成器（冲稳保策略）
package simulation

import (
	"context"
	"math/rand"
	"sort"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
	"highschool-backend/pkg/logger"
)

// shuffleSchools 随机打乱学校列表顺序（Fisher-Yates洗牌算法）
func shuffleSchools(schools []*repository.SchoolRankingInfo, rng *rand.Rand) {
	for i := len(schools) - 1; i > 0; i-- {
		j := rng.Intn(i + 1)
		schools[i], schools[j] = schools[j], schools[i]
	}
}

// VolunteerGenerator 志愿生成器接口
type VolunteerGenerator interface {
	// GenerateUnifiedVolunteers 生成统一招生志愿（1-15志愿）
	// 使用冲稳保策略，基于学校排名和考生分数
	// rng: 随机数生成器，用于蒙特卡洛模拟
	GenerateUnifiedVolunteers(ctx context.Context, score float64, districtID int32, rng *rand.Rand) []int32

	// GenerateQuotaDistrictVolunteer 生成名额分配到区志愿
	GenerateQuotaDistrictVolunteer(ctx context.Context, score float64, districtID int32, rng *rand.Rand) *int32

	// GenerateQuotaSchoolVolunteers 生成名额分配到校志愿
	GenerateQuotaSchoolVolunteers(ctx context.Context, score float64, districtID int32, middleSchoolID int32, hasEligibility bool, rng *rand.Rand) []int32

	// PreloadDistrictData 预加载区县数据（优化性能，避免重复查询数据库）
	PreloadDistrictData(ctx context.Context, districtID int32, middleSchoolID int32)
}

// StrategyVolunteerGenerator 基于冲稳保策略的志愿生成器
type StrategyVolunteerGenerator struct {
	schoolRepo repository.SchoolRepository
}

// NewStrategyVolunteerGenerator 创建志愿生成器
func NewStrategyVolunteerGenerator(schoolRepo repository.SchoolRepository) *StrategyVolunteerGenerator {
	return &StrategyVolunteerGenerator{
		schoolRepo: schoolRepo,
	}
}

// PreloadDistrictData 预加载区县数据（在生成大量竞争对手前调用）
func (g *StrategyVolunteerGenerator) PreloadDistrictData(ctx context.Context, districtID int32, middleSchoolID int32) {
	// 调用 repository 的预加载方法（缓存逻辑统一在 repository 层）
	g.schoolRepo.PreloadCache(ctx, districtID, middleSchoolID)
}

// GenerateUnifiedVolunteers 生成统一招生志愿（1-15志愿）
// 策略：基于学校排名，从好到差，同时根据考生分数使用冲稳保策略
// 限制：只能填报该区可填报的学校（本区高中+面向全市招生的学校）
// - 冲：分数线高于考生分数5-15分的学校（2-3个）
// - 稳：分数线在考生分数±5分范围内的学校（5-7个）
// - 保：分数线低于考生分数5-20分的学校（5-8个）
// - 无分数线数据的学校：随机分配到各类
func (g *StrategyVolunteerGenerator) GenerateUnifiedVolunteers(ctx context.Context, score float64, districtID int32, rng *rand.Rand) []int32 {
	// 获取统一招生可填报学校（repository 有缓存）
	availableSchools, err := g.schoolRepo.GetSchoolsForUnified(ctx, districtID)
	if err != nil || len(availableSchools) == 0 {
		logger.Warn(ctx, "failed to get available schools for unified batch",
			logger.Int("district_id", int(districtID)),
			logger.ErrorField(err),
		)
		return nil
	}

	// 获取学校分数线排名（repository 有缓存）
	allRankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID)
	if err != nil {
		logger.Warn(ctx, "failed to get school ranking, using available schools only",
			logger.Int("district_id", int(districtID)),
			logger.ErrorField(err),
		)
		// 如果没有排名数据，从可填报学校中随机选择
		return selectRandomVolunteersFromUnified(availableSchools, rng)
	}

	if len(availableSchools) == 0 {
		return nil
	}

	// 建立可填报学校的ID集合和排名映射
	availableIDs := make(map[int32]bool)
	for _, s := range availableSchools {
		availableIDs[s.Id] = true
	}

	rankingMap := make(map[int32]*repository.SchoolRankingInfo)
	for _, r := range allRankings {
		if availableIDs[r.ID] {
			rankingMap[r.ID] = r
		}
	}

	// 分类学校：冲、稳、保、未知
	reachSchools := make([]*repository.SchoolRankingInfo, 0)   // 冲
	targetSchools := make([]*repository.SchoolRankingInfo, 0)  // 稳
	safetySchools := make([]*repository.SchoolRankingInfo, 0)  // 保
	unknownSchools := make([]*repository.SchoolRankingInfo, 0) // 无分数线数据

	for _, s := range availableSchools {
		if ranking, ok := rankingMap[s.Id]; ok {
			diff := ranking.CutoffScore - score
			switch {
			case diff > 5 && diff <= 15:
				reachSchools = append(reachSchools, ranking)
			case diff >= -5 && diff <= 5:
				targetSchools = append(targetSchools, ranking)
			case diff < -5 && diff >= -20:
				safetySchools = append(safetySchools, ranking)
			case diff > 15:
				// 分数线太高，也放入"冲"类
				reachSchools = append(reachSchools, ranking)
			default:
				// 分数线太低，也放入"保"类
				safetySchools = append(safetySchools, ranking)
			}
		} else {
			// 没有分数线数据的学校
			unknownSchools = append(unknownSchools, &repository.SchoolRankingInfo{
				ID:       s.Id,
				FullName: s.FullName,
			})
		}
	}

	// 随机打乱无分数线数据的学校，并分配到各类
	shuffleSchools(unknownSchools, rng)
	for i, school := range unknownSchools {
		// 按比例分配到冲(30%)、稳(30%)、保(40%)
		switch {
		case i%10 < 3:
			reachSchools = append(reachSchools, school)
		case i%10 < 6:
			targetSchools = append(targetSchools, school)
		default:
			safetySchools = append(safetySchools, school)
		}
	}

	// 按分数线排序（从高到低）
	sort.Slice(reachSchools, func(i, j int) bool {
		return reachSchools[i].CutoffScore > reachSchools[j].CutoffScore
	})
	sort.Slice(targetSchools, func(i, j int) bool {
		return targetSchools[i].CutoffScore > targetSchools[j].CutoffScore
	})
	sort.Slice(safetySchools, func(i, j int) bool {
		return safetySchools[i].CutoffScore > safetySchools[j].CutoffScore
	})

	// 随机选择志愿数量（模拟不同考生的策略差异）
	reachCount := 2 + rng.Intn(2)  // 2-3个冲
	targetCount := 5 + rng.Intn(3) // 5-7个稳
	safetyCount := 15 - reachCount - targetCount
	if safetyCount < 3 {
		safetyCount = 3 // 至少3个保底
	}

	// 建立所有学校的列表（用于补充志愿）
	allSchools := make([]*repository.SchoolRankingInfo, 0)
	allSchools = append(allSchools, reachSchools...)
	allSchools = append(allSchools, targetSchools...)
	allSchools = append(allSchools, safetySchools...)

	var selectedSchools []*repository.SchoolRankingInfo

	// 随机打乱每类学校（增加选择随机性）
	shuffleSchools(reachSchools, rng)
	shuffleSchools(targetSchools, rng)
	shuffleSchools(safetySchools, rng)

	// 从每类中随机选择学校，但有一定概率跳过某些学校（模拟真实考生的偏好差异）
	for i := 0; i < min(reachCount, len(reachSchools)); i++ {
		// 30% 概率跳过当前学校（如果还有足够的候选学校）
		if rng.Float64() < 0.3 && len(reachSchools)-i > reachCount-len(selectedSchools) {
			continue
		}
		selectedSchools = append(selectedSchools, reachSchools[i])
	}

	for i := 0; i < min(targetCount, len(targetSchools)); i++ {
		// 20% 概率跳过当前学校（如果还有足够的候选学校）
		if rng.Float64() < 0.2 && len(targetSchools)-i > targetCount-len(selectedSchools)+reachCount {
			continue
		}
		selectedSchools = append(selectedSchools, targetSchools[i])
	}

	for i := 0; i < min(safetyCount, len(safetySchools)); i++ {
		// 10% 概率跳过当前学校
		if rng.Float64() < 0.1 && len(safetySchools)-i > safetyCount-len(selectedSchools)+reachCount+targetCount {
			continue
		}
		selectedSchools = append(selectedSchools, safetySchools[i])
	}

	// 如果志愿不足15个，从剩余学校中随机补充
	usedIDs := make(map[int32]bool)
	for _, s := range selectedSchools {
		usedIDs[s.ID] = true
	}

	var remainingSchools []*repository.SchoolRankingInfo
	for _, school := range allSchools {
		if !usedIDs[school.ID] {
			remainingSchools = append(remainingSchools, school)
		}
	}
	shuffleSchools(remainingSchools, rng)
	for _, s := range remainingSchools {
		if len(selectedSchools) >= 15 {
			break
		}
		selectedSchools = append(selectedSchools, s)
	}

	// 按分数线从高到低排序，但加入随机性
	// 模拟真实考生的不同策略：有些严格按分数线排序，有些会有一些"跳跃"
	// 分数线差距大于 10 分时严格排序，差距小时有 50% 概率交换
	sort.Slice(selectedSchools, func(i, j int) bool {
		scoreDiff := selectedSchools[i].CutoffScore - selectedSchools[j].CutoffScore
		// 分数线差距大于 10 分，严格按分数线排序
		if scoreDiff > 10 || scoreDiff < -10 {
			return selectedSchools[i].CutoffScore > selectedSchools[j].CutoffScore
		}
		// 分数线接近时，有 50% 概率交换顺序（增加随机性）
		if rng.Float64() < 0.5 {
			return false // 交换顺序
		}
		return selectedSchools[i].CutoffScore > selectedSchools[j].CutoffScore
	})

	// 限制最多15个志愿
	if len(selectedSchools) > 15 {
		selectedSchools = selectedSchools[:15]
	}

	// 转换为ID列表
	volunteers := make([]int32, len(selectedSchools))
	for i, s := range selectedSchools {
		volunteers[i] = s.ID
	}

	return volunteers
}

// selectRandomVolunteersFromUnified 从可填报学校中随机选择志愿
func selectRandomVolunteersFromUnified(schools []*highschoolv1.SchoolForUnified, rng *rand.Rand) []int32 {
	if len(schools) == 0 {
		return nil
	}

	// 转换为 SchoolRankingInfo
	rankings := make([]*repository.SchoolRankingInfo, len(schools))
	for i, s := range schools {
		rankings[i] = &repository.SchoolRankingInfo{
			ID:       s.Id,
			FullName: s.FullName,
		}
	}

	// 随机打乱
	shuffleSchools(rankings, rng)

	// 选择最多15个
	count := min(15, len(rankings))
	volunteers := make([]int32, count)
	for i := 0; i < count; i++ {
		volunteers[i] = rankings[i].ID
	}

	return volunteers
}

// GenerateQuotaDistrictVolunteer 生成名额分配到区志愿
// 策略：选择一个分数线略高于或接近考生分数的好学校
func (g *StrategyVolunteerGenerator) GenerateQuotaDistrictVolunteer(ctx context.Context, score float64, districtID int32, rng *rand.Rand) *int32 {
	// 获取有名额分配到区的学校（repository 有缓存）
	schools, err := g.schoolRepo.GetSchoolsWithQuotaDistrict(ctx, districtID)
	if err != nil || len(schools) == 0 {
		logger.Debug(ctx, "GenerateQuotaDistrictVolunteer: no schools available",
			logger.Int("district_id", int(districtID)),
			logger.Int("schools_count", len(schools)),
			logger.ErrorField(err),
		)
		return nil
	}

	// 获取学校分数线排名（repository 有缓存）
	rankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID)
	if err != nil {
		// 如果没有排名数据，随机选择一个
		idx := rng.Intn(len(schools))
		return &schools[idx].Id
	}

	if len(schools) == 0 {
		return nil
	}

	// 建立学校ID到排名信息的映射
	rankingMap := make(map[int32]*repository.SchoolRankingInfo)
	for _, r := range rankings {
		rankingMap[r.ID] = r
	}

	// 找到分数线略高于考生分数的学校（冲一冲）
	// 或者分数线接近考生分数的学校
	var candidates []int32
	for _, school := range schools {
		if ranking, ok := rankingMap[school.Id]; ok {
			diff := ranking.CutoffScore - score
			// 选择分数线在考生分数-10到+10之间的学校
			if diff >= -10 && diff <= 10 {
				candidates = append(candidates, school.Id)
			}
		}
	}

	if len(candidates) > 0 {
		// 随机选择一个
		idx := rng.Intn(len(candidates))
		return &candidates[idx]
	}

	// 如果没有合适的，选择排名最高的一个
	if len(schools) > 0 {
		// 按分数线排序
		sort.Slice(schools, func(i, j int) bool {
			ri, oki := rankingMap[schools[i].Id]
			rj, okj := rankingMap[schools[j].Id]
			if !oki {
				return false
			}
			if !okj {
				return true
			}
			return ri.CutoffScore > rj.CutoffScore
		})

		// 选择排名中等偏上的学校
		idx := rng.Intn(min(3, len(schools)))
		return &schools[idx].Id
	}

	return nil
}

// GenerateQuotaSchoolVolunteers 生成名额分配到校志愿
// 策略：选择2个有名额分配到校的学校，添加随机性模拟不同考生的策略差异
func (g *StrategyVolunteerGenerator) GenerateQuotaSchoolVolunteers(ctx context.Context, score float64, districtID int32, middleSchoolID int32, hasEligibility bool, rng *rand.Rand) []int32 {
	if !hasEligibility {
		return nil
	}

	// 获取有名额分配到校的高中（repository 有缓存）
	schools, err := g.schoolRepo.GetSchoolsWithQuotaSchool(ctx, middleSchoolID)
	if err != nil || len(schools) == 0 {
		return nil
	}

	// 获取学校分数线排名（repository 有缓存）
	rankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID)
	if err != nil {
		// 如果没有排名数据，随机选择2个
		shuffleSchools(convertToRankingInfo(schools), rng)
		var result []int32
		for i := 0; i < min(2, len(schools)); i++ {
			result = append(result, schools[i].Id)
		}
		return result
	}

	if len(schools) == 0 {
		return nil
	}

	// 建立学校ID到排名信息的映射
	rankingMap := make(map[int32]*repository.SchoolRankingInfo)
	for _, r := range rankings {
		rankingMap[r.ID] = r
	}

	// 按分数线排序
	sort.Slice(schools, func(i, j int) bool {
		ri, oki := rankingMap[schools[i].Id]
		rj, okj := rankingMap[schools[j].Id]
		if !oki {
			return false
		}
		if !okj {
			return true
		}
		return ri.CutoffScore > rj.CutoffScore
	})

	// 分类学校：冲、稳、保（基于分数线与考生分数的差异）
	reachSchools := make([]*repository.SchoolRankingInfo, 0)
	targetSchools := make([]*repository.SchoolRankingInfo, 0)
	safetySchools := make([]*repository.SchoolRankingInfo, 0)

	for _, school := range schools {
		if ranking, ok := rankingMap[school.Id]; ok {
			diff := ranking.CutoffScore - score
			switch {
			case diff > 10:
				// 冲：分数线高于考生10分以上
				reachSchools = append(reachSchools, ranking)
			case diff >= -10 && diff <= 10:
				// 稳：分数线在考生分数±10分范围内
				targetSchools = append(targetSchools, ranking)
			case diff < -10:
				// 保：分数线低于考生10分以上
				safetySchools = append(safetySchools, ranking)
			}
		} else {
			// 没有分数线数据的学校，随机分类（增加随机性）
			fakeRanking := &repository.SchoolRankingInfo{
				ID:          school.Id,
				FullName:    school.FullName,
				CutoffScore: score + float64(rng.Intn(21)-10), // 随机分数
			}
			// 随机决定放入哪个类别
			switch rng.Intn(3) {
			case 0:
				reachSchools = append(reachSchools, fakeRanking)
			case 1:
				targetSchools = append(targetSchools, fakeRanking)
			default:
				safetySchools = append(safetySchools, fakeRanking)
			}
		}
	}

	// 随机打乱每类学校
	shuffleSchools(reachSchools, rng)
	shuffleSchools(targetSchools, rng)
	shuffleSchools(safetySchools, rng)

	var volunteers []int32
	usedIDs := make(map[int32]bool)

	// 选择第一志愿（优先从"冲"或"稳"中随机选择）
	if len(reachSchools) > 0 && rng.Float64() < 0.6 {
		volunteers = append(volunteers, reachSchools[0].ID)
		usedIDs[reachSchools[0].ID] = true
	} else if len(targetSchools) > 0 {
		volunteers = append(volunteers, targetSchools[0].ID)
		usedIDs[targetSchools[0].ID] = true
	} else if len(reachSchools) > 0 {
		volunteers = append(volunteers, reachSchools[0].ID)
		usedIDs[reachSchools[0].ID] = true
	}

	// 选择第二志愿（优先从"保"或"稳"中随机选择）
	if len(volunteers) > 0 {
		if len(safetySchools) > 0 && !usedIDs[safetySchools[0].ID] && rng.Float64() < 0.7 {
			volunteers = append(volunteers, safetySchools[0].ID)
		} else if len(targetSchools) > 0 && !usedIDs[targetSchools[0].ID] {
			volunteers = append(volunteers, targetSchools[0].ID)
		} else if len(safetySchools) > 0 && !usedIDs[safetySchools[0].ID] {
			volunteers = append(volunteers, safetySchools[0].ID)
		} else {
			// 从所有未使用的学校中随机选择
			for _, s := range schools {
				if !usedIDs[s.Id] {
					volunteers = append(volunteers, s.Id)
					break
				}
			}
		}
	}

	// 如果志愿不足2个，从剩余学校中补充
	if len(volunteers) < 2 {
		for _, s := range schools {
			if !usedIDs[s.Id] {
				volunteers = append(volunteers, s.Id)
				if len(volunteers) >= 2 {
					break
				}
			}
		}
	}

	// 最多2个志愿
	if len(volunteers) > 2 {
		volunteers = volunteers[:2]
	}

	return volunteers
}

// convertToRankingInfo 将 SchoolWithQuota 列表转换为 SchoolRankingInfo 列表
func convertToRankingInfo(schools []*highschoolv1.SchoolWithQuota) []*repository.SchoolRankingInfo {
	result := make([]*repository.SchoolRankingInfo, len(schools))
	for i, s := range schools {
		result[i] = &repository.SchoolRankingInfo{
			ID:       s.Id,
			FullName: s.FullName,
		}
	}
	return result
}
