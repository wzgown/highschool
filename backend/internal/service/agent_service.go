// agent_service.go AI 顾问 Agent 服务层（编排：限流 → 会话恢复 → 状态图 → 持久化）
package service

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"sync"
	"time"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/wechat"
	"highschool-backend/internal/service/agent"
	"highschool-backend/internal/service/agent/graph"
	"highschool-backend/pkg/config"
	"highschool-backend/pkg/logger"
	"highschool-backend/pkg/metrics"
)

// AgentService Agent 服务接口
type AgentService interface {
	Chat(ctx context.Context, req *highschoolv1.ChatRequest) (*highschoolv1.ChatResponse, error)
	NewSession(ctx context.Context, req *highschoolv1.NewSessionRequest) (*highschoolv1.NewSessionResponse, error)
	GetSessionHistory(ctx context.Context, req *highschoolv1.GetSessionHistoryRequest) (*highschoolv1.GetSessionHistoryResponse, error)
}

type agentService struct {
	cfg        config.AgentConfig
	graph      *graph.Graph
	store      agent.Store
	secChecker wechat.SecChecker
	sem        chan struct{} // 全局 LLM 并发闸
	mu         sync.Map      // sessionID -> *sync.Mutex（同一会话串行）
}

// NewAgentService 创建 Agent 服务
func NewAgentService(cfg config.AgentConfig, g *graph.Graph, store agent.Store, secChecker wechat.SecChecker) AgentService {
	conc := cfg.MaxLLMConcurrency
	if conc <= 0 {
		conc = 10
	}
	if secChecker == nil {
		secChecker = wechat.NewNoopChecker()
	}
	return &agentService{
		cfg:        cfg,
		graph:      g,
		store:      store,
		secChecker: secChecker,
		sem:        make(chan struct{}, conc),
	}
}

// sessionLock 取会话级互斥锁（同一 session 串行处理，防双击/多端并发）
func (s *agentService) sessionLock(sessionID int64) *sync.Mutex {
	key := strconv.FormatInt(sessionID, 10)
	l, _ := s.mu.LoadOrStore(key, &sync.Mutex{})
	return l.(*sync.Mutex)
}

