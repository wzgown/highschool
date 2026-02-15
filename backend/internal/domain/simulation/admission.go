// simulation/admission.go - 录取规则实现
package simulation

import (
	"context"
	"sort"
)

// AdmissionBatch 录取批次类型
type AdmissionBatch string

const (
	BatchQuotaDistrict AdmissionBatch = "QUOTA_DISTRICT" // 名额分配到区
	BatchQuotaSchool   AdmissionBatch = "QUOTA_SCHOOL"   // 名额分配到校
	BatchUnified       AdmissionBatch = "UNIFIED"        // 统一招生
	BatchNone          AdmissionBatch = "NONE"           // 未录取
)

// AdmissionResult 录取结果
type AdmissionResult struct {
	CandidateID      int32
	AdmittedBatch    AdmissionBatch
	AdmittedSchoolID *int32
	AdmittedRank     int32 // 录取时的排名
}

// AdmissionRule 录取规则接口
type AdmissionRule interface {
	// Execute 执行录取
	// candidates: 所有待录取考生（会被修改状态）
	// 返回: 本批次的录取结果
	Execute(ctx context.Context, candidates []*Candidate) []AdmissionResult

	// Name 批次名称
	Name() string
}

// QuotaDistrictRule 名额分配到区录取规则
// 规则：全区排名竞争，1个志愿，按分数从高到低投档
type QuotaDistrictRule struct {
	quotaRepo QuotaRepository
	year      int
}

func NewQuotaDistrictRule(quotaRepo QuotaRepository, year int) *QuotaDistrictRule {
	return &QuotaDistrictRule{
		quotaRepo: quotaRepo,
		year:      year,
	}
}

func (r *QuotaDistrictRule) Name() string {
	return "名额分配到区"
}

func (r *QuotaDistrictRule) Execute(ctx context.Context, candidates []*Candidate) []AdmissionResult {
	results := []AdmissionResult{}

	// 按区分组处理
	districtCandidates := make(map[int32][]*Candidate)
	for _, c := range candidates {
		if c.AdmittedBatch != "" && c.AdmittedBatch != string(BatchNone) {
			continue // 已录取，跳过
		}
		if c.QuotaDistrictSchoolID == nil {
			continue // 没有填报本批次志愿
		}
		districtCandidates[c.DistrictID] = append(districtCandidates[c.DistrictID], c)
	}

	// 对每个区的考生按分数排序并投档
	for districtID, districtCands := range districtCandidates {
		// 按分数排序（降序），同分按6位序比较
		sort.Slice(districtCands, func(i, j int) bool {
			if districtCands[i].TotalScore != districtCands[j].TotalScore {
				return districtCands[i].TotalScore > districtCands[j].TotalScore
			}
			return districtCands[i].Compare(districtCands[j]) > 0
		})

		// 统计各学校的录取人数
		schoolAdmitted := make(map[int32]int)

		// 按排名依次投档
		for rank, c := range districtCands {
			schoolID := *c.QuotaDistrictSchoolID
			admitted := schoolAdmitted[schoolID]

			// 获取该学校在该区的名额数
			quota, err := r.quotaRepo.GetQuotaDistrictPlan(ctx, schoolID, districtID, r.year)
			if err != nil || quota <= 0 {
				continue // 无法获取名额数据，跳过
			}

			if admitted < quota {
				// 录取
				c.AdmittedBatch = string(BatchQuotaDistrict)
				c.AdmittedSchoolID = &schoolID
				c.AdmittedRank = int32(rank + 1)
				schoolAdmitted[schoolID]++

				results = append(results, AdmissionResult{
					CandidateID:      c.ID,
					AdmittedBatch:    BatchQuotaDistrict,
					AdmittedSchoolID: &schoolID,
					AdmittedRank:     int32(rank + 1),
				})
			}
		}
	}

	return results
}

// QuotaSchoolRule 名额分配到校录取规则
// 规则：校内排名竞争，2个平行志愿，按分数从高到低投档
type QuotaSchoolRule struct {
	quotaRepo QuotaRepository
	year      int
}

func NewQuotaSchoolRule(quotaRepo QuotaRepository, year int) *QuotaSchoolRule {
	return &QuotaSchoolRule{
		quotaRepo: quotaRepo,
		year:      year,
	}
}

func (r *QuotaSchoolRule) Name() string {
	return "名额分配到校"
}

