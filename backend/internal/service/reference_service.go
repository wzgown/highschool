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
}

// referenceService 实现
type referenceService struct {
	districtRepo repository.DistrictRepository
	schoolRepo   repository.SchoolRepository
}

// NewReferenceService 创建参考数据服务
func NewReferenceService() ReferenceService {
	return &referenceService{
		districtRepo: repository.NewDistrictRepository(),
		schoolRepo:   repository.NewSchoolRepository(),
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

// GetMiddleSchools 获取初中学校列表 (简化版)
func (s *referenceService) GetMiddleSchools(ctx context.Context, districtID *int32, keyword *string) ([]*highschoolv1.MiddleSchool, error) {
	// 这里可以实现具体的查询逻辑
	// 简化版返回空列表
	return []*highschoolv1.MiddleSchool{}, nil
}


