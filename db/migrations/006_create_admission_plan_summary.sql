-- =============================================================================
-- 上海中考招生模拟系统 - 招生计划汇总表
-- =============================================================================
-- 说明：
--   记录每所高中学校各招生批次的计划招生名额
--   招生批次包括：
--   1. 自主招生 (AUTONOMOUS) - 约10-15%
--   2. 名额分配到区 (QUOTA_DISTRICT) - 委属约80%，区属约30%
--   3. 名额分配到校 (QUOTA_SCHOOL) - 委属约20%，区属约70%
--   4. 统一招生 (UNIFIED) - 剩余名额
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 招生计划汇总表 (ref_admission_plan_summary)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_admission_plan_summary (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    school_id INTEGER NOT NULL REFERENCES ref_school(id),
    school_code VARCHAR(20) NOT NULL,
    school_name VARCHAR(200) NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    school_type_id VARCHAR(50) NOT NULL,
    is_municipal BOOLEAN NOT NULL DEFAULT FALSE,

    -- 各批次招生名额
    autonomous_count INTEGER DEFAULT 0,           -- 自主招生名额
    autonomous_sports_count INTEGER DEFAULT 0,    -- 其中：市级优秀体育学生
    autonomous_arts_count INTEGER DEFAULT 0,      -- 其中：市级艺术骨干学生
    quota_district_count INTEGER DEFAULT 0,       -- 名额分配到区名额
    quota_school_count INTEGER DEFAULT 0,         -- 名额分配到校名额
    unified_count INTEGER DEFAULT 0,              -- 统一招生名额

    -- 汇总信息
    total_plan_count INTEGER DEFAULT 0,           -- 总招生计划
    quota_total_count INTEGER DEFAULT 0,          -- 名额分配总计(到区+到校)
    quota_ratio DECIMAL(5,2),                     -- 名额分配比例（%）

    -- 计算字段（用于验证）
    autonomous_ratio DECIMAL(5,2),                -- 自主招生比例（%）
    unified_ratio DECIMAL(5,2),                   -- 统一招生比例（%）

    data_year INTEGER NOT NULL DEFAULT 2025,
    data_source VARCHAR(255),
    remarks TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(year, school_code)
);

CREATE INDEX idx_admission_plan_summary_year ON ref_admission_plan_summary(year);
CREATE INDEX idx_admission_plan_summary_school ON ref_admission_plan_summary(school_id);
CREATE INDEX idx_admission_plan_summary_district ON ref_admission_plan_summary(district_id);
CREATE INDEX idx_admission_plan_summary_type ON ref_admission_plan_summary(school_type_id);
CREATE INDEX idx_admission_plan_summary_municipal ON ref_admission_plan_summary(is_municipal);

COMMENT ON TABLE ref_admission_plan_summary IS '招生计划汇总表 - 记录每所学校各批次招生名额';
COMMENT ON COLUMN ref_admission_plan_summary.year IS '招生年份';
COMMENT ON COLUMN ref_admission_plan_summary.school_id IS '学校ID';
COMMENT ON COLUMN ref_admission_plan_summary.school_code IS '学校招生代码';
COMMENT ON COLUMN ref_admission_plan_summary.school_name IS '学校名称';
COMMENT ON COLUMN ref_admission_plan_summary.district_id IS '所属区ID';
COMMENT ON COLUMN ref_admission_plan_summary.school_type_id IS '学校类型代码';
COMMENT ON COLUMN ref_admission_plan_summary.is_municipal IS '是否委属学校（上海市直属）';
COMMENT ON COLUMN ref_admission_plan_summary.autonomous_count IS '自主招生计划数';
COMMENT ON COLUMN ref_admission_plan_summary.autonomous_sports_count IS '自主招生中市级优秀体育学生数';
COMMENT ON COLUMN ref_admission_plan_summary.autonomous_arts_count IS '自主招生中市级艺术骨干学生数';
COMMENT ON COLUMN ref_admission_plan_summary.quota_district_count IS '名额分配到区计划数';
COMMENT ON COLUMN ref_admission_plan_summary.quota_school_count IS '名额分配到校计划数';
COMMENT ON COLUMN ref_admission_plan_summary.unified_count IS '统一招生计划数';
COMMENT ON COLUMN ref_admission_plan_summary.total_plan_count IS '总招生计划数';
COMMENT ON COLUMN ref_admission_plan_summary.quota_total_count IS '名额分配总计（到区+到校）';
COMMENT ON COLUMN ref_admission_plan_summary.quota_ratio IS '名额分配比例（%）';
COMMENT ON COLUMN ref_admission_plan_summary.autonomous_ratio IS '自主招生比例（%）';
COMMENT ON COLUMN ref_admission_plan_summary.unified_ratio IS '统一招生比例（%）';
COMMENT ON COLUMN ref_admission_plan_summary.data_source IS '数据来源';

-- -----------------------------------------------------------------------------
-- 触发器: 自动更新 updated_at
-- -----------------------------------------------------------------------------
CREATE TRIGGER update_ref_admission_plan_summary_updated_at BEFORE UPDATE ON ref_admission_plan_summary
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- -----------------------------------------------------------------------------
-- 视图: 2025年招生计划汇总视图（含学校详细信息）
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_admission_plan_2025 AS
SELECT
    aps.id,
    aps.year,
    aps.school_code,
    aps.school_name,
    d.code AS district_code,
    d.name AS district_name,
    aps.school_type_id,
    aps.is_municipal,
    aps.autonomous_count,
    aps.autonomous_sports_count,
    aps.autonomous_arts_count,
    aps.quota_district_count,
    aps.quota_school_count,
    aps.unified_count,
    aps.total_plan_count,
    aps.quota_total_count,
    aps.quota_ratio,
    aps.autonomous_ratio,
    aps.unified_ratio
FROM ref_admission_plan_summary aps
JOIN ref_district d ON aps.district_id = d.id
WHERE aps.year = 2025
ORDER BY aps.is_municipal DESC, d.display_order, aps.school_code;

COMMENT ON VIEW v_admission_plan_2025 IS '2025年招生计划汇总视图';
