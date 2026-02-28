-- =============================================================================
-- 模拟历史记录表
-- =============================================================================

-- 模拟历史记录表
CREATE TABLE IF NOT EXISTS simulation_history (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(255) NOT NULL,
    device_info JSONB,
    candidate_data JSONB NOT NULL,
    simulation_result JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_simulation_history_device_created 
    ON simulation_history(device_id, created_at);

COMMENT ON TABLE simulation_history IS '模拟历史记录表';
COMMENT ON COLUMN simulation_history.device_id IS '设备指纹';
COMMENT ON COLUMN simulation_history.device_info IS '设备信息（平台、型号等）';
COMMENT ON COLUMN simulation_history.candidate_data IS '考生输入数据（脱敏）';
COMMENT ON COLUMN simulation_history.simulation_result IS '模拟结果';

-- 虚拟竞争对手生成记录表
CREATE TABLE IF NOT EXISTS competitor_generation_log (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(255) NOT NULL,
    candidate_score_range VARCHAR(20) NOT NULL,
    generated_competitors JSONB NOT NULL,
    actual_success_rate DECIMAL(5,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE competitor_generation_log IS '虚拟竞争对手生成记录表（用于算法优化）';
