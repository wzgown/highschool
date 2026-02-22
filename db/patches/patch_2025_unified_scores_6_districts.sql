-- 2025年统一招生分数线数据补丁
-- 补充徐汇区、静安区、虹口区、杨浦区、松江区、青浦区的数据
-- 数据来源：用户提供的2025年上海中考统一招生分数线

-- 使用 UPSERT (ON CONFLICT) 来处理已存在的记录

-- ============================================
-- 徐汇区 (district_id=3)
-- ============================================

-- 上海市上海中学 - 707.0 (更新已有记录)
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 1, '上海市上海中学', 707.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学徐汇分校 - 702.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 53, '复旦大学附属中学徐汇分校', 702.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市南洋模范中学 - 695.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 49, '上海市南洋模范中学', 695.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市位育中学 - 689.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 50, '上海市位育中学', 689.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市第二中学 - 682.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 48, '上海市第二中学', 682.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 静安区 (district_id=5)
-- ============================================

-- 上海市市西中学 - 685.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 5, 75, '上海市市西中学', 685.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市育才中学 - 668.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 5, 76, '上海市育才中学', 668.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市新中高级中学 - 665.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 5, 77, '上海市新中高级中学', 665.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市市北中学 - 676.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 5, 78, '上海市市北中学', 676.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 注意：上海市风华中学 在数据库中未找到，跳过

-- ============================================
-- 虹口区 (district_id=7)
-- ============================================

-- 复旦大学附属复兴中学 - 680.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 7, 110, '复旦大学附属复兴中学', 680.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第一附属中学 - 670.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 7, 111, '华东师范大学第一附属中学', 670.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海财经大学附属北郊高级中学 - 664.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 7, 112, '上海财经大学附属北郊高级中学', 664.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 注意：上海师范大学附属虹口高级中学 在数据库中未找到，跳过

-- 上海音乐学院虹口区北虹高级中学 - 627.0
-- 注意：用户提供名称为"上海音乐学院附属北虹高级中学"，数据库中为"上海音乐学院虹口区北虹高级中学"
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 7, 113, '上海音乐学院虹口区北虹高级中学', 627.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 杨浦区 (district_id=8)
-- ============================================

-- 复旦大学附属中学 - 707.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 3, '复旦大学附属中学', 707.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学 - 707.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 2, '上海交通大学附属中学', 707.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 - 707.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 4, '华东师范大学第二附属中学', 707.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市上海中学 - 707.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 1, '上海市上海中学', 707.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市控江中学 - 690.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 121, '上海市控江中学', 690.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 松江区 (district_id=14)
-- ============================================

-- 上海市上海中学 - 713.0 (更新已有记录)
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 1, '上海市上海中学', 713.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学 - 712.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 3, '复旦大学附属中学', 712.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学 - 711.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 2, '上海交通大学附属中学', 711.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 - 709.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 4, '华东师范大学第二附属中学', 709.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学松江分校 - 702.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 254, '华东师范大学第二附属中学松江分校', 702.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 青浦区 (district_id=15)
-- ============================================

-- 上海市上海中学 - 711.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 1, '上海市上海中学', 711.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学 - 707.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 2, '上海交通大学附属中学', 707.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学 - 708.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 3, '复旦大学附属中学', 708.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 - 707.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 4, '华东师范大学第二附属中学', 707.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学 - 699.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 5, '上海师范大学附属中学', 699.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;
