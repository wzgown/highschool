// simulation/volunteer_generator.go - 志愿生成器（冲稳保策略）
package simulation

import (
	"context"
	"math/rand"
	"sort"

	"highschool-backend/internal/repository"
	"highschool-backend/pkg/logger"
)

// VolunteerGenerator 志愿生成器接口
type VolunteerGenerator interface {
	// GenerateUnifiedVolunteers 生成统一招生志愿（1-15志愿）
	// 使用冲稳保策略，基于学校排名和考生分数
	GenerateUnifiedVolunteers(ctx context.Context, score float64, districtID int32) []int32

	// GenerateQuotaDistrictVolunteer 生成名额分配到区志愿
	GenerateQuotaDistrictVolunteer(ctx context.Context, score float64, districtID int32) *int32

	// GenerateQuotaSchoolVolunteers 生成名额分配到校志愿
	GenerateQuotaSchoolVolunteers(ctx context.Context, score float64, districtID int32, middleSchoolID int32, hasEligibility bool) []int32

	// PreloadDistrictData 预加载区县数据（优化性能，避免重复查询数据库）
	PreloadDistrictData(ctx context.Context, districtID int32, middleSchoolID int32)
}

// StrategyVolunteerGenerator 基于冲稳保策略的志愿生成器
type StrategyVolunteerGenerator struct {
	schoolRepo repository.SchoolRepository
	year       int
}

// NewStrategyVolunteerGenerator 创建志愿生成器
func NewStrategyVolunteerGenerator(schoolRepo repository.SchoolRepository, year int) *StrategyVolunteerGenerator {
	return &StrategyVolunteerGenerator{
		schoolRepo: schoolRepo,
		year:       year,
	}
}

// PreloadDistrictData 预加载区县数据（在生成大量竞争对手前调用）
func (g *StrategyVolunteerGenerator) PreloadDistrictData(ctx context.Context, districtID int32, middleSchoolID int32) {
	// 调用 repository 的预加载方法（缓存逻辑统一在 repository 层）
	g.schoolRepo.PreloadCache(ctx, districtID, middleSchoolID, g.year)
}

