// service/candidate_service_test.go - Candidate Service 测试 (TDD)
package service

import (
	"context"
	"fmt"
	"strconv"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"

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

func (m *MockSimulationHistoryRepo) SavePending(ctx context.Context, deviceID string, deviceInfo map[string]interface{},
	candidateData *highschoolv1.SubmitAnalysisRequest) (string, error) {
	args := m.Called(ctx, deviceID, deviceInfo, candidateData)
	return args.String(0), args.Error(1)
}

func (m *MockSimulationHistoryRepo) UpdateResult(ctx context.Context, id string, result *highschoolv1.SimulationResults) error {
	args := m.Called(ctx, id, result)
	return args.Error(0)
}

func (m *MockSimulationHistoryRepo) UpdateStatus(ctx context.Context, id string, status string, errorMessage *string) error {
	args := m.Called(ctx, id, status, errorMessage)
	return args.Error(0)
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

// =============================================================================
// 异步 SubmitAnalysis 测试（内存 fake，无数据库依赖）
// =============================================================================

// fakeSimRepo 内存版 SimulationHistoryRepository，支持后台 goroutine 并发读写
type fakeSimRepo struct {
	mu      sync.Mutex
	records map[int64]*repository.SimulationHistoryRecord
	nextID  int64
}

func newFakeSimRepo() *fakeSimRepo {
	return &fakeSimRepo{records: make(map[int64]*repository.SimulationHistoryRecord)}
}

func (f *fakeSimRepo) Save(ctx context.Context, deviceID string, deviceInfo map[string]interface{},
	candidateData *highschoolv1.SubmitAnalysisRequest,
	result *highschoolv1.SimulationResults) (string, error) {
	return "", fmt.Errorf("not implemented")
}

func (f *fakeSimRepo) SavePending(ctx context.Context, deviceID string, deviceInfo map[string]interface{},
	candidateData *highschoolv1.SubmitAnalysisRequest) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.nextID++
	f.records[f.nextID] = &repository.SimulationHistoryRecord{
		ID:            f.nextID,
		DeviceID:      deviceID,
		CandidateData: candidateData,
		Status:        "pending",
		CreatedAt:     time.Now(),
	}
	return strconv.FormatInt(f.nextID, 10), nil
}

func (f *fakeSimRepo) UpdateResult(ctx context.Context, id string, result *highschoolv1.SimulationResults) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	idInt, _ := strconv.ParseInt(id, 10, 64)
	rec, ok := f.records[idInt]
	if !ok {
		return fmt.Errorf("record not found")
	}
	rec.SimulationResult = result
	rec.Status = "completed"
	rec.ErrorMessage = nil
	return nil
}

func (f *fakeSimRepo) UpdateStatus(ctx context.Context, id string, status string, errorMessage *string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	idInt, _ := strconv.ParseInt(id, 10, 64)
	rec, ok := f.records[idInt]
	if !ok {
		return fmt.Errorf("record not found")
	}
	rec.Status = status
	rec.ErrorMessage = errorMessage
	return nil
}

func (f *fakeSimRepo) GetByID(ctx context.Context, id string) (*repository.SimulationHistoryRecord, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		return nil, fmt.Errorf("invalid id format")
	}
	rec, ok := f.records[idInt]
	if !ok {
		return nil, fmt.Errorf("record not found")
	}
	copied := *rec
	return &copied, nil
}

func (f *fakeSimRepo) ListByDevice(ctx context.Context, deviceID string, page, pageSize int32) ([]*repository.SimulationHistoryRecord, int32, error) {
	return nil, 0, fmt.Errorf("not implemented")
}

func (f *fakeSimRepo) DeleteByID(ctx context.Context, id string) error {
	return fmt.Errorf("not implemented")
}

func (f *fakeSimRepo) DeleteByDevice(ctx context.Context, deviceID string) error {
	return fmt.Errorf("not implemented")
}

// fakeEngine 可编程的模拟引擎
type fakeEngine struct {
	run func(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults
}

func (f fakeEngine) Run(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults {
	return f.run(ctx, req)
}

// fakeSchoolRepo 最小实现，仅满足校验路径（允许学校 ID 101）
type fakeSchoolRepo struct{}

func (fakeSchoolRepo) GetByID(ctx context.Context, id int32) (*highschoolv1.School, error) {
	return nil, fmt.Errorf("not implemented")
}

func (fakeSchoolRepo) List(ctx context.Context, districtID *int32, schoolTypeID, schoolNatureID *string,
	hasInternationalCourse *bool, keyword *string, page, pageSize int32) ([]*highschoolv1.School, int32, error) {
	return nil, 0, fmt.Errorf("not implemented")
}

func (fakeSchoolRepo) GetDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error) {
	return nil, fmt.Errorf("not implemented")
}

func (fakeSchoolRepo) GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error) {
	return nil, fmt.Errorf("not implemented")
}

func (fakeSchoolRepo) GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolWithQuota, error) {
	return nil, nil
}

func (fakeSchoolRepo) GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32) ([]*highschoolv1.SchoolWithQuota, error) {
	return nil, nil
}

func (fakeSchoolRepo) GetSchoolsForUnified(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolForUnified, error) {
	return []*highschoolv1.SchoolForUnified{{Id: 101, FullName: "测试高中"}}, nil
}

func (fakeSchoolRepo) GetSchoolsByCutoffScoreRanking(ctx context.Context, districtID int32) ([]*repository.SchoolRankingInfo, error) {
	return nil, fmt.Errorf("not implemented")
}

