# 「折桂登高」AI 顾问 Agent 模式 — 产品与技术方案报告

> 版本：v3（2026-07-29）
> 演进：v1 基础方案 → v2 参考「电子牛马」企业级 Agent 架构纳入状态图/checkpoint/HITL → v3 数据资产利用提升为差异化核心
> 状态：待评审开工（P1 ~10 天 / P2 ~4 天 / P3 ~4 天）

---

## 0. 背景与目标

### 0.1 现状
- 小程序「折桂登高」：上海中考志愿模拟系统。用户流程：输入区/初中/成绩 → 蒙特卡洛模拟或规则推荐 → 查看三批次（名额到区/到校/统招）录取概率与推荐。
- 后端：Go 1.24 + Connect-RPC（h2c，单端口同时支持 Connect/gRPC/JSON）+ PostgreSQL（pgx）+ viper 配置 + OTLP trace。**无鉴权、无限流**（身份靠客户端自报 device_id）。
- 前端：原生微信小程序（WXML/WXSS/JS），Connect-RPC JSON 手拼客户端（`utils/api.js` 的 `callRpc`），无 WebSocket/SSE。
- 数据：2024-2026 三年全量——三类分数线（到区/到校 800 制、平行志愿 750 制）、到区/到校招生计划、320 所高中主档、750 所初中（含梯队/区内排名/推算人数/700+/声誉分）、控线、各区考生数、招生计划汇总、用户模拟历史。

### 0.2 目标
增加**对话式 AI 志愿顾问**：用自然语言回答政策、查数据、给策略，并能调用系统内的推荐/模拟引擎。相对通用大模型（ChatGPT 等）的**唯一壁垒是我们的数据**——方案的一切设计以"把数据榨干"为中心。

### 0.3 非目标
- 不做通用聊天/多轮闲聊；话题限定上海中考。
- P1 不做流式输出、不接 RAG/向量库（政策知识量小，直接注入 prompt；数据走工具查库更准确）。
- 不做自招批次（现有系统也不支持）。

---

## 1. 产品方案

### 1.1 核心场景（对应意图分类）
| 场景 | 意图 | 说明 |
|---|---|---|
| 数据查询 | `data_query` | 「市二中学近三年平行志愿多少分？」——回答带三年趋势而非单点数字 |
| 政策/规则问答 | `policy_qa` | 批次顺序、同分 6 位序、2026 控线（615/615/501） |
| 个性化推荐 | `recommendation` | 「我徐汇一模 690 怎么填？」——槽位收集（HITL 追问）后调推荐引擎 |
| **我的初中视角** | 交叉意图 | 「我是建平西校的，我们学校去年华二到校线多少？名额几个？校内什么水平能走？」——到校线+名额+初中画像交叉，**差异化最强** |
| 结果解读 | `result_interpretation` | 带 analysisId 解读蒙特卡洛结果，指出风险志愿 |
| 模拟触发 | `simulation`（P3） | 高成本操作，HITL 确认后异步执行 |

### 1.2 交互设计
- **入口 1（主）**：tabBar 新增第三个 tab「AI 顾问」（`pages/chat/chat`）。
- **入口 2**：result 页「问问 AI 顾问」→ `wx.switchTab`，经 `app.globalData.pendingAnalysisId` 传 analysisId。
- **对话页**：消息列表（用户/助手气泡、节点状态条如「意图识别→数据查询」、错误条）+ 输入栏 + 快捷问题 chips。首轮 chips 直接亮数据壁垒：「我们学校到校线多少」「XX 中学三年分数线走势」。
- **初中语境记忆**：用户首次提供初中后写入 session slots，后续「我们学校」自动指代——个性化体验关键细节。
- **追问交互（HITL 产品形态）**：缺槽位出可点选项 chips（16 区、一模/二模）；run_simulation 前出「确认开始模拟」按钮。
- **多轮上下文**：sessionId 存 `wx.getStorageSync`；「新对话」重置 session。
- **渲染策略**：工具结构化结果用卡片（学校卡/趋势小表/并排对比卡），LLM 文本纯文本（不引入富文本依赖）。

### 1.3 护栏
- 固定免责：「数据仅供参考，以上海市教育考试院官方公布为准」。
- 越界请求（非上海中考）由 Router `off_topic` 走模板拒答，零工具/零规划消耗。
- **800/750 两套分制不混用**——prompt 硬规则 + Reflection 程序化校验（本库数据最易错点）。
- 数据口径随回答走：官方/民间（700+）/推算（考生数）必须标注。
- P2 接微信 `msgSecCheck`；P1 先做输入长度/敏感词过滤。

