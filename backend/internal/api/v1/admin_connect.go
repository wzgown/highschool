// admin_connect.go - 管理后台 Admin 服务处理器（协议转换）
package v1

import (
	"context"
	"errors"
	"fmt"
	"net/http"

	"connectrpc.com/connect"
	"connectrpc.com/otelconnect"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	highschoolv1connect "highschool-backend/gen/highschool/v1/highschoolv1connect"
	"highschool-backend/internal/service/admin"
	"highschool-backend/pkg/logger"
)

// CacheInvalidator 配置缓存失效器（settings.Provider 即满足此接口）。
// 抽成窄接口便于 handler 测试：无需引入具体 Provider 依赖即可断言 Invalidate 被调用。
type CacheInvalidator interface {
	Invalidate()
}

// AdminServiceHandler 管理后台处理器
type AdminServiceHandler struct {
	highschoolv1connect.UnimplementedAdminServiceHandler
	store admin.Store
	cache CacheInvalidator
}

// NewAdminServiceHandler 创建管理后台处理器。cache 可为 nil（仅 SetAppConfig 用，nil 时跳过热刷）。
func NewAdminServiceHandler(store admin.Store, cache CacheInvalidator) *AdminServiceHandler {
	return &AdminServiceHandler{store: store, cache: cache}
}

