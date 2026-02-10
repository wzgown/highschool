// service/candidate_service.go - 考生业务逻辑层
package service

import (
	"context"
	"fmt"
	"time"

	"github.com/google/uuid"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/domain/simulation"
	"highschool-backend/internal/repository"
)

// CandidateService 考生服务接口
type CandidateService interface {
	// SubmitAnalysis 提交模拟分析
	SubmitAnalysis(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) (*highschoolv1.SubmitAnalysisResponse, error)

	// GetAnalysisResult 获取分析结果
	GetAnalysisResult(ctx context.Context, id string) (*highschoolv1.AnalysisResult, error)

	// GetHistory 获取历史记录
	GetHistory(ctx context.Context, deviceID string, page, pageSize int32) (*highschoolv1.GetHistoryResponse, error)

	// DeleteHistory 删除历史记录
	DeleteHistory(ctx context.Context, id, deviceID string) error
}

// candidateService 实现
type candidateService struct {
	simRepo    repository.SimulationHistoryRepository
	schoolRepo repository.SchoolRepository
	simEngine  *simulation.Engine
}

// NewCandidateService 创建考生服务
func NewCandidateService() CandidateService {
	return &candidateService{
		simRepo:    repository.NewSimulationHistoryRepository(),
		schoolRepo: repository.NewSchoolRepository(),
		simEngine:  simulation.NewEngine(),
	}
}

// SubmitAnalysis 提交模拟分析
func (s *candidateService) SubmitAnalysis(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) (*highschoolv1.SubmitAnalysisResponse, error) {
	// 1. 验证成绩
	if err := s.validateScores(req.Scores); err != nil {
		return nil, err
	}

	// 2. 处理设备ID
	var deviceID string
	if req.DeviceId != nil {
		deviceID = *req.DeviceId
	} else {
		deviceID = uuid.New().String()
	}

	// 3. 执行模拟分析
	results := s.simEngine.Run(req)

	// 4. 保存到数据库
	deviceInfo := map[string]interface{}{} // 简化版
	analysisID, err := s.simRepo.Save(ctx, deviceID, deviceInfo, req, results)
	if err != nil {
		return nil, fmt.Errorf("save analysis failed: %w", err)
	}

	// 5. 组装响应
	createdAt := time.Now().Format(time.RFC3339)
	return &highschoolv1.SubmitAnalysisResponse{
		Result: &highschoolv1.AnalysisResult{
			Id:          analysisID,
			Status:      "completed",
			Results:     results,
			CreatedAt:   createdAt,
			CompletedAt: &createdAt,
		},
	}, nil
}

// GetAnalysisResult 获取分析结果
func (s *candidateService) GetAnalysisResult(ctx context.Context, id string) (*highschoolv1.AnalysisResult, error) {
	record, err := s.simRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	createdAt := record.CreatedAt.Format(time.RFC3339)
	return &highschoolv1.AnalysisResult{
		Id:        record.ID,
		Status:    "completed",
		Results:   record.SimulationResult,
		CreatedAt: createdAt,
	}, nil
}

// GetHistory 获取历史记录
func (s *candidateService) GetHistory(ctx context.Context, deviceID string, page, pageSize int32) (*highschoolv1.GetHistoryResponse, error) {
	records, total, err := s.simRepo.ListByDevice(ctx, deviceID, page, pageSize)
	if err != nil {
		return nil, err
	}

	// 转换为 HistorySummary
	histories := make([]*highschoolv1.HistorySummary, len(records))
	for i, record := range records {
		histories[i] = &highschoolv1.HistorySummary{
			Id:        record.ID,
			CreatedAt: record.CreatedAt.Format(time.RFC3339),
			Summary: &highschoolv1.HistorySummary_Summary{
				TotalVolunteers: 18,
				SafeCount:       5,
				ModerateCount:   8,
				RiskyCount:      5,
			},
		}
	}

	return &highschoolv1.GetHistoryResponse{
		Histories: histories,
		Meta: &highschoolv1.PaginationMeta{
			Total:     total,
			Page:      page,
			PageSize:  pageSize,
			TotalPage: (total + pageSize - 1) / pageSize,
			HasNext:   page*pageSize < total,
			HasPrev:   page > 1,
		},
	}, nil
}

// DeleteHistory 删除历史记录
func (s *candidateService) DeleteHistory(ctx context.Context, id, deviceID string) error {
	if id == "" {
		// 删除设备所有记录
		return s.simRepo.DeleteByDevice(ctx, deviceID)
	}
	return s.simRepo.DeleteByID(ctx, id)
}

// validateScores 验证成绩
func (s *candidateService) validateScores(scores *highschoolv1.CandidateScores) error {
	calculatedTotal := scores.Chinese + scores.Math + scores.Foreign +
		scores.Integrated + scores.Ethics + scores.History + scores.Pe
	if calculatedTotal != scores.Total {
		return fmt.Errorf("总分(%d)与各科成绩之和(%d)不符", scores.Total, calculatedTotal)
	}
	return nil
}
