# 管理后台 P1（地基 + 会话回放）实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 单管理员可登录一个 Web 管理后台,在浏览器里按时间线回放任意 AI 顾问会话的消息 / LLM 调用 / 工具调用 / checkpoint 留痕。

**Architecture:** Vue 3 SPA(`admin/`,Vite + Element Plus)构建后 `go:embed` 进 Go 二进制,挂在 `/admin/*`;新增 `AdminService`(Connect-RPC),cookie 鉴权(bcrypt 密码 + HMAC 签名)。后端直连现有 `agent_*` 表(只读)拼装回放数据。P2–P4(成本看板 / 告警 / 开关)后续规划。

**Tech Stack:** Go 1.24+ · Connect-RPC · pgx/v5 · `golang.org/x/crypto`(bcrypt) · Vue 3 · Vite · TypeScript · Element Plus · Pinia · Vue Router · `@connectrpc/connect-web`

**关联 spec:** `docs/superpowers/specs/2026-08-10-admin-console-design.md`

## Global Constraints

- 仓库根:`/Users/lance.wang/workspace/wzgown/highschool_new`;工作分支 `feat/admin-console`。
- Go module 名 `highschool-backend`;proto 生成路径 `backend/gen/highschool/v1/`(managed `go_package_prefix=highschool-backend/gen`)。
- 现有 Connect 服务注册范式:`v1.RegisterXxxService(mux, *otelconnect.Interceptor)`,内部 `highschoolv1connect.NewXxxHandler(h, connect.WithInterceptors(...)...)`。
- 仓储范式:`NewXxxRepository()` 内部 `database.GetDB()` 取 `*pgxpool.Pool` 单例。
- 配置范式:`pkg/config/config.go` 结构体 + mapstructure + viper,env 前缀 `HS_`、`.`→`_`(如 `admin.password_hash` → `HS_ADMIN_PASSWORD_HASH`)。
- 改 proto 后必须 `cd proto && buf generate`。
- 每个 Task 结尾 commit;commit message 以 `feat(admin):`/`fix(admin):`/`chore(admin):` 开头,正文末尾加 `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`。
- 不碰小程序目录 `frontend/`;管理后台是独立目录 `admin/`。
- 回放展示原始 LLM/工具 IO(含可能的考生信息)——单管理员可信,不脱敏。

---

## File Structure

**后端(新建/修改):**
- `db/migrations/013_create_agent_alert.sql` — 新表(P3 用,P1 先建)
- `backend/pkg/config/config.go` — 加 `AdminConfig`
- `backend/config.yaml`、`backend/config.docker.yaml` — 加 `admin:` 段
- `backend/pkg/auth/auth.go` + `_test.go` — bcrypt + HMAC cookie
- `backend/internal/service/admin/store.go` — `Store` 接口 + 回放类型
- `backend/internal/repository/admin_repository.go` — pgx 实现
- `backend/internal/repository/admin_repository_test.go` — 集成测试(无 DB 跳过)
- `proto/highschool/v1/admin_service.proto` — 新 RPC
- `proto/buf.gen.yaml` — 加 admin TS 输出
- `backend/internal/api/v1/admin_connect.go` + `_test.go` — handler + 注册
- `backend/internal/api/v1/admin_auth.go` + `_test.go` — 鉴权 interceptor
- `backend/internal/api/v1/admin_login.go` — `/admin/api/login`
- `backend/internal/api/v1/admin_static.go` + `admin_dist/index.html` — embed + SPA
- `backend/cmd/api/main.go` — 装配

**前端(新建 `admin/`):**
- `admin/package.json`、`admin/vite.config.ts`、`admin/tsconfig.json`、`admin/index.html`、`admin/src/main.ts`、`admin/src/App.vue`
- `admin/src/gen/...` — buf 生成的 TS Connect 客户端
- `admin/src/api/client.ts`、`admin/src/stores/auth.ts`
- `admin/src/router/index.ts`
- `admin/src/views/Login.vue`、`admin/src/views/SessionList.vue`、`admin/src/views/SessionReplay.vue`
- `admin/src/layouts/AdminLayout.vue`

**部署:**
- `backend/Dockerfile` — 多阶段(node 构建 admin → go build)

---

## Task 1: `agent_alert` 表迁移

**Files:**
- Create: `db/migrations/013_create_agent_alert.sql`

**Interfaces:** 无依赖;产出表 `agent_alert`(P3 告警引擎使用,P1 先建以匹配 spec §13)。

- [ ] **Step 1: 写迁移 SQL**

Create `db/migrations/013_create_agent_alert.sql`:
```sql
-- ============================================================
-- Agent 运行告警表（管理后台 P3 巡检引擎写入；P1 先建表）
-- 设计文档: docs/superpowers/specs/2026-08-10-admin-console-design.md §5.1
-- ============================================================
CREATE TABLE IF NOT EXISTS agent_alert (
    id          SERIAL PRIMARY KEY,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    kind        VARCHAR(30)  NOT NULL,            -- llm_error_rate | trace_missing | token_budget
    severity    VARCHAR(10)  NOT NULL DEFAULT 'warn',  -- warn | critical
    title       TEXT         NOT NULL,
    detail      JSONB        NOT NULL DEFAULT '{}'::jsonb,
    status      VARCHAR(10)  NOT NULL DEFAULT 'open',  -- open | acked | resolved
    acked_at    TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_agent_alert_status_created ON agent_alert(status, created_at DESC);
```

- [ ] **Step 2: 应用到开发库**

Run:
```bash
psql -h 192.168.71.160 -U highschool -d highschool -f db/migrations/013_create_agent_alert.sql
```
Expected: `CREATE TABLE` + `CREATE INDEX`,无报错。

- [ ] **Step 3: 验证表结构**

Run:
```bash
psql -h 192.168.71.160 -U highschool -d highschool -c "\d agent_alert"
```
Expected: 列 `id/created_at/kind/severity/title/detail/status/acked_at` 齐全。

- [ ] **Step 4: Commit**

```bash
git add db/migrations/013_create_agent_alert.sql
git commit -m "chore(admin): 新增 agent_alert 表迁移" -m "P3 告警引擎将写入此表；P1 先建表以匹配 spec §13。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 2: Admin 配置项

**Files:**
- Modify: `backend/pkg/config/config.go`
- Modify: `backend/config.yaml`
- Modify: `backend/config.docker.yaml`

**Interfaces:**
- Produces: `config.AdminConfig{PasswordHash, CookieSecret, SessionTTLHours}`;`Config.Admin`。env:`HS_ADMIN_PASSWORD_HASH`、`HS_ADMIN_COOKIE_SECRET`、`HS_ADMIN_SESSION_TTL_HOURS`。

- [ ] **Step 1: 加 AdminConfig 结构与字段**

在 `backend/pkg/config/config.go` 的 `Config` 结构体里,`Feature FeatureConfig` 行之后加一行:
```go
	Admin   AdminConfig    `mapstructure:"admin"`
```
在 `FeatureConfig` 结构体定义之后新增:
```go
// AdminConfig 管理后台配置（单管理员）
type AdminConfig struct {
	PasswordHash    string `mapstructure:"password_hash"`     // bcrypt 哈希；优先经 HS_ADMIN_PASSWORD_HASH 注入
	CookieSecret    string `mapstructure:"cookie_secret"`     // HMAC 签名密钥；优先经 HS_ADMIN_COOKIE_SECRET 注入
	SessionTTLHours int    `mapstructure:"session_ttl_hours"` // 登录会话有效期
}
```

- [ ] **Step 2: 加默认值**

在 `func Load()` 的 `viper.SetDefault("feature.agent_enabled", true)` 行之后加:
```go
	viper.SetDefault("admin.session_ttl_hours", 12)