// GenerateUnifiedVolunteers 生成统一招生志愿（1-15志愿）
// 策略：基于学校排名，从好到差，同时根据考生分数使用冲稳保策略
// 限制：只能填报该区可填报的学校（本区高中+面向全市招生的学校）
// - 冲：分数线高于考生分数5-15分的学校（2-3个）
// - 稳：分数线在考生分数±5分范围内的学校（5-7个）
// - 保：分数线低于考生分数5-20分的学校（5-8个）
func (g *StrategyVolunteerGenerator) GenerateUnifiedVolunteers(ctx context.Context, score float64, districtID int32) []int32 {
	// 获取统一招生可填报学校（repository 有缓存）
	availableSchools, err := g.schoolRepo.GetSchoolsForUnified(ctx, districtID, g.year)
	if err != nil || len(availableSchools) == 0 {
		logger.Warn(ctx, "failed to get available schools for unified batch",
			logger.Int("district_id", int(districtID)),
			logger.ErrorField(err),
		)
		return nil
	}

	// 获取学校分数线排名（repository 有缓存）
	allRankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID, g.year)
	if err != nil {
		logger.Warn(ctx, "failed to get school ranking, using empty volunteers",
			logger.Int("district_id", int(districtID)),
			logger.ErrorField(err),
		)
		return nil
	}

	if len(availableSchools) == 0 || len(allRankings) == 0 {
		return nil
	}

	// 建立可填报学校的ID集合
	availableIDs := make(map[int32]bool)
	for _, s := range availableSchools {
		availableIDs[s.Id] = true
	}

	// 从排名列表中筛选出可填报的学校
	var schools []*repository.SchoolRankingInfo
	for _, r := range allRankings {
		if availableIDs[r.ID] {
			schools = append(schools, r)
		}
	}

	if len(schools) == 0 {
		logger.Warn(ctx, "no available schools with ranking data",
			logger.Int("district_id", int(districtID)),
		)
		return nil
	}

	// 分类学校：冲、稳、保
	reachSchools := make([]*repository.SchoolRankingInfo, 0)   // 冲
	targetSchools := make([]*repository.SchoolRankingInfo, 0)  // 稳
	safetySchools := make([]*repository.SchoolRankingInfo, 0)  // 保

	for _, school := range schools {
		diff := school.CutoffScore - score
		switch {
		case diff > 5 && diff <= 15:
			// 冲：分数线高于考生5-15分
			reachSchools = append(reachSchools, school)
		case diff >= -5 && diff <= 5:
			// 稳：分数线在考生分数±5分范围内
			targetSchools = append(targetSchools, school)
		case diff < -5 && diff >= -20:
			// 保：分数线低于考生5-20分
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
	reachCount := 2 + rand.Intn(2)    // 2-3个冲
	targetCount := 5 + rand.Intn(3)   // 5-7个稳
	safetyCount := 15 - reachCount - targetCount
	if safetyCount < 3 {
		safetyCount = 3 // 至少3个保底
	}

	var volunteers []int32

	// 添加冲的学校（从高到低选）
	for i := 0; i < min(reachCount, len(reachSchools)); i++ {
		volunteers = append(volunteers, reachSchools[i].ID)
	}

	// 添加稳的学校（从高到低选）
	for i := 0; i < min(targetCount, len(targetSchools)); i++ {
		volunteers = append(volunteers, targetSchools[i].ID)
	}

	// 添加保的学校（从高到低选）
	for i := 0; i < min(safetyCount, len(safetySchools)); i++ {
		volunteers = append(volunteers, safetySchools[i].ID)
	}

	// 如果志愿不足15个，从剩余学校中补充（按分数线从高到低）
	if len(volunteers) < 15 {
		usedIDs := make(map[int32]bool)
		for _, id := range volunteers {
			usedIDs[id] = true
		}

		for _, school := range schools {
			if !usedIDs[school.ID] && len(volunteers) < 15 {
				volunteers = append(volunteers, school.ID)
				usedIDs[school.ID] = true
			}
		}
	}

	// 限制最多15个志愿
	if len(volunteers) > 15 {
		volunteers = volunteers[:15]
	}

	return volunteers
}

// GenerateQuotaDistrictVolunteer 生成名额分配到区志愿
// 策略：选择一个分数线略高于或接近考生分数的好学校
func (g *StrategyVolunteerGenerator) GenerateQuotaDistrictVolunteer(ctx context.Context, score float64, districtID int32) *int32 {
	// 获取有名额分配到区的学校（repository 有缓存）
	schools, err := g.schoolRepo.GetSchoolsWithQuotaDistrict(ctx, districtID, g.year)
	if err != nil || len(schools) == 0 {
		return nil
	}

	// 获取学校分数线排名（repository 有缓存）
	rankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID, g.year)
	if err != nil {
		// 如果没有排名数据，随机选择一个
		idx := rand.Intn(len(schools))
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
		idx := rand.Intn(len(candidates))
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
		idx := rand.Intn(min(3, len(schools)))
		return &schools[idx].Id
	}

	return nil
}

// GenerateQuotaSchoolVolunteers 生成名额分配到校志愿
// 策略：选择2个有名额分配到校的学校，一个冲一个保
func (g *StrategyVolunteerGenerator) GenerateQuotaSchoolVolunteers(ctx context.Context, score float64, districtID int32, middleSchoolID int32, hasEligibility bool) []int32 {
	if !hasEligibility {
		return nil
	}

	// 获取有名额分配到校的高中（repository 有缓存）
	schools, err := g.schoolRepo.GetSchoolsWithQuotaSchool(ctx, middleSchoolID, g.year)
	if err != nil || len(schools) == 0 {
		return nil
	}

	// 获取学校分数线排名（repository 有缓存）
	rankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID, g.year)
	if err != nil {
		// 如果没有排名数据，随机选择2个
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

	var volunteers []int32

	// 第一志愿：选择分数线略高于考生分数的学校（冲）
	for _, school := range schools {
		if ranking, ok := rankingMap[school.Id]; ok {
			diff := ranking.CutoffScore - score
			if diff > 0 && diff <= 15 {
				volunteers = append(volunteers, school.Id)
				break
			}
		}
	}

	// 如果没找到冲的学校，选择排名最高的
	if len(volunteers) == 0 && len(schools) > 0 {
		volunteers = append(volunteers, schools[0].Id)
	}

	// 第二志愿：选择分数线低于考生分数的学校（保）
	for _, school := range schools {
		if ranking, ok := rankingMap[school.Id]; ok {
			diff := ranking.CutoffScore - score
			if diff < 0 && diff >= -20 {
				volunteers = append(volunteers, school.Id)
				break
			}
		}
	}

	// 如果没找到保的学校，选择排名最低的
	if len(volunteers) < 2 && len(schools) > 1 {
		volunteers = append(volunteers, schools[len(schools)-1].Id)
	}

	// 最多2个志愿
	if len(volunteers) > 2 {
		volunteers = volunteers[:2]
	}

	return volunteers
}
