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
	// 使用冲稳保策略，基于排名而非分数差距
	// rank: 考生排名（1开始），totalCandidates: 总考生数
	// rng: 随机数生成器，用于蒙特卡洛模拟
	GenerateUnifiedVolunteers(ctx context.Context, rank, totalCandidates int, districtID int32, rng *rand.Rand) []int32

	// GenerateQuotaDistrictVolunteer 生成名额分配到区志愿
	// 基于排名选择学校：排名靠前的选择好学校，排名靠后的选择普通学校
	GenerateQuotaDistrictVolunteer(ctx context.Context, rank, totalCandidates int, districtID int32, rng *rand.Rand) *int32

	// GenerateQuotaSchoolVolunteers 生成名额分配到校志愿
	GenerateQuotaSchoolVolunteers(ctx context.Context, rank, totalCandidates int, districtID int32, middleSchoolID int32, hasEligibility bool, rng *rand.Rand) []int32

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
// 策略：基于排名选择学校，排名越靠前选择的学校越好
// 限制：只能填报该区可填报的学校（本区高中+面向全市招生的学校）
// 排名百分位决定学校档次：前10%选顶级学校，10-30%选次级学校，以此类推
func (g *StrategyVolunteerGenerator) GenerateUnifiedVolunteers(ctx context.Context, rank, totalCandidates int, districtID int32, rng *rand.Rand) []int32 {
	// 计算排名百分位（0-1，越大表示排名越靠前）
	percentile := float64(totalCandidates-rank) / float64(totalCandidates)

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

	// 收集有分数线数据的可填报学校，并按分数线排序
	var sortedSchools []*repository.SchoolRankingInfo
	for _, r := range allRankings {
		if availableIDs[r.ID] {
			sortedSchools = append(sortedSchools, r)
		}
	}

	// 按分数线从高到低排序
	sort.Slice(sortedSchools, func(i, j int) bool {
		return sortedSchools[i].CutoffScore > sortedSchools[j].CutoffScore
	})

	// 收集没有分数线数据的学校
	var unknownSchools []*repository.SchoolRankingInfo
	for _, s := range availableSchools {
		if !availableIDs[s.Id] {
			continue
		}
		found := false
		for _, r := range sortedSchools {
			if r.ID == s.Id {
				found = true
				break
			}
		}
		if !found {
			unknownSchools = append(unknownSchools, &repository.SchoolRankingInfo{
				ID:       s.Id,
				FullName: s.FullName,
			})
		}
	}

	// 基于百分位确定目标学校范围
	// 排名越靠前（percentile 越大），越倾向于选择分数线高的学校
	totalSchools := len(sortedSchools)
	if totalSchools == 0 {
		return selectRandomVolunteersFromUnified(availableSchools, rng)
	}

	// 根据百分位确定目标学校的起始位置
	// percentile 0.9 (前10%) -> 从第0个学校开始选
	// percentile 0.5 (前50%) -> 从第50%位置的学校开始选
	// percentile 0.1 (后10%) -> 从第90%位置的学校开始选
	targetStartIdx := int((1.0 - percentile) * float64(totalSchools))
	if targetStartIdx < 0 {
		targetStartIdx = 0
	}
	if targetStartIdx >= totalSchools {
		targetStartIdx = totalSchools - 1
	}

	// 选择15个志愿
	// 策略：冲稳保策略
	// - 冲刺：2-3个比目标位置更好的学校
	// - 稳妥：5-7个目标位置附近的学校
	// - 保底：必须包含中等和低排名的学校（确保覆盖广泛）
	//
	// 关键修改：高分考生也应该填报中等排名学校，增加这些学校的竞争
	var selectedSchools []*repository.SchoolRankingInfo
	usedIndices := make(map[int]bool)

	// 向上冲刺：选 2-3 个比目标位置更好的学校
	reachCount := 2 + rng.Intn(2)
	for i := targetStartIdx - 1; i >= 0 && len(selectedSchools) < reachCount; i-- {
		if rng.Float64() < 0.7 { // 70% 概率选择
			selectedSchools = append(selectedSchools, sortedSchools[i])
			usedIndices[i] = true
		}
	}

	// 目标学校：从目标位置开始选 4-5 个
	targetCount := 4 + rng.Intn(2)
	for i := targetStartIdx; i < totalSchools && len(selectedSchools) < reachCount+targetCount; i++ {
		if rng.Float64() < 0.8 { // 80% 概率选择
			if !usedIndices[i] {
				selectedSchools = append(selectedSchools, sortedSchools[i])
				usedIndices[i] = true
			}
		}
	}

	// 中等学校：从 30%-60% 位置选择 3-4 个
	// 这是关键：高分考生也要填报中等排名学校
	midStartIdx := int(float64(totalSchools) * 0.3) // 30% 位置
	midEndIdx := int(float64(totalSchools) * 0.6)   // 60% 位置
	if midStartIdx < targetStartIdx+targetCount {
		midStartIdx = targetStartIdx + targetCount // 确保不重复
	}
	midCount := 3 + rng.Intn(2)
	midAdded := 0
	for i := midStartIdx; i < midEndIdx && midAdded < midCount; i++ {
		if !usedIndices[i] && rng.Float64() < 0.6 {
			selectedSchools = append(selectedSchools, sortedSchools[i])
			usedIndices[i] = true
			midAdded++
		}
	}

	// 保底学校：从 60%-100% 位置选择 3-4 个
	safetyStartIdx := int(float64(totalSchools) * 0.6) // 60% 位置
	if safetyStartIdx < midStartIdx {
		safetyStartIdx = midEndIdx
	}
	safetyCount := 3 + rng.Intn(2)
	safetyAdded := 0
	for i := safetyStartIdx; i < totalSchools && safetyAdded < safetyCount; i++ {
		if !usedIndices[i] && rng.Float64() < 0.6 {
			selectedSchools = append(selectedSchools, sortedSchools[i])
			usedIndices[i] = true
			safetyAdded++
		}
	}

	// 填充剩余志愿：从目标位置之后继续选择
	for i := targetStartIdx; i < totalSchools && len(selectedSchools) < 15; i++ {
		if !usedIndices[i] {
			selectedSchools = append(selectedSchools, sortedSchools[i])
			usedIndices[i] = true
		}
	}

	// 如果还不够15个，从没有分数线数据的学校中随机补充
	if len(selectedSchools) < 15 && len(unknownSchools) > 0 {
		shuffleSchools(unknownSchools, rng)
		for _, s := range unknownSchools {
			if len(selectedSchools) >= 15 {
				break
			}
			selectedSchools = append(selectedSchools, s)
		}
	}

	// 按分数线从高到低排序（加入随机性）
	sort.Slice(selectedSchools, func(i, j int) bool {
		// 分数线差距大于 10 分，严格排序
		if selectedSchools[i].CutoffScore > selectedSchools[j].CutoffScore+10 {
			return true
		}
		if selectedSchools[j].CutoffScore > selectedSchools[i].CutoffScore+10 {
			return false
		}
		// 分数线接近时，有 30% 概率交换顺序（增加随机性）
		if rng.Float64() < 0.3 {
			return false
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
// 策略：基于排名选择学校，排名越靠前选择的学校越好
// 考虑因素：1. 排名百分位 2. 本地偏好 3. 配额数量
func (g *StrategyVolunteerGenerator) GenerateQuotaDistrictVolunteer(ctx context.Context, rank, totalCandidates int, districtID int32, rng *rand.Rand) *int32 {
	// 计算排名百分位（0-1，越大表示排名越靠前）
	percentile := float64(totalCandidates-rank) / float64(totalCandidates)

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

	// 获取学校分数线排名（使用统一的排名API）
	rankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID)
	if err != nil || len(rankings) == 0 {
		// 如果没有排名数据，随机选择一个
		idx := rng.Intn(len(schools))
		return &schools[idx].Id
	}

	if len(schools) == 0 {
		return nil
	}

	// 建立学校ID到排名信息和配额的映射
	rankingMap := make(map[int32]*repository.SchoolRankingInfo)
	for _, r := range rankings {
		rankingMap[r.ID] = r
	}
	quotaMap := make(map[int32]int32)
	for _, s := range schools {
		quotaMap[s.Id] = s.QuotaCount
	}

	// 收集有分数线数据且有名额的学校，按分数线排序
	type candidateSchool struct {
		id         int32
		isLocal    bool
		quota      int32
		cutoffScore float64
	}
	var sortedCandidates []candidateSchool

	for _, school := range schools {
		if ranking, ok := rankingMap[school.Id]; ok {
			isLocal := ranking.DistrictID == districtID
			sortedCandidates = append(sortedCandidates, candidateSchool{
				id:          school.Id,
				isLocal:     isLocal,
				quota:       quotaMap[school.Id],
				cutoffScore: ranking.CutoffScore,
			})
		}
	}

	// 按分数线从高到低排序
	sort.Slice(sortedCandidates, func(i, j int) bool {
		return sortedCandidates[i].cutoffScore > sortedCandidates[j].cutoffScore
	})

	if len(sortedCandidates) == 0 {
		// 没有分数线数据，随机选择
		idx := rng.Intn(len(schools))
		return &schools[idx].Id
	}

	// 基于百分位确定目标学校位置
	// 排名越靠前（percentile 越大），越倾向于选择分数线高的学校
	totalSchools := len(sortedCandidates)
	targetIdx := int((1.0 - percentile) * float64(totalSchools))
	if targetIdx < 0 {
		targetIdx = 0
	}
	if targetIdx >= totalSchools {
		targetIdx = totalSchools - 1
	}

	// 选择目标位置附近的学校（加入随机性）
	// 70% 概率选择目标位置，30% 概率上下浮动
	selectIdx := targetIdx
	if rng.Float64() < 0.3 {
		// 上下浮动最多 20% 的学校数量
		maxOffset := max(1, totalSchools/5)
		offset := rng.Intn(2*maxOffset+1) - maxOffset
		selectIdx = targetIdx + offset
		if selectIdx < 0 {
			selectIdx = 0
		}
		if selectIdx >= totalSchools {
			selectIdx = totalSchools - 1
		}
	}

	// 应用本地偏好和配额权重
	// 在目标位置附近（前后各2个学校）应用加权选择
	startIdx := max(0, selectIdx-2)
	endIdx := min(totalSchools, selectIdx+3)
	nearbyCandidates := sortedCandidates[startIdx:endIdx]

	// 计算权重
	totalWeight := 0.0
	weights := make([]float64, len(nearbyCandidates))
	for i, c := range nearbyCandidates {
		// 基础权重：配额占比
		quotaWeight := float64(c.quota)
		// 本地偏好：本地学校权重 x3
		localFactor := 1.0
		if c.isLocal {
			localFactor = 3.0
		}
		// 距离权重：越靠近目标位置权重越高
		distance := abs(i - (selectIdx - startIdx))
		distanceFactor := 1.0 / (1.0 + float64(distance)*0.5)

		weights[i] = quotaWeight * localFactor * distanceFactor
		totalWeight += weights[i]
	}

	// 加权随机选择
	if totalWeight > 0 {
		r := rng.Float64() * totalWeight
		cumWeight := 0.0
		for i, w := range weights {
			cumWeight += w
			if r < cumWeight {
				return &nearbyCandidates[i].id
			}
		}
	}

	// 回退：返回目标位置的学校
	return &sortedCandidates[selectIdx].id
}

// abs 返回绝对值
func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// GenerateQuotaSchoolVolunteers 生成名额分配到校志愿
// 策略：基于排名选择2个学校，排名越靠前选择的学校越好
func (g *StrategyVolunteerGenerator) GenerateQuotaSchoolVolunteers(ctx context.Context, rank, totalCandidates int, districtID int32, middleSchoolID int32, hasEligibility bool, rng *rand.Rand) []int32 {
	if !hasEligibility {
		return nil
	}

	// 计算排名百分位（0-1，越大表示排名越靠前）
	percentile := float64(totalCandidates-rank) / float64(totalCandidates)

	// 获取有名额分配到校的高中（repository 有缓存）
	schools, err := g.schoolRepo.GetSchoolsWithQuotaSchool(ctx, middleSchoolID)
	if err != nil || len(schools) == 0 {
		return nil
	}

	// 获取学校分数线排名（使用统一的排名API）
	rankings, err := g.schoolRepo.GetSchoolsByCutoffScoreRanking(ctx, districtID)
	if err != nil || len(rankings) == 0 {
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

	// 收集有分数线数据的学校，按分数线排序
	type candidateSchool struct {
		id          int32
		cutoffScore float64
	}
	var sortedCandidates []candidateSchool

	for _, school := range schools {
		if ranking, ok := rankingMap[school.Id]; ok {
			sortedCandidates = append(sortedCandidates, candidateSchool{
				id:          school.Id,
				cutoffScore: ranking.CutoffScore,
			})
		}
	}

	// 按分数线从高到低排序
	sort.Slice(sortedCandidates, func(i, j int) bool {
		return sortedCandidates[i].cutoffScore > sortedCandidates[j].cutoffScore
	})

	if len(sortedCandidates) == 0 {
		// 没有分数线数据，随机选择2个
		var result []int32
		for i := 0; i < min(2, len(schools)); i++ {
			result = append(result, schools[i].Id)
		}
		return result
	}

	// 基于百分位确定目标学校位置
	totalSchools := len(sortedCandidates)
	targetIdx := int((1.0 - percentile) * float64(totalSchools))
	if targetIdx < 0 {
		targetIdx = 0
	}
	if targetIdx >= totalSchools {
		targetIdx = totalSchools - 1
	}

	var volunteers []int32
	usedIDs := make(map[int32]bool)

	// 选择第一志愿：目标位置附近的学校，加入随机性
	// 50% 概率选择目标位置，30% 概率向上冲刺，20% 概率向下保底
	firstIdx := targetIdx
	r := rng.Float64()
	if r < 0.3 && targetIdx > 0 {
		// 向上冲刺
		firstIdx = rng.Intn(targetIdx + 1)
	} else if r >= 0.8 && targetIdx < totalSchools-1 {
		// 向下保底
		firstIdx = targetIdx + rng.Intn(totalSchools-targetIdx)
		if firstIdx >= totalSchools {
			firstIdx = totalSchools - 1
		}
	}
	volunteers = append(volunteers, sortedCandidates[firstIdx].id)
	usedIDs[sortedCandidates[firstIdx].id] = true

	// 选择第二志愿：从剩余学校中随机选择（增加多样性）
	// 50% 概率选择目标位置以下的学校，50% 概率随机选择
	var secondIdx int
	if rng.Float64() < 0.5 {
		// 选择目标位置以下的学校（保底）
		for i := targetIdx + 1; i < totalSchools; i++ {
			if !usedIDs[sortedCandidates[i].id] {
				secondIdx = i
				break
			}
		}
	} else {
		// 随机选择一个未使用的学校
		availableIdxs := []int{}
		for i := 0; i < totalSchools; i++ {
			if !usedIDs[sortedCandidates[i].id] {
				availableIdxs = append(availableIdxs, i)
			}
		}
		if len(availableIdxs) > 0 {
			secondIdx = availableIdxs[rng.Intn(len(availableIdxs))]
		}
	}
	if !usedIDs[sortedCandidates[secondIdx].id] {
		volunteers = append(volunteers, sortedCandidates[secondIdx].id)
		usedIDs[sortedCandidates[secondIdx].id] = true
	}

	// 如果第二志愿没选到，从任意未使用的学校中选择
	if len(volunteers) < 2 {
		for _, s := range schools {
			if !usedIDs[s.Id] {
				volunteers = append(volunteers, s.Id)
				break
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