```
（`password_hash` / `cookie_secret` 无默认值,必须经环境变量注入;未配则管理后台不启用。）

- [ ] **Step 3: config.yaml 加段**

在 `backend/config.yaml` 末尾(`feature:` 段之后)加:
```yaml
# 管理后台（单管理员；password_hash 为 bcrypt，cookie_secret 为 HMAC 密钥；
# 生产经 HS_ADMIN_PASSWORD_HASH / HS_ADMIN_COOKIE_SECRET 注入，勿提交真实值）
admin:
  enabled: true
  password_hash: ""
  cookie_secret: ""
  session_ttl_hours: 12
```
> 注:`enabled` 仅作开关占位,代码里以 `password_hash != "" && cookie_secret != ""` 判定启用。

在 `backend/config.docker.yaml` 的 `feature:` 段之后加同样内容(本地与 docker 同步)。

- [ ] **Step 4: 编译验证**

Run:
```bash
cd backend && go build ./pkg/config/
```
Expected: 无报错。

- [ ] **Step 5: Commit**

```bash
git add backend/pkg/config/config.go backend/config.yaml backend/config.docker.yaml
git commit -m "feat(admin): 新增 AdminConfig（bcrypt 密码 + HMAC cookie + TTL）" -m "env: HS_ADMIN_PASSWORD_HASH / HS_ADMIN_COOKIE_SECRET / HS_ADMIN_SESSION_TTL_HOURS。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 3: Auth 包（bcrypt + HMAC cookie）

**Files:**
- Create: `backend/pkg/auth/auth.go`
- Test: `backend/pkg/auth/auth_test.go`

**Interfaces:**
- Produces:
  - `auth.HashPassword(plain string) (string, error)` — bcrypt 哈希(仅用于生成初始哈希的工具)
  - `auth.VerifyPassword(hashed, plain string) bool`
  - `auth.SignSession(secret, subject string, exp time.Time) string` — 返回 `payload.signature`
  - `auth.VerifySession(secret, token string) (subject string, ok bool)`

- [ ] **Step 1: 写失败测试**

Create `backend/pkg/auth/auth_test.go`:
```go
package auth

import (
	"testing"
	"time"
)

func TestVerifyPassword(t *testing.T) {
	hashed, err := HashPassword("s3cret")
	if err != nil {
		t.Fatalf("hash: %v", err)
	}
	if !VerifyPassword(hashed, "s3cret") {
		t.Fatal("correct password should verify")
	}
	if VerifyPassword(hashed, "wrong") {
		t.Fatal("wrong password should not verify")
	}
}

func TestSessionTokenRoundTrip(t *testing.T) {
	secret := "super-secret-key"
	exp := time.Now().Add(1 * time.Hour)
	token := SignSession(secret, "admin", exp)
	sub, ok := VerifySession(secret, token)
	if !ok || sub != "admin" {
		t.Fatalf("round-trip failed: sub=%q ok=%v", sub, ok)
	}
}

func TestSessionTokenRejectsTamper(t *testing.T) {
	secret := "super-secret-key"
	exp := time.Now().Add(1 * time.Hour)
	token := SignSession(secret, "admin", exp)
	// 篡改 payload
	tampered := token[:len(token)-2] + "XX"
	if _, ok := VerifySession(secret, tampered); ok {
		t.Fatal("tampered token must not verify")
	}
}

func TestSessionTokenRejectsExpired(t *testing.T) {
	secret := "super-secret-key"
	exp := time.Now().Add(-1 * time.Hour) // 已过期
	token := SignSession(secret, "admin", exp)
	if _, ok := VerifySession(secret, token); ok {
		t.Fatal("expired token must not verify")
	}
}

func TestSessionTokenRejectsWrongSecret(t *testing.T) {
	exp := time.Now().Add(1 * time.Hour)
	token := SignSession("secret-A", "admin", exp)
	if _, ok := VerifySession("secret-B", token); ok {
		t.Fatal("wrong-secret token must not verify")
	}
}
```

- [ ] **Step 2: 跑测试确认失败**

Run:
```bash
cd backend && go test ./pkg/auth/ -v
```
Expected: FAIL(包/函数未定义)。

- [ ] **Step 3: 写实现**

Create `backend/pkg/auth/auth.go`:
```go
// Package auth 管理后台鉴权：bcrypt 密码校验 + HMAC 签名会话 cookie。
package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"strconv"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// HashPassword 生成 bcrypt 哈希（用于生成初始管理员密码哈希）。
func HashPassword(plain string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	return string(b), err
}

// VerifyPassword 校验明文密码与 bcrypt 哈希是否匹配。
func VerifyPassword(hashed, plain string) bool {
	return bcrypt.CompareHashAndPassword([]byte(hashed), []byte(plain)) == nil
}

// SignSession 生成会话 token：base64(subject.expUnix).base64(hmac)。
func SignSession(secret, subject string, exp time.Time) string {
	payload := subject + "." + strconv.FormatInt(exp.Unix(), 10)
	enc := base64.RawURLEncoding.EncodeToString([]byte(payload))
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(enc))
	sig := base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
	return enc + "." + sig
}

// VerifySession 校验 token 签名与有效期，返回 subject。
func VerifySession(secret, token string) (string, bool) {
	enc, sig, ok := strings.Cut(token, ".")
	if !ok {
		return "", false
	}
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(enc))
	want := base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
	if !hmac.Equal([]byte(sig), []byte(want)) {
		return "", false
	}
	raw, err := base64.RawURLEncoding.DecodeString(enc)
	if err != nil {
		return "", false
	}
	sub, expStr, ok := strings.Cut(string(raw), ".")
	if !ok {
		return "", false
	}
	expUnix, err := strconv.ParseInt(expStr, 10, 64)
	if err != nil {
		return "", false
	}
	if time.Now().Unix() > expUnix {
		return "", false
	}
	return sub, true
}

// errPlaceholder 抑制未使用（HashPassword 在 main 外通过 CLI 使用）。
var _ = errors.New
```
> 删除末尾 `var _ = errors.New` 与 `"errors"` import 若编译器不报未使用——保留 `errors` 仅在需要时;实际如无引用则移除该 import 与占位行。

- [ ] **Step 4: 清理未用 import 后跑测试**

如 Step 3 注释,移除 `errors` import 与 `var _ = errors.New` 两行(本文件实际未用 errors),然后:
```bash
cd backend && go mod tidy && go test ./pkg/auth/ -v
```
Expected: 全部 PASS。

- [ ] **Step 5: Commit**

```bash
git add backend/pkg/auth/auth.go backend/pkg/auth/auth_test.go backend/go.mod backend/go.sum
git commit -m "feat(admin): auth 包——bcrypt 密码 + HMAC 会话 cookie" -m "TDD：哈希/往返/篡改/过期/错密 五例。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 4: Admin 鉴权 interceptor

**Files:**
- Create: `backend/internal/api/v1/admin_auth.go`
- Test: `backend/internal/api/v1/admin_auth_test.go`

**Interfaces:**
- Consumes: `auth.VerifySession(secret, token)`
- Produces: `newAdminAuthInterceptor(secret string) connect.Interceptor`——挂在 AdminService 上,无有效 cookie 返回 `connect.CodeUnauthenticated`。

- [ ] **Step 1: 写失败测试**

Create `backend/internal/api/v1/admin_auth_test.go`:
```go
package v1

import (
	"context"
	"net/http"
	"testing"
	"time"

	"connectrpc.com/connect"
	"highschool-backend/pkg/auth"
)

// 模拟一次 unary 拦截：给入站请求注入 cookie，断言拦截器放行/拒绝。
func runUnary(i connect.Interceptor, cookie string) error {
	req := &connect.Request[struct{}]{}
	req.Header().Set("Cookie", cookie)
	_, err := i.WrapUnary(context.Background(), connect.NewUnaryRequest(
		"/svc/Method", nil, req.Spec(), // Spec 仅占位，WrapUnary 内部只看 Header
	))
	_ = req
	return err
}

func TestAuthInterceptor_NoCookie(t *testing.T) {
	ic := newAdminAuthInterceptor("k")
	// 直接验底层判断函数，避免构造完整 unary 调用
	if _, ok := checkAdminCookie("k", http.Header{}); ok {
		t.Fatal("missing cookie must fail")
	}
}

