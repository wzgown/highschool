-- 2025年统一招生分数线数据补充（完整版）
-- 基于用户提供的详细数据

-- ============================================
-- 需要先更新的数据（分数有变化）
-- ============================================

-- 徐汇区：上海市第二中学（梅陇校区） 690.0 → 683.0
UPDATE ref_admission_score_unified SET min_score = 683.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 3 AND school_name = '上海市第二中学（梅陇校区）';

-- 松江区：上海领科双语学校 640.0 → 610.5
UPDATE ref_admission_score_unified SET min_score = 610.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 14 AND school_name = '上海领科双语学校';

-- 松江区：上海赫贤学校 541.0 → 598.5
UPDATE ref_admission_score_unified SET min_score = 598.5, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 14 AND school_name = '上海赫贤学校';

-- 青浦区：上海青浦区世界外国语学校 639.0 → 647.0
UPDATE ref_admission_score_unified SET min_score = 647.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 15 AND school_name = '上海青浦区世界外国语学校';

-- 黄浦区：上海市同济黄浦设计创意中学 629.0 → 639.0
UPDATE ref_admission_score_unified SET min_score = 639.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 2 AND school_name = '上海市同济黄浦设计创意中学';

-- 黄浦区：上海市向明中学（浦江校区） 689.0 → 674.0
UPDATE ref_admission_score_unified SET min_score = 674.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 2 AND school_name = '上海市向明中学（浦江校区）';

-- 静安区：上海市华东模范中学 620.5 → 690.0
UPDATE ref_admission_score_unified SET min_score = 690.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 5 AND school_name = '上海市华东模范中学';

-- 闵行区：上海外国语大学闵行外国语中学 679.5 → 679.0
UPDATE ref_admission_score_unified SET min_score = 679.0, updated_at = CURRENT_TIMESTAMP
WHERE year = 2025 AND district_id = 9 AND school_name = '上海外国语大学闵行外国语中学';

-- ============================================
-- 浦东新区 (district_id=12) - 新增
-- ============================================

-- 上海师范大学附属中学 - 690.5 (浦东区)
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 5, '上海师范大学附属中学', 690.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市民办平和学校 - 710.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 232, '上海市民办平和学校', 710.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市民办尚德实验学校 - 634
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海市民办尚德实验学校', 634.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市民办丰华高级中学 - 588.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 225, '上海市民办丰华高级中学', 588.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办东鼎外国语学校 - 564.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海浦东新区民办东鼎外国语学校', 564.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市民办金苹果学校 - 563.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海市民办金苹果学校', 563.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属第二外国语学校 - 586
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海师范大学附属第二外国语学校', 586.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市民办中芯学校 - 620
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海市民办中芯学校', 620.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办宏文学校 - 563.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 240, '上海浦东新区民办宏文学校', 563.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办沪港学校 - 520
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 236, '上海浦东新区民办沪港学校', 520.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办康德学校 - 602.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海浦东新区民办康德学校', 602.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办光华中学 - 559
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 220, '上海浦东新区民办光华中学', 559.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办万科学校 - 555
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 238, '上海浦东新区民办万科学校', 555.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办协和双语学校 - 597.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海浦东新区民办协和双语学校', 597.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办惠立学校 - 530.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 239, '上海浦东新区民办惠立学校', 530.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海浦东新区民办启能东方外国语学校 - 520
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海浦东新区民办启能东方外国语学校', 520.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 闵行区 (district_id=9) - 新增
-- ============================================

-- 上海市文来中学 - 648
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, NULL, '上海市文来中学', 648.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市民办文绮中学 - 613.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 154, '上海市民办文绮中学', 613.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市民办燎原双语高级中学 - 571.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 157, '上海市民办燎原双语高级中学', 571.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海闵行区协和双语教科学校 - 576.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, NULL, '上海闵行区协和双语教科学校', 576.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行中学东校 - 639.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, NULL, '上海市闵行中学东校', 639.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行区实验高级中学 - 623.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, NULL, '上海市闵行区实验高级中学', 623.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 七宝中学浦江分校 - 659.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, NULL, '七宝中学浦江分校', 659.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 普陀区 (district_id=6) - 新增
-- ============================================

-- 上海市曹杨第二中学东校 - 689
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 6, 108, '上海市曹杨第二中学东校', 689.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 徐汇区 (district_id=3) - 新增
-- ============================================

-- 上海市零陵中学 - 626.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 58, '上海市零陵中学', 626.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 位育附属徐汇科技实验中学 - 682.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 65, '位育附属徐汇科技实验中学', 682.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市徐汇中学 - 663.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, NULL, '上海市徐汇中学', 663.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市西南位育中学 - 660
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 60, '上海市西南位育中学', 660.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 松江区 (district_id=14) - 新增
-- ============================================

-- 松江九峰实验学校 - 641
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 265, '上海市松江九峰实验学校', 641.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市松江区科德高级中学 - 635.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 263, '上海市松江区科德高级中学', 635.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 杨浦区 (district_id=8) - 新增
-- ============================================

-- 上海市市东实验学校 - 650
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 127, '上海市市东实验学校', 650.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海财经大学附属中学 - 638
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 125, '上海财经大学附属中学', 638.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市复旦实验中学 - 631
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, NULL, '上海市复旦实验中学', 631.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 青浦区 (district_id=15) - 新增
-- ============================================

-- 青浦区第二中学 - 570.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 275, '上海市青浦区第二中学', 570.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 青浦区东湖中学 - 603
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 276, '上海市青浦区东湖中学', 603.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 青浦区第一中学 - 631
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 274, '上海市青浦区第一中学', 631.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 宋庆龄学校 - 644.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 280, '上海宋庆龄学校', 644.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 虹口区 (district_id=7) - 新增
-- ============================================

-- 上海市继光高级中学 - 567
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 7, 114, '上海市继光高级中学', 567.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 同济大学创意设计中学 - 613
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 7, NULL, '同济大学创意设计中学', 613.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属虹口中学 - 641
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 7, NULL, '上海师范大学附属虹口中学', 641.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 静安区 (district_id=5) - 新增
-- ============================================

-- 上海市民办扬波中学 - 523.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 5, 92, '上海市民办扬波中学', 523.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海戏剧学院附属高级中学 - 579.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 5, 82, '上海戏剧学院附属高级中学', 579.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 金山区 (district_id=13) - 新增
-- ============================================

-- 上海体育大学附属金山亭林中学 - 518.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 13, 248, '上海体育大学附属金山亭林中学', 518.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 长宁区 (district_id=4) - 新增
-- ============================================

-- 上海市民办新虹桥中学 - 514
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 4, 73, '上海市民办新虹桥中学', 514.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 奉贤区 (district_id=16) - 新增
-- ============================================

-- 东华大学附属奉贤致远中学 - 631.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 16, 287, '东华大学附属奉贤致远中学', 631.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 崇明区 (district_id=17) - 新增
-- ============================================

-- 上海市崇明区堡镇中学 - 513
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 17, 294, '上海市崇明区堡镇中学', 513.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;
