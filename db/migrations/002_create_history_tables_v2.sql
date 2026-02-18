-- =============================================================================
-- 上海中考招生模拟系统 - 历史数据表 DDL（优化版）
-- =============================================================================
-- 基于 original_data/ 目录下的2024年等历年中考数据
-- 优化说明：
--   - ref_middle_school 表的 school_nature_id 改为字符串类型
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. 各区中考人数表 (ref_district_exam_count)
-- 数据来源: 2024-2027年上海各区中考人数.csv
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_district_exam_count (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    exam_count INTEGER NOT NULL,
    data_source VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, district_id)
);

CREATE INDEX idx_district_exam_count_year ON ref_district_exam_count(year);
CREATE INDEX idx_district_exam_count_district ON ref_district_exam_count(district_id);

COMMENT ON TABLE ref_district_exam_count IS '各区中考人数统计表';
COMMENT ON COLUMN ref_district_exam_count.year IS '中考年份';
COMMENT ON COLUMN ref_district_exam_count.district_id IS '区ID';
COMMENT ON COLUMN ref_district_exam_count.exam_count IS '中考报名人数';
COMMENT ON COLUMN ref_district_exam_count.data_source IS '数据来源文件';

-- -----------------------------------------------------------------------------
-- 2. 初中学校表 (ref_middle_school)
-- 用于名额分配到校招生计划
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_middle_school (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(100),
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    school_nature_id VARCHAR(50),
    is_non_selective BOOLEAN NOT NULL DEFAULT TRUE,
    data_year INTEGER NOT NULL DEFAULT 2025,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_middle_school_district ON ref_middle_school(district_id);
CREATE INDEX idx_middle_school_nature ON ref_middle_school(school_nature_id);
CREATE INDEX idx_middle_school_non_selective ON ref_middle_school(is_non_selective);

COMMENT ON TABLE ref_middle_school IS '初中学校表（用于名额分配到校）';
COMMENT ON COLUMN ref_middle_school.name IS '学校全称';
COMMENT ON COLUMN ref_middle_school.short_name IS '学校简称';
COMMENT ON COLUMN ref_middle_school.district_id IS '所属区ID';
COMMENT ON COLUMN ref_middle_school.school_nature_id IS '办别代码（PUBLIC=公办, PRIVATE=民办）';
COMMENT ON COLUMN ref_middle_school.is_non_selective IS '是否不选择生源初中（名额分配到校填报资格）';
COMMENT ON COLUMN ref_middle_school.data_year IS '数据年份';

-- -----------------------------------------------------------------------------
-- 3. 名额分配到校招生计划表 (ref_quota_allocation_school)
-- 数据来源: 2024年上海市高中名额分配到校招生计划（各区）.csv
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_quota_allocation_school (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    high_school_id INTEGER NOT NULL REFERENCES ref_school(id),
    high_school_code VARCHAR(20) NOT NULL,
    middle_school_id INTEGER REFERENCES ref_middle_school(id),
    middle_school_name VARCHAR(200),
    quota_count INTEGER NOT NULL,
    data_year INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, high_school_code, middle_school_name)
);

CREATE INDEX idx_quota_allocation_school_year ON ref_quota_allocation_school(year);
CREATE INDEX idx_quota_allocation_school_district ON ref_quota_allocation_school(district_id);
CREATE INDEX idx_quota_allocation_school_high ON ref_quota_allocation_school(high_school_id);

COMMENT ON TABLE ref_quota_allocation_school IS '名额分配到校招生计划表';
COMMENT ON COLUMN ref_quota_allocation_school.year IS '招生年份';
COMMENT ON COLUMN ref_quota_allocation_school.district_id IS '所属区ID';
COMMENT ON COLUMN ref_quota_allocation_school.high_school_id IS '高中学校ID';
COMMENT ON COLUMN ref_quota_allocation_school.high_school_code IS '高中学校代码';
COMMENT ON COLUMN ref_quota_allocation_school.middle_school_id IS '初中学校ID';
COMMENT ON COLUMN ref_quota_allocation_school.middle_school_name IS '初中学校名称';
COMMENT ON COLUMN ref_quota_allocation_school.quota_count IS '分配到该校的计划数';

-- -----------------------------------------------------------------------------
-- 4. 名额分配到区录取最低分数线表 (ref_admission_score_quota_district)
-- 数据来源: 2024年上海市高中学校名额分配到区招生录取最低分数线（各区）.csv
-- 总分800分（学业考750分+综合素质评价50分）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_admission_score_quota_district (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    school_id INTEGER REFERENCES ref_school(id),
    school_name VARCHAR(200) NOT NULL,
    min_score DECIMAL(6,2) NOT NULL,
    is_tie_preferred BOOLEAN DEFAULT FALSE,
    chinese_math_foreign_sum DECIMAL(6,2),
    math_score DECIMAL(5,2),
    chinese_score DECIMAL(5,2),
    integrated_test_score DECIMAL(5,2),
    comprehensive_quality_score DECIMAL(4,1) DEFAULT 50,
    data_year INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, district_id, school_name)
);

CREATE INDEX idx_admission_score_quota_year ON ref_admission_score_quota_district(year);
CREATE INDEX idx_admission_score_quota_district ON ref_admission_score_quota_district(district_id);
CREATE INDEX idx_admission_score_quota_school ON ref_admission_score_quota_district(school_id);
CREATE INDEX idx_admission_score_quota_min_score ON ref_admission_score_quota_district(min_score);