func TestAuthInterceptor_ValidCookie(t *testing.T) {
	tok := auth.SignSession("k", "admin", time.Now().Add(time.Hour))
	h := http.Header{}
	h.Set("Cookie", "admin_sess="+tok)
	if sub, ok := checkAdminCookie("k", h); !ok || sub != "admin" {
		t.Fatalf("valid cookie must pass: sub=%q ok=%v", sub, ok)
	}
}

func TestAuthInterceptor_BadCookie(t *testing.T) {
	h := http.Header{}
	h.Set("Cookie", "admin_sess=garbage")
	if _, ok := checkAdminCookie("k", h); ok {
		t.Fatal("garbage cookie must fail")
	}
}
```

- [ ] **Step 2: 跑测试确认失败**

Run:
```bash
cd backend && go test ./internal/api/v1/ -run AuthInterceptor -v
```
Expected: FAIL(`newAdminAuthInterceptor`/`checkAdminCookie` 未定义)。

- [ ] **Step 3: 写实现**

Create `backend/internal/api/v1/admin_auth.go`:
```go
package v1

import (
	"context"
	"net/http"

	"connectrpc.com/connect"
	"highschool-backend/pkg/auth"
)

const adminCookieName = "admin_sess"

// checkAdminCookie 从请求头解析 admin cookie 并校验。
func checkAdminCookie(secret string, h http.Header) (string, bool) {
	req := &http.Request{Header: h}
	c, err := req.Cookie(adminCookieName)
	if err != nil {
		return "", false
	}
	return auth.VerifySession(secret, c.Value)
}

// newAdminAuthInterceptor 返回包裹 AdminService 的鉴权拦截器：
// 无有效 admin cookie → CodeUnauthenticated。
func newAdminAuthInterceptor(secret string) connect.Interceptor {
	return &adminAuthInterceptor{secret: secret}
}

type adminAuthInterceptor struct{ secret string }

func (a *adminAuthInterceptor) WrapUnary(ctx context.Context, req connect.AnyRequest) (context.Context, connect.Receiver, error) {
	if _, ok := checkAdminCookie(a.secret, req.Header()); !ok {
		return nil, nil, connect.NewError(connect.CodeUnauthenticated, errAdminUnauthenticated)
	}
	return ctx, nil, nil
}

func (a *adminAuthInterceptor) WrapStreamingClient(ctx context.Context, req connect.StreamingClientFunc) connect.StreamingClientFunc {
	return req
}

func (a *adminAuthInterceptor) WrapStreamingHandler(ctx context.Context, svc connect.StreamingHandlerFunc) connect.StreamingHandlerFunc {
	return svc
}
```

并在 `admin_auth.go` 顶部 import 块后补错误变量:
```go
import "errors"
```
与（文件内）:
```go
var errAdminUnauthenticated = errors.New("admin: unauthenticated")
```
（合并到同一 import；`errors` 单独一行加入 import 块。）

> 说明:`connect.Interceptor.WrapUnary` 签名为 `(ctx, req connect.AnyRequest) (context.Context, connect.Receiver, error)`——返回 `(ctx, nil, nil)` 表示放行,下游 handler 接管。若版本签名不同,以 `go doc connectrpc.com/connect Interceptor` 为准调整。

- [ ] **Step 4: 跑测试确认通过**

Run:
```bash
cd backend && go test ./internal/api/v1/ -run AuthInterceptor -v
```
Expected: 3 例 PASS。若 `connect.Interceptor` 接口签名与上述不符,按编译器提示调整 `WrapUnary` 返回值,使接口满足。

- [ ] **Step 5: Commit**

```bash
git add backend/internal/api/v1/admin_auth.go backend/internal/api/v1/admin_auth_test.go
git commit -m "feat(admin): Connect 鉴权 interceptor（cookie 校验）" -m "无有效 admin_sess cookie → CodeUnauthenticated。TDD 三例。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 5: Admin Store 接口 + 仓储（回放查询）

**Files:**
- Create: `backend/internal/service/admin/store.go`
- Create: `backend/internal/repository/admin_repository.go`
- Test: `backend/internal/repository/admin_repository_test.go`

**Interfaces:**
- Produces:
  - `admin.ListFilter{TimeFrom,TimeTo,DeviceID,Intent string; Page,PageSize int32}`
  - `admin.SessionRow{SessionID int64; DeviceID,Status,Intent,CreatedAt,LastActiveAt string; MessageCount int32; TotalTokens int64}`
  - `admin.ReplayBundle{Session ReplaySession; Messages []ReplayMessage; Traces []ReplayTrace; Checkpoints []ReplayCheckpoint}`
  - `admin.Store` 接口:`ListAgentSessions(ctx, ListFilter) ([]SessionRow, int32, error)`、`GetSessionReplay(ctx, sessionID int64) (*ReplayBundle, error)`
  - `repository.NewAdminRepository()` 返回 `admin.Store` 实现。

- [ ] **Step 1: 定义接口与类型**

Create `backend/internal/service/admin/store.go`:
```go
// Package admin 管理后台业务类型契约（回放/审计只读查询）。
package admin

import "context"

// ListAgentSessions 会话列表过滤条件
type ListFilter struct {
	TimeFrom string // 含；空不过滤；RFC3339 或 'YYYY-MM-DD'
	TimeTo   string
	DeviceID string
	Intent   string
	Page     int32 // 从 1 起
	PageSize int32
}

// SessionRow 会话列表行
type SessionRow struct {
	SessionID     int64
	DeviceID      string
	Status        string
	Intent        string
	CreatedAt     string
	LastActiveAt  string
	MessageCount  int32
	TotalTokens   int64
}

// ReplaySession 回放-会话元信息
type ReplaySession struct {
	SessionID int64
	DeviceID  string
	Status    string
	Intent    string
	CreatedAt string
}

// ReplayMessage 回放-消息
type ReplayMessage struct {
	Role      string
	Content   string
	Node      string
	CreatedAt string
	UsageJSON string // 原始 usage JSON
}

// ReplayTrace 回放-LLM/工具留痕
type ReplayTrace struct {
	Kind             string
	Name             string
	InputJSON        string
	OutputJSON       string
	PromptTokens     int32
	CompletionTokens int32
	LatencyMs        int32
	CreatedAt        string
}

// ReplayCheckpoint 回放-节点快照
type ReplayCheckpoint struct {
	StepSeq   int32
	Node      string
	StateJSON string
	CreatedAt string
}

// ReplayBundle 回放全量数据
type ReplayBundle struct {
	Session     ReplaySession
	Messages    []ReplayMessage
	Traces      []ReplayTrace
	Checkpoints []ReplayCheckpoint
}

// Store 管理后台只读仓储（handler 依赖此接口，便于测试用 fake）
type Store interface {
	ListAgentSessions(ctx context.Context, f ListFilter) ([]SessionRow, int32, error)
	GetSessionReplay(ctx context.Context, sessionID int64) (*ReplayBundle, error)
}
```

- [ ] **Step 2: 写仓储实现**