// Chat 对话主入口
func (s *agentService) Chat(ctx context.Context, req *highschoolv1.ChatRequest) (*highschoolv1.ChatResponse, error) {
	metrics.IncChatRequests()
	if req.DeviceId == "" {
		return nil, fmt.Errorf("device_id 不能为空")
	}
	userMsg := req.Message
	if userMsg == "" && req.PendingAnswer != "" {
		userMsg = req.PendingAnswer
	}
	if userMsg == "" {
		return nil, fmt.Errorf("message 不能为空")
	}
	if len(userMsg) > 500 {
		userMsg = userMsg[:500]
	}

	// 内容安全：用户输入检测（违规直接拒答，不消耗 LLM）
	if suggest, err := s.secChecker.CheckText(ctx, userMsg); err != nil {
		logger.Warn(ctx, "agent msgSecCheck(input) failed, allow through: "+err.Error())
	} else if suggest == "risky" {
		return &highschoolv1.ChatResponse{
			Reply: "你的提问包含不适宜的内容，无法处理。请换个与上海中考相关的问题。",
		}, nil
	}

	// 限流：device 每日配额
	if s.cfg.DailyQuota > 0 {
		n, err := s.store.CountTodayUserMessages(ctx, req.DeviceId)
		if err != nil {
			logger.Error(ctx, "agent count today messages failed", err)
		} else if n >= s.cfg.DailyQuota {
			return &highschoolv1.ChatResponse{
				Reply: "今天的咨询次数已用完啦，明天再来吧。志愿相关问题也可以先用「智能推荐」功能。\n\n数据仅供参考，以上海市教育考试院官方公布为准。",
			}, nil
		}
	}

	// 会话获取/创建
	var sessionID int64
	var sess *agent.Session
	if req.SessionId != "" {
		id, err := strconv.ParseInt(req.SessionId, 10, 64)
		if err != nil {
			return nil, fmt.Errorf("session_id 格式错误")
		}
		sess, err = s.store.GetSession(ctx, id)
		if err != nil {
			return nil, err
		}
		if sess.DeviceID != req.DeviceId {
			return nil, fmt.Errorf("会话不属于当前设备")
		}
		sessionID = id
	} else {
		var analysisID *int64
		if req.Context != nil && req.Context.AnalysisId > 0 {
			aid := int64(req.Context.AnalysisId)
			analysisID = &aid
		}
		id, err := s.store.CreateSession(ctx, req.DeviceId, analysisID)
		if err != nil {
			return nil, err
		}
		sess = &agent.Session{ID: id, DeviceID: req.DeviceId, Status: agent.SessionStatusRunning}
		sessionID = id
	}

	// 会话级串行
	lock := s.sessionLock(sessionID)
	lock.Lock()
	defer lock.Unlock()

	// 重建 State
	msgs, err := s.store.ListMessages(ctx, sessionID, s.cfg.MaxContextMessages+10)
	if err != nil {
		return nil, err
	}
	state := &agent.State{
		SessionID:     sessionID,
		DeviceID:      req.DeviceId,
		Messages:      msgs,
		Intent:        sess.Intent,
		Slots:         sess.Slots,
		PendingQ:      sess.PendingQ,
		StepBudget:    s.cfg.StepBudget,
		UserMessage:   userMsg,
		PendingAnswer: req.PendingAnswer,
	}
	if state.Slots == nil {
		state.Slots = map[string]any{}
	}
	// 前端显式 context 并入槽位
	if req.Context != nil {
		if req.Context.DistrictId > 0 {
			state.Slots["district_id"] = req.Context.DistrictId
		}
		if req.Context.TotalScore > 0 {
			state.Slots["total_score"] = req.Context.TotalScore
		}
		if req.Context.ExamType != "" {
			state.Slots["exam_type"] = req.Context.ExamType
		}
		if req.Context.AnalysisId > 0 {
			state.Slots["analysis_id"] = req.Context.AnalysisId
		}
	}

	// 全局并发闸（超时等待 30s）
	select {
	case s.sem <- struct{}{}:
		defer func() { <-s.sem }()
	case <-ctx.Done():
		return nil, ctx.Err()
	case <-time.After(30 * time.Second):
		return &highschoolv1.ChatResponse{SessionId: strconv.FormatInt(sessionID, 10),
			Reply: "当前咨询人数较多，请稍后再试。"}, nil
	}

	// 落库用户消息
	_ = s.store.AppendMessage(ctx, sessionID, agent.Message{Role: agent.RoleUser, Content: userMsg}, "", nil)

	// 推进状态图
	state.Messages = append(state.Messages, agent.Message{Role: agent.RoleUser, Content: userMsg})
	state, err = s.graph.Run(ctx, state)
	if err != nil {
		return nil, err
	}

	// 内容安全：助手输出检测（违规替换为安全兜底话术）
	if suggest, err := s.secChecker.CheckText(ctx, state.Reply); err != nil {
		logger.Warn(ctx, "agent msgSecCheck(output) failed, allow through: "+err.Error())
	} else if suggest == "risky" {
		state.Reply = "本次回答未能通过内容安全检查，请换个问法再试。数据类问题可以直接问分数线、招生计划、学校信息等。"
		state.Cards = nil
	}

	// 持久化会话状态（CAS 冲突不视为失败）
	sess.Status = agent.SessionStatusRunning
	if state.PendingQ != nil {
		sess.Status = agent.SessionStatusWaitingInput
	}
	sess.Intent = state.Intent
	sess.Slots = state.Slots
	sess.PendingQ = state.PendingQ
	sess.CurrentNode = ""
	if uErr := s.store.UpdateSessionCAS(ctx, sess); uErr != nil && !errors.Is(uErr, agent.ErrSessionConflict) {
		logger.Error(ctx, "agent update session failed", uErr)
	}

	// 落库助手消息（携带本轮累计 token usage）
	var usage *agent.ChatResult
	if state.PromptTokens > 0 || state.CompletionTokens > 0 {
		usage = &agent.ChatResult{PromptTokens: state.PromptTokens, CompletionTokens: state.CompletionTokens}
	}
	_ = s.store.AppendMessage(ctx, sessionID, agent.Message{Role: agent.RoleAssistant, Content: state.Reply}, "", usage)

	// 组装响应
	resp := &highschoolv1.ChatResponse{
		SessionId: strconv.FormatInt(sessionID, 10),
		Reply:     state.Reply,
		Intent:    state.Intent,
		TraceId:   fmt.Sprintf("%d-%d", sessionID, time.Now().Unix()),
	}
	for _, info := range state.ToolCallInfos {
		resp.ToolCalls = append(resp.ToolCalls, &highschoolv1.ToolCallInfo{
			Name: info.Name, Summary: info.Summary, Success: info.Success,
		})
	}
	for _, c := range state.Cards {
		payload, _ := json.Marshal(c.Payload)
		resp.SchoolCards = append(resp.SchoolCards, &highschoolv1.SchoolCard{
			SchoolId: c.SchoolID, SchoolName: c.SchoolName, DistrictName: c.DistrictName,
			CardType: c.CardType, PayloadJson: string(payload),
		})
	}
	if state.PendingQ != nil {
		resp.PendingQuestion = &highschoolv1.PendingQuestion{
			Question: state.PendingQ.Question,
			Field:    state.PendingQ.Field,
			Options:  state.PendingQ.Options,
		}
	}
	return resp, nil
}

// NewSession 新建会话
func (s *agentService) NewSession(ctx context.Context, req *highschoolv1.NewSessionRequest) (*highschoolv1.NewSessionResponse, error) {
	if req.DeviceId == "" {
		return nil, fmt.Errorf("device_id 不能为空")
	}
	var analysisID *int64
	if req.Context != nil && req.Context.AnalysisId > 0 {
		aid := int64(req.Context.AnalysisId)
		analysisID = &aid
	}
	id, err := s.store.CreateSession(ctx, req.DeviceId, analysisID)
	if err != nil {
		return nil, err
	}
	return &highschoolv1.NewSessionResponse{SessionId: strconv.FormatInt(id, 10)}, nil
}

// GetSessionHistory 获取会话历史
func (s *agentService) GetSessionHistory(ctx context.Context, req *highschoolv1.GetSessionHistoryRequest) (*highschoolv1.GetSessionHistoryResponse, error) {
	id, err := strconv.ParseInt(req.SessionId, 10, 64)
	if err != nil {
		return nil, fmt.Errorf("session_id 格式错误")
	}
	sess, err := s.store.GetSession(ctx, id)
	if err != nil {
		return nil, err
	}
	if sess.DeviceID != req.DeviceId {
		return nil, fmt.Errorf("会话不属于当前设备")
	}
	limit := int(req.Limit)
	if limit <= 0 {
		limit = 50
	}
	msgs, err := s.store.ListMessages(ctx, id, limit)
	if err != nil {
		return nil, err
	}
	resp := &highschoolv1.GetSessionHistoryResponse{SessionId: req.SessionId}
	for _, m := range msgs {
		resp.Messages = append(resp.Messages, &highschoolv1.SessionMessage{
			Role: m.Role, Content: m.Content,
		})
	}
	return resp, nil
}