func (r *QuotaSchoolRule) Execute(ctx context.Context, candidates []*Candidate) []AdmissionResult {
	results := []AdmissionResult{}

	// 按初中学校分组处理
	schoolCandidates := make(map[int32][]*Candidate)
	for _, c := range candidates {
		if c.AdmittedBatch != "" && c.AdmittedBatch != string(BatchNone) {
			continue // 已录取，跳过
		}
		if !c.HasQuotaSchoolEligible {
			continue // 不具备资格
		}
		if len(c.QuotaSchoolIDs) == 0 {
			continue // 没有填报本批次志愿
		}
		schoolCandidates[c.MiddleSchoolID] = append(schoolCandidates[c.MiddleSchoolID], c)
	}

	// 对每个初中学校的考生按分数排序并投档
	for middleSchoolID, schoolCands := range schoolCandidates {
		// 按分数排序（降序），同分按6位序比较
		sort.Slice(schoolCands, func(i, j int) bool {
			if schoolCands[i].TotalScore != schoolCands[j].TotalScore {
				return schoolCands[i].TotalScore > schoolCands[j].TotalScore
			}
			return schoolCands[i].Compare(schoolCands[j]) > 0
		})

		// 统计各高中的录取人数（在该初中）
		highSchoolAdmitted := make(map[int32]int)

		// 按排名依次投档（平行志愿）
		for rank, c := range schoolCands {
			// 遍历考生的志愿（平行志愿）
			admitted := false
			for _, schoolID := range c.QuotaSchoolIDs {
				admittedCount := highSchoolAdmitted[schoolID]

				// 获取该高中在该初中的名额数
				quota, err := r.quotaRepo.GetQuotaSchoolPlan(ctx, schoolID, middleSchoolID, r.year)
				if err != nil || quota <= 0 {
					continue // 无法获取名额数据或没有名额，尝试下一个志愿
				}

				if admittedCount < quota {
					// 录取
					c.AdmittedBatch = string(BatchQuotaSchool)
					c.AdmittedSchoolID = &schoolID
					c.AdmittedRank = int32(rank + 1)
					highSchoolAdmitted[schoolID]++

					results = append(results, AdmissionResult{
						CandidateID:      c.ID,
						AdmittedBatch:    BatchQuotaSchool,
						AdmittedSchoolID: &schoolID,
						AdmittedRank:     int32(rank + 1),
					})
					admitted = true
					break // 一轮投档，录取后不再处理后续志愿
				}
			}
			_ = admitted
		}
	}

	return results
}

// UnifiedRule 统一招生录取规则
// 规则：区内排名竞争，15个平行志愿，按分数从高到低投档
// 注意：统一招生使用750分制（不含综合素质评价）
type UnifiedRule struct {
	quotaRepo QuotaRepository
	year      int
}

func NewUnifiedRule(quotaRepo QuotaRepository, year int) *UnifiedRule {
	return &UnifiedRule{
		quotaRepo: quotaRepo,
		year:      year,
	}
}

func (r *UnifiedRule) Name() string {
	return "统一招生"
}

func (r *UnifiedRule) Execute(ctx context.Context, candidates []*Candidate) []AdmissionResult {
	results := []AdmissionResult{}

	// 统一招生使用750分制（学业考成绩，不含综合素质评价）
	// 计算学业考总分
	type candidateWithScore struct {
		candidate *Candidate
		score750  float64
	}

	// 按区分组处理
	districtCandidates := make(map[int32][]candidateWithScore)
	for _, c := range candidates {
		if c.AdmittedBatch != "" && c.AdmittedBatch != string(BatchNone) {
			continue // 已录取，跳过
		}
		if len(c.UnifiedSchoolIDs) == 0 {
			continue // 没有填报本批次志愿
		}

		// 计算学业考成绩（750分制）= 语文 + 数学 + 外语 + 综合 + 道德法治 + 历史 + 体育
		score750 := c.ChineseScore + c.MathScore + c.ForeignScore + c.IntegratedScore + c.EthicsScore + c.HistoryScore + c.PEScore

		districtCandidates[c.DistrictID] = append(districtCandidates[c.DistrictID], candidateWithScore{
			candidate: c,
			score750:  score750,
		})
	}

	// 对每个区的考生按分数排序并投档
	for _, districtCands := range districtCandidates {
		// 按分数排序（降序），同分按6位序比较
		sort.Slice(districtCands, func(i, j int) bool {
			if districtCands[i].score750 != districtCands[j].score750 {
				return districtCands[i].score750 > districtCands[j].score750
			}
			return districtCands[i].candidate.Compare(districtCands[j].candidate) > 0
		})

		// 统计各学校的录取人数
		schoolAdmitted := make(map[int32]int)

		// 按排名依次投档（平行志愿）
		for rank, cs := range districtCands {
			c := cs.candidate
			admitted := false

			// 遍历考生的15个志愿（平行志愿）
			for _, schoolID := range c.UnifiedSchoolIDs {
				admittedCount := schoolAdmitted[schoolID]

				// 获取该学校的统一招生计划数
				// 这里简化处理，假设统一招生计划可以从总计划减去名额分配计划得出
				// 实际应从数据库获取
				quota := 200 // 默认值，实际应从数据库获取

				if admittedCount < quota {
					// 录取
					c.AdmittedBatch = string(BatchUnified)
					c.AdmittedSchoolID = &schoolID
					c.AdmittedRank = int32(rank + 1)
					schoolAdmitted[schoolID]++

					results = append(results, AdmissionResult{
						CandidateID:      c.ID,
						AdmittedBatch:    BatchUnified,
						AdmittedSchoolID: &schoolID,
						AdmittedRank:     int32(rank + 1),
					})
					admitted = true
					break // 一轮投档，录取后不再处理后续志愿
				}
			}

			if !admitted {
				// 未录取
				c.AdmittedBatch = string(BatchNone)
			}
		}
	}

	return results
}

// Simulator 模拟器
type Simulator struct {
	rules    []AdmissionRule
	quotaRep QuotaRepository
}

func NewSimulator(quotaRep QuotaRepository, year int) *Simulator {
	return &Simulator{
		rules: []AdmissionRule{
			NewQuotaDistrictRule(quotaRep, year),
			NewQuotaSchoolRule(quotaRep, year),
			NewUnifiedRule(quotaRep, year),
		},
		quotaRep: quotaRep,
	}
}

// Run 执行录取模拟
func (s *Simulator) Run(ctx context.Context, candidates []*Candidate) map[int32]*AdmissionResult {
	results := make(map[int32]*AdmissionResult)

	// 按批次顺序执行录取
	for _, rule := range s.rules {
		batchResults := rule.Execute(ctx, candidates)
		for _, r := range batchResults {
			results[r.CandidateID] = &r
		}
	}

	return results
}
