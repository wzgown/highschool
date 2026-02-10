// api/v1/reference_connect.go - API 层（只处理协议转换）
package v1

import (
	"context"
	"fmt"
	"net/http"

	"connectrpc.com/connect"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/gen/highschool/v1/highschoolv1connect"
	"highschool-backend/internal/service"
	"highschool-backend/pkg/logger"
)

// ReferenceServiceHandler 参考数据服务处理器
type ReferenceServiceHandler struct {
	highschoolv1connect.UnimplementedReferenceServiceHandler
	service service.ReferenceService
}

// NewReferenceServiceHandler 创建参考数据服务处理器
func NewReferenceServiceHandler() *ReferenceServiceHandler {
	return &ReferenceServiceHandler{
		service: service.NewReferenceService(),
	}
}

// GetDistricts 获取区县列表
func (h *ReferenceServiceHandler) GetDistricts(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetDistrictsRequest],
) (*connect.Response[highschoolv1.GetDistrictsResponse], error) {
	districts, err := h.service.GetDistricts(ctx)
	if err != nil {
		logger.Error("get districts failed", err)
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("获取区县列表失败"))
	}

	return connect.NewResponse(&highschoolv1.GetDistrictsResponse{
		Districts: districts,
	}), nil
}

// GetSchools 获取学校列表
func (h *ReferenceServiceHandler) GetSchools(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetSchoolsRequest],
) (*connect.Response[highschoolv1.GetSchoolsResponse], error) {
	schools, total, err := h.service.GetSchools(ctx, req.Msg)
	if err != nil {
		logger.Error("get schools failed", err)
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("获取学校列表失败"))
	}

	page := req.Msg.Page
	if page < 1 {
		page = 1
	}
	pageSize := req.Msg.PageSize
	if pageSize < 1 {
		pageSize = 20
	}

	return connect.NewResponse(&highschoolv1.GetSchoolsResponse{
		Schools: schools,
		Meta: &highschoolv1.PaginationMeta{
			Total:     total,
			Page:      page,
			PageSize:  pageSize,
			TotalPage: (total + pageSize - 1) / pageSize,
			HasNext:   page*pageSize < total,
			HasPrev:   page > 1,
		},
	}), nil
}

// GetSchoolDetail 获取学校详情
func (h *ReferenceServiceHandler) GetSchoolDetail(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetSchoolDetailRequest],
) (*connect.Response[highschoolv1.GetSchoolDetailResponse], error) {
	detail, err := h.service.GetSchoolDetail(ctx, req.Msg.Id)
	if err != nil {
		logger.Error("get school detail failed", err)
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("学校不存在"))
	}

	return connect.NewResponse(&highschoolv1.GetSchoolDetailResponse{
		School: detail,
	}), nil
}

// GetMiddleSchools 获取初中学校列表
func (h *ReferenceServiceHandler) GetMiddleSchools(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetMiddleSchoolsRequest],
) (*connect.Response[highschoolv1.GetMiddleSchoolsResponse], error) {
	// TODO: 实现初中学校查询
	return connect.NewResponse(&highschoolv1.GetMiddleSchoolsResponse{
		MiddleSchools: []*highschoolv1.MiddleSchool{},
	}), nil
}

// GetHistoryScores 获取历年分数线
func (h *ReferenceServiceHandler) GetHistoryScores(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetHistoryScoresRequest],
) (*connect.Response[highschoolv1.GetHistoryScoresResponse], error) {
	if req.Msg.SchoolId == nil {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("school_id is required"))
	}
	scores, err := h.service.GetHistoryScores(ctx, *req.Msg.SchoolId)
	if err != nil {
		logger.Error("get history scores failed", err)
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("获取历史分数线失败"))
	}

	return connect.NewResponse(&highschoolv1.GetHistoryScoresResponse{
		Scores: scores,
	}), nil
}

// GetDistrictExamCount 获取区县中考人数
func (h *ReferenceServiceHandler) GetDistrictExamCount(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetDistrictExamCountRequest],
) (*connect.Response[highschoolv1.GetDistrictExamCountResponse], error) {
	// 返回所有区县的考试人数
	// TODO: 实现批量查询
	return connect.NewResponse(&highschoolv1.GetDistrictExamCountResponse{
		Year:      req.Msg.Year,
		Districts: []*highschoolv1.DistrictExamCountItem{},
	}), nil
}

// RegisterReferenceService 注册参考数据服务
func RegisterReferenceService(mux *http.ServeMux) {
	handler := NewReferenceServiceHandler()
	path, svc := highschoolv1connect.NewReferenceServiceHandler(handler)
	mux.Handle(path, svc)
}
