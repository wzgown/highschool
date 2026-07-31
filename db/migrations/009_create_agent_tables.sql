-- ============================================================
-- Agent 模式：会话 / 消息 / checkpoint / trace 四表
-- 设计文档: docs/agent-mode-plan.md §3.4
-- - agent_session:  ThreadStore 主表, version 乐观锁(Thread Lock) 防并发写
-- - agent_checkpoint: 每节点转换后的 State 快照, 支持 HITL 续跑/崩溃恢复/回放
-- - agent_trace:    每次 LLM/工具调用留痕, 支撑回放/评测/成本审计
-- ============================================================

CREATE TABLE IF NOT EXISTS agent_session (
    id               SERIAL PRIMARY KEY,
    device_id        VARCHAR(64)  NOT NULL,
    status           VARCHAR(20)  NOT NULL DEFAULT 'running',   -- running/waiting_input/done/aborted
    current_node     VARCHAR(30),
    intent           VARCHAR(30),                               -- policy_qa/data_query/recommendation/simulation/result_interpretation/off_topic
    slots            JSONB        NOT NULL DEFAULT '{}'::jsonb,
    pending_question JSONB,
    analysis_id      INTEGER,
    version          INTEGER      NOT NULL DEFAULT 0,           -- Thread Lock 乐观锁
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_active_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_agent_session_device ON agent_session(device_id);
CREATE INDEX IF NOT EXISTS idx_agent_session_active ON agent_session(last_active_at);

CREATE TRIGGER update_agent_session_updated_at
    BEFORE UPDATE ON agent_session
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS agent_message (
    id         SERIAL PRIMARY KEY,
    session_id INTEGER      NOT NULL REFERENCES agent_session(id) ON DELETE CASCADE,
    role       VARCHAR(20)  NOT NULL,                             -- user/assistant/tool/system
    content    TEXT         NOT NULL DEFAULT '',
    node       VARCHAR(30),                                       -- 产生该消息的节点
    tool_calls JSONB,
    usage      JSONB,                                             -- {prompt_tokens, completion_tokens}
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_agent_message_session ON agent_message(session_id, id);

CREATE TABLE IF NOT EXISTS agent_checkpoint (
    id         SERIAL PRIMARY KEY,
    session_id INTEGER     NOT NULL REFERENCES agent_session(id) ON DELETE CASCADE,
    step_seq   INTEGER     NOT NULL,
    node       VARCHAR(30) NOT NULL,
    state      JSONB       NOT NULL,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (session_id, step_seq)
);
CREATE INDEX IF NOT EXISTS idx_agent_checkpoint_session ON agent_checkpoint(session_id, step_seq DESC);

CREATE TABLE IF NOT EXISTS agent_trace (
    id                SERIAL PRIMARY KEY,
    session_id        INTEGER REFERENCES agent_session(id) ON DELETE CASCADE,
    checkpoint_id     INTEGER,
    kind              VARCHAR(10) NOT NULL,                       -- llm/tool/node
    name              VARCHAR(100),
    input             JSONB,
    output            JSONB,
    prompt_tokens     INTEGER,
    completion_tokens INTEGER,
    latency_ms        INTEGER,
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_agent_trace_session ON agent_trace(session_id, id);
CREATE INDEX IF NOT EXISTS idx_agent_trace_created ON agent_trace(created_at);
