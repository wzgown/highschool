// api/v1/candidate_connect_test.go - Candidate API 测试 (TDD)
package v1

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/stretchr/testify/assert"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/gen/highschool/v1/highschoolv1connect"
)

// MockCandidateService Mock 实现
type MockCandidateService struct{}

func (m *MockCandidateService) SubmitAnalysis(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) (*highschoolv1.SubmitAnalysisResponse, error) {
	if req.Scores.Total != req.Scores.Chinese+req.Scores.Math+req.Scores.Foreign+
		req.Scores.Integrated+req.Scores.Ethics+req.Scores.History+req.Scores.Pe {
		return nil, assert.AnError
	}
	return &highschoolv1.SubmitAnalysisResponse{
		Result: &highschoolv1.AnalysisResult{
			Id:     "test-id-123",
			Status: "completed",
		},
	}, nil
}

func (m *MockCandidateService) GetAnalysisResult(ctx context.Context, id string) (*highschoolv1.AnalysisResult, error) {
	if id == "not-found" {
		return nil, assert.AnError
	}
	return &highschoolv1.AnalysisResult{
		Id:     id,
		Status: "completed",
	}, nil
}

func (m *MockCandidateService) GetHistory(ctx context.Context, deviceID string, page, pageSize int32) (*highschoolv1.GetHistoryResponse, error) {
	return &highschoolv1.GetHistoryResponse{
		Histories: []*highschoolv1.HistorySummary{},
		Meta:      &highschoolv1.PaginationMeta{},
	}, nil
}

func (m *MockCandidateService) DeleteHistory(ctx context.Context, id, deviceID string) error {
	return nil
}

// 验证 handler 实现了接口
func TestCandidateServiceHandler_Interface(t *testing.T) {
	var _ highschoolv1connect.CandidateServiceHandler = (*CandidateServiceHandler)(nil)
}

func TestCandidateServiceHandler_SubmitAnalysis(t *testing.T) {
	t.Run("should return error when scores don't match", func(t *testing.T) {
		// Arrange
		handler := &CandidateServiceHandler{
			service: &MockCandidateService{},
		}
		req := connect.NewRequest(&highschoolv1.SubmitAnalysisRequest{
			Scores: &highschoolv1.CandidateScores{
				Total: 700,
				Chinese: 100, Math: 100, Foreign: 100,
				Integrated: 100, Ethics: 10, History: 10, Pe: 10, // 总和 = 430
			},
		})

		// Act
		_, err := handler.SubmitAnalysis(context.Background(), req)

		// Assert
		assert.Error(t, err)
	})

	t.Run("should return success when scores match", func(t *testing.T) {
		// Arrange
		handler := &CandidateServiceHandler{
			service: &MockCandidateService{},
		}
		req := connect.NewRequest(&highschoolv1.SubmitAnalysisRequest{
			Scores: &highschoolv1.CandidateScores{
				Total: 750,
				Chinese: 150, Math: 150, Foreign: 150,
				Integrated: 150, Ethics: 30, History: 30, Pe: 90,
			},
		})

		// Act
		resp, err := handler.SubmitAnalysis(context.Background(), req)

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, resp)
		assert.Equal(t, "test-id-123", resp.Msg.Result.Id)
	})
}

func TestCandidateServiceHandler_GetAnalysisResult(t *testing.T) {
	t.Run("should return result when exists", func(t *testing.T) {
		// Arrange
		handler := &CandidateServiceHandler{
			service: &MockCandidateService{},
		}
		req := connect.NewRequest(&highschoolv1.GetAnalysisResultRequest{
			Id: "test-id",
		})

		// Act
		resp, err := handler.GetAnalysisResult(context.Background(), req)

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, resp)
		assert.Equal(t, "test-id", resp.Msg.Result.Id)
	})

	t.Run("should return error when not found", func(t *testing.T) {
		// Arrange
		handler := &CandidateServiceHandler{
			service: &MockCandidateService{},
		}
		req := connect.NewRequest(&highschoolv1.GetAnalysisResultRequest{
			Id: "not-found",
		})

		// Act
		_, err := handler.GetAnalysisResult(context.Background(), req)

		// Assert
		assert.Error(t, err)
	})
}

func TestCandidateServiceHandler_GetHistory(t *testing.T) {
	t.Run("should return history list", func(t *testing.T) {
		// Arrange
		handler := &CandidateServiceHandler{
			service: &MockCandidateService{},
		}
		req := connect.NewRequest(&highschoolv1.GetHistoryRequest{
			Page:     1,
			PageSize: 10,
		})

		// Act
		resp, err := handler.GetHistory(context.Background(), req)

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, resp)
		assert.NotNil(t, resp.Msg.Histories)
	})
}

func TestCandidateServiceHandler_DeleteHistory(t *testing.T) {
	t.Run("should delete history successfully", func(t *testing.T) {
		// Arrange
		handler := &CandidateServiceHandler{
			service: &MockCandidateService{},
		}
		id := "test-id"
		req := connect.NewRequest(&highschoolv1.DeleteHistoryRequest{
			Id: id,
		})

		// Act
		resp, err := handler.DeleteHistory(context.Background(), req)

		// Assert
		assert.NoError(t, err)
		assert.NotNil(t, resp)
		assert.True(t, resp.Msg.Success)
	})
}
