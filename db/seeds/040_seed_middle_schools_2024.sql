-- ============================================================================
-- 2024年初中学校名单 - 种子数据（从名额分配到校数据提取）
-- 数据来源: raw/2024/quota_school/*.csv（12个区）+ cutoff_scores/*.csv（4个区）
-- 注：不选择生源初中默认为TRUE，适用于名额分配到校填报资格判断
-- 注：此数据仅包含有名额分配到校的初中学校
-- ============================================================================

-- 格致初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011001', '格致初级中学', '格致初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 大同初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011002', '大同初级中学', '大同初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 向明初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011003', '向明初级中学', '向明初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 大境初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011004', '大境初级中学', '大境初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 光明初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011005', '光明初级中学', '光明初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 敬业初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011006', '敬业初级中学', '敬业初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 卢湾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011007', '卢湾中学', '卢湾中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 市八初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011008', '市八初级中学', '市八初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 尚文中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011009', '尚文中学', '尚文中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 交附黄浦实验
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011012', '交附黄浦实验', '交附黄浦实验',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 清华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011014', '清华中学', '清华中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 民办明珠中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011015', '民办明珠中学', '民办明珠中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 民办立达中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011016', '民办立达中学', '民办立达中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 民办震旦外国语
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '011017', '民办震旦外国语', '民办震旦外国',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 市十中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '013003', '市十中学', '市十中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 储能中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '013004', '储能中学', '储能中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 金陵中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '014001', '金陵中学', '金陵中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 市南中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '014003', '市南中学', '市南中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上音比乐中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '014004', '上音比乐中学', '上音比乐中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 中山学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '015003', '中山学校', '中山学校',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 民办永昌学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '015004', '民办永昌学校', '民办永昌学校',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 康德双语实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '015005', '康德双语实验学校', '康德双语实验',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 大同初级中学（原黄浦学校）
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '017777', '大同初级中学（原黄浦学校）', '大同初级中学',
    (SELECT id FROM ref_district WHERE code = 'HP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市位育初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041302', '上海市位育初级中学', '上海市位育初',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第二初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041305', '上海市第二初级中学', '上海市第二初',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南洋模范初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041306', '上海市南洋模范初级中学', '上海市南洋模',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南洋初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041316', '上海市南洋初级中学', '上海市南洋初',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市田林中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041318', '上海市田林中学', '上海市田林中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市田林第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041319', '上海市田林第二中学', '上海市田林第',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市田林第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041320', '上海市田林第三中学', '上海市田林第',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市龙苑中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041326', '上海市龙苑中学', '上海市龙苑中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市徐汇区教育学院附属实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041327', '上海市徐汇区教育学院附属实验中学', '上海市徐汇区',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市长桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041328', '上海市长桥中学', '上海市长桥中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市园南中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041329', '上海市园南中学', '上海市园南中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市汾阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041331', '上海市汾阳中学', '上海市汾阳中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市梅园中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041334', '上海市梅园中学', '上海市梅园中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市紫阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041336', '上海市紫阳中学', '上海市紫阳中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市康健外国语实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041347', '上海市康健外国语实验中学', '上海市康健外',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市世外中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041363', '上海市世外中学', '上海市世外中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办华育中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '041385', '上海市民办华育中学', '上海市民办华',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市中国中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044103', '上海市中国中学', '上海市中国中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第五十四中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044107', '上海市第五十四中学', '上海市第五十',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市徐汇中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044109', '上海市徐汇中学', '上海市徐汇中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 徐汇南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044110', '徐汇南校', '徐汇南校',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第四中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044111', '上海市第四中学', '上海市第四中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市零陵中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044114', '上海市零陵中学', '上海市零陵中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师大附中附属龙华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044125', '上海师大附中附属龙华中学', '上海师大附中',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东理工大学附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044133', '华东理工大学附属中学', '华东理工大学',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市西南位育中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044162', '上海市西南位育中学', '上海市西南位',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市西南模范中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044164', '上海市西南模范中学', '上海市西南模',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办位育中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044181', '上海民办位育中学', '上海民办位育',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办南模中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '044182', '上海民办南模中学', '上海民办南模',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市位育实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '045304', '上海市位育实验学校', '上海市位育实',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学第三附属实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '045444', '上海师范大学第三附属实验学校', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'XH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第三女子初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0001', '上海市第三女子初级中学', '上海市第三女',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市天山第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0002', '上海市天山第二中学', '上海市天山第',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市姚连生中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0003', '上海市姚连生中学', '上海市姚连生',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市天山初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0004', '上海市天山初级中学', '上海市天山初',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市虹桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0005', '上海市虹桥中学', '上海市虹桥中',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市延安实验初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0006', '上海市延安实验初级中学', '上海市延安实',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市复旦初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0007', '上海市复旦初级中学', '上海市复旦初',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市泸定中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0008', '上海市泸定中学', '上海市泸定中',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市娄山中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0009', '上海市娄山中学', '上海市娄山中',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市西延安中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0010', '上海市西延安中学', '上海市西延安',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新泾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0011', '上海市新泾中学', '上海市新泾中',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办新世纪中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0012', '上海市民办新世纪中学', '上海市民办新',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市延安初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0013', '上海市延安初级中学', '上海市延安初',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建青实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0014', '上海市建青实验学校', '上海市建青实',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市西郊学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0015', '上海市西郊学校', '上海市西郊学',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东政法大学附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0016', '华东政法大学附属中学', '华东政法大学',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市仙霞高级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0017', '上海市仙霞高级中学', '上海市仙霞高',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市开元学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CN0018', '上海市开元学校', '上海市开元学',
    (SELECT id FROM ref_district WHERE code = 'CN'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市育才初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061002', '上海市育才初级中学', '上海市育才初',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市静安区协和双语培明学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061003', '上海市静安区协和双语培明学校', '上海市静安区',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市时代中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061005', '上海市时代中学', '上海市时代中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市五四中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061008', '上海市五四中学', '上海市五四中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 民办上海上外静安外国语中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061009', '民办上海上外静安外国语中学', '民办上海上外',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市静安区市北初级中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061050', '上海市静安区市北初级中学北校', '上海市静安区',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新中初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061051', '上海市新中初级中学', '上海市新中初',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市静安区实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061053', '上海市静安区实验中学', '上海市静安区',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市朝阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061055', '上海市朝阳中学', '上海市朝阳中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市市北初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061059', '上海市市北初级中学', '上海市市北初',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市风华初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061060', '上海市风华初级中学', '上海市风华初',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市彭浦初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061061', '上海市彭浦初级中学', '上海市彭浦初',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学苏河湾实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061062', '上海外国语大学苏河湾实验中学', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青云中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061066', '上海市青云中学', '上海市青云中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市岭南中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061071', '上海市岭南中学', '上海市岭南中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市保德中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061072', '上海市保德中学', '上海市保德中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市彭浦第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061073', '上海市彭浦第三中学', '上海市彭浦第',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市彭浦第四中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '061074', '上海市彭浦第四中学', '上海市彭浦第',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市回民中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '062011', '上海市回民中学', '上海市回民中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民立中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '063001', '上海市民立中学', '上海市民立中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '063002', '上海市第一中学', '上海市第一中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市久隆模范中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '063008', '上海市久隆模范中学', '上海市久隆模',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闸北第八中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '063077', '上海市闸北第八中学', '上海市闸北第',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市华东模范中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '064001', '上海市华东模范中学', '上海市华东模',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 同济大学附属七一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '064003', '同济大学附属七一中学', '同济大学附属',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市向东中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '064007', '上海市向东中学', '上海市向东中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海田家炳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '064020', '上海田家炳中学', '上海田家炳中',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办扬波中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '064021', '上海市民办扬波中学', '上海市民办扬',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办新和中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '064023', '上海市民办新和中学', '上海市民办新',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办风范中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '064024', '上海市民办风范中学', '上海市民办风',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市爱国学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '065001', '上海市爱国学校', '上海市爱国学',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市静安区教育学院附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '065002', '上海市静安区教育学院附属学校', '上海市静安区',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市华灵学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '065056', '上海市华灵学校', '上海市华灵学',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三泉学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '065057', '上海市三泉学校', '上海市三泉学',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海戏剧学院附属静安学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '065058', '上海戏剧学院附属静安学校', '上海戏剧学院',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市静安区大宁国际学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '065078', '上海市静安区大宁国际学校', '上海市静安区',
    (SELECT id FROM ref_district WHERE code = 'JA'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洵阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71045', '上海市洵阳中学', '上海市洵阳中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市北海中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71046', '上海市北海中学', '上海市北海中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市延河中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71047', '上海市延河中学', '上海市延河中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨第二中学附属实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71048', '上海市曹杨第二中学附属实验中学', '上海市曹杨第',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第四附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71049', '华东师范大学第四附属中学', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市怒江中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71050', '上海市怒江中学', '上海市怒江中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属第二实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71051', '上海师范大学附属第二实验学校', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市真北中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71053', '上海市真北中学', '上海市真北中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市普陀区教育学院附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71054', '上海市普陀区教育学院附属中学', '上海市普陀区',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市梅陇中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71056', '上海市梅陇中学', '上海市梅陇中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海兰田中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '71060', '上海兰田中学', '上海兰田中学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '73004', '上海市曹杨中学', '上海市曹杨中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 同济大学第二附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74005', '同济大学第二附属中学', '同济大学第二',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新杨中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74009', '上海市新杨中学', '上海市新杨中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市长征中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74010', '上海市长征中学', '上海市长征中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市桃浦中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74011', '上海市桃浦中学', '上海市桃浦中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市晋元高级中学附属学校南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74012', '上海市晋元高级中学附属学校南校', '上海市晋元高',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海音乐学院附属安师实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74016', '上海音乐学院附属安师实验中学', '上海音乐学院',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海华东师范大学附属进华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74018', '上海华东师范大学附属进华中学', '上海华东师范',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海安生学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '74081', '上海安生学校', '上海安生学校',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海培佳双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75013', '上海培佳双语学校', '上海培佳双语',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市光新学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75044', '上海市光新学校', '上海市光新学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市铜川学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75061', '上海市铜川学校', '上海市铜川学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市沙田学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75062', '上海市沙田学校', '上海市沙田学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属外国语实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75063', '华东师范大学附属外国语实验学校', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市子长学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75064', '上海市子长学校', '上海市子长学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洛川学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75065', '上海市洛川学校', '上海市洛川学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宜川中学附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75066', '上海市宜川中学附属学校', '上海市宜川中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨中学附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75067', '上海市曹杨中学附属学校', '上海市曹杨中',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市普陀区教育学院附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75068', '上海市普陀区教育学院附属学校', '上海市普陀区',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市晋元高级中学附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75069', '上海市晋元高级中学附属学校', '上海市晋元高',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨第二中学附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75070', '上海市曹杨第二中学附属学校', '上海市曹杨第',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办新黄浦实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75071', '上海市民办新黄浦实验学校', '上海市民办新',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市江宁学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75072', '上海市江宁学校', '上海市江宁学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市中远实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75073', '上海市中远实验学校', '上海市中远实',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金鼎学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75077', '上海市金鼎学校', '上海市金鼎学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学尚阳外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75078', '上海外国语大学尚阳外国语学校', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市文达学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75079', '上海市文达学校', '上海市文达学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海理工大学附属普陀实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75080', '上海理工大学附属普陀实验学校', '上海理工大学',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市万里城实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '75113', '上海市万里城实验学校', '上海市万里城',
    (SELECT id FROM ref_district WHERE code = 'PT'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市钟山初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0001', '上海市钟山初级中学', '上海市钟山初',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市江湾初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0002', '上海市江湾初级中学', '上海市江湾初',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市复兴实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0003', '上海市复兴实验中学', '上海市复兴实',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市虹口区教育学院实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0004', '上海市虹口区教育学院实验中学', '上海市虹口区',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第五中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0005', '上海市第五中学', '上海市第五中',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曲阳第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0006', '上海市曲阳第二中学', '上海市曲阳第',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市北虹初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0007', '上海市北虹初级中学', '上海市北虹初',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市海南中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0008', '上海市海南中学', '上海市海南中',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市丰镇中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0009', '上海市丰镇中学', '上海市丰镇中',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市澄衷初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0010', '上海市澄衷初级中学', '上海市澄衷初',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市鲁迅初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0011', '上海市鲁迅初级中学', '上海市鲁迅初',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市继光初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0012', '上海市继光初级中学', '上海市继光初',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第一附属初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0013', '华东师范大学第一附属初级中学', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办新复兴初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0014', '上海市民办新复兴初级中学', '上海市民办新',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办新华初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0015', '上海市民办新华初级中学', '上海市民办新',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办新北郊初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0016', '上海市民办新北郊初级中学', '上海市民办新',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第五十二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0017', '上海市第五十二中学', '上海市第五十',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办迅行中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0018', '上海市民办迅行中学', '上海市民办迅',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学第一实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0019', '上海外国语大学第一实验学校', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市北郊学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0020', '上海市北郊学校', '上海市北郊学',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市霍山学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0021', '上海市霍山学校', '上海市霍山学',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市长青学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0022', '上海市长青学校', '上海市长青学',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市虹口实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0023', '上海市虹口实验学校', '上海市虹口实',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海世外教育附属虹口区欧阳学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'HK0024', '上海世外教育附属虹口区欧阳学校', '上海世外教育',
    (SELECT id FROM ref_district WHERE code = 'HK'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市铁岭中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101000', '上海市铁岭中学', '上海市铁岭中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市鞍山初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101001', '上海市鞍山初级中学', '上海市鞍山初',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市十五中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101002', '上海市十五中学', '上海市十五中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市杨浦初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101003', '上海市杨浦初级中学', '上海市杨浦初',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市惠民中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101004', '上海市惠民中学', '上海市惠民中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市辽阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101005', '上海市辽阳中学', '上海市辽阳中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新大桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101006', '上海市新大桥中学', '上海市新大桥',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建设初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101007', '上海市建设初级中学', '上海市建设初',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市东辽阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101008', '上海市东辽阳中学', '上海市东辽阳',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市二十五中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101009', '上海市二十五中学', '上海市二十五',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海理工大学附属初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101012', '上海理工大学附属初级中学', '上海理工大学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市杨浦区教育学院附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101014', '上海市杨浦区教育学院附属中学', '上海市杨浦区',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市同济初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101015', '上海市同济初级中学', '上海市同济初',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三门中学（上海财经大学
附属初级中学）
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101016', '上海市三门中学（上海财经大学
附属初级中学）', '上海市三门中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市包头中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101018', '上海市包头中学', '上海市包头中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市思源中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101019', '上海市思源中学', '上海市思源中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市鞍山实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101020', '上海市鞍山实验中学', '上海市鞍山实',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市同济第二初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101021', '上海市同济第二初级中学', '上海市同济第',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市国和中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101022', '上海市国和中学', '上海市国和中',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海理工大学附属实验初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101023', '上海理工大学附属实验初级中学', '上海理工大学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市控江初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101024', '上海市控江初级中学', '上海市控江初',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市存志学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101026', '上海市存志学校', '上海市存志学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办杨浦凯慧初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '101027', '上海民办杨浦凯慧初级中学', '上海民办杨浦',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市市东实验学校（上海市市
东中学）
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '103012', '上海市市东实验学校（上海市市
东中学）', '上海市市东实',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市复旦实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '103075', '上海市复旦实验中学', '上海市复旦实',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办兰生中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '104001', '上海民办兰生中学', '上海民办兰生',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市长阳实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '104014', '上海市长阳实验学校', '上海市长阳实',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办杨浦实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '104067', '上海民办杨浦实验学校', '上海民办杨浦',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市体育学院附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '104073', '上海市体育学院附属中学', '上海市体育学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海音乐学院实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105000', '上海音乐学院实验学校', '上海音乐学院',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市黄兴学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105001', '上海市黄兴学校', '上海市黄兴学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市昆明学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105002', '上海市昆明学校', '上海市昆明学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市育鹰学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105003', '上海市育鹰学校', '上海市育鹰学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海杨浦双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105004', '上海杨浦双语学校', '上海杨浦双语',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市市光学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105005', '上海市市光学校', '上海市市光学',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办沪东外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105006', '上海民办沪东外国语学校', '上海民办沪东',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海同大实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105007', '上海同大实验学校', '上海同大实验',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学第二附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '105008', '复旦大学第二附属学校', '复旦大学第二',
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 初中学校名称
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    (SELECT id FROM ref_district WHERE code = 'YP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市航华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121002', '上海市航华中学', '上海市航华中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区上虹中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121003', '上海市闵行区上虹中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市龙柏中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121004', '上海市龙柏中学', '上海市龙柏中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区七宝第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121005', '上海市闵行区七宝第二中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市罗阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121008', '上海市罗阳中学', '上海市罗阳中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区莘松中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121009', '上海市闵行区莘松中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市七宝中学附属闵行金都实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121010', '上海市七宝中学附属闵行金都实验中学', '上海市七宝中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区北桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121011', '上海市闵行区北桥中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区浦江第一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121013', '上海市闵行区浦江第一中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区浦江第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121014', '上海市闵行区浦江第二中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区浦江第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121015', '上海市闵行区浦江第三中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行第四中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121016', '上海市闵行第四中学', '上海市闵行第',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区颛桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121018', '上海市闵行区颛桥中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校西校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121022', '上海市实验学校西校', '上海市实验学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区鹤北初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121024', '上海市闵行区鹤北初级中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区龙茗中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121025', '上海市闵行区龙茗中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市七宝实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121026', '上海市七宝实验中学', '上海市七宝实',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市师资培训中心附属闵行实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121027', '上海市师资培训中心附属闵行实验中学', '上海市师资培',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市吴泾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121030', '上海市吴泾中学', '上海市吴泾中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区七宝第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121031', '上海市闵行区七宝第三中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学附属初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121032', '华东师范大学第二附属中学附属初级中学', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区浦航实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121033', '上海市闵行区浦航实验中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区马桥复旦万科实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121034', '上海市闵行区马桥复旦万科实验中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海中医药大学附属闵行晶城中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121035', '上海中医药大学附属闵行晶城中学', '上海中医药大',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属闵行第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121036', '上海师范大学附属闵行第三中学', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区田园外国语中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121038', '上海市闵行区田园外国语中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行中学附属实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121039', '上海市闵行中学附属实验中学', '上海市闵行中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海尚师初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121131', '上海尚师初级中学', '上海尚师初级',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市骏博外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '121132', '上海市骏博外国语学校', '上海市骏博外',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124006', '上海市闵行第三中学', '上海市闵行第',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区教育学院附属友爱实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124007', '上海市闵行区教育学院附属友爱实验中学', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124008', '上海交通大学附属第二中学', '上海交通大学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办上宝中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124009', '上海市民办上宝中学', '上海市民办上',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市七宝中学附属鑫都实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124011', '上海市七宝中学附属鑫都实验中学', '上海市七宝中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市文来中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124108', '上海市文来中学', '上海市文来中',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办文绮中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124109', '上海市民办文绮中学', '上海市民办文',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海闵行区协和双语教科学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '124115', '上海闵行区协和双语教科学校', '上海闵行区协',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区诸翟学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125001', '上海市闵行区诸翟学校', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金汇实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125002', '上海市金汇实验学校', '上海市金汇实',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市莘光学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125003', '上海市莘光学校', '上海市莘光学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区纪王学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125010', '上海市闵行区纪王学校', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市马桥强恕学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125011', '上海市马桥强恕学校', '上海市马桥强',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市古美学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125013', '上海市古美学校', '上海市古美学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学康城实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125015', '上海师范大学康城实验学校', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市莘城学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125016', '上海市莘城学校', '上海市莘城学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区明星学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125017', '上海市闵行区明星学校', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区文来实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125018', '上海市闵行区文来实验学校', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区君莲学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125020', '上海市闵行区君莲学校', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区华漕学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125021', '上海市闵行区华漕学校', '上海市闵行区',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海世外教育附属浦江外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125022', '上海世外教育附属浦江外国语学校', '上海世外教育',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东理工大学附属闵行梅陇实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125027', '华东理工大学附属闵行梅陇实验学校', '华东理工大学',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办德英乐实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125106', '上海市民办德英乐实验学校', '上海市民办德',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市燎原双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125107', '上海市燎原双语学校', '上海市燎原双',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办协和双语尚音学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125109', '上海市民办协和双语尚音学校', '上海市民办协',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办协和双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125110', '上海市民办协和双语学校', '上海市民办协',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办万源城协和双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125112', '上海市民办万源城协和双语学校', '上海市民办万',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海星河湾双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125113', '上海星河湾双语学校', '上海星河湾双',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海博世凯外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125114', '上海博世凯外国语学校', '上海博世凯外',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海闵行区万科双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125115', '上海闵行区万科双语学校', '上海闵行区万',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海闵行区民办美高双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125116', '上海闵行区民办美高双语学校', '上海闵行区民',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海闵行区诺达双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125117', '上海闵行区诺达双语学校', '上海闵行区诺',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办圣华紫竹双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125118', '上海民办圣华紫竹双语学校', '上海民办圣华',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海闵行区民办德闳学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '125119', '上海闵行区民办德闳学校', '上海闵行区民',
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 初中学校名称
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    (SELECT id FROM ref_district WHERE code = 'MH'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市淞谊中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131002', '上海市淞谊中学', '上海市淞谊中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区教育学院附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131004', '上海市宝山区教育学院附属中学', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市吴淞初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131006', '上海市吴淞初级中学', '上海市吴淞初',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市海滨第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131008', '上海市海滨第二中学', '上海市海滨第',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办宝莲中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131009', '上海民办宝莲中学', '上海民办宝莲',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市吴淞第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131010', '上海市吴淞第二中学', '上海市吴淞第',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市虎林中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131011', '上海市虎林中学', '上海市虎林中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市泗塘中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131012', '上海市泗塘中学', '上海市泗塘中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区求真中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131013', '上海市宝山区求真中学北校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市泗塘第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131014', '上海市泗塘第二中学', '上海市泗塘第',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市长江第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131015', '上海市长江第二中学', '上海市长江第',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区求真中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131016', '上海市宝山区求真中学', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市大场中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131018', '上海市大场中学', '上海市大场中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市大华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131019', '上海市大华中学', '上海市大华中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市月浦中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131020', '上海市月浦中学', '上海市月浦中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市罗泾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131023', '上海市罗泾中学', '上海市罗泾中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市罗南中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131026', '上海市罗南中学', '上海市罗南中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办交华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131035', '上海市民办交华中学', '上海市民办交',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区高境镇第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131036', '上海市宝山区高境镇第三中学', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区罗店第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131038', '上海市宝山区罗店第二中学', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区乐之中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131039', '上海市宝山区乐之中学', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区美兰湖中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131040', '上海市宝山区美兰湖中学', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区杨泰实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131041', '上海市宝山区杨泰实验中学', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属宝山经纬实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '131042', '上海师范大学附属宝山经纬实验中学', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属宝山罗店中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '133002', '上海师范大学附属宝山罗店中学', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市顾村中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '134004', '上海市顾村中学', '上海市顾村中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市行知实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '134005', '上海市行知实验中学', '上海市行知实',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市高境第一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '134006', '上海市高境第一中学', '上海市高境第',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市盛桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '134008', '上海市盛桥中学', '上海市盛桥中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市同洲模范学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135001', '上海市同洲模范学校', '上海市同洲模',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135002', '上海市宝山实验学校', '上海市宝山实',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办锦秋学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135004', '上海市民办锦秋学校', '上海市民办锦',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市月浦实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135005', '上海市月浦实验学校', '上海市月浦实',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝钢新世纪学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135006', '上海市宝钢新世纪学校', '上海市宝钢新',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市吴淞实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135007', '上海市吴淞实验学校', '上海市吴淞实',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区天馨学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135009', '上海市宝山区天馨学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区上海大学附属中学实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135010', '上海市宝山区上海大学附属中学实验学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区共富实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135011', '上海市宝山区共富实验学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学宝山实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135012', '华东师范大学宝山实验学校', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海大学附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135013', '上海大学附属学校', '上海大学附属',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海农场学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135014', '上海农场学校', '上海农场学校',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区馨家园学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135018', '上海市宝山区馨家园学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海世外教育附属宝山大华实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135019', '上海世外教育附属宝山大华实验学校', '上海世外教育',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区教育学院实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135020', '上海市宝山区教育学院实验学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区鹿鸣学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135021', '上海市宝山区鹿鸣学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区庙行实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135022', '上海市宝山区庙行实验学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区顾村实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135023', '上海市宝山区顾村实验学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市教育学会宝山实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135024', '上海市教育学会宝山实验学校', '上海市教育学',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区行知外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135025', '上海市宝山区行知外国语学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区新民实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135026', '上海市宝山区新民实验学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市刘行新华实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135027', '上海市刘行新华实验学校', '上海市刘行新',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办华曜宝山实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135028', '上海民办华曜宝山实验学校', '上海民办华曜',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海大学附属宝山外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135029', '上海大学附属宝山外国语学校', '上海大学附属',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市白茅岭学校（上海市白茅岭学校军天湖分校）
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135030', '上海市白茅岭学校（上海市白茅岭学校军天湖分校）', '上海市白茅岭',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学附属宝山双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135031', '上海外国语大学附属宝山双语学校', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市行知中学附属宝山实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135032', '上海市行知中学附属宝山实验学校', '上海市行知中',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办至德实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135033', '上海民办至德实验学校', '上海民办至德',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海宝山区世外学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135034', '上海宝山区世外学校', '上海宝山区世',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属宝山实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135035', '上海师范大学附属宝山实验学校', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属宝山潜溪学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135036', '上海师范大学附属宝山潜溪学校', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市存志附属宝山实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135040', '上海市存志附属宝山实验学校', '上海市存志附',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属宝山宝杨实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135042', '华东师范大学附属宝山宝杨实验学校', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山区陈伯吹罗店实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '135043', '上海市宝山区陈伯吹罗店实验学校', '上海市宝山区',
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 合计
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    (SELECT id FROM ref_district WHERE code = 'BS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区启良中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0001', '上海市嘉定区启良中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区方泰中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0002', '上海市嘉定区方泰中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨二中附属江桥实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0003', '上海市曹杨二中附属江桥实验中学', '上海市曹杨二',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区迎园中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0004', '上海市嘉定区迎园中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区南苑中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0005', '上海市嘉定区南苑中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区黄渡中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0006', '上海市嘉定区黄渡中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区徐行中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0007', '上海市嘉定区徐行中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区马陆育才联合中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0008', '上海市嘉定区马陆育才联合中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办嘉一联合中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0009', '上海市民办嘉一联合中学', '上海市民办嘉',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区丰庄中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0010', '上海市嘉定区丰庄中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区外冈中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0011', '上海市嘉定区外冈中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办华曜嘉定初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0012', '上海民办华曜嘉定初级中学', '上海民办华曜',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区震川中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0013', '上海市嘉定区震川中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海大学附属嘉定留云中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0014', '上海大学附属嘉定留云中学', '上海大学附属',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 交大附中附属嘉定德富中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0015', '交大附中附属嘉定德富中学', '交大附中附属',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 同济大学附属实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0016', '同济大学附属实验中学', '同济大学附属',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区华江中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0017', '上海市嘉定区华江中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区新城实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0018', '上海市嘉定区新城实验中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区南翔中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0019', '上海市嘉定区南翔中学', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区疁城实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0020', '上海市嘉定区疁城实验学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区戬浜学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0021', '上海市嘉定区戬浜学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区朱桥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0022', '上海市嘉定区朱桥学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区苏民学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0023', '上海市嘉定区苏民学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办远东学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0024', '上海市民办远东学校', '上海市民办远',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办桃李园实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0025', '上海市民办桃李园实验学校', '上海市民办桃',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区华亭学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0026', '上海市嘉定区华亭学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区娄塘学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0027', '上海市嘉定区娄塘学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学嘉定外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0028', '上海外国语大学嘉定外国语学校', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区练川实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0029', '上海市嘉定区练川实验学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海华旭双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0030', '上海华旭双语学校', '上海华旭双语',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 中科院上海实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0031', '中科院上海实验学校', '中科院上海实',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海嘉定区世界外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0032', '上海嘉定区世界外国语学校', '上海嘉定区世',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区金鹤学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0033', '上海市嘉定区金鹤学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区嘉二实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0034', '上海市嘉定区嘉二实验学校', '上海市嘉定区',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海嘉定区民办华盛怀少学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JD0035', '上海嘉定区民办华盛怀少学校', '上海嘉定区民',
    (SELECT id FROM ref_district WHERE code = 'JD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建平中学西校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0001', '上海市建平中学西校', '上海市建平中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市进才中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0002', '上海市进才中学北校', '上海市进才中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属东昌中学南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0003', '华东师范大学附属东昌中学南校', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洋泾中学东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0004', '上海市洋泾中学东校', '上海市洋泾中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市上南中学东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0005', '上海市上南中学东校', '上海市上南中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市上南中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0006', '上海市上南中学北校', '上海市上南中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三林中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0007', '上海市三林中学北校', '上海市三林中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洪山中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0008', '上海市洪山中学', '上海市洪山中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市上南中学南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0009', '上海市上南中学南校', '上海市上南中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市清流中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0010', '上海市清流中学', '上海市清流中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦泾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0011', '上海市浦泾中学', '上海市浦泾中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属浦东实验中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0012', '上海交通大学附属浦东实验中学北校', '上海交通大学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区教育学院附属实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0013', '上海市浦东新区教育学院附属实验中学', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洋泾中学南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0014', '上海市洋泾中学南校', '上海市洋泾中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市东昌东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0015', '上海市东昌东校', '上海市东昌东',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市罗山中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0016', '上海市罗山中学', '上海市罗山中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金杨中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0017', '上海市金杨中学', '上海市金杨中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金川中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0018', '上海市金川中学', '上海市金川中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市华林中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0019', '上海市华林中学', '上海市华林中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市孙桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0020', '上海市孙桥中学', '上海市孙桥中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市育人中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0021', '上海市育人中学', '上海市育人中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市东林中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0022', '上海市东林中学', '上海市东林中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市施湾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0023', '上海市施湾中学', '上海市施湾中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市黄楼中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0024', '上海市黄楼中学', '上海市黄楼中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市王港中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0025', '上海市王港中学', '上海市王港中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市杨园中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0026', '上海市杨园中学', '上海市杨园中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市东沟中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0027', '上海市东沟中学', '上海市东沟中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属高桥实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0028', '上海师范大学附属高桥实验中学', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市凌桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0029', '上海市凌桥中学', '上海市凌桥中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市顾路中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0030', '上海市顾路中学', '上海市顾路中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东模范中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0031', '上海市浦东模范中学', '上海市浦东模',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市川沙中学华夏西校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0032', '上海市川沙中学华夏西校', '上海市川沙中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市陆行中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0033', '上海市陆行中学北校', '上海市陆行中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市致远中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0034', '上海市致远中学', '上海市致远中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区进才实验中学南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0035', '上海市浦东新区进才实验中学南校', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市蔡路中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0036', '上海市蔡路中学', '上海市蔡路中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市六团中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0037', '上海市六团中学', '上海市六团中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海戏剧学院附属浦东实验中学（原上海
市唐镇中学）
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0038', '上海戏剧学院附属浦东实验中学（原上海
市唐镇中学）', '上海戏剧学院',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦兴中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0039', '上海市浦兴中学', '上海市浦兴中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办恒洋外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0040', '上海浦东新区民办恒洋外国语学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办欣竹中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0041', '上海浦东新区民办欣竹中学', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新云台中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0042', '上海市新云台中学', '上海市新云台',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市陆行中学南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0043', '上海市陆行中学南校', '上海市陆行中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市杨思中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0044', '上海市杨思中学', '上海市杨思中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办浦东交中初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0045', '上海民办浦东交中初级中学', '上海民办浦东',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建平香梅中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0046', '上海市建平香梅中学', '上海市建平香',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南汇第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0047', '上海市南汇第二中学', '上海市南汇第',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南汇第三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0048', '上海市南汇第三中学', '上海市南汇第',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新港中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0049', '上海市新港中学', '上海市新港中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市书院中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0050', '上海市书院中学', '上海市书院中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市大团中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0051', '上海市大团中学', '上海市大团中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市坦直中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0052', '上海市坦直中学', '上海市坦直中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市傅雷中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0053', '上海市傅雷中学', '上海市傅雷中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市澧溪中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0054', '上海市澧溪中学', '上海市澧溪中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市六灶中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0055', '上海市六灶中学', '上海市六灶中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东教育发展研究院附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0056', '上海市浦东教育发展研究院附属中学', '上海市浦东教',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南汇第四中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0057', '上海市南汇第四中学', '上海市南汇第',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海中学东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0058', '上海中学东校', '上海中学东校',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东模范中学东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0059', '上海市浦东模范中学东校', '上海市浦东模',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市北蔡中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0060', '上海市北蔡中学', '上海市北蔡中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市临港第一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0061', '上海市临港第一中学', '上海市临港第',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办光华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0062', '上海民办光华中学', '上海民办光华',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南汇第五中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0063', '上海市南汇第五中学', '上海市南汇第',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区进才中学南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0064', '上海市浦东新区进才中学南校', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市临港实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0065', '上海市临港实验中学', '上海市临港实',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区进才中学东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0066', '上海市浦东新区进才中学东校', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东外国语学校东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0067', '上海市浦东外国语学校东校', '上海市浦东外',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东模范实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0068', '上海市浦东模范实验中学', '上海市浦东模',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区三灶实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0069', '上海市浦东新区三灶实验中学', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0070', '上海市实验学校南校', '上海市实验学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区新场实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0071', '上海市浦东新区新场实验中学', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区懿德中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0072', '上海市浦东新区懿德中学', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建平实验地杰中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0073', '上海市建平实验地杰中学', '上海市建平实',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建平实验张江中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0074', '上海市建平实验张江中学', '上海市建平实',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市历城中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0075', '上海市历城中学', '上海市历城中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市竹园中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0076', '上海市竹园中学', '上海市竹园中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市泾南中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0077', '上海市泾南中学', '上海市泾南中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市香山中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0078', '上海市香山中学', '上海市香山中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市沪新中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0079', '上海市沪新中学', '上海市沪新中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市育民中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0080', '上海市育民中学', '上海市育民中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市高行中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0081', '上海市高行中学', '上海市高行中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海第二工业大学附属龚路中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0082', '上海第二工业大学附属龚路中学', '上海第二工业',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市五三中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0083', '上海市五三中学', '上海市五三中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市侨光中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0084', '上海市侨光中学', '上海市侨光中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市江镇中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0085', '上海市江镇中学', '上海市江镇中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市合庆中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0086', '上海市合庆中学', '上海市合庆中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学张江实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0087', '华东师范大学张江实验中学', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三林中学东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0088', '上海市三林中学东校', '上海市三林中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市川沙中学北校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0089', '上海市川沙中学北校', '上海市川沙中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办正达外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0090', '上海浦东新区民办正达外国语学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市高东中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0091', '上海市高东中学', '上海市高东中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南汇第一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0092', '上海市南汇第一中学', '上海市南汇第',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市老港中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0093', '上海市老港中学', '上海市老港中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市泥城中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0094', '上海市泥城中学', '上海市泥城中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区建平康梧中学（原上海市
吴迅中学）
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0095', '上海市浦东新区建平康梧中学（原上海市
吴迅中学）', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市长岛中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0096', '上海市长岛中学', '上海市长岛中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海立信会计金融学院附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0097', '上海立信会计金融学院附属学校', '上海立信会计',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市绿川学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0098', '上海市绿川学校', '上海市绿川学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洋泾菊园实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0099', '上海市洋泾菊园实验学校', '上海市洋泾菊',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办平和学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0100', '上海市民办平和学校', '上海市民办平',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市川沙中学南校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0101', '上海市川沙中学南校', '上海市川沙中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建平实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0102', '上海市建平实验中学', '上海市建平实',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办金苹果学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0103', '上海市民办金苹果学校', '上海市民办金',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办启能东方外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0104', '上海民办启能东方外国语学校', '上海民办启能',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办中芯学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0105', '上海市民办中芯学校', '上海市民办中',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市进才实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0106', '上海市进才实验中学', '上海市进才实',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校东校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0107', '上海市实验学校东校', '上海市实验学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市张江集团中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0108', '上海市张江集团中学', '上海市张江集',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办协和双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0109', '上海浦东新区民办协和双语学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区建平南汇实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0110', '上海市浦东新区建平南汇实验学校', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三灶学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0111', '上海市三灶学校', '上海市三灶学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市黄路学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0112', '上海市黄路学校', '上海市黄路学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区彭镇中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0113', '上海市浦东新区彭镇中学', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市秋萍学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0114', '上海市秋萍学校', '上海市秋萍学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三墩学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0115', '上海市三墩学校', '上海市三墩学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市万祥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0116', '上海市万祥学校', '上海市万祥学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宣桥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0117', '上海市宣桥学校', '上海市宣桥学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市航头学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0118', '上海市航头学校', '上海市航头学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市周浦育才学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0119', '上海市周浦育才学校', '上海市周浦育',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校附属光明学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0120', '上海市实验学校附属光明学校', '上海市实验学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市东海学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0121', '上海市东海学校', '上海市东海学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市今日学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0122', '上海市今日学校', '上海市今日学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市康城学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0123', '上海市康城学校', '上海市康城学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海中医药大学附属浦东鹤沙学校（原上海市下沙学校）
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0124', '上海中医药大学附属浦东鹤沙学校（原上海市下沙学校）', '上海中医药大',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办东鼎外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0125', '上海浦东新区民办东鼎外国语学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办尚德实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0126', '上海市民办尚德实验学校', '上海市民办尚',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办远翔实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0127', '上海浦东新区民办远翔实验学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办进德外国语中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0128', '上海浦东新区民办进德外国语中学', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市周浦实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0129', '上海市周浦实验学校', '上海市周浦实',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办沪港学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0130', '上海浦东新区民办沪港学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办更新学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0131', '上海浦东新区民办更新学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办华曜浦东实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0132', '上海民办华曜浦东实验学校', '上海民办华曜',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办万科学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0133', '上海浦东新区民办万科学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学前滩学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0134', '华东师范大学第二附属中学前滩学校', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办惠立学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0135', '上海浦东新区民办惠立学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办宏文学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0136', '上海浦东新区民办宏文学校', '上海浦东新区',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海科技大学附属学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0137', '上海科技大学附属学校', '上海科技大学',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海浦东民办未来科技学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0138', '上海浦东民办未来科技学校', '上海浦东民办',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东新区东城学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'PD0139', '上海市浦东新区东城学校', '上海市浦东新',
    (SELECT id FROM ref_district WHERE code = 'PD'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市罗星中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0001', '上海市罗星中学', '上海市罗星中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松隐中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0002', '上海市松隐中学', '上海市松隐中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市亭新中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0003', '上海市亭新中学', '上海市亭新中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市漕泾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0004', '上海市漕泾中学', '上海市漕泾中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市山阳中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0005', '上海市山阳中学', '上海市山阳中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市张堰第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0006', '上海市张堰第二中学', '上海市张堰第',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市廊下中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0007', '上海市廊下中学', '上海市廊下中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市蒙山中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0008', '上海市蒙山中学', '上海市蒙山中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山区教育学院附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0009', '上海市金山区教育学院附属中学', '上海市金山区',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0010', '上海市金山初级中学', '上海市金山初',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市西林中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0011', '上海市西林中学', '上海市西林中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市朱行中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0012', '上海市朱行中学', '上海市朱行中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海金山区健桥实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0013', '上海金山区健桥实验中学', '上海金山区健',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山区青少年业余体育学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0014', '上海市金山区青少年业余体育学校', '上海市金山区',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市同凯中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0015', '上海市同凯中学', '上海市同凯中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0016', '上海市金山实验中学', '上海市金山实',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属枫泾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0017', '华东师范大学附属枫泾中学', '华东师范大学',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金卫中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0018', '上海市金卫中学', '上海市金卫中',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市干巷学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0019', '上海市干巷学校', '上海市干巷学',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新农学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0020', '上海市新农学校', '上海市新农学',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市民办金盟学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0021', '上海市民办金盟学校', '上海市民办金',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海金山区世外学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0022', '上海金山区世外学校', '上海金山区世',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山区吕巷学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0023', '上海市金山区吕巷学校', '上海市金山区',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山区钱圩学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'JS0024', '上海市金山区钱圩学校', '上海市金山区',
    (SELECT id FROM ref_district WHERE code = 'JS'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区第七中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '171001', '上海市松江区第七中学', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海对外经贸大学附属松江实验
学校花园分校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '171002', '上海对外经贸大学附属松江实验
学校花园分校', '上海对外经贸',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江二中（集团）初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '171003', '上海市松江二中（集团）初级中学', '上海市松江二',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江四中初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '171004', '上海市松江四中初级中学', '上海市松江四',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区九亭中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '171006', '上海市松江区九亭中学', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区第六中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '171013', '上海市松江区第六中学', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区九亭第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '171015', '上海市松江区九亭第二中学', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区立达中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '174001', '上海市松江区立达中学', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区新桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '174005', '上海市松江区新桥中学', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区民办茸一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '174007', '上海市松江区民办茸一中学', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江九峰实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '174008', '上海市松江九峰实验学校', '上海市松江九',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海领科双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '174013', '上海领科双语学校', '上海领科双语',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区洞泾学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175001', '上海市松江区洞泾学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区李塔汇学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175002', '上海市松江区李塔汇学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区古松学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175003', '上海市松江区古松学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区泖港学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175004', '上海市松江区泖港学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区民乐学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175005', '上海市松江区民乐学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区泗泾实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175007', '上海市松江区泗泾实验学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区佘山外国语实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175008', '上海市松江区佘山外国语实验学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区五厍学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175009', '上海市松江区五厍学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 东华大学附属实验学校松江小昆山分校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175010', '东华大学附属实验学校松江小昆山分校', '东华大学附属',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区仓桥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175011', '上海市松江区仓桥学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区佘山学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175012', '上海市松江区佘山学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三新学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175013', '上海市三新学校', '上海市三新学',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海世外教育附属松江区车墩学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175014', '上海世外教育附属松江区车墩学校', '上海世外教育',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区张泽学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175015', '上海市松江区张泽学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区天马山学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175016', '上海市松江区天马山学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海戏剧学院附属松江实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175017', '上海戏剧学院附属松江实验学校', '上海戏剧学院',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市西外外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175018', '上海市西外外国语学校', '上海市西外外',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区叶榭学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175019', '上海市松江区叶榭学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学松江外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175020', '上海外国语大学松江外国语学校', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区新浜学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175022', '上海市松江区新浜学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 东华大学附属实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175023', '东华大学附属实验学校', '东华大学附属',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海赫贤学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175024', '上海赫贤学校', '上海赫贤学校',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 华东政法大学附属松江实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175026', '华东政法大学附属松江实验学校', '华东政法大学',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区新闵学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175028', '上海市松江区新闵学校', '上海市松江区',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属松江实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175029', '上海师范大学附属松江实验学校', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海工程技术大学附属松江泗泾实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175030', '上海工程技术大学附属松江泗泾实验学校', '上海工程技术',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市三新学校松江东部分校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '175037', '上海市三新学校松江东部分校', '上海市三新学',
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 合计
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    (SELECT id FROM ref_district WHERE code = 'SJ'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181001', '上海市青浦区实验中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区东方中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181002', '上海市青浦区东方中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区尚美中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181003', '上海市青浦区尚美中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区徐泾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181004', '上海市青浦区徐泾中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区凤溪中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181005', '上海市青浦区凤溪中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区重固中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181006', '上海市青浦区重固中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区豫才中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181007', '上海市青浦区豫才中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区华新中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181008', '上海市青浦区华新中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区白鹤中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181009', '上海市青浦区白鹤中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区珠溪中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181011', '上海市青浦区珠溪中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区沈巷中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181012', '上海市青浦区沈巷中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区颜安中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181013', '上海市青浦区颜安中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区金泽中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181016', '上海市青浦区金泽中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海政法学院附属青浦崧淀中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181017', '上海政法学院附属青浦崧淀中学', '上海政法学院',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市教育学会青浦清河湾中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181018', '上海市教育学会青浦清河湾中学', '上海市教育学',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区教师进修学院附属中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '181019', '上海市青浦区教师进修学院附属中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区第一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '184005', '上海市青浦区第一中学', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市毓华学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185001', '上海市毓华学校', '上海市毓华学',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区崧泽学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185003', '上海市青浦区崧泽学校', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市博文学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185004', '上海市博文学校', '上海市博文学',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦区少年业余体育学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185005', '上海市青浦区少年业余体育学校', '上海市青浦区',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市毓秀学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185007', '上海市毓秀学校', '上海市毓秀学',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海宋庆龄学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185008', '上海宋庆龄学校', '上海宋庆龄学',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市佳信学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185009', '上海市佳信学校', '上海市佳信学',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海五浦汇实验学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185011', '上海五浦汇实验学校', '上海五浦汇实',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海青浦区世外学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185012', '上海青浦区世外学校', '上海青浦区世',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海青浦平和双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185013', '上海青浦平和双语学校', '上海青浦平和',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海青浦区协和双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '185014', '上海青浦区协和双语学校', '上海青浦区协',
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 初中学校名称
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    (SELECT id FROM ref_district WHERE code = 'QP'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区青少年业余体育学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201001', '上海市奉贤区青少年业余体育学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区古华中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201002', '上海市奉贤区古华中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201003', '上海市奉贤区实验中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤中学附属南桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201004', '上海市奉贤中学附属南桥中学', '上海市奉贤中',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区汇贤中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201005', '上海市奉贤区汇贤中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区塘外中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201010', '上海市奉贤区塘外中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区青村中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201011', '上海市奉贤区青村中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区奉城第二中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201012', '上海市奉贤区奉城第二中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区头桥中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201013', '上海市奉贤区头桥中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区洪庙中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201014', '上海市奉贤区洪庙中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区四团中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201015', '上海市奉贤区四团中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区青溪中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201016', '上海市奉贤区青溪中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区尚同中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201017', '上海市奉贤区尚同中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学附属奉贤实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201018', '上海外国语大学附属奉贤实验中学', '上海外国语大',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区崇实中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201019', '上海市奉贤区崇实中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区待问中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201020', '上海市奉贤区待问中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤中学附属初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '201021', '上海市奉贤中学附属初级中学', '上海市奉贤中',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区肖塘中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '204002', '上海市奉贤区肖塘中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区育秀中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205002', '上海市奉贤区育秀中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区华亭学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205003', '上海市奉贤区华亭学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区西渡学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205004', '上海市奉贤区西渡学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区新寺学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205005', '上海市奉贤区新寺学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区胡桥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205007', '上海市奉贤区胡桥学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区柘林学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205008', '上海市奉贤区柘林学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区阳光外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205009', '上海市奉贤区阳光外国语学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区庄行学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205010', '上海市奉贤区庄行学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区邬桥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205011', '上海市奉贤区邬桥学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区金汇学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205012', '上海市奉贤区金汇学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区齐贤学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205013', '上海市奉贤区齐贤学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区泰日学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205014', '上海市奉贤区泰日学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤中学附属三官堂学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205015', '上海市奉贤中学附属三官堂学校', '上海市奉贤中',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区钱桥学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205016', '上海市奉贤区钱桥学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区平安学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205017', '上海市奉贤区平安学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区邵厂学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205018', '上海市奉贤区邵厂学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区弘文学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205019', '上海市奉贤区弘文学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区星火学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205020', '上海市奉贤区星火学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区五四学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205021', '上海市奉贤区五四学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区肇文学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205022', '上海市奉贤区肇文学校', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区奉浦中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205023', '上海市奉贤区奉浦中学', '上海市奉贤区',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海奉贤区世外教育附属临港外国语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205030', '上海奉贤区世外教育附属临港外国语学校', '上海奉贤区世',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 柘林学校师大附中教学点
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    '205099', '柘林学校师大附中教学点', '柘林学校师大',
    (SELECT id FROM ref_district WHERE code = 'FX'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区三星中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0001', '上海市崇明区三星中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区建设中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0002', '上海市崇明区建设中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区合兴中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0003', '上海市崇明区合兴中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区向化中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0004', '上海市崇明区向化中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区崇东中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0005', '上海市崇明区崇东中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区裕安中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0006', '上海市崇明区裕安中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区实验中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0007', '上海市崇明区实验中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明中学附属东门中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0008', '上海市崇明中学附属东门中学', '上海市崇明中',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区城桥中学附属明志初级中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0009', '上海市崇明区城桥中学附属明志初级中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区长兴中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0010', '上海市崇明区长兴中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区长明中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0011', '上海市崇明区长明中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属崇明正大中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0012', '上海师范大学附属崇明正大中学', '上海师范大学',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区庙镇学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0013', '上海市崇明区庙镇学校', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区大新中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0014', '上海市崇明区大新中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区三烈中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0015', '上海市崇明区三烈中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区大公中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0016', '上海市崇明区大公中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海民办民一中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0017', '上海民办民一中学', '上海民办民一',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PRIVATE', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区横沙中学
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0018', '上海市崇明区横沙中学', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海新纪元双语学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0019', '上海新纪元双语学校', '上海新纪元双',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区新海学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0020', '上海市崇明区新海学校', '上海市崇明区',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校附属东滩学校
INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES (
    'CM0021', '上海市实验学校附属东滩学校', '上海市实验学',
    (SELECT id FROM ref_district WHERE code = 'CM'), 'PUBLIC', TRUE, 2024, TRUE)
ON CONFLICT (code, data_year) DO UPDATE SET
    name = EXCLUDED.name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    updated_at = CURRENT_TIMESTAMP;
