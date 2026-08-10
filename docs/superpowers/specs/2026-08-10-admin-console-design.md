# 管理后台（Admin Console）设计

- 状态：草案（待实现计划）
- 日期：2026-08-10
- 分支：`feat/admin-console`
- 相关：`docs/superpowers/specs/` 本文件；依赖 `agent_*` 留痕表与 `012_agent_observability_views.sql`

## 1. 背景与动机

Agent（AI 顾问）可观测性已具备完整的数据底座：`agent_session / agent_message / agent_checkpoint / agent_trace` 四张表 + `v_agent_llm_daily / v_agent_tool_daily / v_agent_session_daily` 三个聚合视图，加上 OTel span、Prometheus `/metrics`、OpenObserve trace 管道。

但**消费侧仍是脚本式**：

- 会话回放：只能 SSH 上服务器跑 `backend/scripts/replay_session.py` 手写 SQL。
- 成本/用量审计：只能跑 `agent_daily_report.py` 或直接查 `v_agent_*` 视图。
- 告警巡检：`agent_alert.py` 设计为 cron 驱动，但**仓库内无任何调度、`AGENT_ALERT_WEBHOOK` 也未配**，线上告警实际处于关闭状态（即原调研的 #3 缺口）。
- 功能开关：`app_config` 表已 DB 驱动（`infrastructure/settings/flags.go` 的 Provider，UPDATE 后 60s 生效），但只能在 SQL 里改。

目标：建一个 **Web 端管理后台**，把回放、审计、告警、开关管理统一到浏览器里操作；同时把告警巡检收进后端进程，顺带补掉 #3 调度缺口。

## 2. 目标 / 非目标

**目标**

- 单管理员登录后，在浏览器内：
  - 回放任意 agent 会话的完整决策链（消息 / LLM 调用 / 工具调用 / 节点 checkpoint，按时间线）。
  - 查看成本与用量审计看板（按天、按模型、按工具的 token / 次数 / 耗时 / 错误率）。
  - 查看告警列表、标记已读/确认，并自动接收 webhook 推送。
  - 查看/修改 `app_config` 功能开关，修改后即时生效。
- 告警巡检由后端内置定时器驱动，落库可查、可去重、可推送，不再依赖主机 cron。
- 单容器部署，前端构建产物 `go:embed` 进后端二进制。

**非目标（v1 不做）**

- 多用户 / 角色 / 权限分级（v1 仅单一管理员共享密钥；后续可在同一鉴权层上扩展）。
- 对小程序用户侧的任何改动。
- 实时推送（WebSocket / SSE）——告警与数据均按需轮询或刷新。
- 把告警检测/日报能力下沉到 OpenObserve——仍由后端 Go 引擎负责（OO 仅作 trace 存储）。

## 3. 决策记录

| 议题 | 决策 | 理由 |
|------|------|------|
| 范围 | 全功能（回放+审计+告警+开关），分阶段交付 | 用户明确要全部；按阶段切片保证每步可独立跑通 |
| 鉴权 | 单一管理员，bcrypt 密码 + HMAC 签名 cookie | 当前仅单人运营；鉴权层独立，将来可升级 |
| 托管 | Go 后端 `go:embed` SPA，挂 `/admin/*` | 单容器、与现有部署一致、无 CORS |
| API 风格 | Connect-RPC（新 `AdminService`） | 与现有 Reference/Candidate/Agent 服务同构，proto 共享类型 |
| 告警调度 | 后端进程内 goroutine ticker | 单实例 7×24 运行；收掉 #3；无需外部 cron |
| 前端栈 | Vue 3 + Vite + Element Plus | CLAUDE.md 指定栈 |

## 4. 总体架构

```
admin/  (新, Vue3 SPA) ──build──► go:embed 进后端二进制
                                      │
浏览器 ──► /admin/*            (静态 SPA + 子路由回落 index.html)
       ──► /admin/api/login    (POST, 设 httpOnly cookie)
       ──► /highschool.v1.AdminService/*  (Connect-RPC, cookie 鉴权)
                                      │
                          AdminService handler (internal/api/v1)
                                      │
            repository 新增只读查询 + 写 agent_alert / app_config
                                      │
              Postgres: agent_session/message/trace/checkpoint
                        + v_agent_*_daily (012 视图)
                        + agent_alert (新表)
                        + app_config (既有)

巡检 ticker (goroutine, cmd/api) ──► 周期检查 ──► 命中写 agent_alert + webhook
```

**数据流**：运维登录 → SPA 调 AdminService（cookie 随请求带）→ repository 查库 → 返回。巡检 ticker 独立运行，只写 `agent_alert`，控制台读它展示。

