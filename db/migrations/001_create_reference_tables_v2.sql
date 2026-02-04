-- =============================================================================
-- 上海中考招生模拟系统 - 参考数据表 DDL（优化版）
-- =============================================================================
-- 优化说明：
--   - 删除了适合作为常量的表（ref_school_nature, ref_school_type, ref_boarding_type, ref_admission_batch, ref_subject）
--   - 这些常量已移至 shared/constants/index.ts
--   - ref_school, ref_middle_school, ref_control_score 中的外键列改为字符串类型，直接存储常量代码
-- =============================================================================

-- =============================================================================
-- 1. 区县表 (ref_district)
-- 上海16个区
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_district (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    name_en VARCHAR(50),
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_district IS '上海16个区县参考表';
COMMENT ON COLUMN ref_district.code IS '区代码';
COMMENT ON COLUMN ref_district.name IS '区名称';
COMMENT ON COLUMN ref_district.name_en IS '区英文名称';
COMMENT ON COLUMN ref_district.display_order IS '显示顺序';

-- =============================================================================
-- 2. 学校主表 (ref_school)
-- 基于 2025年参加本市高中阶段学校招生学校名单
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_school (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    short_name VARCHAR(100),
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    school_nature_id VARCHAR(50) NOT NULL,
    school_type_id VARCHAR(50),
    boarding_type_id VARCHAR(50),
    has_international_course BOOLEAN DEFAULT FALSE,
    remarks TEXT,
    data_year INTEGER NOT NULL DEFAULT 2025,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(code, data_year)
);

CREATE INDEX idx_ref_school_code ON ref_school(code);
CREATE INDEX idx_ref_school_district ON ref_school(district_id);
CREATE INDEX idx_ref_school_nature ON ref_school(school_nature_id);
CREATE INDEX idx_ref_school_type ON ref_school(school_type_id);

COMMENT ON TABLE ref_school IS '学校主表（基于2025年招生学校名单）';
COMMENT ON COLUMN ref_school.code IS '学校招生代码（6位）';
COMMENT ON COLUMN ref_school.full_name IS '学校全称';
COMMENT ON COLUMN ref_school.short_name IS '学校简称';
COMMENT ON COLUMN ref_school.district_id IS '所属区ID';
COMMENT ON COLUMN ref_school.school_nature_id IS '办别代码（PUBLIC=公办, PRIVATE=民办, COOPERATION=中外合作）';
COMMENT ON COLUMN ref_school.school_type_id IS '学校类型代码';
COMMENT ON COLUMN ref_school.boarding_type_id IS '寄宿类型代码（FULL=全部寄宿, PARTIAL=部分寄宿, NONE=无寄宿）';
COMMENT ON COLUMN ref_school.has_international_course IS '是否含国际课程班';
COMMENT ON COLUMN ref_school.remarks IS '备注';
COMMENT ON COLUMN ref_school.data_year IS '数据年份';

-- =============================================================================
-- 3. 名额分配到区招生计划表 (ref_quota_allocation_district)
-- 基于 2025年上海市高中名额分配到区招生计划
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_quota_allocation_district (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    school_id INTEGER NOT NULL REFERENCES ref_school(id),
    school_code VARCHAR(20) NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    quota_count INTEGER NOT NULL,
    data_year INTEGER NOT NULL DEFAULT 2025,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, school_code, district_id)
);

CREATE INDEX idx_quota_allocation_year ON ref_quota_allocation_district(year);
CREATE INDEX idx_quota_allocation_school ON ref_quota_allocation_district(school_id);
CREATE INDEX idx_quota_allocation_district ON ref_quota_allocation_district(district_id);

COMMENT ON TABLE ref_quota_allocation_district IS '名额分配到区招生计划表';
COMMENT ON COLUMN ref_quota_allocation_district.year IS '招生年份';
COMMENT ON COLUMN ref_quota_allocation_district.school_id IS '学校ID';
COMMENT ON COLUMN ref_quota_allocation_district.school_code IS '学校代码';
COMMENT ON COLUMN ref_quota_allocation_district.district_id IS '分配区ID';
COMMENT ON COLUMN ref_quota_allocation_district.quota_count IS '计划数';

-- =============================================================================
-- 4. 最低投档控制分数线表 (ref_control_score)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_control_score (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    admission_batch_id VARCHAR(50) NOT NULL,
    category VARCHAR(100) NOT NULL,
    min_score DECIMAL(5,2) NOT NULL,
    description TEXT,
    data_year INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, admission_batch_id, category)
);

CREATE INDEX idx_control_score_year ON ref_control_score(year);

COMMENT ON TABLE ref_control_score IS '最低投档控制分数线表';
COMMENT ON COLUMN ref_control_score.year IS '招生年份';
COMMENT ON COLUMN ref_control_score.admission_batch_id IS '招生批次代码（AUTONOMOUS=自主招生, QUOTA_DISTRICT=名额分配到区, QUOTA_SCHOOL=名额分配到校, UNIFIED_1_15=统一招生1-15志愿, UNIFIED_CONSULT=统一招生征求志愿）';
COMMENT ON COLUMN ref_control_score.category IS '招生类别';
COMMENT ON COLUMN ref_control_score.min_score IS '最低投档控制分数线';

-- =============================================================================
-- 触发器: 自动更新 updated_at
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为所有表添加 updated_at 触发器
CREATE TRIGGER update_ref_district_updated_at BEFORE UPDATE ON ref_district
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_school_updated_at BEFORE UPDATE ON ref_school
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_quota_allocation_district_updated_at BEFORE UPDATE ON ref_quota_allocation_district
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_control_score_updated_at BEFORE UPDATE ON ref_control_score
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