---

## 2. 技术选型决策

### 2.1 为什么不用 LangGraph（评估结论）
参考架构「电子牛马」（FastAPI + LangGraph StateGraph）的核心价值——显式状态图、每步 checkpoint、可回放可审计——**是架构模式而非框架专利**。不引入 Python sidecar 的理由：
1. **技术栈**：后端纯 Go 单二进制，sidecar 意味着第二语言运行时、第二部署单元、第二套监控。
2. **工具在 Go 进程内**：9~15 个工具就是 Go 的 repository/service 层（含 910 行蒙特卡洛引擎）。Python sidecar 要么重写数据访问层（两份真相），要么回调 Go HTTP（进程内调用变网络往返 + 内网鉴权）。
3. **场景规模**：五节点线性图 + 一条重规划回边，Go 显式状态机 ~300 行可测代码即可承载。
4. **退出路径**：节点划分与 LangGraph/Eino 概念 1:1 文档化（见 3.1 对应表）；未来工作流复杂化（多 agent、审批链、LangSmith 级 eval）可平移到 **CloudWeGo Eino**（Go 原生图编排，首选）或 LangGraph sidecar，proto/工具/存储层不动。

### 2.2 LLM 供应商
OpenAI 兼容 Chat Completions + tool calling。默认 **DeepSeek**（`deepseek-chat`，已备案、成本约 GPT-4 的 1/50、tool calling 稳定）；`base_url/api_key/model` 全配置化，可平切 Kimi(Moonshot)/通义千问（均 OpenAI 兼容、均已备案）。

### 2.3 流式取舍
小程序 `wx.request` 不支持 Connect server-streaming。P1 用 unary + loading 态；P3 流式走**裸 HTTP 端点** `/agent/chat/stream`（行分隔 JSON + `enableChunked`），挂法仿现有裸端点 `/tip-config`。

---

## 3. 技术方案

### 3.1 总体架构

```
小程序 pages/chat ──wx.request(JSON)──> Connect-RPC AgentService.Chat
                                            │
                              internal/api/v1/agent_connect.go    (协议转换/参数校验)
                                            │
                       ┌──────────── internal/service/agent/graph ────────────┐
                       │  ① Router 意图识别(+槽位抽取, structured output)      │
                       │      ↓                    ↑                          │
                       │  ② Planner 任务规划 ──────┤ 重规划回边(≤2次)          │
                       │      ↓                    │                          │
                       │  ③ PlanExecutor 工具执行  │  ⑥ Reflection            │
                       │      ↓                    │  校验·评测·风险          │
                       │  ⑤ ResultSynthesizer ─────┘                          │
                       │      ↑                                               │
                       │  ④ Clarify/HITL（缺槽位追问·高成本确认，断点等待）     │
                       └───────┬──────────────────────────────────────────────┘
              ┌────────────────┼──────────────────┬────────────────────┐
   infrastructure/llm   service/agent/tools   repository/agent_*   repository/agent_trace
   ChatModel 抽象       ToolRegistry          ThreadStore          Trace·回放·审计
   (DeepSeek默认,       (薄查询+分析型工具,   (session+checkpoint  (每节点输入/输出/
    可切Kimi/通义)       只读·超时熔断)        +Thread Lock乐观锁)   tokens/耗时落库)
                              │
                    ┌─────────┴─────────┐
                    │ 分析视图层(PG VIEW) │  v_school_profile / v_school_score_trend /
                    │ 三年数据预聚合     │  v_quota_trend / v_middle_school_profile
                    └───────────────────┘
```

与参考架构的对应关系：

| 参考架构（电子牛马） | 本方案对应 |
|---|---|
| LangGraph StateGraph 五节点 | `service/agent/graph` 显式状态机，同五节点 + Clarify 节点 |
| Reflection → Router 重规划回边 | 同，≤2 次重规划，之后降级话术 |
| Human Input 分支 | Clarify 节点：缺槽位追问 / 高成本确认，checkpoint 断点续跑 |
| LangChain ChatModel 抽象（可插拔） | `infrastructure/llm.Client`（OpenAI 兼容，配置切 provider） |
| ToolRegistry 受控接入 | `service/agent/tools`：JSON schema、参数校验、只读、超时熔断 |
| ThreadStore + Thread Lock（PG） | `agent_session`（version 乐观锁）+ `agent_checkpoint`（每节点快照） |
| Trace·回放 / Audit Events | `agent_trace` + `agent_message.usage` 成本审计 |
| RAG/Milvus | 不需要：政策知识注入 prompt；数据走工具查库 |

