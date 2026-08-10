-- =============================================================================
-- simulation_history 增加异步任务状态列
-- 背景: SubmitAnalysis 改为异步（提交即返回 pending，后台跑模拟引擎）
-- 存量数据均为同步时代已完成的结果，故 status 默认 'completed'
-- =============================================================================

ALTER TABLE simulation_history
    ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'completed',
    ADD COLUMN IF NOT EXISTS error_message TEXT;

COMMENT ON COLUMN simulation_history.status IS '分析任务状态：pending/processing/completed/failed（存量数据为 completed）';
COMMENT ON COLUMN simulation_history.error_message IS '分析失败原因（status=failed 时有值）';
