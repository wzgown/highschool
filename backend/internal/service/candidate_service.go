// service/candidate_service.go - 考生业务逻辑层
package service

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/google/uuid"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/domain/simulation"
	"highschool-backend/internal/repository"
	"highschool-backend/pkg/logger"
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
	quotaRepo := repository.NewQuotaRepository()
	return &candidateService{
		simRepo:    repository.NewSimulationHistoryRepository(),
		schoolRepo: repository.NewSchoolRepository(),
		simEngine:  simulation.NewEngine(simulation.WithQuotaRepo(quotaRepo)),
	}
}

// SubmitAnalysis 提交模拟分析
func (s *candidateService) SubmitAnalysis(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) (*highschoolv1.SubmitAnalysisResponse, error) {
	startTime := time.Now()
	logger.Info(ctx, "SubmitAnalysis started",
		logger.Int("district_id", int(req.Candidate.DistrictId)),
		logger.Int("middle_school_id", int(req.Candidate.MiddleSchoolId)),
		logger.Int("total_score", int(req.Scores.Total)),
	)

	// 1. 验证成绩
	logger.Debug(ctx, "step 1: validating scores")
	if err := s.validateScores(req.Scores); err != nil {
		logger.Error(ctx, "score validation failed", err,
			logger.Int("total", int(req.Scores.Total)),
		)
		return nil, err
	}
	logger.Debug(ctx, "score validation passed",
		logger.Int("total", int(req.Scores.Total)),
	)

	// 2. 处理设备ID
	var deviceID string
	if req.DeviceId != nil {
		deviceID = *req.DeviceId
		logger.Debug(ctx, "using existing device_id", logger.String("device_id", deviceID))
	} else {
		deviceID = uuid.New().String()
		logger.Debug(ctx, "generated new device_id", logger.String("device_id", deviceID))
	}

	// 3. 执行模拟分析
	logger.Info(ctx, "step 2: running simulation engine",
		logger.Int("ranking", int(req.Ranking.Rank)),
		logger.Int("total_students", int(req.Ranking.TotalStudents)),
		logger.Bool("has_quota_district", req.Volunteers.QuotaDistrict != nil),
		logger.Int("quota_school_count", len(req.Volunteers.QuotaSchool)),
		logger.Int("unified_count", len(req.Volunteers.Unified)),
	)

	simStart := time.Now()
	results := s.simEngine.Run(ctx, req)
	logger.Info(ctx, "simulation engine completed",
		logger.String("duration", time.Since(simStart).String()),
		logger.Int("probabilities_count", len(results.Probabilities)),
	)

	// 4. 保存到数据库
	logger.Debug(ctx, "step 3: saving to database")
	saveStart := time.Now()
	deviceInfo := map[string]interface{}{} // 简化版
	analysisID, err := s.simRepo.Save(ctx, deviceID, deviceInfo, req, results)
	if err != nil {
		logger.Error(ctx, "save analysis failed", err)
		return nil, fmt.Errorf("save analysis failed: %w", err)
	}
	logger.Info(ctx, "analysis saved to database",
		logger.String("analysis_id", analysisID),
		logger.String("duration", time.Since(saveStart).String()),
	)

	// 5. 组装响应
	createdAt := time.Now().Format(time.RFC3339)
	response := &highschoolv1.SubmitAnalysisResponse{
		Result: &highschoolv1.AnalysisResult{
			Id:          analysisID,
			Status:      "completed",
			Results:     results,
			CreatedAt:   createdAt,
			CompletedAt: &createdAt,
		},
	}

	logger.Info(ctx, "SubmitAnalysis completed",
		logger.String("analysis_id", analysisID),
		logger.String("total_duration", time.Since(startTime).String()),
		logger.String("prediction_confidence", results.Predictions.Confidence),
		logger.Float64("percentile", results.Predictions.Percentile),
	)

	return response, nil
}

// GetAnalysisResult 获取分析结果
func (s *candidateService) GetAnalysisResult(ctx context.Context, id string) (*highschoolv1.AnalysisResult, error) {
	record, err := s.simRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	createdAt := record.CreatedAt.Format(time.RFC3339)
	return &highschoolv1.AnalysisResult{
		Id:        strconv.FormatInt(record.ID, 10),
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
			Id:        strconv.FormatInt(record.ID, 10),
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
// 规则：
// 1. 单科不能超过满分
// 2. 已填科目之和不能超过总分
// 3. 只有当所有科目都填了（>0）时，才要求总和等于总分
func (s *candidateService) validateScores(scores *highschoolv1.CandidateScores) error {
	// 各科满分
	const (
		maxChinese    = 150.0
		maxMath       = 150.0
		maxForeign    = 150.0
		maxIntegrated = 150.0
		maxEthics     = 60.0
		maxHistory    = 60.0
		maxPE         = 30.0
		maxTotal      = 750.0
	)

	// 校验单科不超过满分
	if scores.Chinese > maxChinese {
		return fmt.Errorf("语文成绩(%.1f)不能超过满分(%.0f)", scores.Chinese, maxChinese)
	}
	if scores.Math > maxMath {
		return fmt.Errorf("数学成绩(%.1f)不能超过满分(%.0f)", scores.Math, maxMath)
	}
	if scores.Foreign > maxForeign {
		return fmt.Errorf("外语成绩(%.1f)不能超过满分(%.0f)", scores.Foreign, maxForeign)
	}
	if scores.Integrated > maxIntegrated {
		return fmt.Errorf("综合测试成绩(%.1f)不能超过满分(%.0f)", scores.Integrated, maxIntegrated)
	}
	if scores.Ethics > maxEthics {
		return fmt.Errorf("道德与法治成绩(%.1f)不能超过满分(%.0f)", scores.Ethics, maxEthics)
	}
	if scores.History > maxHistory {
		return fmt.Errorf("历史成绩(%.1f)不能超过满分(%.0f)", scores.History, maxHistory)
	}
	if scores.Pe > maxPE {
		return fmt.Errorf("体育成绩(%.1f)不能超过满分(%.0f)", scores.Pe, maxPE)
	}

	// 校验总分不超过满分
	if scores.Total > maxTotal {
		return fmt.Errorf("总分(%.1f)不能超过满分(%.0f)", scores.Total, maxTotal)
	}

	// 计算已填科目之和（>0 的科目）
	calculatedTotal := scores.Chinese + scores.Math + scores.Foreign +
		scores.Integrated + scores.Ethics + scores.History + scores.Pe

	// 已填科目之和不能超过总分
	if calculatedTotal > scores.Total {
		return fmt.Errorf("各科成绩之和(%.1f)不能超过总分(%.1f)", calculatedTotal, scores.Total)
	}

	// 判断是否所有科目都填了（>0）
	allSubjectsFilled := scores.Chinese > 0 && scores.Math > 0 && scores.Foreign > 0 &&
		scores.Integrated > 0 && scores.Ethics > 0 && scores.History > 0 && scores.Pe > 0

	// 只有当所有科目都填了，才要求总和等于总分
	if allSubjectsFilled && calculatedTotal != scores.Total {
		return fmt.Errorf("各科成绩之和(%.1f)与总分(%.1f)不符", calculatedTotal, scores.Total)
	}

	return nil
}