### 3.2 数据资产利用设计（差异化核心）

#### 3.2.1 数据资产盘点（按差异化强度排序）
| 资产 | 表 | 壁垒 |
|---|---|---|
| **到校录取线（初中×高中，2024-2026）** | ref_admission_score_quota_school | 全网分散难查、ChatGPT 基本答不出；「我的初中」语境的根基 |
| **到校招生计划（初中×高中）** | ref_quota_allocation_school | 名额+线交叉才能回答「校内多少名能走」 |
| **三年到区线/平行志愿线 + 到区计划** | ref_admission_score_quota_district / ref_admission_score_unified / ref_quota_allocation_district | 趋势与波动分析只能靠本地三年全量 |
| **同分小分（语数外/数学/语文/综合）** | 三张分数线表内嵌列 | 「同分要比数学」的精细策略 |
| **初中画像（梯队/区内排名/推算人数/700+/声誉）** | ref_middle_school | 「你们学校什么水平」的直接素材；带 data_nature 口径 |
| **高中主档（类型/办别/寄宿/国际班）** | ref_school + ref_admission_plan_summary | 学校对比的结构化维度 |
| **控线 + 各区考生数** | ref_control_score / ref_district_exam_count | 定位分析锚点 |
| **用户模拟历史** | simulation_history | 连续顾问：记得你上次的志愿和概率 |

#### 3.2.2 分析视图层（`db/migrations/010_agent_analysis_views.sql`）
不让 LLM 现场做三年 JOIN 聚合——常用分析预计算成 **PG VIEW**（数据量千级，普通 VIEW，无物化刷新运维；同时服务后端其他模块）：
- **`v_school_profile`**：每所高中一行：主档属性 + 最新年三类线（本区）+ 2026 到区/到校名额合计。
- **`v_school_score_trend`**：校 × 批次 × 年 → 最低分、同比涨跌、小分。
- **`v_quota_trend`**：校 × 区 × 年 → 名额、同比增减。
- **`v_middle_school_profile`**：每所初中一行：区/梯队/区内排名/推算人数/700+/到校名额合计/到校线聚合，全部带 `data_nature`（官方/民间/推算）。

#### 3.2.3 工具全集（ToolRegistry，15 个，全部只读）
薄查询（P1）：
| 工具 | 实现来源 |
|---|---|
| `get_admission_scores`（三类分数线，batch 参数区分 800/750 制） | recommendation_repository 既有查询 |
| `search_schools` / `get_school_detail` | ReferenceService 既有方法 |
| `get_quota_plan`（到区/到校计划） | quota_repository |
| `get_control_scores` | recommendation_repository |
| `get_middle_school_stats` | ref_middle_school |
| `get_district_exam_count` | 既有表 |

分析型（P1，差异化武器）：
| 工具 | 语义 | 数据源 |
|---|---|---|
| `compare_schools(school_ids[])` | 多校并排：三年线+计划+类型+寄宿 | v_school_profile + trend |
| `get_score_trend(school, batch)` | 单校趋势+波动幅度（"稳不稳"判断） | v_school_score_trend |
| **`get_middle_school_advantage(middle, high?)`** | 初中×高中交叉：名额、历年到校线、画像、校内竞争强度 | 到校线/计划 + v_middle_school_profile |
| `locate_score(district, score, batch)` | 分数定位：「线 ≤ 分」学校列表 + gap 排序（冲稳保粗筛） | 三类线 + 控线 |
| `get_quota_change(school, district)` | 名额同比（"今年扩招/缩招"） | v_quota_trend |
| `get_tie_break_detail(school, district, batch)` | 录取同分小分明细 | 分数线表小分列 |

引擎型（P2/P3）：
| 工具 | 实现来源 |
|---|---|
| `run_recommendation`（三批次推荐） | RecommendationService 注入（P2） |
| `get_analysis_result`（读模拟结果） | simulation_history（P2） |
| `run_simulation`（HITL 确认后异步） | simulation.Engine（P3） |