## 5. 数据层

### 5.1 新表 `agent_alert`

迁移：`db/migrations/013_create_agent_alert.sql`

```sql
CREATE TABLE agent_alert (
  id          BIGSERIAL PRIMARY KEY,
  created_at  TIMESTAMP NOT NULL DEFAULT now(),
  kind        TEXT NOT NULL,            -- llm_error_rate | trace_missing | token_budget
  severity    TEXT NOT NULL DEFAULT 'warn',  -- warn | critical
  title       TEXT NOT NULL,
  detail      JSONB NOT NULL DEFAULT '{}',   -- 阈值/实际值/窗口等上下文
  status      TEXT NOT NULL DEFAULT 'open',  -- open | acked | resolved
  acked_at    TIMESTAMP
);
CREATE INDEX idx_agent_alert_status_created ON agent_alert(status, created_at DESC);
```

### 5.2 新增 repository 只读/写方法

SQL 逻辑多移植自 `backend/scripts/replay_session.py` 与 `agent_alert.py`（已验证）：

- `ListAgentSessions(ctx, filter{From, To, Device, Intent, Limit, Offset}) ([]SessionRow, total, err)`
- `GetSessionReplay(ctx, sessionID) (*ReplayBundle, err)` —— session + messages + traces + checkpoints，按时间合并
- `GetCostDashboard(ctx, from, to) (*Dashboard, err)` —— 读 `v_agent_llm_daily / v_agent_tool_daily / v_agent_session_daily`
- `ListAlerts(ctx, status, limit, offset) ([]Alert, total, err)` / `AckAlert(ctx, id) error`
- `ListAppConfig(ctx) ([]ConfigRow, err)` / `SetAppConfig(ctx, key, value) error` —— 复用既有 `app_config` 表；写后触发 Provider 缓存热刷

### 5.3 复用既有资产

- `012_agent_observability_views.sql` 的三个视图 = 成本看板数据源。
- `agent_*` 四张留痕表 = 回放数据源。
- `app_config` + `settings.Provider` = 开关管理数据源与生效机制。

## 6. RPC 接口（AdminService）

新 proto：`proto/highschool/v1/admin_service.proto`，`buf generate` 后前后端共享类型。

| 方法 | 入参 | 出参 | 备注 |
|------|------|------|------|
| `ListAgentSessions` | time_range, device?, intent?, page, page_size | items[], total | 只读 |
| `GetSessionReplay` | session_id | session, messages[], traces[], checkpoints[] | 只读；单会话全量 |
| `GetCostDashboard` | from, to | daily[], per_model[], per_tool[], error_rate, token_totals | 只读；读 012 视图 |
| `ListAlerts` | status?, page, page_size | items[], total | 只读 |
| `AcknowledgeAlert` | id | — | **写** |
| `GetAppConfig` | — | flags[] | 只读 |
| `SetAppConfig` | key, value | — | **写**，写后热刷 Provider |

**Login 不走 RPC**：`/admin/api/login` 为普通 HTTP handler（POST JSON），校验密码后下发 cookie。

## 7. 鉴权

- **配置**：`admin.password_hash`（bcrypt）、`admin.cookie_secret`（HMAC 密钥）、`admin.session_ttl`（默认 12h）。环境变量：`HS_ADMIN_PASSWORD_HASH`、`HS_ADMIN_COOKIE_SECRET`。
- **登录**：`POST /admin/api/login {password}` → bcrypt 校验 → 下发 `admin_sess` httpOnly cookie = `base64({sub,exp})` + HMAC-SHA256 签名。
- **校验**：AdminService 注册时挂鉴权 interceptor，验签 + 验期，失败 → `connect.CodeUnauthenticated`。Login handler 与静态资源不经过它。
- **登出**：清 cookie。

实现细节：现有服务以 `v1.RegisterXxxService(mux, interceptor)` 形式注册，AdminService 注册时传入 `[otelInterceptor, authInterceptor]` 链。

## 8. 巡检告警引擎

- **调度**：`cmd/api/main.go` 起一个 goroutine，按 `admin.inspect_interval`（默认 15min）tick；启动后短延迟先跑一次。
- **三项检查**（SQL 已在 `agent_alert.py` 验证，移植为 repository 方法）：
  1. 最近 1h LLM 错误率 > 20% 且调用数 > 5
  2. `trace_missing`：近 1h 有新用户消息但 `agent_trace` 零写入（落库疑似失败）
  3. 当日 token 超 `admin.daily_token_budget`（默认 2,000,000）