Create `backend/internal/repository/admin_repository.go`:
```go
// admin_repository.go 管理后台只读仓储（回放/审计查询）
package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/service/admin"
)

// AdminRepository admin.Store 的 pgx 实现
type AdminRepository struct {
	db *pgxpool.Pool
}

// NewAdminRepository 创建管理后台仓储
func NewAdminRepository() *AdminRepository {
	return &AdminRepository{db: database.GetDB()}
}

var _ admin.Store = (*AdminRepository)(nil)

// ListAgentSessions 分页列出会话（含消息数、累计 LLM token）
func (r *AdminRepository) ListAgentSessions(ctx context.Context, f admin.ListFilter) ([]admin.SessionRow, int32, error) {
	if f.Page < 1 {
		f.Page = 1
	}
	if f.PageSize < 1 || f.PageSize > 100 {
		f.PageSize = 20
	}
	offset := (f.Page - 1) * f.PageSize

	const q = `
		SELECT s.id, s.device_id, s.status, COALESCE(s.intent,''),
		       s.created_at::text, s.last_active_at::text,
		       (SELECT COUNT(*) FROM agent_message m WHERE m.session_id = s.id),
		       COALESCE((SELECT SUM(COALESCE(prompt_tokens,0)+COALESCE(completion_tokens,0))
		                 FROM agent_trace t WHERE t.session_id = s.id AND t.kind='llm'), 0)
		FROM agent_session s
		WHERE ($1 = '' OR s.created_at >= $1::timestamp)
		  AND ($2 = '' OR s.created_at <= $2::timestamp)
		  AND ($3 = '' OR s.device_id = $3)
		  AND ($4 = '' OR s.intent = $4)
		ORDER BY s.created_at DESC
		LIMIT $5 OFFSET $6`
	rows, err := r.db.Query(ctx, q, f.TimeFrom, f.TimeTo, f.DeviceID, f.Intent, f.PageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("admin list sessions: %w", err)
	}
	defer rows.Close()

	out := make([]admin.SessionRow, 0, f.PageSize)
	for rows.Next() {
		var r2 admin.SessionRow
		if err := rows.Scan(&r2.SessionID, &r2.DeviceID, &r2.Status, &r2.Intent,
			&r2.CreatedAt, &r2.LastActiveAt, &r2.MessageCount, &r2.TotalTokens); err != nil {
			return nil, 0, fmt.Errorf("admin list sessions scan: %w", err)
		}
		out = append(out, r2)
	}
	if err := rows.Err(); err != nil {
		return nil, 0, err
	}

	var total int32
	const cq = `SELECT COUNT(*) FROM agent_session s
		WHERE ($1='' OR s.created_at >= $1::timestamp)
		  AND ($2='' OR s.created_at <= $2::timestamp)
		  AND ($3='' OR s.device_id = $3)
		  AND ($4='' OR s.intent = $4)`
	if err := r.db.QueryRow(ctx, cq, f.TimeFrom, f.TimeTo, f.DeviceID, f.Intent).Scan(&total); err != nil {
		return nil, 0, fmt.Errorf("admin count sessions: %w", err)
	}
	return out, total, nil
}

// GetSessionReplay 取单会话回放全量数据（消息/trace/checkpoint 按时间）
func (r *AdminRepository) GetSessionReplay(ctx context.Context, sessionID int64) (*admin.ReplayBundle, error) {
	b := &admin.ReplayBundle{}

	// 1) 会话元信息
	const sq = `SELECT id, device_id, status, COALESCE(intent,''), created_at::text
	            FROM agent_session WHERE id = $1`
	if err := r.db.QueryRow(ctx, sq, sessionID).Scan(
		&b.Session.SessionID, &b.Session.DeviceID, &b.Session.Status,
		&b.Session.Intent, &b.Session.CreatedAt); err != nil {
		return nil, fmt.Errorf("admin replay session: %w", err)
	}

	// 2) 消息
	mrows, err := r.db.Query(ctx, `
		SELECT role, content, COALESCE(node,''), created_at::text, COALESCE(usage::text,'')
		FROM agent_message WHERE session_id = $1 ORDER BY id`, sessionID)
	if err != nil {
		return nil, fmt.Errorf("admin replay messages: %w", err)
	}
	defer mrows.Close()
	for mrows.Next() {
		var m admin.ReplayMessage
		if err := mrows.Scan(&m.Role, &m.Content, &m.Node, &m.CreatedAt, &m.UsageJSON); err != nil {
			return nil, err
		}
		b.Messages = append(b.Messages, m)
	}

	// 3) trace
	trows, err := r.db.Query(ctx, `
		SELECT kind, COALESCE(name,''), COALESCE(input::text,''), COALESCE(output::text,''),
		       COALESCE(prompt_tokens,0), COALESCE(completion_tokens,0), COALESCE(latency_ms,0), created_at::text
		FROM agent_trace WHERE session_id = $1 ORDER BY id`, sessionID)
	if err != nil {
		return nil, fmt.Errorf("admin replay traces: %w", err)
	}
	defer trows.Close()
	for trows.Next() {
		var t admin.ReplayTrace
		if err := trows.Scan(&t.Kind, &t.Name, &t.InputJSON, &t.OutputJSON,
			&t.PromptTokens, &t.CompletionTokens, &t.LatencyMs, &t.CreatedAt); err != nil {
			return nil, err
		}
		b.Traces = append(b.Traces, t)
	}

	// 4) checkpoint
	crows, err := r.db.Query(ctx, `
		SELECT step_seq, node, COALESCE(state::text,''), created_at::text
		FROM agent_checkpoint WHERE session_id = $1 ORDER BY step_seq`, sessionID)
	if err != nil {
		return nil, fmt.Errorf("admin replay checkpoints: %w", err)
	}
	defer crows.Close()
	for crows.Next() {
		var c admin.ReplayCheckpoint
		if err := crows.Scan(&c.StepSeq, &c.Node, &c.StateJSON, &c.CreatedAt); err != nil {
			return nil, err
		}
		b.Checkpoints = append(b.Checkpoints, c)
	}
	return b, nil
}
```

- [ ] **Step 3: 写集成测试（无 DB 自动跳过）**

Create `backend/internal/repository/admin_repository_test.go`:
```go
package repository

import (
	"context"
	"testing"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/service/admin"
)

// 集成测试：需要可达的 Postgres（database.GetDB 初始化过）。
// 无 DB 时跳过，不阻断 CI。
func TestAdminRepository_Smoke(t *testing.T) {
	if database.GetDB() == nil {
		t.Skip("database not initialized; skipping admin repository integration test")
	}
	r := NewAdminRepository()
	ctx := context.Background()

	// 列表：取第 1 页（库可能为空，只验不报错）
	rows, total, err := r.ListAgentSessions(ctx, admin.ListFilter{Page: 1, PageSize: 5})
	if err != nil {
		t.Fatalf("ListAgentSessions: %v", err)
	}
	if total < 0 {
		t.Fatalf("total = %d", total)
	}
	_ = rows

	// 若有会话，回放第一条
	if total > 0 {
		b, err := r.GetSessionReplay(ctx, rows[0].SessionID)
		if err != nil {
			t.Fatalf("GetSessionReplay: %v", err)
		}
		if b.Session.SessionID != rows[0].SessionID {
			t.Fatalf("session mismatch")
		}
	}
}
```
> 注:本测试需先初始化 DB 连接。执行时可加 `TestMain` 调 `database.Connect(cfg)`(若仓储测试包尚未有)。如已有 district_repository_test.go 走真实库,沿用其初始化方式;否则保留 skip 守卫,SQL 正确性靠 Task 11 端到端验证。

- [ ] **Step 4: 编译 + 跑测试**

Run:
```bash
cd backend && go build ./internal/repository/ ./internal/service/admin/ && go test ./internal/repository/ -run AdminRepository -v
```
Expected: 编译通过;集成测试 PASS 或 SKIP。

- [ ] **Step 5: Commit**

```bash
git add backend/internal/service/admin/store.go backend/internal/repository/admin_repository.go backend/internal/repository/admin_repository_test.go
git commit -m "feat(admin): 回放只读仓储——ListAgentSessions + GetSessionReplay" -m "admin.Store 接口 + pgx 实现（直查 agent_session/message/trace/checkpoint）。集成测试无 DB 跳过。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 6: admin_service.proto + buf 生成

**Files:**
- Create: `proto/highschool/v1/admin_service.proto`
- Modify: `proto/buf.gen.yaml`
- Create: `admin/src/`（目录,供 buf 写入 TS 生成码）

**Interfaces:**
- Produces:`AdminService` Connect 服务;Go 类型 `highschoolv1.AdminService*`、`highschoolv1connect.NewAdminServiceHandler`;TS 客户端 `admin/src/gen/highschool/v1/admin_service_connect.ts`。

- [ ] **Step 1: 写 proto**

Create `proto/highschool/v1/admin_service.proto`:
```proto
syntax = "proto3";

