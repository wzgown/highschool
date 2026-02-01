-- =============================================================================
-- 上海中考招生模拟系统 - 参考数据表 DDL
-- =============================================================================
-- 数据来源:
--   - https://www.shmeea.edu.cn/download/20250528/014.pdf (名额分配到区招生计划)
--   - https://www.shmeea.edu.cn/download/20250430/90.pdf (招生学校名单)
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
-- 2. 学校类型枚举 (ref_school_type)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_school_type (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_school_type IS '学校类型枚举表';
COMMENT ON COLUMN ref_school_type.code IS '类型代码';
COMMENT ON COLUMN ref_school_type.name IS '类型名称';
COMMENT ON COLUMN ref_school_type.description IS '类型描述';

-- =============================================================================
-- 3. 办别枚举 (ref_school_nature)
-- 公办/民办
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_school_nature (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(20) NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_school_nature IS '学校办别枚举表（公办/民办）';
COMMENT ON COLUMN ref_school_nature.code IS '办别代码';
COMMENT ON COLUMN ref_school_nature.name IS '办别名称';

-- =============================================================================
-- 4. 寄宿情况枚举 (ref_boarding_type)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_boarding_type (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(20) NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_boarding_type IS '寄宿情况枚举表';
COMMENT ON COLUMN ref_boarding_type.code IS '寄宿类型代码';
COMMENT ON COLUMN ref_boarding_type.name IS '寄宿类型名称';

-- =============================================================================
-- 5. 学校主表 (ref_school)
-- 基于 2025年参加本市高中阶段学校招生学校名单
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_school (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    short_name VARCHAR(100),
    district_id INTEGER NOT NULL REFERENCES ref_district(id),
    school_nature_id INTEGER NOT NULL REFERENCES ref_school_nature(id),
    school_type_id INTEGER REFERENCES ref_school_type(id),
    boarding_type_id INTEGER REFERENCES ref_boarding_type(id),
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
CREATE INDEX idx_ref_school_type ON ref_school(school_type_id);

COMMENT ON TABLE ref_school IS '学校主表（基于2025年招生学校名单）';
COMMENT ON COLUMN ref_school.code IS '学校招生代码（6位）';
COMMENT ON COLUMN ref_school.full_name IS '学校全称';
COMMENT ON COLUMN ref_school.short_name IS '学校简称';
COMMENT ON COLUMN ref_school.district_id IS '所属区ID';
COMMENT ON COLUMN ref_school.school_nature_id IS '办别ID（公办/民办）';
COMMENT ON COLUMN ref_school.school_type_id IS '学校类型ID';
COMMENT ON COLUMN ref_school.boarding_type_id IS '寄宿情况ID';
COMMENT ON COLUMN ref_school.has_international_course IS '是否含国际课程班';
COMMENT ON COLUMN ref_school.remarks IS '备注';
COMMENT ON COLUMN ref_school.data_year IS '数据年份';

-- =============================================================================
-- 6. 招生批次枚举 (ref_admission_batch)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_admission_batch (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_admission_batch IS '招生批次枚举表';
COMMENT ON COLUMN ref_admission_batch.code IS '批次代码';
COMMENT ON COLUMN ref_admission_batch.name IS '批次名称';

-- =============================================================================
-- 7. 名额分配到区招生计划表 (ref_quota_allocation_district)
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
-- 8. 科目表 (ref_subject)
-- 中考计分科目
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_subject (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    max_score DECIMAL(5,2) NOT NULL DEFAULT 150,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE ref_subject IS '中考计分科目表';
COMMENT ON COLUMN ref_subject.code IS '科目代码';
COMMENT ON COLUMN ref_subject.name IS '科目名称';
COMMENT ON COLUMN ref_subject.max_score IS '满分值';

-- =============================================================================
-- 9. 最低投档控制分数线表 (ref_control_score)
-- =============================================================================
CREATE TABLE IF NOT EXISTS ref_control_score (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    admission_batch_id INTEGER NOT NULL REFERENCES ref_admission_batch(id),
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
COMMENT ON COLUMN ref_control_score.admission_batch_id IS '招生批次ID';
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

CREATE TRIGGER update_ref_school_type_updated_at BEFORE UPDATE ON ref_school_type
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_school_nature_updated_at BEFORE UPDATE ON ref_school_nature
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_boarding_type_updated_at BEFORE UPDATE ON ref_boarding_type
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_school_updated_at BEFORE UPDATE ON ref_school
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_admission_batch_updated_at BEFORE UPDATE ON ref_admission_batch
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_quota_allocation_district_updated_at BEFORE UPDATE ON ref_quota_allocation_district
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_subject_updated_at BEFORE UPDATE ON ref_subject
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ref_control_score_updated_at BEFORE UPDATE ON ref_control_score
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
