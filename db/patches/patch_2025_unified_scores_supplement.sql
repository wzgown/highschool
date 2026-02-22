-- 2025年统一招生分数线数据补充
-- 基于用户提供的数据导入

-- ============================================
-- 浦东新区 (district_id=12)
-- ============================================

-- 上海中学东校 - 692.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 54, '上海市上海中学东校', 692.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东复旦附中分校 - 703.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 200, '上海市浦东复旦附中分校', 703.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海南汇中学 - 674.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 195, '上海南汇中学', 674.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市洋泾中学 - 689.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 196, '上海市洋泾中学', 689.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市川沙中学 - 686.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 198, '上海市川沙中学', 686.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市高桥中学 - 672.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 197, '上海市高桥中学', 672.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属东昌中学 - 673.0 (学校ID待确认)
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '华东师范大学附属东昌中学', 673.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海海事大学附属北蔡高级中学 - 663.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 202, '上海海事大学附属北蔡高级中学', 663.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市香山中学 - 603.0 (学校ID待确认)
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海市香山中学', 603.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市建平中学筠溪分校 - 678.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 221, '上海市建平中学筠溪分校', 678.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市进才中学根林分校 - 670.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 222, '上海市进才中学根林分校', 670.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市川沙中学友仁分校 - 665.0 (学校ID待确认)
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, NULL, '上海市川沙中学友仁分校', 665.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东外国语学校东校 - 634.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 219, '上海市浦东外国语学校东校', 634.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市上南中学 - 647.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 203, '上海市上南中学', 647.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市三林中学 - 634.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 204, '上海市三林中学', 634.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市杨思高级中学 - 626.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 205, '上海市杨思高级中学', 626.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市新川中学 - 645.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 206, '上海市新川中学', 645.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属周浦中学 - 654.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 207, '华东师范大学附属周浦中学', 654.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海海洋大学附属大团高级中学 - 596.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 208, '上海海洋大学附属大团高级中学', 596.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市新场中学 - 564.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 209, '上海市新场中学', 564.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东理工大学附属浦东科技高级中学 - 654.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 210, '华东理工大学附属浦东科技高级中学', 654.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学附属浦东临港高级中学 - 640.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 211, '华东师范大学附属浦东临港高级中学', 640.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市文建中学 - 589.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 212, '上海市文建中学', 589.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市陆行中学 - 635.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 213, '上海市陆行中学', 635.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东中学 - 581.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 214, '上海市浦东中学', 581.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海立信会计金融学院附属高行中学 - 627.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 215, '上海立信会计金融学院附属高行中学', 627.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市建平世纪中学 - 619.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 12, 216, '上海市建平世纪中学', 619.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 闵行区 (district_id=9)
-- ============================================

-- 上海市七宝中学附属鑫都实验中学 - 664.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 147, '上海市七宝中学附属鑫都实验中学', 664.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学闵行外国语中学 - 679.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 9, 141, '上海外国语大学闵行外国语中学', 679.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 普陀区 (district_id=6)
-- ============================================

-- 上海市同济大学第二附属中学 - 641.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 6, 103, '上海市同济大学第二附属中学', 641.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 徐汇区 (district_id=3)
-- ============================================

-- 上海市第二中学（梅陇校区） - 690.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 3, 52, '上海市第二中学（梅陇校区）', 690.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 松江区 (district_id=14)
-- ============================================

-- 上海领科双语学校 - 640.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 266, '上海领科双语学校', 640.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海赫贤学校 - 541.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 269, '上海赫贤学校', 541.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海阿德科特学校 - 564.0 (根据用户数据推测，浦东新场中学也是564)
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 14, 267, '上海阿德科特学校', 564.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 杨浦区 (district_id=8)
-- ============================================

-- 上海市上海理工大学附属中学 - 661.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 8, 124, '上海市上海理工大学附属中学', 661.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 青浦区 (district_id=15)
-- ============================================

-- 上海青浦区世界外国语学校 - 639.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 15, 278, '上海青浦区世界外国语学校', 639.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 黄浦区 (district_id=2)
-- ============================================

-- 上海市同济黄浦设计创意中学 - 629.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 47, '上海市同济黄浦设计创意中学', 629.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市向明中学（浦江校区） - 689.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 39, '上海市向明中学（浦江校区）', 689.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学（奉贤校区） - 679.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 2, 38, '上海市格致中学（奉贤校区）', 679.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 静安区 (district_id=5)
-- ============================================

-- 上海市华东模范中学 - 620.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 5, 85, '上海市华东模范中学', 620.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 金山区 (district_id=13)
-- ============================================

-- 上海市民办永昌中学 - 516.0
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 13, 251, '上海市民办永昌中学', 516.0, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 长宁区 (district_id=4)
-- ============================================

-- 上海市建青实验学校（高中部） - 630.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 4, 70, '上海市建青实验学校（高中部）', 630.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- 宝山区 (district_id=10)
-- ============================================

-- 上海市罗店中学 - 649.5
INSERT INTO ref_admission_score_unified (year, district_id, school_id, school_name, min_score, data_year)
VALUES (2025, 10, 169, '上海市罗店中学', 649.5, 2025)
ON CONFLICT (year, district_id, school_name)
DO UPDATE SET min_score = EXCLUDED.min_score, school_id = EXCLUDED.school_id, updated_at = CURRENT_TIMESTAMP;
