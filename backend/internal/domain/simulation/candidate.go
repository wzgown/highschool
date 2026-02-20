// simulation/candidate.go - 模拟考生模型
package simulation

import (
	"context"
	"math/rand"
)

// Candidate 模拟考生
type Candidate struct {
	ID               int32
	IsRealCandidate  bool   // 是否是真实考生（用户）
	DistrictID       int32  // 所在区ID
	MiddleSchoolID   int32  // 初中学校ID
	MiddleSchoolName string // 初中学校名称

	// 成绩信息
	TotalScore             float64 // 总分（名额分配批次800分，统一招生750分）
	ChineseScore           float64 // 语文
	MathScore              float64 // 数学
	ForeignScore           float64 // 外语
	IntegratedScore        float64 // 综合测试
	EthicsScore            float64 // 道德与法治
	HistoryScore           float64 // 历史
	PEScore                float64 // 体育
	ComprehensiveQuality   float64 // 综合素质评价（默认50分）
	HasTiePreference       bool    // 是否有同分优待
	SchoolRank             int32   // 校内排名
	SchoolTotalStudents    int32   // 校内总人数
	HasQuotaSchoolEligible bool    // 是否具备名额分配到校资格

	// 志愿信息
	QuotaDistrictSchoolID *int32  // 名额分配到区志愿学校ID
	QuotaSchoolIDs        []int32 // 名额分配到校志愿学校ID（2个）
	UnifiedSchoolIDs      []int32 // 统一招生志愿学校ID（最多15个）

	// 录取结果
	AdmittedBatch    string // 录取批次: QUOTA_DISTRICT, QUOTA_SCHOOL, UNIFIED, NONE
	AdmittedSchoolID *int32 // 录取学校ID
	AdmittedRank     int32  // 录取时的排名
}

// Compare 按照同分比较规则比较两个考生
// 返回值: 1 表示 c > other, -1 表示 c < other, 0 表示相等
func (c *Candidate) Compare(other *Candidate) int {
	// 1. 同分优待
	if c.HasTiePreference && !other.HasTiePreference {
		return 1
	}
	if !c.HasTiePreference && other.HasTiePreference {
		return -1
	}

	// 2. 综合素质评价成绩
	if c.ComprehensiveQuality > other.ComprehensiveQuality {
		return 1
	}
	if c.ComprehensiveQuality < other.ComprehensiveQuality {
		return -1
	}

	// 3. 语数外三科合计
	cSum := c.ChineseScore + c.MathScore + c.ForeignScore
	otherSum := other.ChineseScore + other.MathScore + other.ForeignScore
	if cSum > otherSum {
		return 1
	}
	if cSum < otherSum {
		return -1
	}

	// 4. 数学成绩
	if c.MathScore > other.MathScore {
		return 1
	}
	if c.MathScore < other.MathScore {
		return -1
	}

	// 5. 语文成绩
	if c.ChineseScore > other.ChineseScore {
		return 1
	}
	if c.ChineseScore < other.ChineseScore {
		return -1
	}

	// 6. 综合测试成绩
	if c.IntegratedScore > other.IntegratedScore {
		return 1
	}
	if c.IntegratedScore < other.IntegratedScore {
		return -1
	}

	return 0
}

// CandidateGenerator 竞争对手生成器接口
type CandidateGeneratorInterface interface {
	Generate(ctx context.Context, realCandidate *Candidate, count int, quotaRepo QuotaRepository) []*Candidate
}

// QuotaRepository 名额分配数据仓库接口
type QuotaRepository interface {
	GetQuotaDistrictPlan(ctx context.Context, schoolID int32, districtID int32, year int) (int, error)
	GetQuotaSchoolPlan(ctx context.Context, schoolID int32, middleSchoolID int32, year int) (int, error)
	GetUnifiedPlan(ctx context.Context, schoolID int32, year int) (int, error)
	GetDistrictExamCount(ctx context.Context, districtID int32, year int) (int, error)
	GetMiddleSchoolStudentCount(ctx context.Context, middleSchoolID int32, year int) (int, error)
	PreloadCache(ctx context.Context, districtID int32, middleSchoolID int32, year int)
}

// RandomScoreGenerator 随机分数生成器
type RandomScoreGenerator struct {
	rand *rand.Rand
}

func NewRandomScoreGenerator(seed int64) *RandomScoreGenerator {
	return &RandomScoreGenerator{
		rand: rand.New(rand.NewSource(seed)),
	}
}

// GenerateNormalScore 生成正态分布分数
func (g *RandomScoreGenerator) GenerateNormalScore(mean, stddev float64) float64 {
	return g.rand.NormFloat64()*stddev + mean
}

// GenerateRandomScore 生成随机分数（在范围内均匀分布）
func (g *RandomScoreGenerator) GenerateRandomScore(min, max float64) float64 {
	return min + g.rand.Float64()*(max-min)
}

// GenerateCompetitorScores 生成竞争对手的分数
func (g *RandomScoreGenerator) GenerateCompetitorScores(totalScore float64, scoreRange float64) (chinese, math, foreign, integrated, ethics, history, pe float64) {
	// 基于总分生成合理的分数分布
	// 假设各科比例约为: 语文20%, 数学20%, 外语20%, 综合20%, 道德法治8%, 历史8%, 体育4%
	baseRatio := []float64{0.2, 0.2, 0.2, 0.2, 0.08, 0.08, 0.04}
	variation := scoreRange * 0.1 // 10%的波动

	chinese = totalScore*baseRatio[0] + g.GenerateRandomScore(-variation, variation)
	math = totalScore*baseRatio[1] + g.GenerateRandomScore(-variation, variation)
	foreign = totalScore*baseRatio[2] + g.GenerateRandomScore(-variation, variation)
	integrated = totalScore*baseRatio[3] + g.GenerateRandomScore(-variation, variation)
	ethics = totalScore*baseRatio[4] + g.GenerateRandomScore(-variation, variation)
	history = totalScore*baseRatio[5] + g.GenerateRandomScore(-variation, variation)
	pe = totalScore*baseRatio[6] + g.GenerateRandomScore(-variation, variation)

	// 确保分数在合理范围内
	chinese = clamp(chinese, 0, 150)
	math = clamp(math, 0, 150)
	foreign = clamp(foreign, 0, 150)
	integrated = clamp(integrated, 0, 150)
	ethics = clamp(ethics, 0, 60)
	history = clamp(history, 0, 60)
	pe = clamp(pe, 0, 30)

	return
}

func clamp(value, min, max float64) float64 {
	if value < min {
		return min
	}
	if value > max {
		return max
	}
	return value
}
