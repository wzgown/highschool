// simulation/competitor_generator.go - 竞争对手生成器
package simulation

import (
	"math/rand"

	highschoolv1 "highschool-backend/gen/highschool/v1"
)

// CompetitorGenerator 竞争对手生成器
type CompetitorGenerator struct {
	baseCount  int
	scoreRange float64
}

// NewCompetitorGenerator 创建竞争对手生成器
func NewCompetitorGenerator() *CompetitorGenerator {
	return &CompetitorGenerator{
		baseCount:  100,
		scoreRange: 30.0, // 分数波动范围
	}
}

// Competitor 竞争对手
type Competitor struct {
	Score         int32
	VolunteerPrefs []int32 // 志愿偏好
}

// Generate 生成竞争对手分析
func (g *CompetitorGenerator) Generate(req *highschoolv1.SubmitAnalysisRequest, count int) *highschoolv1.CompetitorAnalysis {
	if count <= 0 {
		count = g.baseCount
	}

	competitors := g.generateCompetitors(req, count)
	distribution := g.calculateDistribution(competitors)

	return &highschoolv1.CompetitorAnalysis{
		Count:             int32(len(competitors)),
		ScoreDistribution: distribution,
	}
}

// generateCompetitors 生成竞争对手列表
func (g *CompetitorGenerator) generateCompetitors(req *highschoolv1.SubmitAnalysisRequest, count int) []*Competitor {
	competitors := make([]*Competitor, count)
	candidateScore := req.Scores.Total

	for i := 0; i < count; i++ {
		score := g.generateScore(candidateScore)
		competitors[i] = &Competitor{
			Score:          score,
			VolunteerPrefs: g.generateVolunteerPrefs(req),
		}
	}

	return competitors
}

// generateScore 生成竞争对手分数
// 使用正态分布在考生分数附近生成
func (g *CompetitorGenerator) generateScore(candidateScore int32) int32 {
	// 简化版：在考生分数 ±scoreRange 范围内随机生成
	minScore := candidateScore - int32(g.scoreRange)
	maxScore := candidateScore + int32(g.scoreRange)

	if minScore < 0 {
		minScore = 0
	}
	if maxScore > 750 {
		maxScore = 750
	}

	return minScore + int32(rand.Intn(int(maxScore-minScore+1)))
}

// generateVolunteerPrefs 生成志愿偏好
func (g *CompetitorGenerator) generateVolunteerPrefs(req *highschoolv1.SubmitAnalysisRequest) []int32 {
	// 简化版：复制考生的志愿选择
	var prefs []int32

	if req.Volunteers.QuotaDistrict != nil {
		prefs = append(prefs, *req.Volunteers.QuotaDistrict)
	}
	prefs = append(prefs, req.Volunteers.QuotaSchool...)
	prefs = append(prefs, req.Volunteers.Unified...)

	return prefs
}

// calculateDistribution 计算分数分布
func (g *CompetitorGenerator) calculateDistribution(competitors []*Competitor) []*highschoolv1.ScoreDistributionItem {
	ranges := []struct {
		min, max int32
		label    string
	}{
		{700, 750, "700-750"},
		{650, 699, "650-699"},
		{600, 649, "600-649"},
		{550, 599, "550-599"},
		{500, 549, "500-549"},
		{0, 499, "<500"},
	}

	counts := make(map[string]int32)
	for _, r := range ranges {
		counts[r.label] = 0
	}

	for _, c := range competitors {
		for _, r := range ranges {
			if c.Score >= r.min && c.Score <= r.max {
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

	return distribution
}
