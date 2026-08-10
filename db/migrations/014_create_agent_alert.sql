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
