// repository/simulation_history_test.go - Simulation History Repository 测试 (TDD)
package repository

import (
	"context"
	"fmt"
	"strconv"
	"testing"
	"time"

	highschoolv1 "highschool-backend/gen/highschool/v1"
)

// MockSimulationHistoryRepo 用于测试的 mock 实现
type MockSimulationHistoryRepo struct {
	data    map[int64]*SimulationHistoryRecord
	counter int64
}

func NewMockSimulationHistoryRepo() *MockSimulationHistoryRepo {
	return &MockSimulationHistoryRepo{
		data: make(map[int64]*SimulationHistoryRecord),
	}
}

func (m *MockSimulationHistoryRepo) Save(ctx context.Context, deviceID string, deviceInfo map[string]interface{},
	candidateData *highschoolv1.SubmitAnalysisRequest,
	result *highschoolv1.SimulationResults) (string, error) {

	m.counter++
	m.data[m.counter] = &SimulationHistoryRecord{
		ID:               m.counter,
		DeviceID:         deviceID,
		DeviceInfo:       deviceInfo,
		CandidateData:    candidateData,
		SimulationResult: result,
		CreatedAt:        time.Now(),
	}
	return fmt.Sprintf("%d", m.counter), nil
}

func (m *MockSimulationHistoryRepo) GetByID(ctx context.Context, id string) (*SimulationHistoryRecord, error) {
	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		return nil, err
	}
	record, ok := m.data[idInt]
	if !ok {
		return nil, context.DeadlineExceeded // 简化错误处理
	}
	return record, nil
}

func (m *MockSimulationHistoryRepo) ListByDevice(ctx context.Context, deviceID string, page, pageSize int32) ([]*SimulationHistoryRecord, int32, error) {
	var records []*SimulationHistoryRecord
	for _, r := range m.data {
		if r.DeviceID == deviceID {
			records = append(records, r)
		}
	}
	return records, int32(len(records)), nil
}

func (m *MockSimulationHistoryRepo) DeleteByID(ctx context.Context, id string) error {
	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		return err
	}
	delete(m.data, idInt)
	return nil
}

func (m *MockSimulationHistoryRepo) DeleteByDevice(ctx context.Context, deviceID string) error {
	for id, r := range m.data {
		if r.DeviceID == deviceID {
			delete(m.data, id)
		}
	}
	return nil
}

// 验证 Mock 实现了接口
var _ SimulationHistoryRepository = (*MockSimulationHistoryRepo)(nil)

func TestSimulationHistoryRepository_Save(t *testing.T) {
	t.Run("should save simulation history and return ID", func(t *testing.T) {
		// Arrange
		repo := NewMockSimulationHistoryRepo()
		ctx := context.Background()
		
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{
				DistrictId: 1,
			},
			Scores: &highschoolv1.CandidateScores{
				Total:    700,
				Chinese:  140,
				Math:     150,
				Foreign:  140,
				Integrated: 140,
				Ethics:   30,
				History:  30,
				Pe:       70,
			},
		}
		results := &highschoolv1.SimulationResults{
			Probabilities: []*highschoolv1.VolunteerProbability{
				{Probability: 80.0, RiskLevel: "safe"},
			},
		}

		// Act
		id, err := repo.Save(ctx, "test-device-123", nil, req, results)

		// Assert
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if id == "" {
			t.Error("Expected non-empty ID")
		}
	})
}

func TestSimulationHistoryRepository_GetByID(t *testing.T) {
	t.Run("should return record when exists", func(t *testing.T) {
		// Arrange
		repo := NewMockSimulationHistoryRepo()
		ctx := context.Background()
		
		req := &highschoolv1.SubmitAnalysisRequest{
			Candidate: &highschoolv1.CandidateInfo{DistrictId: 1},
		}
		results := &highschoolv1.SimulationResults{}
		id, _ := repo.Save(ctx, "test-device", nil, req, results)

		// Act
		record, err := repo.GetByID(ctx, id)

		// Assert
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if fmt.Sprintf("%d", record.ID) != id {
			t.Errorf("Expected ID %s, got %d", id, record.ID)
		}
	})

	t.Run("should return error when not exists", func(t *testing.T) {
		// Arrange
		repo := NewMockSimulationHistoryRepo()
		ctx := context.Background()

		// Act
		_, err := repo.GetByID(ctx, "non-existent-id")

		// Assert
		if err == nil {
			t.Error("Expected error for non-existent record")
		}
	})
}