executor 统一签名：`Execute(ctx, args json.RawMessage) (ToolResult, error)`；`ToolResult` 双载荷（给 LLM 的 JSON 文本 + 给前端的卡片结构）。每个工具的 schema description 写明**何时用、与谁组合**（中文示例），这是 Planner 选准工具的关键。

#### 3.2.4 复合问题的 Planner 编排
- 「我浦东 705 想冲四校」→ `locate_score`（定位）→ `get_score_trend`×N（目标校稳定性）→ `get_quota_change`（今年名额）→ 综合。
- 「我们学校能走华二吗」→ `get_middle_school_advantage(本校, 华二)` → `get_middle_school_stats`（画像/人数，估校内位次）→ 综合。

#### 3.2.5 回答策略（Synthesizer prompt 硬要求）
- 分数线必带**三年**（有则）并指出涨跌；单年数字视为信息不足。
- 涉及用户初中必用「你们学校」语境 + 名额/线/画像三件套。
- 对比类问题先卡片并排后文字。
- 每个数字带年份；民间/推算数据带口径。
- 数字必须来自工具结果（Reflection 程序化校验兜底）。

### 3.3 状态定义与节点职责

```go
// service/agent/graph/state.go
type State struct {
    SessionID   string
    Messages    []Message          // 最近20轮
    Intent      string             // policy_qa/data_query/recommendation/simulation/result_interpretation/off_topic
    Slots       map[string]any     // district_id/total_score/exam_type/middle_school_id/analysis_id...
    Plan        []Step             // Planner 产出(多步+依赖)
    ToolResults []ToolResult       // Executor 累积
    PendingQ    *PendingQuestion   // HITL: 非空=等待用户输入
    ReplanCount int
    StepBudget  int                // 全局步数预算(默认12)
}
```

- **① Router**：一次轻量 LLM 调用（JSON schema 强约束），输出 `{intent, slots, confidence}`；解析「我们学校」指代到 slots.middle_school_id。`off_topic`/低置信 → 模板拒答。session 处于 `waiting_input` 时跳过 Router，先把用户回答并入 Slots 再判定。
- **② Planner**：按 intent 产出多步计划（支持复合编排，见 3.2.4）。必填槽位缺失 → 转 ④。
- **③ PlanExecutor**：无依赖步骤并行（`errgroup`），每步参数校验 + 5s 超时熔断，单步失败降级不中断。
- **④ Clarify/HITL**：生成追问（文案 + 选项 chips），写 checkpoint → session 置 `waiting_input` → 返回用户；下条消息从 checkpoint 恢复。高成本步骤（run_simulation）执行前必经确认。
- **⑤ ResultSynthesizer**：LLM 综合工具结果生成回答 + 卡片；prompt 含 3.2.5 硬要求。
- **⑥ Reflection**：(a) **程序化**：抽取回答数字全部须溯源到 ToolResults，800/750 分制表述与批次一致；(b) **LLM 轻量评测**（P2，答非所问/无来源数字/风险承诺词）。未通过 → 回 Router 重规划（≤2 次）；仍不过 → 降级「请以卡片数据为准」+ 原始卡片。

### 3.4 Checkpoint 持久化与并发守护（ThreadStore/Thread Lock）

```sql
-- db/migrations/009_create_agent_tables.sql
agent_session(id, device_id, status,          -- running/waiting_input/done/aborted
              current_node, intent, slots jsonb, pending_question jsonb,
              analysis_id, version int,        -- version: 乐观锁
              created_at, updated_at, last_active_at)
agent_message(id, session_id FK, role, content, node, tool_calls jsonb, usage jsonb, created_at)
agent_checkpoint(id, session_id FK, step_seq, node, state jsonb, created_at)   -- 每节点转换后快照
agent_trace(id, session_id FK, checkpoint_id FK, kind,   -- llm/tool/node
            name, input jsonb, output jsonb, prompt_tokens, completion_tokens, latency_ms, created_at)
```

- **写路径**：每节点执行完 → 同事务内 `INSERT checkpoint` + `UPDATE session SET version=version+1 WHERE id=? AND version=?`（Thread Lock，防双击/多端并发写）。
- **恢复**：`Chat` 入口按 sessionId 读最新 checkpoint 重建 State——支持 HITL 续跑、进程重启恢复。
- **回放/评测**：`agent_trace` 全量留痕，可按 session 重放决策链；既是调试器也是 eval 数据集，客服可凭 trace_id 人工接管复盘。