- **去重**：插入前查同 `kind` 是否已有 `status='open'` 告警，有则不重复插入（避免每 tick 刷屏）。
- **自动 resolve（可选）**：条件转好时把对应 open 告警置 `resolved`。P3 视情况取舍。
- **webhook**：新告警时，若 `admin.webhook_url`（env `HS_ADMIN_WEBHOOK_URL`）已配，POST markdown 到企业微信群机器人；失败仅记日志（不阻断）。python 脚本原用的 `AGENT_ALERT_WEBHOOK` 在引擎上线后随之废弃。
- **错误兜底**：每 tick `recover`，DB 抖动只记日志、不崩主进程。
- **脚本归宿**：引擎 + 看板上线、P3 验证等价后，`agent_alert.py` / `agent_daily_report.py` 可废弃；保留一段时间作离线兜底亦可。

## 9. 前端（admin/）

- **栈**：Vite + Vue 3 + Element Plus + Vue Router + Pinia + `@connectrpc/connect`（类型来自 `gen/highschool/v1/`）。
- **页面**：
  - 登录页
  - 布局（侧栏：会话回放 / 成本审计 / 告警 / 开关）
  - 会话列表（表：时间 / device / intent / 消息数 / token）→ 点击进回放时间线（消息 / trace / checkpoint 按时间合并，raw IO 可展开，token+耗时 badge）
  - 成本审计看板（日期范围 + ECharts：按天 token/次数、按模型、按工具、错误率、Top N 会话）
  - 告警列表（severity / kind / status，ack 按钮，detail JSON 查看）
  - 开关管理（`app_config` 列表，行内编辑/切换）
- **Connect client**：`credentials: 'include'`，baseURL `/`（同源）。

## 10. 部署与配置

- **构建**：Dockerfile 多阶段 —— Node 阶段构建 `admin/` 产物 → 拷入后端 `go:embed` 目录 → Go 构建单二进制。
- **静态托管**：Go 在 `/admin/*` 托管，子路由回落 `index.html`（支持前端路由）；SPA 未构建时返回提示页，不让 `/admin` 500。
- **docker-compose 新增 env**：`HS_ADMIN_PASSWORD_HASH`、`HS_ADMIN_COOKIE_SECRET`、`HS_ADMIN_WEBHOOK_URL`（+ 可选 `HS_ADMIN_INSPECT_INTERVAL`、`HS_ADMIN_DAILY_TOKEN_BUDGET`）。OpenObserve profile 不受影响。

## 11. 错误处理

- AdminService 除 Login/AcknowledgeAlert/SetAppConfig 外全只读；写操作经鉴权、返回结构化错误（connect code）。
- 巡检 goroutine 每 tick `recover`，单次失败不影响后续 tick 与主服务。
- 回放/审计查询遇大体积 session：单会话全量返回（session 体量有限，非数千条消息）；`ListAgentSessions` 强制分页。
- SPA 构建缺失：`/admin` 返回提示页，不影响 `/health`、`/metrics`、Connect 业务接口。

## 12. 测试策略（TDD）

- **repository**：只读/写方法按现有仓储测试模式（含 `agent_alert` 增删查、回放合并、视图读取）。
- **鉴权 interceptor**：合法 / 伪造 / 过期 / 缺失 cookie 四例。
- **巡检引擎**：fake clock + fake store，断言「命中插入 / 去重不重复插 / webhook 调用 / tick recover」。
- **AdminService handler**：各 RPC 的成功与鉴权失败路径。
- **前端**：`npm run type-check` + 构建；回放时间线渲染的最小组件测试。

## 13. 分阶段交付

每阶段独立可跑通、可 review，在同一 `feat/admin-console` 分支上累积：

- **P1 地基 + 回放**：鉴权/登录 + SPA 壳子 + AdminService 骨架 + 静态托管 + `agent_alert` 表 + 只读查询层 + `ListAgentSessions`/`GetSessionReplay`。**交付物：能登录、能回放单会话。**
- **P2 成本/审计看板**：`GetCostDashboard`（读 012 视图）+ ECharts 图表。
- **P3 告警模块**：巡检 ticker 引擎 + `ListAlerts`/`AcknowledgeAlert` + webhook。**收掉 #3 调度缺口。**
- **P4 开关管理**：`GetAppConfig`/`SetAppConfig` + Provider 热刷。

## 14. 遗留与待定

- 巡检「自动 resolve」是否在 P3 内做，视实现复杂度定。
- `agent_alert.py` / `agent_daily_report.py` 的废弃时机：P3 验证等价后另行处理。
- 管理员密码修改入口（当前靠 env/config）：v1 不做 UI，后续可加。
