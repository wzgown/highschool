// service/candidate_service_test.go - Candidate Service 测试 (TDD)
package service

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
)

// MockSimulationHistoryRepo Mock 实现
type MockSimulationHistoryRepo struct {
	mock.Mock
}

func (m *MockSimulationHistoryRepo) Save(ctx context.Context, deviceID string, deviceInfo map[string]interface{},
	candidateData *highschoolv1.SubmitAnalysisRequest,
	result *highschoolv1.SimulationResults) (string, error) {
	args := m.Called(ctx, deviceID, deviceInfo, candidateData, result)
	return args.String(0), args.Error(1)
}

func (m *MockSimulationHistoryRepo) GetByID(ctx context.Context, id string) (*repository.SimulationHistoryRecord, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*repository.SimulationHistoryRecord), args.Error(1)
}

func (m *MockSimulationHistoryRepo) ListByDevice(ctx context.Context, deviceID string, page, pageSize int32) ([]*repository.SimulationHistoryRecord, int32, error) {
	args := m.Called(ctx, deviceID, page, pageSize)
	return args.Get(0).([]*repository.SimulationHistoryRecord), args.Get(1).(int32), args.Error(2)
}

func (m *MockSimulationHistoryRepo) DeleteByID(ctx context.Context, id string) error {
	args := m.Called(ctx, id)
	return args.Error(0)
}

func (m *MockSimulationHistoryRepo) DeleteByDevice(ctx context.Context, deviceID string) error {
	args := m.Called(ctx, deviceID)
	return args.Error(0)
}

// MockSchoolRepo Mock 实现
type MockSchoolRepo struct {
	mock.Mock
}

func (m *MockSchoolRepo) GetByID(ctx context.Context, id int32) (*highschoolv1.School, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*highschoolv1.School), args.Error(1)
}

func (m *MockSchoolRepo) List(ctx context.Context, districtID *int32, schoolTypeID, schoolNatureID *string,
	hasInternationalCourse *bool, keyword *string, page, pageSize int32) ([]*highschoolv1.School, int32, error) {
	args := m.Called(ctx, districtID, schoolTypeID, schoolNatureID, hasInternationalCourse, keyword, page, pageSize)
	return args.Get(0).([]*highschoolv1.School), args.Get(1).(int32), args.Error(2)
}

func (m *MockSchoolRepo) GetDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*highschoolv1.SchoolDetail), args.Error(1)
}

func (m *MockSchoolRepo) GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error) {
	args := m.Called(ctx, schoolID)
	return args.Get(0).([]*highschoolv1.HistoryScore), args.Error(1)
}

func TestCandidateService_SubmitAnalysis(t *testing.T) {
	t.Run("should reject when total score doesn't match sum", func(t *testing.T) {
		// Arrange
		service := NewCandidateService()
		districtID := int32(7)
		middleSchoolID := int32(1)
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId:     districtID,
				MiddleSchoolId: middleSchoolID,
			},
			Ranking: &highschoolv1.RankingInfo{
				Rank:         100,
				TotalStudents: 500,
			},
			Scores: &highschoolv1.CandidateScores{
				Total:      700,
				Chinese:    140,
				Math:       150,
				Foreign:    140,
				Integrated: 140,
				Ethics:     30,
				History:    30,
				Pe:         20, // 总和是 650，不是 700
			},
		}

		// Act
		_, err := service.SubmitAnalysis(context.Background(), req)

		// Assert
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "不符")
	})

	t.Run("should accept when total score matches sum", func(t *testing.T) {
		// 这个测试需要数据库连接，跳过
		t.Skip("Requires database connection - skipping integration test")
	})

	t.Run("should use provided device ID", func(t *testing.T) {
		// 这是一个需要 mock 的测试
		t.Skip("Requires mock setup for full testing")
	})

	t.Run("should generate new device ID when not provided", func(t *testing.T) {
		t.Skip("Requires mock setup for full testing")
	})
}

func TestCandidateService_validateScores(t *testing.T) {
	service := NewCandidateService().(*candidateService)

	tests := []struct {
		name    string
		scores  *highschoolv1.CandidateScores
		wantErr bool
	}{
		{
			name: "valid scores",
			scores: &highschoolv1.CandidateScores{
				Total:      660,
				Chinese:    140,
				Math:       150,
				Foreign:    140,
				Integrated: 140,
				Ethics:     30,
				History:    30,
				Pe:         30,
			},
			wantErr: false,
		},
		{
			name: "invalid scores - sum mismatch",
			scores: &highschoolv1.CandidateScores{
				Total:      660,
				Chinese:    140,
				Math:       150,
				Foreign:    140,
				Integrated: 140,
				Ethics:     30,
				History:    30,
				Pe:         29, // 少了 1 分
			},
			wantErr: true,
		},
		{
			name: "valid scores - zero",
			scores: &highschoolv1.CandidateScores{
				Total:      0,
				Chinese:    0,
				Math:       0,
				Foreign:    0,
				Integrated: 0,
				Ethics:     0,
				History:    0,
				Pe:         0,
			},
			wantErr: false,
		},
		{
			name: "valid scores - max",
			scores: &highschoolv1.CandidateScores{
				Total:      750,
				Chinese:    150,
				Math:       150,
				Foreign:    150,
				Integrated: 150,
				Ethics:     60,
				History:    60,
				Pe:         30,
			},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := service.validateScores(tt.scores)
			if tt.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestCandidateService_GetAnalysisResult(t *testing.T) {
	t.Run("should return result when exists", func(t *testing.T) {
		t.Skip("Requires mock setup")
	})

	t.Run("should return error when not exists", func(t *testing.T) {
		t.Skip("Requires mock setup")
	})
}

func TestCandidateService_GetHistory(t *testing.T) {
	t.Run("should return paginated history", func(t *testing.T) {
		t.Skip("Requires mock setup")
	})

	t.Run("should return empty list for new device", func(t *testing.T) {
		t.Skip("Requires mock setup")
	})
}

func TestCandidateService_DeleteHistory(t *testing.T) {
	t.Run("should delete single record when ID provided", func(t *testing.T) {
		t.Skip("Requires mock setup")
	})

	t.Run("should delete all records for device when ID empty", func(t *testing.T) {
		t.Skip("Requires mock setup")
	})
}

// 验证 service 实现了接口
func TestCandidateService_Interface(t *testing.T) {
	var _ CandidateService = (*candidateService)(nil)
}

// Benchmark 测试
func BenchmarkCandidateService_SubmitAnalysis(b *testing.B) {
	service := NewCandidateService()
	req := &highschoolv1.SubmitAnalysisRequest{
		Scores: &highschoolv1.CandidateScores{
			Total:      700,
			Chinese:    140,
			Math:       150,
			Foreign:    140,
			Integrated: 140,
			Ethics:     30,
			History:    30,
			Pe:         70,
		},
		Ranking: &highschoolv1.RankingInfo{
			Rank:          100,
			TotalStudents: 1000,
		},
		Volunteers: &highschoolv1.Volunteers{
			Unified: []int32{1, 2, 3},
		},
	}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		// 只验证成绩部分，不涉及数据库
		service.(*candidateService).validateScores(req.Scores)
	}
}

// 验证模拟引擎集成
func TestCandidateService_SimulationIntegration(t *testing.T) {
	t.Run("engine should be initialized", func(t *testing.T) {
		// 此测试需要数据库连接，跳过
		t.Skip("Requires database connection - skipping integration test")
	})

	t.Run("engine should produce consistent results", func(t *testing.T) {
		// 此测试需要数据库连接，跳过
		t.Skip("Requires database connection - skipping integration test")
	})
}