package highschool.v1;

option go_package = "github.com/highschool/backend/gen/highschool/v1;highschoolv1";

// 管理后台服务（单管理员 cookie 鉴权；设计文档 docs/superpowers/specs/2026-08-10-admin-console-design.md）
service AdminService {
  // 会话列表（分页）
  rpc ListAgentSessions(ListAgentSessionsRequest) returns (ListAgentSessionsResponse);
  // 单会话回放（消息/trace/checkpoint 全量）
  rpc GetSessionReplay(GetSessionReplayRequest) returns (GetSessionReplayResponse);
}

message ListAgentSessionsRequest {
  string time_from = 1;   // 含；空不过滤；RFC3339 或 'YYYY-MM-DD'
  string time_to = 2;
  string device_id = 3;
  string intent = 4;
  int32 page = 5;         // 从 1 起
  int32 page_size = 6;
}

message AgentSessionRow {
  int64 session_id = 1;
  string device_id = 2;
  string status = 3;
  string intent = 4;
  string created_at = 5;
  string last_active_at = 6;
  int32 message_count = 7;
  int64 total_tokens = 8;
}

message ListAgentSessionsResponse {
  repeated AgentSessionRow items = 1;
  int32 total = 2;
}

message GetSessionReplayRequest {
  int64 session_id = 1;
}

message ReplaySession {
  int64 session_id = 1;
  string device_id = 2;
  string status = 3;
  string intent = 4;
  string created_at = 5;
}

message ReplayMessage {
  string role = 1;
  string content = 2;
  string node = 3;
  string created_at = 4;
  string usage_json = 5;
}

message ReplayTrace {
  string kind = 1;
  string name = 2;
  string input_json = 3;
  string output_json = 4;
  int32 prompt_tokens = 5;
  int32 completion_tokens = 6;
  int32 latency_ms = 7;
  string created_at = 8;
}

message ReplayCheckpoint {
  int32 step_seq = 1;
  string node = 2;
  string state_json = 3;
  string created_at = 4;
}

message GetSessionReplayResponse {
  ReplaySession session = 1;
  repeated ReplayMessage messages = 2;
  repeated ReplayTrace traces = 3;
  repeated ReplayCheckpoint checkpoints = 4;
}
```

- [ ] **Step 2: buf.gen.yaml 加 admin TS 输出（es + connectrpc 两条）**

在 `proto/buf.gen.yaml` 的 `plugins:` 下,现有 frontend 的两条 TS remote 之后,为 admin 各加一条指向 `../admin/src/gen`。connectrpc/es 客户端依赖 bufbuild/es 的消息类型,必须两条都加:
```yaml
  # 生成 TypeScript protobuf 消息类型 (用于管理后台 admin/)
  - remote: buf.build/bufbuild/es:v1.7.2
    out: ../admin/src/gen
    opt: target=ts
  # 生成 TypeScript Connect 代码 (用于管理后台 admin/)
  - remote: buf.build/connectrpc/es:v1.4.0
    out: ../admin/src/gen
    opt: target=ts
```

- [ ] **Step 3: 建 admin/src 目录并生成**

Run:
```bash
mkdir -p admin/src/gen
cd proto && buf generate
```
Expected: 生成 `backend/gen/highschool/v1/admin_service.pb.go`、`admin_service_connect.go`、`admin/src/gen/highschool/v1/admin_service_connect.ts`。

- [ ] **Step 4: 验证生成物**

Run:
```bash
ls backend/gen/highschool/v1/admin_service_connect.go && ls admin/src/gen/highschool/v1/admin_service_connect.ts
```
Expected: 两个文件都存在。

- [ ] **Step 5: Commit**

```bash
git add proto/highschool/v1/admin_service.proto proto/buf.gen.yaml backend/gen/ admin/src/gen/
git commit -m "feat(admin): admin_service.proto + buf 生成（Go + TS Connect 客户端）" -m "ListAgentSessions / GetSessionReplay 两个 RPC。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 7: AdminServiceHandler + RegisterAdminService

**Files:**
- Create: `backend/internal/api/v1/admin_connect.go`
- Test: `backend/internal/api/v1/admin_connect_test.go`

**Interfaces:**
- Consumes: `admin.Store`、`highschoolv1connect.NewAdminServiceHandler`、`newAdminAuthInterceptor`。
- Produces:`NewAdminServiceHandler(store admin.Store)`、`RegisterAdminService(mux, otelInterceptor, secret string, store admin.Store)`。

- [ ] **Step 1: 写失败测试**

Create `backend/internal/api/v1/admin_connect_test.go`:
```go
package v1

import (
	"context"
	"errors"
	"testing"

	"highschool-backend/internal/service/admin"
)

// fakeAdminStore 内存实现 admin.Store
type fakeAdminStore struct {
	sessions []admin.SessionRow
	replay   *admin.ReplayBundle
	err      error
}

func (f *fakeAdminStore) ListAgentSessions(ctx context.Context, fl admin.ListFilter) ([]admin.SessionRow, int32, error) {
	if f.err != nil {
		return nil, 0, f.err
	}
	return f.sessions, int32(len(f.sessions)), nil
}
func (f *fakeAdminStore) GetSessionReplay(ctx context.Context, id int64) (*admin.ReplayBundle, error) {
	if f.err != nil {
		return nil, f.err
	}
	return f.replay, nil
}

func TestAdminHandler_ListSessions(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{
		sessions: []admin.SessionRow{{SessionID: 7, DeviceID: "dev", Intent: "data_query"}},
	})
	out, total, err := h.listSessions(context.Background(), admin.ListFilter{Page: 1, PageSize: 10})
	if err != nil {
		t.Fatalf("listSessions: %v", err)
	}
	if total != 1 || out[0].SessionID != 7 {
		t.Fatalf("unexpected: %v total=%d", out, total)
	}
}

func TestAdminHandler_StoreError(t *testing.T) {
	h := NewAdminServiceHandler(&fakeAdminStore{err: errors.New("db down")})
	if _, _, err := h.listSessions(context.Background(), admin.ListFilter{Page: 1}); err == nil {
		t.Fatal("store error must propagate")
	}
}
```

- [ ] **Step 2: 跑测试确认失败**

Run:
```bash
cd backend && go test ./internal/api/v1/ -run AdminHandler -v
```
Expected: FAIL(`NewAdminServiceHandler` 未定义)。

- [ ] **Step 3: 写实现**

Create `backend/internal/api/v1/admin_connect.go`:
```go
// admin_connect.go - 管理后台 Admin 服务处理器（协议转换）
package v1

import (
	"context"
	"net/http"

	"connectrpc.com/connect"
	"connectrpc.com/otelconnect"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschoolv1connect "highschool-backend/gen/highschool/v1/highschoolv1connect"
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

// listSessions 内部：转调 store（便于单测，不经 connect 层）
func (h *AdminServiceHandler) listSessions(ctx context.Context, f admin.ListFilter) ([]admin.SessionRow, int32, error) {
	return h.store.ListAgentSessions(ctx, f)
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
```

- [ ] **Step 4: 跑测试确认通过**

Run:
```bash
cd backend && go test ./internal/api/v1/ -run AdminHandler -v
```
Expected: 2 例 PASS。

- [ ] **Step 5: Commit**

