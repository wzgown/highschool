// Package wechat 微信内容安全（msgSecCheck）客户端
// 设计文档: docs/agent-mode-plan.md §3.9
// 未配置 AppSecret 时降级为 Noop（放行 + 启动告警），不影响本地开发。
package wechat

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"

	"highschool-backend/pkg/logger"
)

// 场景: 1=资料(无需openid) 2=评论 3=论坛 4=社交日志（2-4需真实openid，本系统无微信登录，用1）
const sceneProfile = 1

// SecChecker 文本安全检测抽象
type SecChecker interface {
	// CheckText 返回 suggest: pass/review/risky
	CheckText(ctx context.Context, content string) (string, error)
}

// ---------- 真实实现 ----------

type secChecker struct {
	appid     string
	secret    string
	client    *http.Client
	mu        sync.Mutex
	token     string
	tokenExpr time.Time
}

// NewSecChecker 创建内容安全检测器
func NewSecChecker(appid, secret string) SecChecker {
	return &secChecker{
		appid:  appid,
		secret: secret,
		client: &http.Client{Timeout: 8 * time.Second},
	}
}

// stableToken 获取/缓存稳定版 access_token
func (c *secChecker) stableToken(ctx context.Context) (string, error) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.token != "" && time.Now().Before(c.tokenExpr) {
		return c.token, nil
	}
	body, _ := json.Marshal(map[string]string{
		"grant_type": "client_credential",
		"appid":      c.appid,
		"secret":     c.secret,
	})
	req, err := http.NewRequestWithContext(ctx, http.MethodPost,
		"https://api.weixin.qq.com/cgi-bin/stable_token", bytes.NewReader(body))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("wechat stable_token: %w", err)
	}
	defer resp.Body.Close()
	var out struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int    `json:"expires_in"`
		ErrCode     int    `json:"errcode"`
		ErrMsg      string `json:"errmsg"`
	}
	if err := json.NewDecoder(io.LimitReader(resp.Body, 1<<20)).Decode(&out); err != nil {
		return "", err
	}
	if out.AccessToken == "" {
		return "", fmt.Errorf("wechat stable_token errcode=%d errmsg=%s", out.ErrCode, out.ErrMsg)
	}
	c.token = out.AccessToken
	// 提前 5 分钟过期
	c.tokenExpr = time.Now().Add(time.Duration(out.ExpiresIn-300) * time.Second)
	return c.token, nil
}

// CheckText 调 wxa/msg_sec_check
func (c *secChecker) CheckText(ctx context.Context, content string) (string, error) {
	token, err := c.stableToken(ctx)
	if err != nil {
		return "", err
	}
	body, _ := json.Marshal(map[string]any{
		"content": content,
		"version": 2,
		"scene":   sceneProfile,
	})
	req, err := http.NewRequestWithContext(ctx, http.MethodPost,
		"https://api.weixin.qq.com/wxa/msg_sec_check?access_token="+token, bytes.NewReader(body))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("msg_sec_check: %w", err)
	}
	defer resp.Body.Close()
	var out struct {
		ErrCode int    `json:"errcode"`
		ErrMsg  string `json:"errmsg"`
		Result  struct {
			Suggest string `json:"suggest"`
			Label   int    `json:"label"`
		} `json:"result"`
	}
	if err := json.NewDecoder(io.LimitReader(resp.Body, 1<<20)).Decode(&out); err != nil {
		return "", err
	}
	if out.ErrCode != 0 {
		return "", fmt.Errorf("msg_sec_check errcode=%d errmsg=%s", out.ErrCode, out.ErrMsg)
	}
	if out.Result.Suggest == "" {
		return "pass", nil
	}
	return out.Result.Suggest, nil
}

// ---------- 降级实现（未配置 secret） ----------

type noopChecker struct{ warned bool }

// NewNoopChecker 未配置微信密钥时的降级检测器（全放行）
func NewNoopChecker() SecChecker { return &noopChecker{} }

func (n *noopChecker) CheckText(ctx context.Context, content string) (string, error) {
	if !n.warned {
		n.warned = true
		logger.Warn(ctx, "wechat msgSecCheck disabled (no app secret configured), all content passed through")
	}
	return "pass", nil
}
