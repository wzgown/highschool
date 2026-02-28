// service/recommendation_service_test.go - 志愿推荐服务测试
package service

import (
	"testing"

	highschoolv1 "highschool-backend/gen/highschool/v1"
)

func TestCalculateConfidence(t *testing.T) {
	tests := []struct {
		name      string
		scoreGap  float64
		expected  highschoolv1.RecommendationConfidence
	}{
		{
			name:     "High confidence - gap > 15",
			scoreGap: 20.0,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_HIGH,
		},
		{
			name:     "High confidence - gap exactly 15.1",
			scoreGap: 15.1,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_HIGH,
		},
		{
			name:     "Medium confidence - gap exactly 15",
			scoreGap: 15.0,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_MEDIUM,
		},
		{
			name:     "Medium confidence - gap 10",
			scoreGap: 10.0,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_MEDIUM,
		},
		{
			name:     "Medium confidence - gap exactly 5",
			scoreGap: 5.0,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_MEDIUM,
		},
		{
			name:     "Low confidence - gap 4.9",
			scoreGap: 4.9,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_LOW,
		},
		{
			name:     "Low confidence - gap 0",
			scoreGap: 0.0,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_LOW,
		},
		{
			name:     "Low confidence - negative gap",
			scoreGap: -5.0,
			expected: highschoolv1.RecommendationConfidence_RECOMMENDATION_CONFIDENCE_LOW,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := calculateConfidence(tt.scoreGap)
			if result != tt.expected {
				t.Errorf("calculateConfidence(%v) = %v, want %v", tt.scoreGap, result, tt.expected)
			}
		})
	}
}

func TestDetermineRecommendationType(t *testing.T) {
	tests := []struct {
		name             string
		scoreGap         float64
		isQuotaDistrict  bool
		expected         highschoolv1.RecommendationType
	}{
		// 名额到区测试
		{
			name:            "Quota district - target (gap 10)",
			scoreGap:        10.0,
			isQuotaDistrict: true,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:            "Quota district - target (gap 5)",
			scoreGap:        5.0,
			isQuotaDistrict: true,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:            "Quota district - target (gap 20)",
			scoreGap:        20.0,
			isQuotaDistrict: true,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:            "Quota district - safety (gap > 20)",
			scoreGap:        25.0,
			isQuotaDistrict: true,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY,
		},
		{
			name:            "Quota district - reach (gap < 5)",
			scoreGap:        3.0,
			isQuotaDistrict: true,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH,
		},
		// 名额到校测试
		{
			name:            "Quota school - safety (gap > 10)",
			scoreGap:        15.0,
			isQuotaDistrict: false,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY,
		},
		{
			name:            "Quota school - target (gap 5)",
			scoreGap:        5.0,
			isQuotaDistrict: false,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:            "Quota school - target (gap -5)",
			scoreGap:        -5.0,
			isQuotaDistrict: false,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:            "Quota school - reach (gap < -5)",
			scoreGap:        -10.0,
			isQuotaDistrict: false,
			expected:        highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := determineRecommendationType(tt.scoreGap, tt.isQuotaDistrict)
			if result != tt.expected {
				t.Errorf("determineRecommendationType(%v, %v) = %v, want %v",
					tt.scoreGap, tt.isQuotaDistrict, result, tt.expected)
			}
		})
	}
}

func TestDetermineRecommendationTypeUnified(t *testing.T) {
	tests := []struct {
		name     string
		scoreGap float64
		expected highschoolv1.RecommendationType
	}{
		{
			name:     "Safety - gap > 15",
			scoreGap: 20.0,
			expected: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY,
		},
		{
			name:     "Safety - gap exactly 15.1",
			scoreGap: 15.1,
			expected: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY,
		},
		{
			name:     "Target - gap exactly 15",
			scoreGap: 15.0,
			expected: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:     "Target - gap 10",
			scoreGap: 10.0,
			expected: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:     "Target - gap -5",
			scoreGap: -5.0,
			expected: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
		},
		{
			name:     "Reach - gap < -5",
			scoreGap: -10.0,
			expected: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := determineRecommendationTypeUnified(tt.scoreGap)
			if result != tt.expected {
				t.Errorf("determineRecommendationTypeUnified(%v) = %v, want %v",
					tt.scoreGap, result, tt.expected)
			}
		})
	}
}

