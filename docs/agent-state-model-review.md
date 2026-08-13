# Agent 状态模型设计 Review

- **日期**：2026-08-12
- **范围**：AI 顾问 Agent 的「状态如何跨轮维持」——`State`、checkpoint、intent、slots 的设计与生命周期。不评审节点内部算法（Router/Planner 的 prompt 质量等）。
- **触发**：管理后台会话回放暴露的疑点——多轮会话（session 18）只看到「一条 flow」的 checkpoint；进而引出「长会话中意图偏移如何处理」的设计问题。
- **相关代码**：`backend/internal/service/agent/`、`backend/internal/service/agent/graph/`、`backend/internal/service/agent_service.go`、`db/migrations/009_create_agent_tables.sql`

---

## 1. 现状（代码事实）

### 1.1 每轮重建 State，**不**从 checkpoint 续接
`agent_service.go` 的 `Chat` 每次请求都重建 `State`：
- 从 `agent_session` 行取 `Intent / Slots / PendingQ`（`agent_service.go:145-147`）；
- 从 `ListMessages` 取最近 N 条消息作为 `Messages`（`agent_service.go:137,144`）；
- **不调用 `LatestCheckpoint`**（grep 全文件无引用）。

→ checkpoint 不是跨轮状态的真源；跨轮状态由 `agent_session` 行 + 消息表承担。

### 1.2 Router 每轮重分类意图，但**只看「当前消息 + 累积槽位」，不看历史**
`graph/nodes.go: routerNode`：
- 上下文只传 `{已知槽位: s.Slots}` + `s.UserMessage`（当前这一句）；
- **不传 `s.Messages`**（对话历史）；
- 每轮覆盖式写 `s.Intent = out.Intent`，并把新槽位 merge 进 `s.Slots`。

### 1.3 槽位**全 session 累积、从不删**
- 加载：`state.Slots = sess.Slots`（`agent_service.go:146`，带入历史轮的槽位）；
- 写回：`sess.Slots = state.Slots`（`agent_service.go` Chat 末尾，存累积结果）；
- `setSlot`（`nodes.go`）只覆盖同名 key，**没有任何删除/失效路径**。

→ 一个会话的槽位袋单调增长，直到会话结束。

### 1.4 checkpoint = **轮内**逐节点 State 快照
`graph.go: Run`（line 70-115）：每个节点转换后 `saveCheckpoint(stepSeq, node, state)`。一轮典型走 Router→Planner→Executor→Synthesizer→Reflection→End，约 5 个 checkpoint。
- `stepSeq` 每轮从 `0` 重置（`graph.go:78`）；
- 表约束 `UNIQUE(session_id, step_seq)`（`009:49`）。

### 1.5 会话行 = 「最新 intent」+「累积 slots」单值
`agent_session.intent`（最新一轮）、`agent_session.slots`（累积）。无「话题段 / 意图轨迹」概念。

### 1.6 两个上下文：Messages（对话原文） vs Slots（结构化字段）
State 同时持有两个相互独立、用途不同的"上下文"，勿混：
- **Messages**：用户/助手原话往返，时间序数组。受 `MaxContextMessages`（默认 20）滑窗约束（仅最近 N 条喂给 LLM）。是 prefix cache 的主体。
- **Slots**：Router 让 LLM 从原话里**抽取的结构化 key-value 参数**（`school_name` / `district_name` / `total_score` / `exam_type`…），`map[string]any`——**不是原话本身**。全 session 累积（见 1.3）。

→ 「slot 是否过期」与「消息是否滑出窗口」是两件事；当前 bug 的本质是 slot 脱离了消息窗口、自己无限累积。

---

## 2. 问题清单

### P1. 槽位累积：意图偏移后，旧槽位污染新意图 【核心】
- **现象**：第 1 轮 data_query 设了 `school_name=市二`、`total_score=685`；第 5 轮用户改问「给我推荐几所学校」，这些旧槽位还在。
- **根因**：1.3（槽位永不清）。
- **影响**：
  - Router 把陈旧槽位当「已知」喂进去（`routerNode` 的 context），**可能把新消息往旧意图上靠**；
  - 更实际的 bug 见 P3。
- **触发场景**：任何「先查信息、后要推荐」或「换学校/换区」的多轮会话。

### P2. Router 不看历史：指代解不开 + 分类短视
- **现象**：用户说「那这个学校适合我吗？」——Router 不看历史，不知道「这个学校」指谁，意图可能误判。
- **根因**：1.2（Router 不传 `s.Messages`）。
- **影响**：指代类、追问类、省略类消息分类不准；置信度低走兜底。
- **注**：Synthesizer 那一侧是看历史的（生成回复用 `Messages`），所以「分类短视、生成不短视」——会出现「分类错了但生成还能凑」的不一致。

