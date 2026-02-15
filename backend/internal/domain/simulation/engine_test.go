// simulation/engine_test.go - 模拟引擎测试 (TDD)
package simulation

import (
	"context"
	"testing"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"github.com/stretchr/testify/assert"
)

// mockSchoolRepo 用于测试的模拟学校仓库
type mockSchoolRepo struct{}

func (m *mockSchoolRepo) GetByID(ctx context.Context, id int32) (*highschoolv1.School, error) {
	return &highschoolv1.School{
		Id:       id,
		FullName: "测试学校",
		Code:     "TEST001",
	}, nil
}

func (m *mockSchoolRepo) List(ctx context.Context, districtID *int32, schoolTypeID, schoolNatureID *string,
	hasInternationalCourse *bool, keyword *string, page, pageSize int32) ([]*highschoolv1.School, int32, error) {
	return nil, 0, nil
}

func (m *mockSchoolRepo) GetDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error) {
	return nil, nil
}

func (m *mockSchoolRepo) GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error) {
	return nil, nil
}

// mockQuotaRepo 用于测试的模拟名额仓库
type mockQuotaRepo struct{}

func (m *mockQuotaRepo) GetQuotaDistrictPlan(ctx context.Context, schoolID int32, districtID int32, year int) (int, error) {
	return 10, nil // 返回10个名额
}

func (m *mockQuotaRepo) GetQuotaSchoolPlan(ctx context.Context, schoolID int32, middleSchoolID int32, year int) (int, error) {
	return 5, nil // 返回5个名额
}

func (m *mockQuotaRepo) GetDistrictExamCount(ctx context.Context, districtID int32, year int) (int, error) {
	return 10000, nil // 返回10000个考生
}

func (m *mockQuotaRepo) GetMiddleSchoolStudentCount(ctx context.Context, middleSchoolID int32, year int) (int, error) {
	return 300, nil
}

func TestEngine_Run(t *testing.T) {
	engine := NewEngine(
		WithSchoolRepo(&mockSchoolRepo{}),
		WithQuotaRepo(&mockQuotaRepo{}),
		WithSimulationCount(10), // 减少模拟次数以加快测试
	)

	districtID := int32(1)
	middleSchoolID := int32(1)

	t.Run("should calculate percentile correctly", func(t *testing.T) {
		// Arrange
		quotaDistrict := int32(1)
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:       districtID,
				MiddleSchoolId:   middleSchoolID,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Volunteers: &highschoolv1.Volunteers{
				QuotaDistrict: &quotaDistrict,
				Unified:       []int32{1, 2, 3},
			},
		}

		// Act
		results := engine.Run(context.Background(), req)

		// Assert
		assert.NotNil(t, results)
		assert.NotNil(t, results.Predictions)
		// 百分位 = (1000-100)/1000 * 100 = 90
		assert.Equal(t, float64(90), results.Predictions.Percentile)
	})

	t.Run("should predict district rank based on school ranking", func(t *testing.T) {
		// Arrange
		quotaDistrict := int32(1)
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:       districtID,
				MiddleSchoolId:   middleSchoolID,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Volunteers: &highschoolv1.Volunteers{
				QuotaDistrict: &quotaDistrict,
				Unified:       []int32{1},
			},
		}

		// Act
		results := engine.Run(context.Background(), req)

		// Assert
		// 区内排名 = 100 / 1000 * 10000 = 1000
		assert.Equal(t, int32(1000), results.Predictions.DistrictRank)
	})

	t.Run("should generate probabilities for all volunteers", func(t *testing.T) {
		// Arrange
		quotaDistrict := int32(1)
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:             districtID,
				MiddleSchoolId:         middleSchoolID,
				HasQuotaSchoolEligibility: true,
			},
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Volunteers: &highschoolv1.Volunteers{
				QuotaDistrict: &quotaDistrict,
				QuotaSchool:   []int32{2, 3},
				Unified:       []int32{4, 5, 6},
			},
		}

		// Act
		results := engine.Run(context.Background(), req)

		// Assert
		assert.Len(t, results.Probabilities, 6) // 1 + 2 + 3 = 6
	})

	t.Run("should calculate strategy analysis", func(t *testing.T) {
		// Arrange
		quotaDistrict := int32(1)
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:       districtID,
				MiddleSchoolId:   middleSchoolID,
			},
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Volunteers: &highschoolv1.Volunteers{
				QuotaDistrict: &quotaDistrict,
				Unified:       []int32{1, 2, 3},
			},
		}

		// Act
		results := engine.Run(context.Background(), req)

		// Assert
		assert.NotNil(t, results.Strategy)
		assert.NotNil(t, results.Strategy.Gradient)
		assert.GreaterOrEqual(t, results.Strategy.Score, int32(0))
		assert.LessOrEqual(t, results.Strategy.Score, int32(100))
	})

	t.Run("should generate competitor analysis", func(t *testing.T) {
		// Arrange
		quotaDistrict := int32(1)
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:       districtID,
				MiddleSchoolId:   middleSchoolID,
			},
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Volunteers: &highschoolv1.Volunteers{
				QuotaDistrict: &quotaDistrict,
				Unified:       []int32{1},
			},
		}

		// Act
		results := engine.Run(context.Background(), req)

		// Assert
		assert.NotNil(t, results.Competitors)
		assert.Greater(t, results.Competitors.Count, int32(0))
		assert.NotEmpty(t, results.Competitors.ScoreDistribution)
	})
}

