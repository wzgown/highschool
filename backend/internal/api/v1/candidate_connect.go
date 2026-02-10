// api/v1/candidate_connect.go - API 层（只处理协议转换）
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

// CandidateServiceHandler 考生服务处理器
type CandidateServiceHandler struct {
	highschoolv1connect.UnimplementedCandidateServiceHandler
	service service.CandidateService
}

// NewCandidateServiceHandler 创建考生服务处理器
func NewCandidateServiceHandler() *CandidateServiceHandler {
	return &CandidateServiceHandler{
		service: service.NewCandidateService(),
	}
}

// SubmitAnalysis 提交模拟分析
func (h *CandidateServiceHandler) SubmitAnalysis(
	ctx context.Context,
	req *connect.Request[highschoolv1.SubmitAnalysisRequest],
) (*connect.Response[highschoolv1.SubmitAnalysisResponse], error) {
	// 调用服务层
	resp, err := h.service.SubmitAnalysis(ctx, req.Msg)
	if err != nil {
		logger.Error("submit analysis failed", err)
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("提交分析失败: %w", err))
	}

	return connect.NewResponse(resp), nil
}

// GetAnalysisResult 获取分析结果
func (h *CandidateServiceHandler) GetAnalysisResult(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetAnalysisResultRequest],
) (*connect.Response[highschoolv1.GetAnalysisResultResponse], error) {
	result, err := h.service.GetAnalysisResult(ctx, req.Msg.Id)
	if err != nil {
		logger.Error("get analysis result failed", err)
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("未找到分析结果"))
	}

	return connect.NewResponse(&highschoolv1.GetAnalysisResultResponse{
		Result: result,
	}), nil
}

// GetHistory 获取历史记录
func (h *CandidateServiceHandler) GetHistory(
	ctx context.Context,
	req *connect.Request[highschoolv1.GetHistoryRequest],
) (*connect.Response[highschoolv1.GetHistoryResponse], error) {
	page := req.Msg.Page
	if page < 1 {
		page = 1
	}
	pageSize := req.Msg.PageSize
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	// TODO: 从请求中获取 deviceID
	deviceID := ""

	resp, err := h.service.GetHistory(ctx, deviceID, page, pageSize)
	if err != nil {
		logger.Error("get history failed", err)
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("获取历史记录失败"))
	}

	return connect.NewResponse(resp), nil
}

// DeleteHistory 删除历史记录
func (h *CandidateServiceHandler) DeleteHistory(
	ctx context.Context,
	req *connect.Request[highschoolv1.DeleteHistoryRequest],
) (*connect.Response[highschoolv1.DeleteHistoryResponse], error) {
	id := req.Msg.Id

	// TODO: 从请求中获取 deviceID
	deviceID := ""

	err := h.service.DeleteHistory(ctx, id, deviceID)
	if err != nil {
		logger.Error("delete history failed", err)
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("删除历史记录失败"))
	}

	return connect.NewResponse(&highschoolv1.DeleteHistoryResponse{
		Success: true,
	}), nil
}

// RegisterCandidateService 注册考生服务
func RegisterCandidateService(mux *http.ServeMux) {
	handler := NewCandidateServiceHandler()
	path, svc := highschoolv1connect.NewCandidateServiceHandler(handler)
	mux.Handle(path, svc)
}
