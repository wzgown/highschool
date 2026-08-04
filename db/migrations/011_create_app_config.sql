-- ============================================================
-- 应用配置表（远程功能开关，免重启生效）
-- 设计文档: docs/agent-mode-plan.md §3.9
-- 修改方式: UPDATE app_config SET value='...' WHERE key='...';
-- 后端 60s 内存缓存，DB 不可读时回退到环境变量 HS_FEATURE_*
-- ============================================================

CREATE TABLE IF NOT EXISTS app_config (
    key         VARCHAR(100) PRIMARY KEY,
    value       TEXT         NOT NULL DEFAULT '',
    description VARCHAR(255),
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_app_config_updated_at
    BEFORE UPDATE ON app_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 功能开关初始值
INSERT INTO app_config (key, value, description) VALUES
    ('feature.agent_enabled', 'true', 'AI顾问总开关（true/false）'),
    ('feature.review_versions', '1.4', '审核中的小程序版本号（逗号分隔），这些版本强制关闭AI顾问；审核通过后置空')
ON CONFLICT (key) DO NOTHING;
