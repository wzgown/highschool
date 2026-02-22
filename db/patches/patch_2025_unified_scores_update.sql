-- 2025年统一招生分数线数据更新
-- 基于新数据源更新分数和补充缺失区县的关键学校

-- ============================================
-- 徐汇区 (district_id=3) - 更新分数
-- ============================================

-- 上海市第二中学: 682.5 → 669.5
UPDATE ref_admission_score_unified
SET min_score = 669.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 3 AND school_name = '上海市第二中学';

-- 上海市南洋中学: 672.0 → 661.5
UPDATE ref_admission_score_unified
SET min_score = 661.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 3 AND school_name = '上海市南洋中学';

-- ============================================
-- 杨浦区 (district_id=8) - 更新分数
-- ============================================

-- 上海市杨浦高级中学: 675.5 → 683.5
UPDATE ref_admission_score_unified
SET min_score = 683.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 8 AND school_name = '上海市杨浦高级中学';

-- 同济大学第一附属中学: 661.0 → 675.5
UPDATE ref_admission_score_unified
SET min_score = 675.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 8 AND school_name = '同济大学第一附属中学';

-- ============================================
-- 松江区 (district_id=14) - 更新分数
-- ============================================

-- 上海市松江一中: 679.5 → 678
UPDATE ref_admission_score_unified
SET min_score = 678.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 14 AND school_name = '上海市松江一中';

-- ============================================
-- 青浦区 (district_id=15) - 更新分数
-- ============================================

-- 复旦大学附属中学青浦分校: 706.0 → 689.5
UPDATE ref_admission_score_unified
SET min_score = 689.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 15 AND school_name = '复旦大学附属中学青浦分校';

-- 上海市青浦高级中学: 666.0 → 668.5
UPDATE ref_admission_score_unified
SET min_score = 668.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 15 AND school_name = '上海市青浦高级中学';

-- 上海市朱家角中学: 638.0 → 656
UPDATE ref_admission_score_unified
SET min_score = 656.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 15 AND school_name = '上海市朱家角中学';

-- 上海市东湖中学: 609.0 → 609.5
UPDATE ref_admission_score_unified
SET min_score = 609.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 15 AND school_name = '上海市东湖中学';

-- ============================================
-- 闵行区 (district_id=9) - 插入/更新关键学校
-- ============================================

-- 上海市七宝中学 - 699
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 134, '上海市七宝中学', 699.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学闵行紫竹分校 - 695
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 136, '华东师范大学第二附属中学闵行紫竹分校', 695.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学闵行分校 - 697
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 138, '上海交通大学附属中学闵行分校', 697.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学闵行分校 - 691.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 137, '上海师范大学附属中学闵行分校', 691.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行中学 - 685.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 135, '上海市闵行中学', 685.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 浦东新区 (district_id=12) - 更新关键学校
-- ============================================

-- 上海市上海中学 - 710
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 1, '上海市上海中学', 710.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学 - 709.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 4, '华东师范大学第二附属中学', 709.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学 - 710
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 3, '复旦大学附属中学', 710.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学 - 709.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 2, '上海交通大学附属中学', 709.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市建平中学 - 703
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 193, '上海市建平中学', 703.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市进才中学 - 696.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 194, '上海市进才中学', 696.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 普陀区 (district_id=6) - 插入/更新关键学校
-- ============================================

-- 华东师范大学第二附属中学普陀校区 - 701.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 6, NULL, '华东师范大学第二附属中学普陀校区', 701.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨第二中学 - 692
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 6, 97, '上海市曹杨第二中学', 692.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市晋元高级中学 - 684
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 6, 96, '上海市晋元高级中学', 684.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市宜川中学 - 677
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 6, 98, '上海市宜川中学', 677.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨中学 - 661
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 6, 100, '上海市曹杨中学', 661.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 黄浦区 (district_id=2) - 插入/更新关键学校
-- ============================================

-- 上海市大同中学 - 682
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 32, '上海市大同中学', 682.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学 - 680.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 31, '上海市格致中学', 680.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市向明中学 - 675
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 33, '上海市向明中学', 675.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市敬业中学 - 669.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 36, '上海市敬业中学', 669.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市卢湾高级中学 - 659
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 37, '上海市卢湾高级中学', 659.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 长宁区 (district_id=4) - 插入/更新关键学校
-- ============================================

-- 上海市延安中学 - 682.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 4, 67, '上海市延安中学', 682.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市复旦中学 - 673.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 4, 68, '上海市复旦中学', 673.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市第三女子中学 - 652
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 4, 66, '上海市第三女子中学', 652.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属天山学校 - 641.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 4, 74, '上海市天山中学', 641.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 宝山区 (district_id=10) - 插入/更新关键学校
-- ============================================

-- 上海市行知中学 - 683.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 10, 164, '上海市行知中学', 683.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学（宝山校区） - 696
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 10, 168, '华东师范大学第二附属中学（宝山校区）', 696.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市吴淞中学 - 667
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 10, 166, '上海市吴淞中学', 667.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海大学附属中学 - 666
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 10, 165, '上海大学附属中学', 666.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市宝山中学 - 635
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 10, 163, '上海市宝山中学', 635.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 嘉定区 (district_id=11) - 插入/更新关键学校
-- ============================================

-- 上海交通大学附属中学嘉定分校 - 689
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 11, 184, '上海交通大学附属中学嘉定分校', 689.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区第一中学 - 677
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 11, 183, '上海市嘉定区第一中学', 677.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属嘉定高级中学 - 679
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 11, 188, '上海师范大学附属嘉定高级中学', 679.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区第二中学 - 648.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 11, 186, '上海市嘉定区第二中学', 648.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 奉贤区 (district_id=16) - 插入/更新关键学校
-- ============================================

-- 上海市奉贤中学 - 679.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 16, 281, '上海市奉贤中学', 679.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学临港奉贤分校 - 673
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 16, 282, '华东师范大学第二附属中学临港奉贤分校', 673.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学奉贤校区 - 671.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 16, NULL, '上海市格致中学奉贤校区', 671.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤区曙光中学 - 650.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 16, 285, '上海市奉贤区曙光中学', 650.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 金山区 (district_id=13) - 插入/更新关键学校
-- ============================================

-- 上海市金山中学 - 670
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 13, 244, '上海市金山中学', 670.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第三附属中学 - 656.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 13, 245, '华东师范大学第三附属中学', 656.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市张堰中学 - 626
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 13, 246, '上海市张堰中学', 626.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 崇明区 (district_id=17) - 插入/更新关键学校
-- ============================================

-- 上海市崇明中学 - 638
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 17, 289, '上海市崇明中学', 638.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校东滩高级中学 - 656
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 17, 290, '上海市实验学校东滩高级中学', 656.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区民本中学 - 572
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 17, 292, '上海市崇明区民本中学', 572.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市扬子中学 - 563
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 17, 293, '上海市扬子中学', 563.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明区城桥中学 - 513
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 17, 291, '上海市崇明区城桥中学', 513.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;
