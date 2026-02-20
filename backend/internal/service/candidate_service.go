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
	simRepo          repository.SimulationHistoryRepository
	schoolRepo       repository.SchoolRepository
	middleSchoolRepo repository.MiddleSchoolRepository
	districtRepo     repository.DistrictRepository
	simEngine        *simulation.Engine
}

// NewCandidateService 创建考生服务
func NewCandidateService() CandidateService {
	quotaRepo := repository.NewQuotaRepository()
	return &candidateService{
		simRepo:          repository.NewSimulationHistoryRepository(),
		schoolRepo:       repository.NewSchoolRepository(),
		middleSchoolRepo: repository.NewMiddleSchoolRepository(),
		districtRepo:     repository.NewDistrictRepository(),
		simEngine:        simulation.NewEngine(simulation.WithQuotaRepo(quotaRepo)),
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

	// 1. 完整参数校验
	logger.Debug(ctx, "step 1: validating request")
	if err := s.validateRequest(ctx, req); err != nil {
		logger.Error(ctx, "request validation failed", err)
		return nil, err
	}
	logger.Debug(ctx, "request validation passed")

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

	// 校验总分范围
	if scores.Total < 0 || scores.Total > maxTotal {
		return fmt.Errorf("总分(%.1f)必须在 0-%.0f 之间", scores.Total, maxTotal)
	}

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

// validateVolunteers 校验志愿学校是否在允许填报范围内
func (s *candidateService) validateVolunteers(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) error {
	districtID := req.Candidate.DistrictId
	middleSchoolID := req.Candidate.MiddleSchoolId

	// 1. 校验名额分配到区志愿
	if req.Volunteers.QuotaDistrict != nil {
		allowedSchools, err := s.schoolRepo.GetSchoolsWithQuotaDistrict(ctx, districtID)
		if err != nil {
			logger.Warn(ctx, "failed to get quota district schools for validation", logger.ErrorField(err))
		} else {
			allowedIDs := make(map[int32]bool)
			for _, school := range allowedSchools {
				allowedIDs[school.Id] = true
			}
			if !allowedIDs[*req.Volunteers.QuotaDistrict] {
				return fmt.Errorf("名额分配到区志愿学校(ID:%d)不在可填报范围内", *req.Volunteers.QuotaDistrict)
			}
		}
	}

	// 2. 校验名额分配到校志愿
	if len(req.Volunteers.QuotaSchool) > 0 {
		allowedSchools, err := s.schoolRepo.GetSchoolsWithQuotaSchool(ctx, middleSchoolID)
		if err != nil {
			logger.Warn(ctx, "failed to get quota school schools for validation", logger.ErrorField(err))
		} else {
			allowedIDs := make(map[int32]bool)
			for _, school := range allowedSchools {
				allowedIDs[school.Id] = true
			}
			for _, schoolID := range req.Volunteers.QuotaSchool {
				if !allowedIDs[schoolID] {
					return fmt.Errorf("名额分配到校志愿学校(ID:%d)不在可填报范围内", schoolID)
				}
			}
		}
	}

	// 3. 校验统一招生志愿
	if len(req.Volunteers.Unified) > 0 {
		allowedSchools, err := s.schoolRepo.GetSchoolsForUnified(ctx, districtID)
		if err != nil {
			logger.Warn(ctx, "failed to get unified schools for validation", logger.ErrorField(err))
		} else {
			allowedIDs := make(map[int32]bool)
			for _, school := range allowedSchools {
				allowedIDs[school.Id] = true
			}
			for _, schoolID := range req.Volunteers.Unified {
				if !allowedIDs[schoolID] {
					return fmt.Errorf("统一招生志愿学校(ID:%d)不在可填报范围内", schoolID)
				}
			}
		}
	}

	return nil
}

// validateRequest 完整参数校验
func (s *candidateService) validateRequest(ctx context.Context, req *highschoolv1.SubmitAnalysisRequest) error {
	// 1. 校验基本信息
	if req.Candidate == nil {
		return fmt.Errorf("缺少考生信息")
	}
	if req.Candidate.DistrictId <= 0 {
		return fmt.Errorf("请选择所属区县")
	}
	if req.Candidate.MiddleSchoolId <= 0 {
		return fmt.Errorf("请选择初中学校")
	}

	// 2. 校验排名
	if req.Ranking.Rank <= 0 {
		return fmt.Errorf("校内排名必须大于0")
	}
	if req.Ranking.TotalStudents <= 0 {
		return fmt.Errorf("校内总人数必须大于0")
	}
	if req.Ranking.Rank > req.Ranking.TotalStudents {
		return fmt.Errorf("校内排名(%d)不能大于总人数(%d)", req.Ranking.Rank, req.Ranking.TotalStudents)
	}

	// 3. 校验成绩
	if err := s.validateScores(req.Scores); err != nil {
		return err
	}

	// 4. 校验志愿 - 至少填报一个志愿
	hasVolunteers := req.Volunteers.QuotaDistrict != nil ||
		len(req.Volunteers.QuotaSchool) > 0 ||
		len(req.Volunteers.Unified) > 0
	if !hasVolunteers {
		return fmt.Errorf("请至少填报一个志愿")
	}

	// 5. 校验志愿数量限制
	if len(req.Volunteers.QuotaSchool) > 2 {
		return fmt.Errorf("名额分配到校志愿最多2个")
	}
	if len(req.Volunteers.Unified) > 15 {
		return fmt.Errorf("统一招生志愿最多15个")
	}

	// 6. 校验志愿学校是否在允许填报范围内
	if err := s.validateVolunteers(ctx, req); err != nil {
		return err
	}

	// 7. 校验学校总人数（与数据库对比）
	dbStudentCount, err := s.middleSchoolRepo.GetStudentCount(ctx, req.Candidate.MiddleSchoolId)
	if err == nil && dbStudentCount > 0 {
		submittedCount := req.Ranking.TotalStudents
		// 计算差异比例
		var diffRatio float64
		if submittedCount > dbStudentCount {
			diffRatio = float64(submittedCount-dbStudentCount) / float64(dbStudentCount)
		} else {
			diffRatio = float64(dbStudentCount-submittedCount) / float64(dbStudentCount)
		}

		// 差异超过20%时打印warn日志
		if diffRatio > 0.2 {
			logger.Warn(ctx, "submitted total_students differs significantly from database",
				logger.Int("submitted_count", int(submittedCount)),
				logger.Int("db_count", int(dbStudentCount)),
				logger.Float64("diff_ratio", diffRatio),
				logger.Int("middle_school_id", int(req.Candidate.MiddleSchoolId)),
			)
		}
	}

	return nil
}
