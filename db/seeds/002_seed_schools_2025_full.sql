-- ==========================================================================
-- 2025年学校全量数据 - 种子数据
-- 数据来源：original_data/processed/2025/schools/2025年学校信息.csv
-- 来源：基于2025年名额分配到区招生计划（76所）
-- 注：全量更新2025年学校信息，覆盖ref_school表
-- ==========================================================================

-- 上海市上海中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '042032',
    '上海市上海中学',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海交通大学附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '102056',
    '上海交通大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 复旦大学附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '102057',
    '复旦大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第二附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '152003',
    '华东师范大学第二附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海师范大学附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '152006',
    '上海师范大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市实验学校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '155001',
    '上海市实验学校',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市格致中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012001',
    '上海市格致中学',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市大同中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012003',
    '上海市大同中学',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市向明中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012005',
    '上海市向明中学',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海外国语大学附属大境中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012007',
    '上海外国语大学附属大境中学',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市光明中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012008',
    '上海市光明中学',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市敬业中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012009',
    '上海市敬业中学',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市卢湾高级中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012010',
    '上海市卢湾高级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市格致中学（奉贤校区）
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012002',
    '上海市格致中学（奉贤校区）',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市向明中学（浦江校区）
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '012006',
    '上海市向明中学（浦江校区）',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市第二中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '042001',
    '上海市第二中学',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市南洋模范中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '042008',
    '上海市南洋模范中学',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市位育中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '042035',
    '上海市位育中学',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市南洋中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '043015',
    '上海市南洋中学',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市第二中学（梅陇校区）
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '042002',
    '上海市第二中学（梅陇校区）',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 复旦大学附属中学徐汇分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '042036',
    '复旦大学附属中学徐汇分校',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市第三女子中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '052001',
    '上海市第三女子中学',
    (SELECT id FROM ref_district WHERE code = 'CN'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市延安中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '052002',
    '上海市延安中学',
    (SELECT id FROM ref_district WHERE code = 'CN'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市复旦中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '053004',
    '上海市复旦中学',
    (SELECT id FROM ref_district WHERE code = 'CN'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市市西中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '062001',
    '上海市市西中学',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市育才中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '062002',
    '上海市育才中学',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市新中高级中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '062003',
    '上海市新中高级中学',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市市北中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '062004',
    '上海市市北中学',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市回民中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '062011',
    '上海市回民中学',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市第六十中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '063004',
    '上海市第六十中学',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市华东模范中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '064001',
    '上海市华东模范中学',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市晋元高级中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '072001',
    '上海市晋元高级中学',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市曹杨第二中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '072002',
    '上海市曹杨第二中学',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市宜川中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '073003',
    '上海市宜川中学',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第二附属中学（普陀校区）
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '073082',
    '华东师范大学第二附属中学（普陀校区）',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 复旦大学附属复兴中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '092001',
    '复旦大学附属复兴中学',
    (SELECT id FROM ref_district WHERE code = 'HK'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第一附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '092002',
    '华东师范大学第一附属中学',
    (SELECT id FROM ref_district WHERE code = 'HK'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海财经大学附属北郊高级中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '093001',
    '上海财经大学附属北郊高级中学',
    (SELECT id FROM ref_district WHERE code = 'HK'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市杨浦高级中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '102004',
    '上海市杨浦高级中学',
    (SELECT id FROM ref_district WHERE code = 'YP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市控江中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '102032',
    '上海市控江中学',
    (SELECT id FROM ref_district WHERE code = 'YP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 同济大学第一附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '103002',
    '同济大学第一附属中学',
    (SELECT id FROM ref_district WHERE code = 'YP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市七宝中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '122001',
    '上海市七宝中学',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市闵行中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '123001',
    '上海市闵行中学',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第二附属中学闵行紫竹分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '122002',
    '华东师范大学第二附属中学闵行紫竹分校',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海师范大学附属中学闵行分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '122003',
    '上海师范大学附属中学闵行分校',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海交通大学附属中学闵行分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '122004',
    '上海交通大学附属中学闵行分校',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市行知中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '132001',
    '上海市行知中学',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海大学附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '132002',
    '上海大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市吴淞中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '133001',
    '上海市吴淞中学',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海师范大学附属中学宝山分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '132003',
    '上海师范大学附属中学宝山分校',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第二附属中学（宝山校区）
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '133003',
    '华东师范大学第二附属中学（宝山校区）',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市嘉定区第一中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '142001',
    '上海市嘉定区第一中学',
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海交通大学附属中学嘉定分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '142002',
    '上海交通大学附属中学嘉定分校',
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海师范大学附属中学嘉定新城分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '142004',
    '上海师范大学附属中学嘉定新城分校',
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市建平中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '152001',
    '上海市建平中学',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市进才中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '152002',
    '上海市进才中学',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海南汇中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '152004',
    '上海南汇中学',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市洋泾中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '153001',
    '上海市洋泾中学',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市高桥中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '153004',
    '上海市高桥中学',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市川沙中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '153005',
    '上海市川沙中学',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海中学东校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '151078',
    '上海中学东校',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市浦东复旦附中分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '152005',
    '上海市浦东复旦附中分校',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市金山中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '162000',
    '上海市金山中学',
    (SELECT id FROM ref_district WHERE code = 'JS'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第三附属中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '163002',
    '华东师范大学第三附属中学',
    (SELECT id FROM ref_district WHERE code = 'JS'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市松江二中
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '172001',
    '上海市松江二中',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市松江一中
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '173001',
    '上海市松江一中',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第二附属中学松江分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '172002',
    '华东师范大学第二附属中学松江分校',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海师范大学附属中学松江分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '172004',
    '上海师范大学附属中学松江分校',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海外国语大学附属外国语学校松江云间中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '174003',
    '上海外国语大学附属外国语学校松江云间中学',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市青浦高级中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '182001',
    '上海市青浦高级中学',
    (SELECT id FROM ref_district WHERE code = 'QP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市朱家角中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '183002',
    '上海市朱家角中学',
    (SELECT id FROM ref_district WHERE code = 'QP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 复旦大学附属中学青浦分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '182002',
    '复旦大学附属中学青浦分校',
    (SELECT id FROM ref_district WHERE code = 'QP'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市奉贤中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '202001',
    '上海市奉贤中学',
    (SELECT id FROM ref_district WHERE code = 'FX'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 华东师范大学第二附属中学临港奉贤分校
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '202002',
    '华东师范大学第二附属中学临港奉贤分校',
    (SELECT id FROM ref_district WHERE code = 'FX'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市崇明中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '512000',
    '上海市崇明中学',
    (SELECT id FROM ref_district WHERE code = 'CM'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP


-- 上海市实验学校东滩高级中学
INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    '512001',
    '上海市实验学校东滩高级中学',
    (SELECT id FROM ref_district WHERE code = 'CM'),
    (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
    (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
    (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
    FALSE,
    2025,
    'None'
    2025)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    updated_at = CURRENT_TIMESTAMP