### P3. 推荐意图的必填槽位校验**用了陈旧值**，跳过 Clarify 【实际 bug】
- `plannerNode` 对 recommendation 要求 `district_name / total_score / exam_type`，缺失才转 Clarify（`nodes.go` plannerNode）。
- 但这些槽位可能来自**前几轮的 context 注入或 data_query**，并非本轮用户真正为「推荐」给出的值。
- **结果**：用户改要推荐时，planner 看到「槽位齐了」→ **不 Clarify，直接用陈旧/错误的分数或区去跑推荐引擎** → 给出基于错误输入的推荐。
- **根因**：P1（槽位累积）+ 槽位没有「来源/新鲜度」标记。

### P4. checkpoint `UNIQUE(session_id, step_seq)` + 每轮 stepSeq 重置 → 多轮 checkpoint 丢失 【已确认 bug】
- **现象**：session 18 有两轮（traces 233-242、461-470 都在），但 checkpoint 只有第 1 轮的 5 条（step_seq 1-5）。回放只能看到「一条 flow」。
- **根因**：`Run` 每轮 `stepSeq := 0`（`graph.go:78`），第 2 轮又写 step_seq 1-5 → 撞 `UNIQUE(session_id, step_seq)`（`009:49`）→ `SaveCheckpoint` 报错 → `graph.go:105-107` 只 `logger.Error` 不中断 → 第 2 轮起 checkpoint 全丢（traces 无此约束，所以两轮都在）。
- **影响**：多轮会话回放不完整；若将来用 checkpoint 做轮内崩溃恢复，多轮下「最新 checkpoint」语义混乱。

### P5. 无「话题/意图段」概念
- 长会话 = 一个不断膨胀的槽位袋 + 一条单值 `intent`。系统不知道「用户已换话题」，不做任何重置。
- 与 P1/P3 同源，单列出来是因为它是个**模型层面的缺口**（缺一个介于「单条消息」和「整个 session」之间的「话题段」抽象）。

### P6. 回放 UI 不利于诊断上述问题
- 时间线只合并 messages + traces（`admin/src/views/SessionReplay.vue:52-57`），**没合并 checkpoint** → 看不出「哪个节点被快照、状态在何时演进」。
- 每轮 intent 没在时间线上标注 → 意图偏移不可见。
- 槽位状态（每个 checkpoint 的 `state.slots`）能展开看，但没有「槽位随轮次变化」的 diff 视图。

---

## 3. 影响面

| 场景 | 当前设计表现 |
|------|-------------|
| 单意图、聊 1-3 轮 | 够用 |
| 单意图、多轮追问同一目标 | 基本够用（槽位累积反而提供上下文） |
| **先查信息 → 再要推荐（意图偏移）** | **退化**：旧槽位污染，可能用错分数/区做推荐（P1/P3） |
| 长会话、多次切换意图 | 持续退化；回放还看不出全貌（P4/P6） |
| 指代/省略/追问（"那这个""换个"） | Router 可能误判（P2） |

---

## 4. 备选方案与取舍

### 针对 P1/P3/P5（槽位累积 / 话题段）
- **A1. 槽位分级 + 意图切换时清空「非持久槽位」**
  槽位标 `persistent`（如 district，跨意图仍有意义）vs `ephemeral`（如 school_name、total_score，强意图相关）。Router 检测到 intent 变化时，清 ephemeral。
  - ✅ 最小改动解决 P3；保留有意义的长期上下文。
  - ✗ 需要定义每个槽位的类别（领域知识）；「意图是否变化」的判定本身可能抖动。
- **A2. 槽位带「来源轮次/新鲜度」**
  每个槽位记 `turn_set`；planner 对推荐必填槽位要求「本轮设置或用户本轮确认」，否则 Clarify。
  - ✅ 直接堵住 P3（陈旧值不能用）。
  - ✗ 改动面更大（槽位结构变）；需要前端/小程序配合「本轮确认」语义。
- **A3. 显式「话题段（segment）」**
  检测意图偏移 → 开新段，段内槽位隔离；用户也可手动「换个问题」。
  - ✅ 最干净，解决 P5；回放按段呈现。
  - ✗ 工作量最大；偏移检测的准确率是新的风险点。

> **推荐**：先做 **A1**（性价比最高，直接消掉 P3 这个实际 bug），把 A3 留作长期演进。

#### 诱人但不可行：每轮从消息窗口"重提 slot"
直观解法是"既然消息有滑窗，slot 也跟着窗口重提、旧的随消息滑出自动消失"。**否决，五条理由**：
1. **丢持久事实**：`district / total_score / exam_type` 这类用户/考生属性，说一次就该记整场；其来源消息一旦滑出窗口，重提就没了 → agent 又来问"哪个区"。当前 bug 是"该丢的不丢"，这是"该留的留不住"——对称的另一种坏。
2. **破坏跨轮拼信息**：用户分多次给信息（turn1 分数、turn3 一模），窗口一滑，已拼好的 slot 又碎掉。
3. **Clarify 死循环**：HITL 的 Q&A 滑出窗 → 重提丢 slot → 重复追问。
4. **重提成本 + LLM 不确定**：每轮把窗口再喂 LLM 抽一次，多花 token/延迟；且 LLM 抽取非确定，同一窗口重抽可能这次有、下次没，slot 不稳定、回放难复现。
5. **打断 prefix cache**（见下）。

