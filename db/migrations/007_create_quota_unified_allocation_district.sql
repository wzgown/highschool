-- =============================================================================
-- 统一招生分区名额表
-- =============================================================================
-- 存储统一招生批次各学校在各区的招生名额
-- 与 ref_quota_allocation_district 结构类似，但用于统一招生批次

CREATE TABLE IF NOT EXISTS ref_quota_unified_allocation_district (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    school_id INTEGER NOT NULL REFERENCES ref_school(id),
    school_code VARCHAR(20) NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    quota_count INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, school_code, district_id)
);

CREATE INDEX idx_quota_unified_year ON ref_quota_unified_allocation_district(year);
CREATE INDEX idx_quota_unified_school ON ref_quota_unified_allocation_district(school_id);
CREATE INDEX idx_quota_unified_district ON ref_quota_unified_allocation_district(district_id);

COMMENT ON TABLE ref_quota_unified_allocation_district IS '统一招生分区名额表';
COMMENT ON COLUMN ref_quota_unified_allocation_district.year IS '招生年份';
COMMENT ON COLUMN ref_quota_unified_allocation_district.school_id IS '学校ID';
COMMENT ON COLUMN ref_quota_unified_allocation_district.school_code IS '学校代码';
COMMENT ON COLUMN ref_quota_unified_allocation_district.district_id IS '分配区ID';
COMMENT ON COLUMN ref_quota_unified_allocation_district.quota_count IS '统一招生计划数';

-- 触发器: 自动更新 updated_at
CREATE TRIGGER update_ref_quota_unified_allocation_district_updated_at BEFORE UPDATE ON ref_quota_unified_allocation_district
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