func TestBuildRecommendationReason(t *testing.T) {
	tests := []struct {
		name     string
		recType  highschoolv1.RecommendationType
		scoreGap float64
		contains string
	}{
		{
			name:     "Reach with positive gap",
			recType:  highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH,
			scoreGap: 3.0,
			contains: "冲刺",
		},
		{
			name:     "Target with positive gap",
			recType:  highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
			scoreGap: 10.0,
			contains: "稳妥",
		},
		{
			name:     "Safety with positive gap",
			recType:  highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY,
			scoreGap: 25.0,
			contains: "保底",
		},
		{
			name:     "Negative gap shows below score",
			recType:  highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH,
			scoreGap: -5.0,
			contains: "低于分数线",
		},
		{
			name:     "Zero gap shows tied",
			recType:  highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
			scoreGap: 0.0,
			contains: "持平",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := buildRecommendationReason(tt.recType, tt.scoreGap, "测试批次")
			if !contains(result, tt.contains) {
				t.Errorf("buildRecommendationReason(%v, %v, \"测试批次\") = %v, should contain %v",
					tt.recType, tt.scoreGap, result, tt.contains)
			}
		})
	}
}

func TestDistributeUnifiedRecommendations(t *testing.T) {
	// 创建测试数据
	var recommendations []*highschoolv1.RecommendedSchool

	// 添加冲刺学校
	for i := 0; i < 5; i++ {
		recommendations = append(recommendations, &highschoolv1.RecommendedSchool{
			SchoolId:           int32(i + 1),
			SchoolName:         "冲刺学校" + string(rune('A'+i)),
			RecommendationType: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH,
			ScoreGap:           -float32(i + 5),
		})
	}

	// 添加稳妥学校
	for i := 0; i < 6; i++ {
		recommendations = append(recommendations, &highschoolv1.RecommendedSchool{
			SchoolId:           int32(i + 100),
			SchoolName:         "稳妥学校" + string(rune('A'+i)),
			RecommendationType: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET,
			ScoreGap:           float32(i + 5),
		})
	}

	// 添加保底学校
	for i := 0; i < 8; i++ {
		recommendations = append(recommendations, &highschoolv1.RecommendedSchool{
			SchoolId:           int32(i + 200),
			SchoolName:         "保底学校" + string(rune('A'+i)),
			RecommendationType: highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY,
			ScoreGap:           float32(i + 20),
		})
	}

	result := distributeUnifiedRecommendations(recommendations)

	// 验证结果
	if len(result) > 15 {
		t.Errorf("Expected at most 15 recommendations, got %d", len(result))
	}

	// 统计各类型数量
	reachCount := 0
	targetCount := 0
	safetyCount := 0
	for _, r := range result {
		switch r.RecommendationType {
		case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_REACH:
			reachCount++
		case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_TARGET:
			targetCount++
		case highschoolv1.RecommendationType_RECOMMENDATION_TYPE_SAFETY:
			safetyCount++
		}
	}

	// 验证分布：3冲刺 + 5稳妥 + 7保底 = 15
	if reachCount > 3 {
		t.Errorf("Expected at most 3 reach schools, got %d", reachCount)
	}
	if targetCount > 5 {
		t.Errorf("Expected at most 5 target schools, got %d", targetCount)
	}
	if safetyCount > 7 {
		t.Errorf("Expected at most 7 safety schools, got %d", safetyCount)
	}

	// 验证没有重复学校
	seen := make(map[int32]bool)
	for _, r := range result {
		if seen[r.SchoolId] {
			t.Errorf("Duplicate school ID: %d", r.SchoolId)
		}
		seen[r.SchoolId] = true
	}
}

func TestAbs32(t *testing.T) {
	tests := []struct {
		input    float32
		expected float32
	}{
		{5.0, 5.0},
		{-5.0, 5.0},
		{0.0, 0.0},
		{-0.1, 0.1},
		{123.456, 123.456},
		{-123.456, 123.456},
	}

	for _, tt := range tests {
		result := abs32(tt.input)
		if result != tt.expected {
			t.Errorf("abs32(%v) = %v, want %v", tt.input, result, tt.expected)
		}
	}
}

// 辅助函数
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && (s[:len(substr)] == substr || s[len(s)-len(substr):] == substr || containsMiddle(s, substr)))
}

func containsMiddle(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
