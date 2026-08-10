// inspector.go P3 告警巡检引擎——后台 ticker 定时跑 3 项检查、去重写入 agent_alert、
// 命中企业微信群机器人 webhook。收掉原 #3「告警从未被调度」的缺口。
package admin

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"highschool-backend/pkg/logger"
)

// 告警阈值常量
const (
	errorRateThreshold = 0.20 // 错误率 > 20% 触发
	errorRateMinCalls  int32  = 5 // 调用数须 > 5，避免小样本误报
)

// InspectorStore 巡检引擎依赖的窄仓储接口（admin.Store 已满足，无需在 Store 上重复声明）。
type InspectorStore interface {
	LLMStatsLastHour(ctx context.Context) (calls int32, errors int32, err error)
	TraceGapLastHour(ctx context.Context) (userMsgs int32, traces int32, err error)
	TodayTokenTotal(ctx context.Context) (int64, error)
	HasOpenAlert(ctx context.Context, kind string) (bool, error)
	InsertAlert(ctx context.Context, a *Alert) (int64, error)
}

// Inspector 告警巡检引擎。每个 check 独立失败隔离；命中条件且无 open 同类告警时
// 写入 agent_alert 并推送 webhook（去重）。
type Inspector struct {
	store      InspectorStore
	budget     int64
	webhookURL string
	// webhook 可注入，便于测试；默认指向 defaultWebhook（企业微信群机器人）。
	webhook func(url, markdown string) error
}

// NewInspector 创建巡检引擎。webhook 默认使用 defaultWebhook。
func NewInspector(store InspectorStore, budget int64, webhookURL string) *Inspector {
	return &Inspector{
		store:      store,
		budget:     budget,
		webhookURL: webhookURL,
		webhook:    defaultWebhook,
	}
}

// RunOnce 顺序执行 3 项检查。任一 check 的仓储查询失败仅记录 warn 并跳过该 check，
// 不影响其余 check 执行。
func (i *Inspector) RunOnce(ctx context.Context) {
	i.checkLLMErrorRate(ctx)
	i.checkTraceMissing(ctx)
	i.checkTokenBudget(ctx)
}

// checkLLMErrorRate 近 1h LLM 错误率：调用数 > 5 且错误率 > 20% 触发 critical 告警。
func (i *Inspector) checkLLMErrorRate(ctx context.Context) {
	calls, errs, err := i.store.LLMStatsLastHour(ctx)
	if err != nil {
		logger.Warn(ctx, "inspector: LLMStatsLastHour failed", logger.ErrorField(err))
		return
	}
	if calls > errorRateMinCalls && float64(errs)/float64(calls) > errorRateThreshold {
		rate := float64(errs) / float64(calls)
		detail := buildDetail(map[string]any{
			"calls":  calls,
			"errors": errs,
			"rate":   rate,
			"window": "1h",
		})
		i.fire(ctx, "llm_error_rate", "critical", "LLM 错误率异常", detail)
	}
}

// checkTraceMissing 近 1h trace 落库：有用户消息但无 trace → 疑似落库中断，critical。
func (i *Inspector) checkTraceMissing(ctx context.Context) {
	userMsgs, traces, err := i.store.TraceGapLastHour(ctx)
	if err != nil {
		logger.Warn(ctx, "inspector: TraceGapLastHour failed", logger.ErrorField(err))
		return
	}
	if traces == 0 && userMsgs > 0 {
		detail := buildDetail(map[string]any{
			"user_msgs": userMsgs,
			"traces":    0,
			"window":    "1h",
		})
		i.fire(ctx, "trace_missing", "critical", "trace 落库疑似中断", detail)
	}
}

// checkTokenBudget 当日 token 合计超预算 → warn 告警。
func (i *Inspector) checkTokenBudget(ctx context.Context) {
	tokens, err := i.store.TodayTokenTotal(ctx)
	if err != nil {
		logger.Warn(ctx, "inspector: TodayTokenTotal failed", logger.ErrorField(err))
		return
	}
	if tokens > i.budget {
		detail := buildDetail(map[string]any{
			"tokens": tokens,
			"budget": i.budget,
		})
		i.fire(ctx, "token_budget", "warn", "当日 token 超预算", detail)
	}
}

// fire 去重写入告警并推送 webhook：若已存在同类 open 告警则跳过（不写不推）。
func (i *Inspector) fire(ctx context.Context, kind, severity, title, detailJSON string) {
	open, err := i.store.HasOpenAlert(ctx, kind)
	if err != nil {
		logger.Warn(ctx, "inspector: HasOpenAlert failed", logger.ErrorField(err), logger.String("kind", kind))
		return
	}
	if open {
		return // 去重：同类告警仍 open，不再重复写入/推送
	}
	if _, err := i.store.InsertAlert(ctx, &Alert{
		Kind:       kind,
		Severity:   severity,
		Title:      title,
		DetailJSON: detailJSON,
	}); err != nil {
		logger.Warn(ctx, "inspector: InsertAlert failed", logger.ErrorField(err), logger.String("kind", kind))
		return
	}
	i.notify(title, detailJSON)
}

// notify 构造 markdown 消息并调用 webhook；失败仅记录 warn，不向上游传播。
func (i *Inspector) notify(title, detailJSON string) {
	if i.webhookURL == "" {
		return
	}
	markdown := fmt.Sprintf("## %s\n```json\n%s\n```", title, detailJSON)
	if err := i.webhook(i.webhookURL, markdown); err != nil {
		logger.Warn(context.Background(), "inspector: webhook notify failed", logger.ErrorField(err))
	}
}

// Start 后台 ticker 循环：启动后立即跑一次，随后按 interval 周期执行。
// 每个 tick 独立 recover，单次 panic 不会杀死循环。
func (i *Inspector) Start(ctx context.Context, interval time.Duration) {
	logger.Info(ctx, "admin inspector started",
		logger.Duration("interval", interval),
		logger.Int64("budget", i.budget),
	)
	i.RunOnce(ctx)
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			logger.Info(ctx, "admin inspector stopped")
			return
		case <-ticker.C:
			func() {
				defer func() {
					if r := recover(); r != nil {
						logger.Warn(ctx, "inspector: tick panic recovered", logger.Any("panic", r))
					}
				}()
				i.RunOnce(ctx)
			}()
		}
	}
}

// buildDetail 将 detail map 序列化为 JSON 文本（保证 pgx $1::jsonb 写入合法）。
func buildDetail(m map[string]any) string {
	b, _ := json.Marshal(m)
	return string(b)
}

// defaultWebhook 企业微信群机器人格式：POST {"msgtype":"markdown","markdown":{"content":..}}。
// 10s 超时；非 2xx 视为失败返回 error。
func defaultWebhook(url, markdown string) error {
	payload := map[string]any{
		"msgtype": "markdown",
		"markdown": map[string]string{
			"content": markdown,
		},
	}
	b, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("inspector webhook: marshal payload: %w", err)
	}
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Post(url, "application/json", bytes.NewReader(b))
	if err != nil {
		return fmt.Errorf("inspector webhook: post: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("inspector webhook: non-2xx status %d", resp.StatusCode)
	}
	return nil
}