func TestCandidate_Compare(t *testing.T) {
	t.Run("tie preference takes precedence", func(t *testing.T) {
		c1 := &Candidate{HasTiePreference: true, TotalScore: 700}
		c2 := &Candidate{HasTiePreference: false, TotalScore: 700}
		assert.Equal(t, 1, c1.Compare(c2))
		assert.Equal(t, -1, c2.Compare(c1))
	})

	t.Run("comprehensive quality breaks tie", func(t *testing.T) {
		c1 := &Candidate{TotalScore: 700, ComprehensiveQuality: 50}
		c2 := &Candidate{TotalScore: 700, ComprehensiveQuality: 45}
		assert.Equal(t, 1, c1.Compare(c2))
		assert.Equal(t, -1, c2.Compare(c1))
	})

	t.Run("chinese_math_foreign_sum breaks tie", func(t *testing.T) {
		c1 := &Candidate{TotalScore: 700, ComprehensiveQuality: 50, ChineseScore: 140, MathScore: 140, ForeignScore: 140}
		c2 := &Candidate{TotalScore: 700, ComprehensiveQuality: 50, ChineseScore: 130, MathScore: 140, ForeignScore: 140}
		assert.Equal(t, 1, c1.Compare(c2))
		assert.Equal(t, -1, c2.Compare(c1))
	})

	t.Run("math score breaks tie", func(t *testing.T) {
		c1 := &Candidate{TotalScore: 700, ComprehensiveQuality: 50, ChineseScore: 140, MathScore: 145, ForeignScore: 140}
		c2 := &Candidate{TotalScore: 700, ComprehensiveQuality: 50, ChineseScore: 140, MathScore: 140, ForeignScore: 140}
		assert.Equal(t, 1, c1.Compare(c2))
		assert.Equal(t, -1, c2.Compare(c1))
	})
}

func TestEngine_calculateConfidence(t *testing.T) {
	engine := NewEngine(WithSchoolRepo(&mockSchoolRepo{}))

	tests := []struct {
		percentile          float64
		expectedConfidence string
	}{
		{50.0, "high"},   // 30-70 范围
		{30.0, "high"},   // 边界
		{70.0, "high"},   // 边界
		{20.0, "medium"}, // 15-30 范围
		{80.0, "medium"}, // 70-85 范围
		{10.0, "low"},    // <15
		{90.0, "low"},    // >85
	}

	for _, tt := range tests {
		t.Run(tt.expectedConfidence, func(t *testing.T) {
			confidence := engine.calculateConfidence(tt.percentile)
			assert.Equal(t, tt.expectedConfidence, confidence)
		})
	}
}

func TestGetRiskLevel(t *testing.T) {
	tests := []struct {
		prob     float64
		expected string
	}{
		{95.0, "safe"},
		{80.0, "safe"},
		{79.9, "moderate"},
		{50.0, "moderate"},
		{49.9, "risky"},
		{20.0, "risky"},
		{19.9, "high_risk"},
		{0.0, "high_risk"},
	}

	for _, tt := range tests {
		t.Run(tt.expected, func(t *testing.T) {
			level := getRiskLevel(tt.prob)
			assert.Equal(t, tt.expected, level)
		})
	}
}