```bash
git add backend/internal/api/v1/admin_connect.go backend/internal/api/v1/admin_connect_test.go
git commit -m "feat(admin): AdminServiceHandler + 注册（挂鉴权 interceptor）" -m "ListAgentSessions / GetSessionReplay；fake store 单测。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 8: 登录 handler + SPA 静态托管 + main.go 装配

**Files:**
- Create: `backend/internal/api/v1/admin_dist/index.html`
- Create: `backend/internal/api/v1/admin_static.go`
- Create: `backend/internal/api/v1/admin_login.go`
- Modify: `backend/cmd/api/main.go`

**Interfaces:**
- Consumes:`auth.VerifyPassword`/`auth.SignSession`、`config.AdminConfig`、`RegisterAdminService`、`repository.NewAdminRepository`。
- Produces:`/admin/api/login`(POST)、`/admin/*`(静态 SPA)。

- [ ] **Step 1: 占位 index.html（保证 go:embed 在前端未构建时也能编译）**

Create `backend/internal/api/v1/admin_dist/index.html`:
```html
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="utf-8"><title>管理后台</title></head>
<body>
  <p>管理后台前端尚未构建（运行 <code>npm run build</code> 于 admin/，或开发模式 <code>npm run dev</code>）。</p>
</body>
</html>
```

- [ ] **Step 2: SPA 静态托管（embed + 回落 index.html）**

Create `backend/internal/api/v1/admin_static.go`:
```go
package v1

import (
	"embed"
	"io/fs"
	"net/http"
	"strings"
)

//go:embed admin_dist/*
var adminDist embed.FS

// AdminSPAHandler 托管管理后台 SPA；找不到的子路径回落 index.html（客户端路由）。
func AdminSPAHandler() http.Handler {
	sub, _ := fs.Sub(adminDist, "admin_dist")
	fileServer := http.FileServer(http.FS(sub))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// 客户端路由路径（如 /admin/replay/7）回落到 index.html
		if _, err := fs.Stat(sub, strings.TrimPrefix(r.URL.Path, "/")); err != nil {
			r.URL.Path = "/"
		}
		fileServer.ServeHTTP(w, r)
	})
}
```

- [ ] **Step 3: 登录 handler**

Create `backend/internal/api/v1/admin_login.go`:
```go
package v1

import (
	"encoding/json"
	"net/http"
	"time"

	"highschool-backend/pkg/auth"
	"highschool-backend/pkg/config"
)

// NewAdminLoginHandler POST /admin/api/login {password} → 设 admin_sess cookie。
// 未配置 password_hash/cookie_secret 时返回 503。
func NewAdminLoginHandler(cfg *config.Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if cfg.Admin.PasswordHash == "" || cfg.Admin.CookieSecret == "" {
			http.Error(w, "admin disabled", http.StatusServiceUnavailable)
			return
		}
		var body struct {
			Password string `json:"password"`
		}
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}
		if !auth.VerifyPassword(cfg.Admin.PasswordHash, body.Password) {
			http.Error(w, "invalid credentials", http.StatusUnauthorized)
			return
		}
		ttl := time.Duration(cfg.Admin.SessionTTLHours) * time.Hour
		if ttl == 0 {
			ttl = 12 * time.Hour
		}
		token := auth.SignSession(cfg.Admin.CookieSecret, "admin", time.Now().Add(ttl))
		http.SetCookie(w, &http.Cookie{
			Name: adminCookieName, Value: token, Path: "/",
			HttpOnly: true, MaxAge: int(ttl.Seconds()), SameSite: http.SameSiteLaxMode,
		})
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]bool{"ok": true})
	}
}
```

- [ ] **Step 4: main.go 装配**

在 `backend/cmd/api/main.go` 的 `v1.RegisterAgentService(mux, otelInterceptor)` 行之后,加（需确认 `cfg` 变量名——参考现有 `cfg, _ := config.Load()` 或类似;以实际为准）:
```go
	// 管理后台：AdminService（cookie 鉴权）+ 登录 + SPA 静态
	v1.RegisterAdminService(mux, otelInterceptor, cfg.Admin.CookieSecret, repository.NewAdminRepository())
	mux.HandleFunc("/admin/api/login", v1.NewAdminLoginHandler(cfg))
	mux.Handle("/admin/", http.StripPrefix("/admin/", v1.AdminSPAHandler()))
	mux.HandleFunc("/admin", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/admin/", http.StatusFound)
	})
```
> 确保 `cfg` 在该作用域可见（现有代码已在 main 中 `config.Load()`）;若变量名不同,对齐即可。`repository` 包应已被 import（agent 服务已用）。

- [ ] **Step 5: 编译**

Run:
```bash
cd backend && go build ./...
```
Expected: 无报错。

- [ ] **Step 6: 启动 + 冒烟测试**

先准备本地 env（生成一个 bcrypt 哈希）:
```bash
cd backend && HS_ADMIN_PASSWORD_HASH=$(go run ./cmd/genhash 2>/dev/null || echo '') HS_ADMIN_COOKIE_SECRET=dev-secret-1234 HS_DATABASE_HOST=192.168.71.160 make run &
```
> 若无 genhash 工具,改用一次性:在 `backend/cmd/genhash/main.go` 临时写 `fmt.Println(auth.HashPassword(os.Args[1]))` 跑一次,或用 `htpasswd -bnBC 10 "" 'mypass' | tr -d ':\n'`。

冒烟:
```bash
curl -s -X POST http://localhost:3000/admin/api/login -d '{"password":"mypass"}' -i | grep -E "HTTP/|Set-Cookie|ok"
curl -s http://localhost:3000/admin/ | head -1
curl -s http://localhost:3000/highschool.v1.AdminService/ListAgentSessions -X POST \
  -H 'Content-Type: application/json' -d '{}' -i | grep -E "HTTP/|unauthenticated"
```
Expected: login 返回 200 + Set-Cookie;`/admin/` 返回占位 HTML;未带 cookie 调 RPC 返回 401 unauthenticated。

- [ ] **Step 7: Commit**

```bash
git add backend/internal/api/v1/admin_dist/ backend/internal/api/v1/admin_static.go backend/internal/api/v1/admin_login.go backend/cmd/api/main.go
git commit -m "feat(admin): 登录 handler + SPA 静态托管 + main.go 装配" -m "/admin/api/login 设 cookie；/admin/* 托管 go:embed SPA；AdminService 挂鉴权。冒烟：未带 cookie → 401。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 9: admin/ 前端脚手架

**Files:**
- Create: `admin/package.json`、`admin/vite.config.ts`、`admin/tsconfig.json`、`admin/tsconfig.node.json`、`admin/index.html`、`admin/src/main.ts`、`admin/src/App.vue`、`admin/src/env.d.ts`

**Interfaces:** 无（仅脚手架）。

- [ ] **Step 1: package.json**

Create `admin/package.json`:
```json
{
  "name": "highschool-admin",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vue-tsc -b && vite build",
    "type-check": "vue-tsc --noEmit"
  },
  "dependencies": {
    "@bufbuild/protobuf": "^1.10.0",
    "@connectrpc/connect": "^1.4.0",
    "@connectrpc/connect-web": "^1.4.0",
    "element-plus": "^2.8.0",
    "pinia": "^2.2.0",
    "vue": "^3.5.0",
    "vue-router": "^4.4.0"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.1.0",
    "typescript": "^5.5.0",
    "vite": "^5.4.0",
    "vue-tsc": "^2.1.0"
  }
}
```

- [ ] **Step 2: vite.config.ts（dev 代理到后端 3000）**

Create `admin/vite.config.ts`:
```ts
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  base: "/admin/",
  server: {
    port: 5174,
    proxy: {
      "/highschool.v1": { target: "http://localhost:3000", changeOrigin: true },
      "/admin/api": { target: "http://localhost:3000", changeOrigin: true },
    },
  },
  build: { outDir: "../backend/internal/api/v1/admin_dist", emptyOutDir: true },
});
```
> `build.outDir` 直接产出到后端 embed 目录,`npm run build` 后后端即可托管真实 SPA。

- [ ] **Step 3: tsconfig + index.html + main.ts + App.vue**

Create `admin/tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "jsx": "preserve",
    "types": ["vite/client"],
    "skipLibCheck": true,
    "esModuleInterop": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.vue"]
}
```

Create `admin/tsconfig.node.json`:
```json
{ "compilerOptions": { "composite": true }, "include": ["vite.config.ts"] }
```

Create `admin/index.html`:
```html
<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>管理后台</title></head>
<body><div id="app"></div><script type="module" src="/src/main.ts"></script></body>
</html>
```

Create `admin/src/env.d.ts`:
```ts
/// <reference types="vite/client" />
declare module "*.vue" { import type { DefineComponent } from "vue"; const c: DefineComponent<{}, {}, any>; export default c; }
```

Create `admin/src/main.ts`:
```ts
import { createApp } from "vue";
import { createPinia } from "pinia";
import ElementPlus from "element-plus";
import "element-plus/dist/index.css";
import App from "./App.vue";
import router from "./router";

createApp(App).use(createPinia()).use(router).use(ElementPlus).mount("#app");
```

Create `admin/src/App.vue`:
```vue
<template><router-view /></template>
```

- [ ] **Step 4: 安装依赖 + 类型检查**

Run:
```bash
cd admin && npm install && npm run type-check
```
Expected: 依赖装好;type-check 报 `router` 缺失(Task 10 创建)——可暂忽略,或先建空 router 占位。为通过,先建 `admin/src/router/index.ts` 占位:
```ts
import { createRouter, createWebHistory } from "vue-router";
const router = createRouter({ history: createWebHistory("/admin/"), routes: [] });
export default router;
```
再 `npm run type-check` → 通过。

- [ ] **Step 5: Commit**

```bash
git add admin/package.json admin/vite.config.ts admin/tsconfig.json admin/tsconfig.node.json admin/index.html admin/src/
git commit -m "feat(admin): Vue3 + Vite + Element Plus 脚手架" -m "dev 代理到 :3000；build 产物直出 backend embed 目录。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 10: 登录页 + 路由守卫 + 布局壳子

**Files:**
- Create: `admin/src/api/client.ts`、`admin/src/stores/auth.ts`、`admin/src/views/Login.vue`、`admin/src/layouts/AdminLayout.vue`
- Modify: `admin/src/router/index.ts`

**Interfaces:**
- Produces:`adminClient`(Connect 客户端,`credentials: include`)、`authStore`、登录后跳 `/sessions`。

- [ ] **Step 1: Connect 客户端**

Create `admin/src/api/client.ts`:
```ts
import { createClient } from "@connectrpc/connect";
import { createConnectTransport } from "@connectrpc/connect-web";
import { AdminService } from "../gen/highschool/v1/admin_service_connect";

const transport = createConnectTransport({
  baseUrl: "/",
  fetchOptions: { credentials: "include" },
});

export const adminClient = createClient(AdminService, transport);

export async function login(password: string): Promise<void> {
  const res = await fetch("/admin/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify({ password }),
  });
  if (!res.ok) throw new Error("登录失败：" + res.status);
}
```

- [ ] **Step 2: auth store**

Create `admin/src/stores/auth.ts`:
```ts
import { defineStore } from "pinia";
import { ref } from "vue";
import { login as doLogin } from "../api/client";

export const useAuthStore = defineStore("auth", () => {
  const loggedIn = ref(false);
  async function login(password: string) {
    await doLogin(password);
    loggedIn.value = true;
  }
  function logout() { loggedIn.value = false; }
  return { loggedIn, login, logout };
});
```

- [ ] **Step 3: 登录页**

Create `admin/src/views/Login.vue`:
```vue
<template>
  <div style="max-width:320px;margin:80px auto">
    <h3>管理后台登录</h3>
    <el-input v-model="password" type="password" placeholder="密码" @keyup.enter="submit" />
    <el-button type="primary" style="margin-top:12px;width:100%" :loading="loading" @click="submit">登录</el-button>
    <p v-if="err" style="color:red;margin-top:8px">{{ err }}</p>
  </div>
</template>
<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "../stores/auth";
import { ElInput, ElButton } from "element-plus";

const password = ref("");
const loading = ref(false);
const err = ref("");
const router = useRouter();
const auth = useAuthStore();

async function submit() {
  loading.value = true; err.value = "";
  try { await auth.login(password.value); router.push("/sessions"); }
  catch (e: any) { err.value = e.message ?? "登录失败"; }
  finally { loading.value = false; }
}
</script>
```

- [ ] **Step 4: 布局壳子**

Create `admin/src/layouts/AdminLayout.vue`:
```vue
<template>
  <el-container style="height:100vh">
    <el-aside width="180px" style="background:#f5f7fa;padding:12px">
      <h4 style="margin:8px 0">管理后台</h4>
      <el-menu :router="true" default-active="/sessions">
        <el-menu-item index="/sessions">会话回放</el-menu-item>
      </el-menu>
    </el-aside>
    <el-main><router-view /></el-main>
  </el-container>
</template>
<script setup lang="ts">
import { ElContainer, ElAside, ElMain, ElMenu, ElMenuItem } from "element-plus";
</script>
```

- [ ] **Step 5: 路由 + 守卫**

Replace `admin/src/router/index.ts`:
```ts
import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "../stores/auth";

const router = createRouter({
  history: createWebHistory("/admin/"),
  routes: [
    { path: "/login", component: () => import("../views/Login.vue") },
    {
      path: "/",
      component: () => import("../layouts/AdminLayout.vue"),
      children: [
        { path: "sessions", component: () => import("../views/SessionList.vue") },
        { path: "replay/:id", component: () => import("../views/SessionReplay.vue") },
      ],
    },
  ],
});

router.beforeEach((to) => {
  const auth = useAuthStore();
  if (!auth.loggedIn && to.path !== "/login") return "/login";
});

export default router;
```

- [ ] **Step 6: 启动 dev，手测登录**

```bash
cd admin && npm run dev
```
浏览器开 `http://localhost:5174/admin/`,应跳转 `/admin/login`;输错密码报错。(SessionList/SessionReplay 在 Task 11 创建,此刻跳 `/sessions` 会 404 路由——正常。)

- [ ] **Step 7: Commit**

```bash
git add admin/src/
git commit -m "feat(admin): 登录页 + 路由守卫 + 布局壳子" -m "Connect 客户端 credentials:include；未登录跳 /login。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 11: 会话列表页 + 回放时间线页

**Files:**
- Create: `admin/src/views/SessionList.vue`、`admin/src/views/SessionReplay.vue`

**Interfaces:**
- Consumes:`adminClient.listAgentSessions`、`adminClient.getSessionReplay`。

- [ ] **Step 1: 会话列表页**

Create `admin/src/views/SessionList.vue`:
```vue
<template>
  <div>
    <el-table :data="rows" v-loading="loading" @row-click="go" style="cursor:pointer">
      <el-table-column prop="sessionId" label="会话" width="80" />
      <el-table-column prop="deviceId" label="设备" width="120" />
      <el-table-column prop="intent" label="意图" width="140" />
      <el-table-column prop="status" label="状态" width="110" />
      <el-table-column prop="messageCount" label="消息数" width="90" />
      <el-table-column prop="totalTokens" label="Token" width="110" />
      <el-table-column prop="createdAt" label="创建时间" />
    </el-table>
    <el-pagination style="margin-top:12px" :current-page="page" :page-size="20" :total="total" layout="prev, pager, next" @current-change="onPage" />
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { adminClient } from "../api/client";
import { ElTable, ElTableColumn, ElPagination } from "element-plus";

const rows = ref<any[]>([]);
const total = ref(0);
const page = ref(1);
const loading = ref(false);
const router = useRouter();

async function load() {
  loading.value = true;
  try {
    const res = await adminClient.listAgentSessions({ page: page.value, pageSize: 20 });
    rows.value = res.items as any[];
    total.value = res.total;
  } finally { loading.value = false; }
}
function onPage(p: number) { page.value = p; load(); }
function go(row: any) { router.push("/replay/" + row.sessionId); }
onMounted(load);
</script>
```

- [ ] **Step 2: 回放时间线页**

Create `admin/src/views/SessionReplay.vue`:
```vue
<template>
  <div v-loading="loading">
    <el-page-header @back="$router.back()" :content="`会话 #${id}`" style="margin-bottom:12px" />
    <el-tabs v-model="tab">
      <el-tab-pane label="时间线" name="timeline">
        <el-timeline>
          <el-timeline-item v-for="e in timeline" :key="e.id" :timestamp="e.ts" :type="e.t" placement="top">
            <strong>[{{ e.kind }}]</strong> <span v-if="e.title">{{ e.title }}</span>
            <pre v-if="e.body" style="white-space:pre-wrap;background:#f6f8fa;padding:8px;margin-top:4px">{{ e.body }}</pre>
          </el-timeline-item>
        </el-timeline>
      </el-tab-pane>
      <el-tab-pane label="消息" name="messages">
        <div v-for="(m,i) in bundle.messages" :key="i" style="margin-bottom:10px">
          <el-tag size="small">{{ m.role }}</el-tag>
          <span style="color:#999;margin-left:8px">{{ m.createdAt }}</span>
          <div style="white-space:pre-wrap">{{ m.content }}</div>
        </div>
      </el-tab-pane>
      <el-tab-pane label="Trace" name="traces">
        <el-collapse>
          <el-collapse-item v-for="(t,i) in bundle.traces" :key="i" :name="i" :title="`[${t.kind}] ${t.name} · ${t.latencyMs}ms · ${t.promptTokens+t.completionTokens}tok`">
            <div><b>in:</b><pre style="white-space:pre-wrap">{{ fmt(t.inputJson) }}</pre></div>
            <div><b>out:</b><pre style="white-space:pre-wrap">{{ fmt(t.outputJson) }}</pre></div>
          </el-collapse-item>
        </el-collapse>
      </el-tab-pane>
      <el-tab-pane label="Checkpoint" name="checkpoints">
        <el-collapse>
          <el-collapse-item v-for="(c,i) in bundle.checkpoints" :key="i" :name="i" :title="`#${c.stepSeq} ${c.node}`">
            <pre style="white-space:pre-wrap">{{ fmt(c.stateJson) }}</pre>
          </el-collapse-item>
        </el-collapse>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useRoute } from "vue-router";
import { adminClient } from "../api/client";
import { ElTabs, ElTabPane, ElTimeline, ElTimelineItem, ElTag, ElCollapse, ElCollapseItem, ElPageHeader } from "element-plus";

const route = useRoute();
const id = Number(route.params.id);
const loading = ref(false);
const bundle = ref<any>({ messages: [], traces: [], checkpoints: [] });

// 合并时间线：消息 + trace 按时间
const timeline = computed(() => {
  const items: any[] = [];
  (bundle.value.messages || []).forEach((m: any) => items.push({ id: "m" + m.createdAt, ts: m.createdAt, kind: "msg:" + m.role, title: m.content?.slice(0, 60), t: "primary" }));
  (bundle.value.traces || []).forEach((t: any) => items.push({ id: "t" + t.createdAt, ts: t.createdAt, kind: t.kind, title: `${t.name} · ${t.latencyMs}ms`, body: t.outputJson?.slice(0, 300), t: t.outputJson?.includes("error") ? "danger" : "success" }));
  return items.sort((a, b) => (a.ts > b.ts ? 1 : -1));
});
const tab = ref("timeline");

function fmt(s: string) { try { return JSON.stringify(JSON.parse(s), null, 2); } catch { return s; } }

async function load() {
  loading.value = true;
  try { bundle.value = await adminClient.getSessionReplay({ sessionId: id }); }
  finally { loading.value = false; }
}
onMounted(load);
</script>
```

- [ ] **Step 3: 类型检查 + 构建**

Run:
```bash
cd admin && npm run type-check && npm run build
```
Expected: 类型通过;构建产物写入 `backend/internal/api/v1/admin_dist/`(覆盖占位)。

- [ ] **Step 4: 端到端验证（后端托管真实 SPA）**

启动后端(带 admin env),浏览器开 `http://localhost:3000/admin/`:
- 登录 → 跳会话列表 → 点任一会话 → 看 4 个 tab(时间线/消息/Trace/Checkpoint)有数据。

若库无 agent 数据,先在小程序里产生一轮 AI 顾问对话再刷新列表。

- [ ] **Step 5: Commit**

```bash
git add admin/src/views/SessionList.vue admin/src/views/SessionReplay.vue backend/internal/api/v1/admin_dist/
git commit -m "feat(admin): 会话列表 + 回放时间线（消息/trace/checkpoint）" -m "端到端：登录→列表→回放 4-tab。build 产物已进 embed 目录。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Task 12: 生产构建集成（Dockerfile 多阶段）

**Files:**
- Modify: `backend/Dockerfile`

**Interfaces:** 无。

- [ ] **Step 1: 读现有 Dockerfile**

Run:
```bash
sed -n '1,60p' backend/Dockerfile
```
了解现有 Go 构建阶段与 `GOTOOLCHAIN=auto` 等设置(见近期 commit `05ecf79`)。

- [ ] **Step 2: 加 Node 构建阶段，产物写入 embed 目录**

在现有 Dockerfile **顶部**加 Node 阶段,并在 Go 阶段 `COPY --from=admin-build`:
```dockerfile
# ---- admin 前端构建 ----
FROM node:20-alpine AS admin-build
WORKDIR /app
COPY admin/package.json admin/package-lock.json* ./
RUN npm install
COPY admin/ ./
# 产物直出 backend embed 目录（vite build.outDir 配置）
RUN npm run build

# ---- 原有 Go 构建阶段（保留现有内容，仅插入一行 COPY） ----
# ... 现有 FROM golang ... 阶段 ...
# 在 go build 之前加：
COPY --from=admin-build /app/../backend/internal/api/v1/admin_dist ./internal/api/v1/admin_dist
```
> 路径以现有 Dockerfile 的 `context`(`./backend`)与 WORKDIR 为准调整:`admin/` 在仓库根,但 Docker context 是 `./backend`,所以需把 context 提到仓库根或用多 context。**若 context 仍为 `./backend`**,改 docker-compose 的 `context: .`(仓库根)+ `dockerfile: backend/Dockerfile`,并在 COPY 用 `admin/` 与 `backend/` 全路径。执行时据实际调整,目标是让 Node 阶段访问 `admin/`,Go 阶段 `COPY --from=admin-build` 拿到 `admin_dist`。

- [ ] **Step 3: 本地构建镜像冒烟**

Run:
```bash
docker build -t highschool-admin-test -f backend/Dockerfile .
```
Expected: 构建成功(Node + Go 两阶段)。

- [ ] **Step 4: Commit**

```bash
git add backend/Dockerfile
git commit -m "feat(admin): Dockerfile 多阶段——node 构建 admin → go embed" -m "单二进制内嵌管理后台 SPA。

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
```

---

## Self-Review（已完成）

**1. Spec 覆盖(P1 范围):**
- 鉴权/登录 → Task 2(config)+ Task 3(auth)+ Task 4(interceptor)+ Task 8(login handler)✓
- SPA 壳子 → Task 9 + Task 10 ✓
- AdminService 骨架 → Task 6(proto)+ Task 7(handler)✓
- 静态托管 → Task 8 ✓
- `agent_alert` 表 → Task 1 ✓
- 只读查询层 → Task 5 ✓
- `ListAgentSessions`/`GetSessionReplay` → Task 5 + Task 6 + Task 7 ✓
- 回放 UI → Task 11 ✓
- 生产构建 → Task 12 ✓
- P2(成本看板)/P3(告警)/P4(开关)不在本计划,后续。

**2. 占位符扫描:** Task 8 Step 6 提到 `cmd/genhash` 为可选辅助(给出生成命令);Task 12 标注 Docker context 需据实际调整——均为可执行指引,非 TBD。

**3. 类型一致性:** `admin.SessionRow`/`ReplayBundle` 字段在 Task 5 定义、Task 7 handler 映射到 proto(Task 6)字段名一致(`SessionId`/`DeviceId`/`UsageJson` 等 proto 生成驼峰)。`adminCookieName` 在 Task 4 定义、Task 8 login 引用一致。

---

## 执行手off

Plan saved to `docs/superpowers/plans/2026-08-10-admin-console-p1.md`。
