-- ============================================================================
-- 2024年初中学校名单 - 种子数据（从名额分配到校数据提取）
-- 数据来源: raw/2024/quota_school/*.csv（共12个区文件）
-- 注：不选择生源初中默认为TRUE，适用于名额分配到校填报资格判断
-- 注：此数据仅包含有名额分配到校的初中学校
-- ============================================================================

-- 
-- 上海华旭双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0012', '上海华旭双语学校', '上海华旭双语',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海嘉定区世界外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0030', '上海嘉定区世界外国语学校', '上海嘉定区世',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海嘉定区民办华盛怀少学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0008', '上海嘉定区民办华盛怀少学校', '上海嘉定区民',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学嘉定外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0004', '上海外国语大学嘉定外国语学校', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海大学附属嘉定留云中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0016', '上海大学附属嘉定留云中学', '上海大学附属',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区丰庄中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0027', '上海市嘉定区丰庄中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区华亭学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0015', '上海市嘉定区华亭学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区华江中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0017', '上海市嘉定区华江中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区南翔中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0010', '上海市嘉定区南翔中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区南苑中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0005', '上海市嘉定区南苑中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区启良中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0026', '上海市嘉定区启良中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区嘉二实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0023', '上海市嘉定区嘉二实验学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区外冈中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0028', '上海市嘉定区外冈中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区娄塘学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0022', '上海市嘉定区娄塘学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区徐行中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0031', '上海市嘉定区徐行中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区戬浜学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0035', '上海市嘉定区戬浜学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区新城实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0019', '上海市嘉定区新城实验中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区方泰中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0021', '上海市嘉定区方泰中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区朱桥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0029', '上海市嘉定区朱桥学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区疁城实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0007', '上海市嘉定区疁城实验学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区练川实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0001', '上海市嘉定区练川实验学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区苏民学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0002', '上海市嘉定区苏民学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区迎园中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0034', '上海市嘉定区迎园中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区金鹤学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0032', '上海市嘉定区金鹤学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区震川中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0006', '上海市嘉定区震川中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区马陆育才联合中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0013', '上海市嘉定区马陆育才联合中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区黄渡中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0003', '上海市嘉定区黄渡中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨二中附属江桥实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0024', '上海市曹杨二中附属江桥实验中学', '上海市曹杨二',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办嘉一联合中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0018', '上海市民办嘉一联合中学', '上海市民办嘉',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办桃李园实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0011', '上海市民办桃李园实验学校', '上海市民办桃',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办远东学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0033', '上海市民办远东学校', '上海市民办远',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办华曜嘉定初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0020', '上海民办华曜嘉定初级中学', '上海民办华曜',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 中科院上海实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0009', '中科院上海实验学校', '中科院上海实',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 交大附中附属嘉定德富中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0014', '交大附中附属嘉定德富中学', '交大附中附属',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 同济大学附属实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES
    'JD0025', '同济大学附属实验中学', '同济大学附属',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;
