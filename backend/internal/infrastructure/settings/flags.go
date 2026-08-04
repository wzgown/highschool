// Package settings 应用配置（DB 驱动的远程开关，带缓存与 env 兜底）
package settings

import (
	"context"
	"strings"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/pkg/logger"
)

// cacheTTL 配置缓存时长
const cacheTTL = 60 * time.Second

// Fallback env/config 兜底值（DB 不可读时使用）
type Fallback struct {
	AgentEnabled       bool
	ReviewVersions     []string
	TipEnabled         bool
	TipURL             string
	TipReviewVersions  []string
}

// Provider 远程配置提供器：DB app_config 表 + 内存缓存 + env/config 兜底
type Provider struct {
	db *pgxpool.Pool
	fb Fallback

	mu        sync.Mutex
	cache     map[string]string
	fetchedAt time.Time
}

// NewProvider 创建配置提供器
func NewProvider(fb Fallback) *Provider {
	return &Provider{db: database.GetDB(), fb: fb}
}

// all 读取全部配置（带缓存；读库失败回退 env/config 值）
func (p *Provider) all(ctx context.Context) map[string]string {
	p.mu.Lock()
	defer p.mu.Unlock()
	if p.cache != nil && time.Since(p.fetchedAt) < cacheTTL {
		return p.cache
	}
	m := map[string]string{
		"feature.agent_enabled":   boolStr(p.fb.AgentEnabled),
		"feature.review_versions": strings.Join(p.fb.ReviewVersions, ","),
		"tip.enabled":             boolStr(p.fb.TipEnabled),
		"tip.qr_url":              p.fb.TipURL,
		"tip.review_versions":     strings.Join(p.fb.TipReviewVersions, ","),
	}
	if p.db != nil {
		rows, err := p.db.Query(ctx, `SELECT key, value FROM app_config`)
		if err != nil {
			logger.Warn(ctx, "app_config read failed, using fallback: "+err.Error())
		} else {
			for rows.Next() {
				var k, v string
				if err := rows.Scan(&k, &v); err == nil {
					m[k] = v
				}
			}
			rows.Close()
		}
	}
	p.cache = m
	p.fetchedAt = time.Now()
	return m
}

// AgentEnabled AI 顾问开关：总开关 AND 版本不在审核列表
func (p *Provider) AgentEnabled(ctx context.Context, version string) bool {
	m := p.all(ctx)
	if isFalse(m["feature.agent_enabled"]) {
		return false
	}
	return !versionListed(m["feature.review_versions"], version)
}

// TipURL 打赏码 URL：关闭或版本在审核列表时返回空串（前端隐藏）
func (p *Provider) TipURL(ctx context.Context, version string) string {
	m := p.all(ctx)
	if isFalse(m["tip.enabled"]) {
		return ""
	}
	if versionListed(m["tip.review_versions"], version) {
		return ""
	}
	return strings.TrimSpace(m["tip.qr_url"])
}

// Invalidate 清空缓存（管理操作后立即生效用）
func (p *Provider) Invalidate() {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.cache = nil
}

func boolStr(b bool) string {
	if b {
		return "true"
	}
	return "false"
}

func isFalse(v string) bool {
	return strings.EqualFold(strings.TrimSpace(v), "false")
}

// versionListed 判断版本号是否在逗号分隔列表中；空 version 视为不在列表
func versionListed(list, version string) bool {
	if version == "" {
		return false
	}
	for _, v := range strings.Split(list, ",") {
		if strings.TrimSpace(v) == version {
			return true
		}
	}
	return false
}