### 3.5 Proto（新增 `proto/highschool/v1/agent_service.proto`）
```proto
service AgentService {
  rpc Chat(ChatRequest) returns (ChatResponse);
  rpc NewSession(NewSessionRequest) returns (NewSessionResponse);
  rpc GetSessionHistory(GetSessionHistoryRequest) returns (GetSessionHistoryResponse);
}
message ChatRequest {
  string device_id = 1; string session_id = 2; string message = 3;
  ChatContext context = 4;           // analysis_id/district_id/middle_school_id/total_score
  string pending_answer = 5;         // HITL: 对 pending_question 的回答
}
message ChatResponse {
  string session_id = 1; string reply = 2;
  string intent = 3; repeated ToolCallInfo tool_calls = 4;
  repeated SchoolCard school_cards = 5;
  PendingQuestion pending_question = 6;  // 非空→前端渲染追问 chips/确认按钮
  string trace_id = 7;                   // 前端可上报"这条回答有问题"
}
```
`buf generate` 后按 `reference_connect.go:221` 模式在 `main.go` 注册。

### 3.6 Prompt 体系（分层）
- **Router prompt**：意图枚举 + 槽位 schema + few-shot，输出强 JSON；「我们学校/我校」指代解析。
- **Synthesizer prompt**：角色、批次顺序与同分 6 位序、800/750 红线、2026 控线锚点、免责话术、≤400 字、3.2.5 回答策略。
- **Reflection prompt**（P2）：答非所问/无来源数字/风险承诺词三维度评测。

### 3.7 配置、限流与成本
- **配置**：viper `llm:`（provider/base_url/api_key/model/max_tokens/timeout）+ `agent:`（max_replan/step_budget/session_ttl/daily_quota）；docker-compose `HS_LLM_API_KEY`。
- **限流**（后端现状零鉴权零限流，agent 上线前必做）：device_id 每日 50 轮 + 全局 10 并发 LLM 闸 + 每日 token 预算熔断（超预算降级为纯工具模板回答，不调 LLM）+ Nginx `limit_req`（IP 层）。
- **成本**：Router max_tokens ≤200；Synthesizer ≤800；session 20 轮截断（P3 换摘要压缩）。粗估 1000 轮/天 ≈ 几元/天（DeepSeek 单价）。

### 3.8 前端改动清单
1. `app.json`：注册 `pages/chat/chat` + tabBar 第三项；图标 `frontend/images/chat.png` / `chat-active.png`（占位 PNG）。
2. `pages/chat/chat.{js,wxml,wxss,json}`：消息列表 + 节点状态条 + 输入栏 + 追问 chips/确认按钮 + typing 态；onShow 消费 `pendingAnalysisId`。
3. `components/chat-bubble/`、`components/school-card/`（趋势小表/并排对比）、`components/pending-question/`。
4. `utils/agent.js`：复用 `callRpc`（timeout 放宽 60s，不改现有 8s 契约）；sessionId 持久化。
5. `pages/result/result`：底部加「问问 AI 顾问」。
6. `utils/api.js` 不动。

### 3.9 合规
- 模型侧：DeepSeek/Kimi/通义均已按《生成式人工智能服务管理暂行办法》备案；小程序内公示「由 XX 模型提供」，更新用户协议/隐私政策。
- 微信侧：纯文本问答不涉及深度合成资质；提审版本声明 AI 生成内容；P2 接 `msgSecCheck`。
- **审核开关（已实现）**：个人开发者类目限制 AI 服务，故做远程开关——后端 `GET /app-config?version=x` 返回 `agent_enabled`；`feature.review_versions` 中的版本强制返回 `false`。审核期把提审版本号加入 `review_versions`（或直接把 `feature.agent_enabled` 设为 false），chat 页整体显示「功能升级中」占位、result 页隐藏「问问 AI 顾问」；通过后从配置移除即可线上打开。同模式复用打赏码 `/tip-config` 的 review_versions 机制。
- 数据侧：回答带年份来源；民间/推算数据保留口径；`agent_trace` 全量留痕支撑审计与人工接管。

### 3.10 测试与观测
- **单测**：Router 意图/槽位（含「我们学校」指代）、Planner 复合编排与槽位校验、**分析视图 SQL 正确性**（已知学校断言三年线/同比）、Reflection 数字校验器（构造幻觉数字断言拦截）、checkpoint 恢复（写断点→重建→续跑）、session 乐观锁并发。
- **冒烟**：`e2e/chat-test.js`——数据问答（断言带三年趋势）/「我们学校」交叉问答/追问补槽/越界拒答 4 条链路。
- **观测**：LLM 调用挂 OTLP trace（model/tokens/latency）；`agent_trace` 按天统计成本与意图分布。

