// admin_connect.go - 管理后台 Admin 服务处理器（协议转换）
package v1

import (
	"context"
	"fmt"
	"net/http"

	"connectrpc.com/connect"
	"connectrpc.com/otelconnect"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	highschoolv1connect "highschool-backend/gen/highschool/v1/highschoolv1connect"
	"highschool-backend/internal/service/admin"
	"highschool-backend/pkg/logger"
)

// AdminServiceHandler 管理后台处理器
type AdminServiceHandler struct {
	highschoolv1connect.UnimplementedAdminServiceHandler
	store admin.Store
}

// NewAdminServiceHandler 创建管理后台处理器
func NewAdminServiceHandler(store admin.Store) *AdminServiceHandler {
	return &AdminServiceHandler{store: store}
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
			StepSeq: c.StepSeq, Node: c.Node, StateJson: c.StateJSON, CreatedAt: c.CreatedAt,
		})
	}
	return connect.NewResponse(resp), nil
}

// RegisterAdminService 注册管理后台服务（挂鉴权 interceptor）
func RegisterAdminService(mux *http.ServeMux, otelInterceptor *otelconnect.Interceptor, secret string, store admin.Store) {
	if secret == "" {
		logger.Warn(context.Background(), "admin service disabled: empty cookie secret (set HS_ADMIN_COOKIE_SECRET)")
		return
	}
	h := NewAdminServiceHandler(store)
	opts := []connect.HandlerOption{connect.WithInterceptors(newAdminAuthInterceptor(secret))}
	if otelInterceptor != nil {
		opts = append(opts, connect.WithInterceptors(otelInterceptor))
	}
	path, svc := highschoolv1connect.NewAdminServiceHandler(h, opts...)
	mux.Handle(path, svc)
}
