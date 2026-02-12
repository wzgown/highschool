-- ============================================================================
-- 2024年名额分配到区招生计划 - 种子数据
-- 数据来源: processed/quota/quota_to_district_2024.csv
-- ============================================================================

-- 上海市上海中学 (42032) - 上海市
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '42032' AND data_year = 2024), '42032',
    (SELECT id FROM ref_district WHERE code = 'SH'), 266, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学 (102056) - 上海市
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '102056' AND data_year = 2024), '102056',
    (SELECT id FROM ref_district WHERE code = 'SH'), 275, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学 (102057) - 上海市
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '102057' AND data_year = 2024), '102057',
    (SELECT id FROM ref_district WHERE code = 'SH'), 239, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 (152003) - 上海市
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '152003' AND data_year = 2024), '152003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 263, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学 (152006) - 上海市
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '152006' AND data_year = 2024), '152006',
    (SELECT id FROM ref_district WHERE code = 'SH'), 187, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校 (155001) - 上海市
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '155001' AND data_year = 2024), '155001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 54, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学 (12001) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12001' AND data_year = 2024), '12001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 118, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市大同中学 (12003) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12003' AND data_year = 2024), '12003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 128, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市向明中学 (12005) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12005' AND data_year = 2024), '12005',
    (SELECT id FROM ref_district WHERE code = 'SH'), 57, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学附属大境中学 (12007) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12007' AND data_year = 2024), '12007',
    (SELECT id FROM ref_district WHERE code = 'SH'), 88, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市光明中学 (12008) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12008' AND data_year = 2024), '12008',
    (SELECT id FROM ref_district WHERE code = 'SH'), 78, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市敬业中学 (12009) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12009' AND data_year = 2024), '12009',
    (SELECT id FROM ref_district WHERE code = 'SH'), 68, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市卢湾高级中学 (12010) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12010' AND data_year = 2024), '12010',
    (SELECT id FROM ref_district WHERE code = 'SH'), 88, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学（奉贤校区） (12002) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12002' AND data_year = 2024), '12002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 40, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市向明中学（浦江校区） (12006) - 黄浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '12006' AND data_year = 2024), '12006',
    (SELECT id FROM ref_district WHERE code = 'SH'), 38, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第二中学 (42001) - 徐汇区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '42001' AND data_year = 2024), '42001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 51, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南洋模范中学 (42008) - 徐汇区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '42008' AND data_year = 2024), '42008',
    (SELECT id FROM ref_district WHERE code = 'SH'), 90, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市位育中学 (42035) - 徐汇区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '42035' AND data_year = 2024), '42035',
    (SELECT id FROM ref_district WHERE code = 'SH'), 89, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南洋中学 (43015) - 徐汇区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '43015' AND data_year = 2024), '43015',
    (SELECT id FROM ref_district WHERE code = 'SH'), 71, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第二中学（梅陇校区） (42002) - 徐汇区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '42002' AND data_year = 2024), '42002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 48, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学徐汇分校 (42036) - 徐汇区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '42036' AND data_year = 2024), '42036',
    (SELECT id FROM ref_district WHERE code = 'SH'), 31, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第三女子中学 (52001) - 长宁区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '52001' AND data_year = 2024), '52001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 51, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市延安中学 (52002) - 长宁区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '52002' AND data_year = 2024), '52002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 72, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市复旦中学 (53004) - 长宁区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '53004' AND data_year = 2024), '53004',
    (SELECT id FROM ref_district WHERE code = 'SH'), 53, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市市西中学 (62001) - 静安区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '62001' AND data_year = 2024), '62001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 68, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市育才中学 (62002) - 静安区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '62002' AND data_year = 2024), '62002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 67, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新中高级中学 (62003) - 静安区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '62003' AND data_year = 2024), '62003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 67, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市市北中学 (62004) - 静安区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '62004' AND data_year = 2024), '62004',
    (SELECT id FROM ref_district WHERE code = 'SH'), 72, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市回民中学 (62011) - 静安区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '62011' AND data_year = 2024), '62011',
    (SELECT id FROM ref_district WHERE code = 'SH'), 52, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第六十中学 (63004) - 静安区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '63004' AND data_year = 2024), '63004',
    (SELECT id FROM ref_district WHERE code = 'SH'), 52, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市华东模范中学 (64001) - 静安区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '64001' AND data_year = 2024), '64001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 37, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市晋元高级中学 (72001) - 普陀区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '72001' AND data_year = 2024), '72001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 84, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨第二中学 (72002) - 普陀区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '72002' AND data_year = 2024), '72002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 82, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宜川中学 (73003) - 普陀区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '73003' AND data_year = 2024), '73003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 84, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 (73082) - 普陀区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '73082' AND data_year = 2024), '73082',
    (SELECT id FROM ref_district WHERE code = 'SH'), 29, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市复兴高级中学 (92001) - 虹口区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '92001' AND data_year = 2024), '92001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 70, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第一附属中学 (92002) - 虹口区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '92002' AND data_year = 2024), '92002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 63, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海财经大学附属北郊高级中学 (93001) - 虹口区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '93001' AND data_year = 2024), '93001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 53, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市杨浦高级中学 (102004) - 杨浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '102004' AND data_year = 2024), '102004',
    (SELECT id FROM ref_district WHERE code = 'SH'), 98, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市控江中学 (102032) - 杨浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '102032' AND data_year = 2024), '102032',
    (SELECT id FROM ref_district WHERE code = 'SH'), 98, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 同济大学第一附属中学 (103002) - 杨浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '103002' AND data_year = 2024), '103002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 82, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市七宝中学 (122001) - 闵行区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '122001' AND data_year = 2024), '122001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 117, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行中学 (123001) - 闵行区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '123001' AND data_year = 2024), '123001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 117, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学闵行紫竹分校 (122002) - 闵行区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '122002' AND data_year = 2024), '122002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 67, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学闵行分校 (122003) - 闵行区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '122003' AND data_year = 2024), '122003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 67, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学闵行分校 (122004) - 闵行区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '122004' AND data_year = 2024), '122004',
    (SELECT id FROM ref_district WHERE code = 'SH'), 64, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市行知中学 (132001) - 宝山区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '132001' AND data_year = 2024), '132001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 96, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海大学附属中学 (132002) - 宝山区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '132002' AND data_year = 2024), '132002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 96, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市吴淞中学 (133001) - 宝山区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '133001' AND data_year = 2024), '133001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 94, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学宝山分校 (132003) - 宝山区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '132003' AND data_year = 2024), '132003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 17, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 (133003) - 宝山区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '133003' AND data_year = 2024), '133003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 35, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区第一中学 (142001) - 嘉定区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2024), '142001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 88, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学嘉定分校 (142002) - 嘉定区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2024), '142002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 105, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建平中学 (152001) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '152001' AND data_year = 2024), '152001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 109, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市进才中学 (152002) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '152002' AND data_year = 2024), '152002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 109, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海南汇中学 (152004) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '152004' AND data_year = 2024), '152004',
    (SELECT id FROM ref_district WHERE code = 'SH'), 140, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洋泾中学 (153001) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '153001' AND data_year = 2024), '153001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 109, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市高桥中学 (153004) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '153004' AND data_year = 2024), '153004',
    (SELECT id FROM ref_district WHERE code = 'SH'), 94, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市川沙中学 (153005) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '153005' AND data_year = 2024), '153005',
    (SELECT id FROM ref_district WHERE code = 'SH'), 94, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海中学东校 (151078) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '151078' AND data_year = 2024), '151078',
    (SELECT id FROM ref_district WHERE code = 'SH'), 78, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东复旦附中分校 (152005) - 浦东新区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '152005' AND data_year = 2024), '152005',
    (SELECT id FROM ref_district WHERE code = 'SH'), 56, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山中学 (162000) - 金山区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '162000' AND data_year = 2024), '162000',
    (SELECT id FROM ref_district WHERE code = 'SH'), 74, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第三附属中学 (163002) - 金山区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '163002' AND data_year = 2024), '163002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 74, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江二中 (172001) - 松江区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '172001' AND data_year = 2024), '172001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 78, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江一中 (173001) - 松江区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '173001' AND data_year = 2024), '173001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 78, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学松江分校 (172002) - 松江区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '172002' AND data_year = 2024), '172002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 26, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学附属外国语学校松江云间中学 (174003) - 松江区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '174003' AND data_year = 2024), '174003',
    (SELECT id FROM ref_district WHERE code = 'SH'), 78, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦高级中学 (182001) - 青浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '182001' AND data_year = 2024), '182001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 106, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市朱家角中学 (183002) - 青浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '183002' AND data_year = 2024), '183002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 106, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学青浦分校 (182002) - 青浦区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '182002' AND data_year = 2024), '182002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 41, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤中学 (202001) - 奉贤区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '202001' AND data_year = 2024), '202001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 82, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学临港奉贤分校 (202002) - 奉贤区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '202002' AND data_year = 2024), '202002',
    (SELECT id FROM ref_district WHERE code = 'SH'), 41, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明中学 (512000) - 崇明区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '512000' AND data_year = 2024), '512000',
    (SELECT id FROM ref_district WHERE code = 'SH'), 62, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校东滩高级中学 (512001) - 崇明区
INSERT INTO ref_quota_allocation_district (
    year, school_id, school_code, district_id, quota_count, data_year
) VALUES (
    2024, (SELECT id FROM ref_school WHERE code = '512001' AND data_year = 2024), '512001',
    (SELECT id FROM ref_district WHERE code = 'SH'), 30, 2024
) ON CONFLICT (year, school_code, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