// ListAgentSessions 会话列表
func (h *AdminServiceHandler) ListAgentSessions(ctx context.Context, req *connect.Request[highschoolv1.ListAgentSessionsRequest]) (*connect.Response[highschoolv1.ListAgentSessionsResponse], error) {
	m := req.Msg
	rows, total, err := h.store.ListAgentSessions(ctx, admin.ListFilter{
		TimeFrom: m.TimeFrom, TimeTo: m.TimeTo, DeviceID: m.DeviceId, Intent: m.Intent,
		Page: m.Page, PageSize: m.PageSize,
	})
	if err != nil {
		logger.Error(ctx, "admin list sessions failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	items := make([]*highschoolv1.AgentSessionRow, 0, len(rows))
	for _, r := range rows {
		items = append(items, &highschoolv1.AgentSessionRow{
			SessionId: r.SessionID, DeviceId: r.DeviceID, Status: r.Status, Intent: r.Intent,
			CreatedAt: r.CreatedAt, LastActiveAt: r.LastActiveAt,
			MessageCount: r.MessageCount, TotalTokens: r.TotalTokens,
		})
	}
	return connect.NewResponse(&highschoolv1.ListAgentSessionsResponse{Items: items, Total: total}), nil
}

// GetSessionReplay 单会话回放
func (h *AdminServiceHandler) GetSessionReplay(ctx context.Context, req *connect.Request[highschoolv1.GetSessionReplayRequest]) (*connect.Response[highschoolv1.GetSessionReplayResponse], error) {
	b, err := h.store.GetSessionReplay(ctx, req.Msg.SessionId)
	if err != nil {
		if errors.Is(err, admin.ErrNotFound) {
			return nil, connect.NewError(connect.CodeNotFound, err)
		}
		logger.Error(ctx, "admin get replay failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if b == nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("admin replay: session %d not found", req.Msg.SessionId))
	}
	resp := &highschoolv1.GetSessionReplayResponse{
		Session: &highschoolv1.ReplaySession{
			SessionId: b.Session.SessionID, DeviceId: b.Session.DeviceID,
			Status: b.Session.Status, Intent: b.Session.Intent, CreatedAt: b.Session.CreatedAt,
		},
	}
	for _, m := range b.Messages {
		resp.Messages = append(resp.Messages, &highschoolv1.ReplayMessage{
			Role: m.Role, Content: m.Content, Node: m.Node, CreatedAt: m.CreatedAt, UsageJson: m.UsageJSON,
		})
	}
	for _, tr := range b.Traces {
		resp.Traces = append(resp.Traces, &highschoolv1.ReplayTrace{
			Kind: tr.Kind, Name: tr.Name, InputJson: tr.InputJSON, OutputJson: tr.OutputJSON,
			PromptTokens: tr.PromptTokens, CompletionTokens: tr.CompletionTokens,
			LatencyMs: tr.LatencyMs, CreatedAt: tr.CreatedAt,
		})
	}
	for _, c := range b.Checkpoints {
		resp.Checkpoints = append(resp.Checkpoints, &highschoolv1.ReplayCheckpoint{
			Id: c.ID, StepSeq: c.StepSeq, Node: c.Node, StateJson: c.StateJSON, CreatedAt: c.CreatedAt,
		})
	}
	return connect.NewResponse(resp), nil
}

// GetCostDashboard 成本/用量审计看板（按天，读 012 视图）
func (h *AdminServiceHandler) GetCostDashboard(ctx context.Context, req *connect.Request[highschoolv1.GetCostDashboardRequest]) (*connect.Response[highschoolv1.GetCostDashboardResponse], error) {
	d, err := h.store.GetCostDashboard(ctx, req.Msg.From, req.Msg.To)
	if err != nil {
		logger.Error(ctx, "admin get cost dashboard failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	resp := &highschoolv1.GetCostDashboardResponse{
		LlmDaily:     make([]*highschoolv1.CostLlmDaily, 0, len(d.LlmDaily)),
		ToolDaily:    make([]*highschoolv1.CostToolDaily, 0, len(d.ToolDaily)),
		SessionDaily: make([]*highschoolv1.CostSessionDaily, 0, len(d.SessionDaily)),
	}
	for _, v := range d.LlmDaily {
		resp.LlmDaily = append(resp.LlmDaily, &highschoolv1.CostLlmDaily{
			Day: v.Day, LlmCalls: v.LlmCalls, PromptTokens: v.PromptTokens,
			CompletionTokens: v.CompletionTokens, TotalTokens: v.TotalTokens,
			AvgLatencyMs: v.AvgLatencyMs, P95LatencyMs: v.P95LatencyMs, ErrorCount: v.ErrorCount,
		})
	}
	for _, v := range d.ToolDaily {
		resp.ToolDaily = append(resp.ToolDaily, &highschoolv1.CostToolDaily{
			Day: v.Day, ToolName: v.ToolName, Calls: v.Calls, Failures: v.Failures, AvgLatencyMs: v.AvgLatencyMs,
		})
	}
	for _, v := range d.SessionDaily {
		resp.SessionDaily = append(resp.SessionDaily, &highschoolv1.CostSessionDaily{
			Day: v.Day, ActiveSessions: v.ActiveSessions, Messages: v.Messages,
			UserMessages: v.UserMessages, AssistantMessages: v.AssistantMessages,
		})
	}
	return connect.NewResponse(resp), nil
}

// ListAlerts 告警列表（分页；status 过滤 open|acked|resolved）
func (h *AdminServiceHandler) ListAlerts(ctx context.Context, req *connect.Request[highschoolv1.ListAlertsRequest]) (*connect.Response[highschoolv1.ListAlertsResponse], error) {
	m := req.Msg
	rows, total, err := h.store.ListAlerts(ctx, admin.AlertFilter{
		Status: m.Status, Page: m.Page, PageSize: m.PageSize,
	})
	if err != nil {
		logger.Error(ctx, "admin list alerts failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	items := make([]*highschoolv1.AdminAlert, 0, len(rows))
	for _, r := range rows {
		items = append(items, &highschoolv1.AdminAlert{
			Id: r.ID, CreatedAt: r.CreatedAt, Kind: r.Kind, Severity: r.Severity,
			Title: r.Title, DetailJson: r.DetailJSON, Status: r.Status, AckedAt: r.AckedAt,
		})
	}
	return connect.NewResponse(&highschoolv1.ListAlertsResponse{Items: items, Total: total}), nil
}

// AcknowledgeAlert 确认告警（status→'acked'）。未命中返回 CodeNotFound。
func (h *AdminServiceHandler) AcknowledgeAlert(ctx context.Context, req *connect.Request[highschoolv1.AcknowledgeAlertRequest]) (*connect.Response[highschoolv1.AcknowledgeAlertResponse], error) {
	if err := h.store.AckAlert(ctx, req.Msg.Id); err != nil {
		if errors.Is(err, admin.ErrNotFound) {
			return nil, connect.NewError(connect.CodeNotFound, err)
		}
		logger.Error(ctx, "admin ack alert failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(&highschoolv1.AcknowledgeAlertResponse{}), nil
}

// GetAppConfig 列出 app_config 全部开关（按 key 升序）。
func (h *AdminServiceHandler) GetAppConfig(ctx context.Context, req *connect.Request[highschoolv1.GetAppConfigRequest]) (*connect.Response[highschoolv1.GetAppConfigResponse], error) {
	flags, err := h.store.ListAppConfig(ctx)
	if err != nil {
		logger.Error(ctx, "admin get app_config failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	items := make([]*highschoolv1.AppConfigFlag, 0, len(flags))
	for _, f := range flags {
		items = append(items, &highschoolv1.AppConfigFlag{
			Key: f.Key, Value: f.Value, Description: f.Description,
		})
	}
	return connect.NewResponse(&highschoolv1.GetAppConfigResponse{Items: items}), nil
}

// SetAppConfig 新增/更新单个开关（upsert）。空 key 返回 CodeInvalidArgument；
// 成功后调用 cache.Invalidate() 使配置热刷（settings.Provider 下一次读即从 DB 重载）。
func (h *AdminServiceHandler) SetAppConfig(ctx context.Context, req *connect.Request[highschoolv1.SetAppConfigRequest]) (*connect.Response[highschoolv1.SetAppConfigResponse], error) {
	if req.Msg.GetKey() == "" {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("admin set app_config: empty key"))
	}
	if err := h.store.SetAppConfig(ctx, req.Msg.GetKey(), req.Msg.GetValue()); err != nil {
		logger.Error(ctx, "admin set app_config failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	if h.cache != nil {
		h.cache.Invalidate()
	}
	return connect.NewResponse(&highschoolv1.SetAppConfigResponse{}), nil
}

// RegisterAdminService 注册管理后台服务（挂鉴权 interceptor）
func RegisterAdminService(mux *http.ServeMux, otelInterceptor *otelconnect.Interceptor, secret string, store admin.Store, cache CacheInvalidator) {
	if secret == "" {
		logger.Warn(context.Background(), "admin service disabled: empty cookie secret (set HS_ADMIN_COOKIE_SECRET)")
		return
	}
	h := NewAdminServiceHandler(store, cache)
	opts := []connect.HandlerOption{connect.WithInterceptors(newAdminAuthInterceptor(secret))}
	if otelInterceptor != nil {
		opts = append(opts, connect.WithInterceptors(otelInterceptor))
	}
	path, svc := highschoolv1connect.NewAdminServiceHandler(h, opts...)
	mux.Handle(path, svc)
}
