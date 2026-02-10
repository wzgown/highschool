// simulation/engine_test.go - 模拟引擎测试 (TDD)
package simulation

import (
	"testing"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"github.com/stretchr/testify/assert"
)

func TestEngine_Run(t *testing.T) {
	engine := NewEngine()

	t.Run("should calculate percentile correctly", func(t *testing.T) {
		// Arrange
		req := &highschoolv1.SubmitAnalysisRequest{
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Volunteers: &highschoolv1.Volunteers{
				Unified: []int32{1, 2, 3},
			},
		}

		// Act
		results := engine.Run(req)

		// Assert
		assert.NotNil(t, results)
		assert.NotNil(t, results.Predictions)
		// 百分位 = (1000-100)/1000 * 100 = 90
		assert.Equal(t, float64(90), results.Predictions.Percentile)
	})

	t.Run("should calculate district rank correctly", func(t *testing.T) {
		// Arrange
		req := &highschoolv1.SubmitAnalysisRequest{
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Volunteers: &highschoolv1.Volunteers{
				Unified: []int32{1},
			},
		}

		// Act
		results := engine.Run(req)

		// Assert
		// 区内排名 = 100 * 12.5 = 1250
		assert.Equal(t, int32(1250), results.Predictions.DistrictRank)
	})

	t.Run("should generate probabilities for all volunteers", func(t *testing.T) {
		// Arrange
		quotaDistrict := int32(1)
		req := &highschoolv1.SubmitAnalysisRequest{
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
		results := engine.Run(req)

		// Assert
		assert.Len(t, results.Probabilities, 6) // 1 + 2 + 3 = 6
	})

	t.Run("should calculate strategy analysis", func(t *testing.T) {
		// Arrange
		req := &highschoolv1.SubmitAnalysisRequest{
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Volunteers: &highschoolv1.Volunteers{
				Unified: []int32{1, 2, 3},
			},
		}

		// Act
		results := engine.Run(req)

		// Assert
		assert.NotNil(t, results.Strategy)
		assert.NotNil(t, results.Strategy.Gradient)
		assert.GreaterOrEqual(t, results.Strategy.Score, int32(0))
		assert.LessOrEqual(t, results.Strategy.Score, int32(100))
	})

	t.Run("should generate competitor analysis", func(t *testing.T) {
		// Arrange
		req := &highschoolv1.SubmitAnalysisRequest{
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 1000,
			},
			Volunteers: &highschoolv1.Volunteers{
				Unified: []int32{1},
			},
		}

		// Act
		results := engine.Run(req)

		// Assert
		assert.NotNil(t, results.Competitors)
		assert.Greater(t, results.Competitors.Count, int32(0))
		assert.NotEmpty(t, results.Competitors.ScoreDistribution)
	})
}

func TestEngine_calculateProbability(t *testing.T) {
	engine := NewEngine()

	tests := []struct {
		name           string
		candidateScore int32
		schoolScore    int32
		expectedProb   float64
	}{
		{"much higher", 750, 700, 95.0},   // +50
		{"higher", 720, 700, 80.0},        // +20
		{"slightly higher", 710, 700, 80.0}, // +10
		{"equal", 700, 700, 60.0},         // 0
		{"slightly lower", 690, 700, 60.0}, // -10
		{"lower", 670, 700, 35.0},         // -30
		{"much lower", 650, 700, 15.0},    // -50
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			prob := engine.calculateProbability(tt.candidateScore, tt.schoolScore)
			assert.Equal(t, tt.expectedProb, prob)
		})
	}
}

func TestEngine_calculateConfidence(t *testing.T) {
	engine := NewEngine()

	tests := []struct {
		percentile       float64
		expectedConfidence string
	}{
		{50.0, "high"},    // 30-70 范围
		{30.0, "high"},    // 边界
		{70.0, "high"},    // 边界
		{20.0, "medium"},  // 15-30 范围
		{80.0, "medium"},  // 70-85 范围
		{10.0, "low"},     // <15
		{90.0, "low"},     // >85
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