func TestSimulationHistoryRepository_ListByDevice(t *testing.T) {
	t.Run("should return records for specific device", func(t *testing.T) {
		// Arrange
		repo := NewMockSimulationHistoryRepo()
		ctx := context.Background()
		
		// 为 device-1 创建 3 条记录
		for i := 0; i < 3; i++ {
			repo.Save(ctx, "device-1", nil, &highschoolv1.SubmitAnalysisRequest{}, &highschoolv1.SimulationResults{})
		}
		// 为 device-2 创建 2 条记录
		for i := 0; i < 2; i++ {
			repo.Save(ctx, "device-2", nil, &highschoolv1.SubmitAnalysisRequest{}, &highschoolv1.SimulationResults{})
		}

		// Act
		records, total, err := repo.ListByDevice(ctx, "device-1", 1, 10)

		// Assert
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if total != 3 {
			t.Errorf("Expected total 3, got %d", total)
		}
		if len(records) != 3 {
			t.Errorf("Expected 3 records, got %d", len(records))
		}
	})

	t.Run("should return empty list for unknown device", func(t *testing.T) {
		// Arrange
		repo := NewMockSimulationHistoryRepo()
		ctx := context.Background()

		// Act
		records, total, err := repo.ListByDevice(ctx, "unknown-device", 1, 10)

		// Assert
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		if total != 0 {
			t.Errorf("Expected total 0, got %d", total)
		}
		if len(records) != 0 {
			t.Errorf("Expected 0 records, got %d", len(records))
		}
	})
}

func TestSimulationHistoryRepository_DeleteByID(t *testing.T) {
	t.Run("should delete existing record", func(t *testing.T) {
		// Arrange
		repo := NewMockSimulationHistoryRepo()
		ctx := context.Background()
		
		id, _ := repo.Save(ctx, "test-device", nil, &highschoolv1.SubmitAnalysisRequest{}, &highschoolv1.SimulationResults{})

		// Act
		err := repo.DeleteByID(ctx, id)

		// Assert
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		_, err = repo.GetByID(ctx, id)
		if err == nil {
			t.Error("Record should be deleted")
		}
	})
}

func TestSimulationHistoryRepository_DeleteByDevice(t *testing.T) {
	t.Run("should delete all records for device", func(t *testing.T) {
		// Arrange
		repo := NewMockSimulationHistoryRepo()
		ctx := context.Background()
		
		repo.Save(ctx, "device-1", nil, &highschoolv1.SubmitAnalysisRequest{}, &highschoolv1.SimulationResults{})
		repo.Save(ctx, "device-1", nil, &highschoolv1.SubmitAnalysisRequest{}, &highschoolv1.SimulationResults{})
		repo.Save(ctx, "device-2", nil, &highschoolv1.SubmitAnalysisRequest{}, &highschoolv1.SimulationResults{})

		// Act
		err := repo.DeleteByDevice(ctx, "device-1")

		// Assert
		if err != nil {
			t.Errorf("Expected no error, got %v", err)
		}
		
		records1, _, _ := repo.ListByDevice(ctx, "device-1", 1, 10)
		records2, _, _ := repo.ListByDevice(ctx, "device-2", 1, 10)
		
		if len(records1) != 0 {
			t.Errorf("Expected 0 records for device-1, got %d", len(records1))
		}
		if len(records2) != 1 {
			t.Errorf("Expected 1 record for device-2, got %d", len(records2))
		}
	})
}