#### 约束：prefix cache 要求"追加式"消息历史
LLM 前缀缓存（DeepSeek 默认开启）从 prompt **开头**匹配最长公共前缀。
- **追加式**（turn N+1 = turn N + 1 条新消息）→ 上一轮整段即本轮前缀 → **全命中**，只算新增那条。
- **每轮滑窗**（前面丢一条）→ 开头变了 → 公共前缀只剩 `system` → **几乎全 miss**，整段历史每轮重算，成本随历史线性涨。

→ 正确范式是 **append-only 当默认，仅在撞 context 上限时裁一次**（裁后继续追加，cache 断裂只发生在偶发裁剪点）；或裁剪时把旧消息压成 summary，形成新的稳定前缀。**不要每轮滑窗。**

**对本项目**：会话通常 3~10 轮，`MaxContextMessages=20` 几乎不触发 → 实际即 append-only → 本就 cache 友好；只有极端长会话才裁一次。真正吃 cache 的是带历史的 Synthesizer 调用（追加→命中）；Router/Planner 每轮短而独立，本就没什么前缀可缓存。

#### 结论：回到 A1 槽位分级
prefix cache 这条 + 上面四条，共同否决"用消息滑窗管 slot"。落点是 **A1**：
- **持久槽位**（`district / total_score / exam_type`）：session 级保留，不受窗口影响；
- **易变槽位**（`school_name` 这类强绑定某次查询的）：意图切换时清，或仅本轮有效。

A1 **完全不碰消息历史的追加结构**，prefix cache 照样命中；同时消掉 P3（易变陈旧值误导推荐）。Prompt 结构上再注意一条：**易变内容放 prompt 尾部（user 消息），稳定内容放开头（system）**——别把每轮都变的 slot 塞进 system 打断 cache。

### 针对 P2（Router 不看历史）
- **B1. Router 传最近 K 条消息**（滑动窗口，如最近 4 条），而非只看当前一句。
  - ✅ 解指代、分类更稳；改动小（一个 prompt 字段）。
  - ✗ 多一点 token；窗口太大可能引入噪声。配合「主要看当前消息、历史仅参考」的 prompt 措辞。
> **推荐**：**B1**，低成本高收益。

### 针对 P4（checkpoint 多轮丢失）
- **C1. 去掉 `UNIQUE(session_id, step_seq)`** + 回放 checkpoint 改 `ORDER BY id`（时间序）。
  - ✅ 最小改动；与「每轮重建 State、checkpoint 是轮内快照」的现有语义一致；回放能看到**每轮一条 flow**。
  - ✗ step_seq 不再全 session 单调；若未来想做「跨轮连续 trail」或崩溃恢复，语义需再处理。
- **C2. step_seq 跨轮单调递增**（State 加 `StepSeq`，Chat 加载时续接，`Run` 从 `s.StepSeq` 起算）。
  - ✅ 保留 UNIQUE 不变量；回放一条连续 trail。
  - ✗ 改动 3 处 + State 字段；与「每轮重建」需对齐（续接的 stepSeq 要从 session 维度取）。
> **推荐**：**C1**（契合现有「每轮重建」设计，最小）。若团队更想要「会话级连续轨迹」再考虑 C2。

### 针对 P6（回放诊断力）
- **D1. checkpoint 并进时间线**：在 timeline 里按 `created_at` 插入 checkpoint 标记（"checkpoint · node=X · step=N"），点开看该快照的 `state.slots`。
- **D2. 每轮 intent 标注在时间线上**：从 router trace 取 intent，标注在每轮开头 → 意图偏移一眼可见。
- **D3. 槽位 diff**：相邻 checkpoint 的 `state.slots` 做增/改/删 diff，看「哪轮加了哪个槽位、是否被带偏」。
> **推荐**：**D1 + D2** 先做（直接把 P1/P4 的诊断可视化），D3 视需要再加。

---

## 5. 建议优先级（供后续决策，本轮不改代码）

| 级别 | 项 | 理由 |
|------|----|------|
| 🔴 高 | **P3（A1）** | 实际 bug：会用错分数/区做推荐，影响用户 |
| 🔴 高 | **P4（C1）** | 实际 bug：多轮回放残缺；改动极小 |
| 🟡 中 | **P2（B1）** | 提升分类/指代；低成本 |
| 🟡 中 | **P6（D1+D2）** | 让上述问题可观测、可回归 |
| 🟢 低 | **P1/P5（A3 话题段）** | 长期模型演进，待 A1 验证后定 |

---

## 6. 附录：session 18 证据
- 消息 4 条：2 轮用户提问（「今年最低控制线多少」「帮我解读这份模拟结果」）+ 2 条 assistant 回复。
- traces 20 条，跨两轮（id 233-242 @23:08、461-470 @次日 14:36）。
- checkpoint 仅 5 条，全是第 1 轮（step_seq 1-5 @23:08）；第 2 轮因 P4 全丢。
- → 直观印证 P4；也说明现有设计在「多轮」上既丢 checkpoint（P4）、又可能被累积槽位带偏（P1/P3）。
