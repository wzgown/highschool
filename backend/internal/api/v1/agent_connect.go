// agent_connect.go - Agent 服务 API 层（协议转换 + 组装依赖）
package v1

import (
	"context"
	"net/http"

	"connectrpc.com/connect"
	"connectrpc.com/otelconnect"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/gen/highschool/v1/highschoolv1connect"
	"highschool-backend/internal/infrastructure/llm"
	"highschool-backend/internal/infrastructure/wechat"
	"highschool-backend/internal/repository"
	"highschool-backend/internal/service"
	"highschool-backend/internal/service/agent/graph"
	"highschool-backend/internal/service/agent/tools"
	"highschool-backend/pkg/config"
	"highschool-backend/pkg/logger"
)

// AgentServiceHandler Agent 服务处理器
type AgentServiceHandler struct {
	highschoolv1connect.UnimplementedAgentServiceHandler
	service service.AgentService
}

// NewAgentServiceHandler 创建 Agent 服务处理器（组装 LLM/工具/状态图/仓储）
func NewAgentServiceHandler() (*AgentServiceHandler, error) {
	cfg, err := config.Load()
	if err != nil {
		return nil, err
	}
	llmClient, err := llm.NewClient(cfg.LLM)
	if err != nil {
		return nil, err
	}
	store := repository.NewAgentStoreRepository()
	dataRepo := repository.NewAgentDataRepository()
	registry := tools.NewRegistryWithEngine(dataRepo, service.NewRecommendationService(), repository.NewSimulationHistoryRepository())
	g := graph.NewGraph(llmClient, registry, store, graph.Config{
		MaxReplan:            cfg.Agent.MaxReplan,
		StepBudget:           cfg.Agent.StepBudget,
		MaxContextMsgs:       cfg.Agent.MaxContextMessages,
		ReflectionLLMEnabled: cfg.Agent.ReflectionLLMEnabled,
		Model:                cfg.LLM.Model,
	})
	var secChecker wechat.SecChecker
	if cfg.WeChat.Secret != "" && cfg.WeChat.AppID != "" {
		secChecker = wechat.NewSecChecker(cfg.WeChat.AppID, cfg.WeChat.Secret)
	} else {
		secChecker = wechat.NewNoopChecker()
	}
	return &AgentServiceHandler{
		service: service.NewAgentService(cfg.Agent, g, store, secChecker),
	}, nil
}

// Chat 对话
func (h *AgentServiceHandler) Chat(ctx context.Context, req *connect.Request[highschoolv1.ChatRequest]) (*connect.Response[highschoolv1.ChatResponse], error) {
	resp, err := h.service.Chat(ctx, req.Msg)
	if err != nil {
		logger.Error(ctx, "agent chat failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(resp), nil
}

// NewSession 新建会话
func (h *AgentServiceHandler) NewSession(ctx context.Context, req *connect.Request[highschoolv1.NewSessionRequest]) (*connect.Response[highschoolv1.NewSessionResponse], error) {
	resp, err := h.service.NewSession(ctx, req.Msg)
	if err != nil {
		logger.Error(ctx, "agent new session failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(resp), nil
}

// GetSessionHistory 获取会话历史
func (h *AgentServiceHandler) GetSessionHistory(ctx context.Context, req *connect.Request[highschoolv1.GetSessionHistoryRequest]) (*connect.Response[highschoolv1.GetSessionHistoryResponse], error) {
	resp, err := h.service.GetSessionHistory(ctx, req.Msg)
	if err != nil {
		logger.Error(ctx, "agent get session history failed", err)
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	return connect.NewResponse(resp), nil
}

// RegisterAgentService 注册 Agent 服务
func RegisterAgentService(mux *http.ServeMux, otelInterceptor *otelconnect.Interceptor) {
	handler, err := NewAgentServiceHandler()
	if err != nil {
		// LLM 未配置（如本地开发无 API key）时不注册服务，不影响其他服务启动
		logger.Warn(context.Background(), "agent service disabled: "+err.Error())
		return
	}
	opts := []connect.HandlerOption{}
	if otelInterceptor != nil {
		opts = append(opts, connect.WithInterceptors(otelInterceptor))
	}
	path, svc := highschoolv1connect.NewAgentServiceHandler(handler, opts...)
	mux.Handle(path, svc)
}
