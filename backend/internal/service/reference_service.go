// service/reference_service.go - 参考数据业务逻辑层
package service

import (
	"context"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
)

// ReferenceService 参考数据服务接口
type ReferenceService interface {
	// GetDistricts 获取区县列表
	GetDistricts(ctx context.Context) ([]*highschoolv1.District, error)

	// GetSchools 获取学校列表
	GetSchools(ctx context.Context, req *highschoolv1.GetSchoolsRequest) ([]*highschoolv1.School, int32, error)

	// GetSchoolDetail 获取学校详情
	GetSchoolDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error)

	// GetHistoryScores 获取历年分数线
	GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error)

	// GetDistrictExamCount 获取区县中考人数
	GetDistrictExamCount(ctx context.Context, districtID int32, year int32) (*highschoolv1.DistrictExamCountItem, error)

	// GetMiddleSchools 获取初中学校列表
	GetMiddleSchools(ctx context.Context, districtID *int32, keyword *string) ([]*highschoolv1.MiddleSchool, error)

	// GetSchoolsWithQuotaDistrict 获取有名额分配到区的高中列表
	GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表
	GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsForUnified 获取统一招生（1-15志愿）可选学校列表
	GetSchoolsForUnified(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolForUnified, error)

	// GetLatestScoreYear 获取数据库中最新的分数线数据年份
	GetLatestScoreYear(ctx context.Context) (int32, error)
}

// referenceService 实现
type referenceService struct {
	districtRepo      repository.DistrictRepository
	schoolRepo        repository.SchoolRepository
	middleSchoolRepo  repository.MiddleSchoolRepository
}

// NewReferenceService 创建参考数据服务
func NewReferenceService() ReferenceService {
	return &referenceService{
		districtRepo:     repository.NewDistrictRepository(),
		schoolRepo:       repository.NewSchoolRepository(),
		middleSchoolRepo: repository.NewMiddleSchoolRepository(),
	}
}

// GetDistricts 获取区县列表
func (s *referenceService) GetDistricts(ctx context.Context) ([]*highschoolv1.District, error) {
	return s.districtRepo.ListAll(ctx)
}

// GetSchools 获取学校列表
func (s *referenceService) GetSchools(ctx context.Context, req *highschoolv1.GetSchoolsRequest) ([]*highschoolv1.School, int32, error) {
	page := req.Page
	if page < 1 {
		page = 1
	}
	pageSize := req.PageSize
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	return s.schoolRepo.List(ctx, req.DistrictId, req.SchoolTypeId, req.SchoolNatureId,
		req.HasInternationalCourse, req.Keyword, page, pageSize)
}

// GetSchoolDetail 获取学校详情
func (s *referenceService) GetSchoolDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error) {
	return s.schoolRepo.GetDetail(ctx, id)
}

// GetHistoryScores 获取历年分数线
func (s *referenceService) GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error) {
	return s.schoolRepo.GetHistoryScores(ctx, schoolID)
}

// GetDistrictExamCount 获取区县中考人数
func (s *referenceService) GetDistrictExamCount(ctx context.Context, districtID int32, year int32) (*highschoolv1.DistrictExamCountItem, error) {
	return s.districtRepo.GetExamCount(ctx, districtID, year)
}

// GetMiddleSchools 获取初中学校列表
func (s *referenceService) GetMiddleSchools(ctx context.Context, districtID *int32, keyword *string) ([]*highschoolv1.MiddleSchool, error) {
	return s.middleSchoolRepo.List(ctx, districtID, keyword)
}

// GetSchoolsWithQuotaDistrict 获取有名额分配到区的高中列表
func (s *referenceService) GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolWithQuota, error) {
	return s.schoolRepo.GetSchoolsWithQuotaDistrict(ctx, districtID)
}

// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表
func (s *referenceService) GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32) ([]*highschoolv1.SchoolWithQuota, error) {
	return s.schoolRepo.GetSchoolsWithQuotaSchool(ctx, middleSchoolID)
}

// GetSchoolsForUnified 获取统一招生（1-15志愿）可选学校列表
func (s *referenceService) GetSchoolsForUnified(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolForUnified, error) {
	return s.schoolRepo.GetSchoolsForUnified(ctx, districtID)
}

// GetLatestScoreYear 获取数据库中最新的分数线数据年份
func (s *referenceService) GetLatestScoreYear(ctx context.Context) (int32, error) {
	year, err := s.schoolRepo.GetLatestScoreYear(ctx)
	if err != nil {
		return 2024, err
	}
	return int32(year), nil
}