---

## 4. 分期计划

| 期 | 内容 | 工作量 |
|---|---|---|
| **P1 MVP** | proto、状态图五节点 + 程序化 Reflection、checkpoint/trace/session 锁、Clarify 追问、**分析视图层（010）+ 6 薄查询 + 6 分析型工具**、限流、chat tab 页 | ~10 天 |
| **P2** | run_recommendation、get_analysis_result、LLM 反思 + 重规划、result 页入口、快捷问题、msgSecCheck、合规文案 | ~4 天 |
| **P3** | run_simulation（HITL 确认 + 异步）、流式输出（裸 HTTP + enableChunked）、会话摘要压缩、成本/意图报表 | ~4 天 |

P1 详细拆解：
1. `db/migrations/009`（agent 四表）+ `010`（分析视图）→ 0.5 天
2. proto + `buf generate` + 注册 → 0.5 天
3. `infrastructure/llm` client（Chat + tool calling + trace）→ 1 天
4. 状态图骨架（五节点 + checkpoint 写读 + session 锁）→ 2 天
5. 12 个工具（6 薄查询 + 6 分析型）→ 2 天
6. 程序化 Reflection（数字校验/分制校验）→ 0.5 天
7. 限流 + 配置 → 0.5 天
8. chat 页 + 3 组件 + result 入口 → 2 天
9. 单测 + e2e 冒烟 + 联调 → 1 天

---

## 5. 风险与对策

| 风险 | 对策 |
|---|---|
| LLM 幻觉分数线 | 四道防线：Router 意图强制 → Synthesizer 禁报无来源数字 → Reflection 程序化数字校验 → 重规划回边 |
| 分析视图口径腐化 | 视图与基表同库实时一致；配 SQL 单测；数据再导入后自动生效无需刷新 |
| 状态机复杂度失控 | 节点纯函数化（State in → 决策 out）+ checkpoint 回放测试 + 步数预算/重规划上限防死循环 |
| 无鉴权被刷成本 | device_id 限流 + Nginx IP 限流 + 每日 token 预算熔断降级 |
| 长耗时坏体验 | P1 只放毫秒级查询工具（目标 <10s 响应）；推荐/模拟放 P2/P3 且 simulation 强制 HITL 确认 + 异步 |
| 框架锁定 | 状态图与 LangGraph/Eino 概念 1:1 文档化；proto/工具/存储层与编排层解耦，迁移成本可控 |

---

## 6. 备选方案记录（已评估未采纳）

| 方案 | 结论 | 理由 |
|---|---|---|
| Python sidecar（FastAPI + LangGraph） | 不采纳 | 双语言双部署；工具层在 Go 进程内，sidecar 只能重写或回调，均亏 |
| Node + LangGraph.js sidecar | 不采纳 | 同上 |
| langchaingo / 其他 Go LLM 框架 | 不采纳（暂） | 当前图复杂度不需要；框架活跃度一般。后续复杂化首选 CloudWeGo Eino |
| RAG/向量库（Milvus） | 不采纳 | 政策知识量小直接注入 prompt；学校/分数数据走工具查库远比向量召回准确 |
| Connect server-streaming | 不采纳 | 小程序 wx.request 不支持；流式改走裸 HTTP + enableChunked（P3） |
| Redis 会话存储 | 不采纳（暂） | 后端无 redis client；会话/checkpoint 走 PG（现有 pgx 模式），量级无压力 |

---

## 7. 验收标准（P1）

1. 四链路冒烟全过：数据问答（回答含三年趋势且数字与库一致）、「我们学校」交叉问答、追问补槽、越界拒答。
2. Reflection 拦截测试：注入幻觉数字的回答 100% 被拦截并触发重规划或降级。
3. checkpoint 恢复：kill 进程后 session 可从最近断点续跑；双击/并发不产生写冲突。
4. 限流生效：单 device_id 超 50 轮/天被拒绝；LLM 并发闸生效。
5. 性能：数据查询类对话 P95 响应 <10s；工具单步 P95 <1s。
6. `agent_trace` 可按 session 完整回放决策链；可按天导出 token 成本。