func (fakeSchoolRepo) PreloadCache(ctx context.Context, districtID int32, middleSchoolID int32) {}

func (fakeSchoolRepo) GetLatestScoreYear(ctx context.Context) (int, error) {
	return 0, fmt.Errorf("not implemented")
}

// fakeMiddleSchoolRepo 最小实现
type fakeMiddleSchoolRepo struct {
	studentCount int32
}

func (f fakeMiddleSchoolRepo) List(ctx context.Context, districtID *int32, keyword *string) ([]*highschoolv1.MiddleSchool, error) {
	return nil, fmt.Errorf("not implemented")
}

func (f fakeMiddleSchoolRepo) GetStudentCount(ctx context.Context, middleSchoolID int32) (int32, error) {
	return f.studentCount, nil
}

// newAsyncTestService 构造用于异步测试的 service（全部 fake 依赖）
func newAsyncTestService(engine simulationRunner) *candidateService {
	return &candidateService{
		simRepo:          newFakeSimRepo(),
		schoolRepo:       fakeSchoolRepo{},
		middleSchoolRepo: fakeMiddleSchoolRepo{studentCount: 300},
		simEngine:        engine,
		engineSem:        make(chan struct{}, maxConcurrentEngineRuns),
	}
}

// validAsyncTestRequest 构造能通过 validateRequest 的请求
func validAsyncTestRequest() *highschoolv1.SubmitAnalysisRequest {
	return &highschoolv1.SubmitAnalysisRequest{
		Candidate: &highschoolv1.CandidateInfo{
			DistrictId:     7,
			MiddleSchoolId: 1,
		},
		Ranking: &highschoolv1.RankingInfo{
			Rank:          100,
			TotalStudents: 300,
		},
		Scores: &highschoolv1.CandidateScores{
			Total:      660,
			Chinese:    140,
			Math:       150,
			Foreign:    140,
			Integrated: 140,
			Ethics:     30,
			History:    30,
			Pe:         30,
		},
		Volunteers: &highschoolv1.Volunteers{
			Unified: []int32{101},
		},
	}
}

// waitAnalysisDone 带超时轮询，等待状态收敛到 completed/failed
func waitAnalysisDone(t *testing.T, svc CandidateService, id string) *highschoolv1.AnalysisResult {
	t.Helper()
	deadline := time.Now().Add(5 * time.Second)
	for {
		res, err := svc.GetAnalysisResult(context.Background(), id)
		require.NoError(t, err)
		if res.Status == "completed" || res.Status == "failed" {
			return res
		}
		if time.Now().After(deadline) {
			t.Fatalf("等待分析状态收敛超时，当前 status=%s", res.Status)
		}
		time.Sleep(20 * time.Millisecond)
	}
}

func TestCandidateService_SubmitAnalysis_Async(t *testing.T) {
	t.Run("should return pending immediately then complete in background", func(t *testing.T) {
		engine := fakeEngine{run: func(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults {
			return &highschoolv1.SimulationResults{
				Predictions: &highschoolv1.RankPrediction{Confidence: "high", Percentile: 33.3},
			}
		}}
		svc := newAsyncTestService(engine)

		resp, err := svc.SubmitAnalysis(context.Background(), validAsyncTestRequest())
		require.NoError(t, err)
		require.NotNil(t, resp.Result)
		assert.Equal(t, "pending", resp.Result.Status)
		assert.NotEmpty(t, resp.Result.Id)
		assert.Nil(t, resp.Result.Results, "pending 响应不应携带结果")

		final := waitAnalysisDone(t, svc, resp.Result.Id)
		assert.Equal(t, "completed", final.Status)
		require.NotNil(t, final.Results, "completed 后应能取到结果")
		assert.Equal(t, "high", final.Results.Predictions.Confidence)
	})

	t.Run("should mark failed with error_message when engine panics", func(t *testing.T) {
		engine := fakeEngine{run: func(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults {
			panic("boom")
		}}
		svc := newAsyncTestService(engine)

		resp, err := svc.SubmitAnalysis(context.Background(), validAsyncTestRequest())
		require.NoError(t, err)
		assert.Equal(t, "pending", resp.Result.Status)

		final := waitAnalysisDone(t, svc, resp.Result.Id)
		assert.Equal(t, "failed", final.Status)
		require.NotNil(t, final.ErrorMessage)
		assert.Contains(t, *final.ErrorMessage, "boom")
		assert.Nil(t, final.Results, "failed 不应携带结果")
	})

	t.Run("should mark failed when engine returns nil results", func(t *testing.T) {
		engine := fakeEngine{run: func(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults {
			return nil
		}}
		svc := newAsyncTestService(engine)

		resp, err := svc.SubmitAnalysis(context.Background(), validAsyncTestRequest())
		require.NoError(t, err)

		final := waitAnalysisDone(t, svc, resp.Result.Id)
		assert.Equal(t, "failed", final.Status)
		require.NotNil(t, final.ErrorMessage)
		assert.NotEmpty(t, *final.ErrorMessage)
	})

	t.Run("should still reject invalid request synchronously", func(t *testing.T) {
		engine := fakeEngine{run: func(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) *highschoolv1.SimulationResults {
			return &highschoolv1.SimulationResults{}
		}}
		svc := newAsyncTestService(engine)

		req := validAsyncTestRequest()
		req.Scores.Total = 700 // 与各科之和 660 不符
		_, err := svc.SubmitAnalysis(context.Background(), req)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "不符")
	})
}
