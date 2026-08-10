-- ============================================================
-- Agent 可观测性视图层：成本/用量日报与告警的数据基础
-- - v_agent_llm_daily:     按天聚合 LLM 调用（次数/tokens/耗时/错误）
-- - v_agent_tool_daily:    按天 × 工具聚合工具调用（次数/失败/平均耗时）
-- - v_agent_session_daily: 按天聚合活跃会话与消息量
--
-- 口径说明：
-- - agent_trace 无独立 error 列，错误以 output JSONB 含 "error" 键判定
--   （见 backend/internal/service/agent/graph/nodes.go callLLM/traceTool，
--    出错时写入 output = {"error": "..."}）
-- - 消息数以 agent_message 为准（会话消息主表），活跃会话按当日有消息的
--   session_id 去重
-- - created_at 为 TIMESTAMP（无时区），按库服务器时区（Asia/Shanghai）取日期
-- ============================================================

-- 按天聚合 LLM 调用：次数 / tokens / 平均与 p95 耗时 / 错误数
CREATE OR REPLACE VIEW v_agent_llm_daily AS
SELECT
    created_at::date                                        AS day,
    COUNT(*)                                                AS llm_calls,
    COALESCE(SUM(prompt_tokens), 0)                         AS prompt_tokens,
    COALESCE(SUM(completion_tokens), 0)                     AS completion_tokens,
    COALESCE(SUM(prompt_tokens), 0)
        + COALESCE(SUM(completion_tokens), 0)               AS total_tokens,
    ROUND(AVG(latency_ms))                                  AS avg_latency_ms,
    ROUND(percentile_cont(0.95) WITHIN GROUP (ORDER BY latency_ms)) AS p95_latency_ms,
    COUNT(*) FILTER (WHERE output ? 'error')                AS error_count
FROM agent_trace
WHERE kind = 'llm'
GROUP BY created_at::date
ORDER BY day;

-- 按天 × 工具名聚合：调用次数 / 失败数 / 平均耗时
CREATE OR REPLACE VIEW v_agent_tool_daily AS
SELECT
    created_at::date                                        AS day,
    COALESCE(name, '(unknown)')                             AS tool_name,
    COUNT(*)                                                AS calls,
    COUNT(*) FILTER (WHERE output ? 'error')                AS failures,
    ROUND(AVG(latency_ms))                                  AS avg_latency_ms
FROM agent_trace
WHERE kind = 'tool'
GROUP BY created_at::date, COALESCE(name, '(unknown)')
ORDER BY day, calls DESC;

-- 按天聚合：活跃会话数 / 消息数（消息数以 agent_message 为准）
CREATE OR REPLACE VIEW v_agent_session_daily AS
SELECT
    created_at::date                                        AS day,
    COUNT(DISTINCT session_id)                              AS active_sessions,
    COUNT(*)                                                AS messages,
    COUNT(*) FILTER (WHERE role = 'user')                   AS user_messages,
    COUNT(*) FILTER (WHERE role = 'assistant')              AS assistant_messages
FROM agent_message
GROUP BY created_at::date
ORDER BY day;
