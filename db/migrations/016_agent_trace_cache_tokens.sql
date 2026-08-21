-- 016: agent_trace 记录 DeepSeek prefix cache 命中/未命中 token
-- 用途：按会话/节点诊断缓存命中率（成本 = 未命中全价 + 命中约 1/10 价）
-- 历史 行默认 0；指标层另由 Prometheus agent_llm_cache_tokens_total 聚合上报 OpenObserve
ALTER TABLE agent_trace ADD COLUMN IF NOT EXISTS prompt_cache_hit_tokens INTEGER NOT NULL DEFAULT 0;
ALTER TABLE agent_trace ADD COLUMN IF NOT EXISTS prompt_cache_miss_tokens INTEGER NOT NULL DEFAULT 0;