COMMENT ON TABLE ref_admission_score_quota_district IS '名额分配到区录取最低分数线表';
COMMENT ON COLUMN ref_admission_score_quota_district.year IS '招生年份';
COMMENT ON COLUMN ref_admission_score_quota_district.district_id IS '录取区ID';
COMMENT ON COLUMN ref_admission_score_quota_district.school_id IS '学校ID';
COMMENT ON COLUMN ref_admission_score_quota_district.school_name IS '学校名称';
COMMENT ON COLUMN ref_admission_score_quota_district.min_score IS '录取最低分（总分800分）';
COMMENT ON COLUMN ref_admission_score_quota_district.is_tie_preferred IS '是否同分优待';
COMMENT ON COLUMN ref_admission_score_quota_district.chinese_math_foreign_sum IS '语数外三科合计';
COMMENT ON COLUMN ref_admission_score_quota_district.math_score IS '数学成绩';
COMMENT ON COLUMN ref_admission_score_quota_district.chinese_score IS '语文成绩';
COMMENT ON COLUMN ref_admission_score_quota_district.integrated_test_score IS '综合测试成绩';
COMMENT ON COLUMN ref_admission_score_quota_district.comprehensive_quality_score IS '综合素质评价成绩（默认50分）';

-- -----------------------------------------------------------------------------
-- 5. 名额分配到校录取最低分数线表 (ref_admission_score_quota_school)
-- 数据来源: 2024年上海市高中学校名额分配到校招生录取最低分数线（各区）.csv
-- 总分800分（学业考750分+综合素质评价50分）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_admission_score_quota_school (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    school_id INTEGER REFERENCES ref_school(id),
    school_name VARCHAR(200) NOT NULL,
    middle_school_name VARCHAR(200),
    min_score DECIMAL(6,2) NOT NULL,
    is_tie_preferred BOOLEAN DEFAULT FALSE,
    chinese_math_foreign_sum DECIMAL(6,2),
    math_score DECIMAL(5,2),
    chinese_score DECIMAL(5,2),
    integrated_test_score DECIMAL(5,2),
    comprehensive_quality_score DECIMAL(4,1) DEFAULT 50,
    data_year INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, district_id, school_name, middle_school_name)
);

CREATE INDEX idx_admission_score_quota_school_year ON ref_admission_score_quota_school(year);
CREATE INDEX idx_admission_score_quota_school_district ON ref_admission_score_quota_school(district_id);
CREATE INDEX idx_admission_score_quota_school_high ON ref_admission_score_quota_school(school_id);
CREATE INDEX idx_admission_score_quota_school_min_score ON ref_admission_score_quota_school(min_score);

COMMENT ON TABLE ref_admission_score_quota_school IS '名额分配到校录取最低分数线表';
COMMENT ON COLUMN ref_admission_score_quota_school.year IS '招生年份';
COMMENT ON COLUMN ref_admission_score_quota_school.district_id IS '录取区ID';
COMMENT ON COLUMN ref_admission_score_quota_school.school_id IS '高中学校ID';
COMMENT ON COLUMN ref_admission_score_quota_school.school_name IS '高中学校名称';
COMMENT ON COLUMN ref_admission_score_quota_school.middle_school_name IS '初中学校名称';
COMMENT ON COLUMN ref_admission_score_quota_school.min_score IS '录取最低分（总分800分）';

-- -----------------------------------------------------------------------------
-- 6. 1-15志愿录取分数线表 (ref_admission_score_unified)
-- 数据来源: 2024中考1-15志愿录取分数线（各区）.csv
-- 总分750分（学业考成绩）
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ref_admission_score_unified (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    school_id INTEGER REFERENCES ref_school(id),
    school_name VARCHAR(200) NOT NULL,
    min_score DECIMAL(6,2) NOT NULL,
    chinese_math_foreign_sum DECIMAL(6,2),
    math_score DECIMAL(5,2),
    chinese_score DECIMAL(5,2),
    data_year INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, district_id, school_name)
);

CREATE INDEX idx_admission_score_unified_year ON ref_admission_score_unified(year);
CREATE INDEX idx_admission_score_unified_district ON ref_admission_score_unified(district_id);
CREATE INDEX idx_admission_score_unified_school ON ref_admission_score_unified(school_id);
CREATE INDEX idx_admission_score_unified_min_score ON ref_admission_score_unified(min_score);

COMMENT ON TABLE ref_admission_score_unified IS '1-15志愿录取分数线表';
COMMENT ON COLUMN ref_admission_score_unified.year IS '招生年份';
COMMENT ON COLUMN ref_admission_score_unified.district_id IS '录取区ID';
COMMENT ON COLUMN ref_admission_score_unified.school_id IS '学校ID';
COMMENT ON COLUMN ref_admission_score_unified.school_name IS '学校名称';
COMMENT ON COLUMN ref_admission_score_unified.min_score IS '投档分数线（总分750分）';
COMMENT ON COLUMN ref_admission_score_unified.chinese_math_foreign_sum IS '语数外三科合计';
COMMENT ON COLUMN ref_admission_score_unified.math_score IS '数学成绩';
COMMENT ON COLUMN ref_admission_score_unified.chinese_score IS '语文成绩';

-- -----------------------------------------------------------------------------
-- 触发器: 自动更新 updated_at
-- -----------------------------------------------------------------------------
CREATE TRIGGER update_ref_district_exam_count_updated_at BEFORE UPDATE ON ref_district_exam_count
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_middle_school_updated_at BEFORE UPDATE ON ref_middle_school
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_quota_allocation_school_updated_at BEFORE UPDATE ON ref_quota_allocation_school
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_admission_score_quota_district_updated_at BEFORE UPDATE ON ref_admission_score_quota_district
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_admission_score_quota_school_updated_at BEFORE UPDATE ON ref_admission_score_quota_school
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_admission_score_unified_updated_at BEFORE UPDATE ON ref_admission_score_unified
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
