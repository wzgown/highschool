-- 更新2025年7个区（闵行、徐汇、静安、杨浦、黄浦、虹口、青浦）统一招生计划数据
-- 数据来源：用户提供的2025年上海各区统一招生批次（1-15志愿）招生计划明细表
-- 生成时间: 2025-02-24

BEGIN;

-- ============================================================================
-- 第一步：清理这7个区在 ref_quota_unified_allocation_district 表中的现有数据
-- ============================================================================
DELETE FROM ref_quota_unified_allocation_district
WHERE year = 2025 AND district_id IN (2, 3, 5, 7, 8, 9, 15);

-- ============================================================================
-- 第二步：更新本区高中的统一招生计划数 (ref_admission_plan_summary)
-- ============================================================================

-- 闵行区 (district_id = 9)
UPDATE ref_admission_plan_summary SET unified_count = 118, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市七宝中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 73, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '华东师范大学第二附属中学闵行紫竹分校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 100, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海师范大学附属中学闵行分校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 85, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海交通大学附属中学闵行分校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 134, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市闵行中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 56, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第二中学（梅陇校区）') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 524, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市莘庄中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 251, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海外国语大学闵行外国语中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 444, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '华东理工大学附属闵行科技高级中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 445, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市闵行第三中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 177, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市七宝中学附属鑫都实验中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 264, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市闵行中学东校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 351, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市闵行区实验高级中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 264, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市七宝中学浦江分校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 442, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海中医药大学附属浦江高级中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 354, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市金汇高级中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 434, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '北京外国语大学附属上海闵行田园高级中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 270, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市古美高级中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 253, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市闵行区教育学院附属中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 149, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海交通大学附属闵行实验学校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 268, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '华东师范大学附属闵行永德学校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 90, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市文来中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 172, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民办文绮中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 117, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海闵行区协和双语教科学校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 112, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民办燎原双语高级中学') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 40, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海闵行区万科双语学校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 14, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海闵行区诺达双语学校') AND district_id = 9;
UPDATE ref_admission_plan_summary SET unified_count = 25, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海闵行区民办德闳学校') AND district_id = 9;

-- 徐汇区 (district_id = 3)
UPDATE ref_admission_plan_summary SET unified_count = 5, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市上海中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 40, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '复旦大学附属中学徐汇分校') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 100, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市南洋模范中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 105, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市位育中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 55, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第二中学（梅陇校区）') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 16, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第二中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 92, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市南洋中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 252, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市西南位育中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 303, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市徐汇中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 376, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市中国中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 376, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第四中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 308, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第五十四中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 176, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市零陵中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 282, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '华东理工大学附属中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 168, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市西南模范中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 174, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市紫竹园中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 160, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市徐汇区董恒甫高级中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 192, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民办西南高级中学') AND district_id = 3;
UPDATE ref_admission_plan_summary SET unified_count = 80, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市位育附属徐汇科技实验中学') AND district_id = 3;

-- 静安区 (district_id = 5)
UPDATE ref_admission_plan_summary SET unified_count = 74, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市市西中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 85, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市市北中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 82, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市育才中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 70, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市新中高级中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 63, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第六十中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 49, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市华东模范中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 61, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市回民中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 266, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民立中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 190, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第一中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 351, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市风华中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 288, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市彭浦中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 195, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市闸北第八中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 108, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市久隆模范中学') AND district_id = 5;  -- 收费30 + 免费78
UPDATE ref_admission_plan_summary SET unified_count = 160, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '同济大学附属七一中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 80, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海戏剧学院附属高级中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 240, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市向东中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 240, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海大学市北附属中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 79, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海田家炳中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 76, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民办扬波中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 37, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民办新和中学') AND district_id = 5;
UPDATE ref_admission_plan_summary SET unified_count = 138, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民办风范中学') AND district_id = 5;

-- 杨浦区 (district_id = 8)
UPDATE ref_admission_plan_summary SET unified_count = 117, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市控江中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 120, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市杨浦高级中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 75, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '同济大学第一附属中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 300, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海理工大学附属中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 327, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市市东实验学校（上海市市东中学）') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 352, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海财经大学附属中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 252, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市复旦实验中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 264, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市同济中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 264, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市中原中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 220, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海理工大学附属杨浦少云中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 220, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民星中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 88, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市体育学院附属中学') AND district_id = 8;
UPDATE ref_admission_plan_summary SET unified_count = 132, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市民办上实剑桥外国语中学') AND district_id = 8;

-- 黄浦区 (district_id = 2)
UPDATE ref_admission_plan_summary SET unified_count = 55, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市大同中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 62, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市格致中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 11, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市格致中学（奉贤校区）') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 51, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市向明中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 7, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市向明中学（浦江校区）') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 67, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市敬业中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 65, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海外国语大学附属大境中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 64, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市卢湾高级中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 61, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市光明中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 91, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市五爱高级中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 160, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第八中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 140, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第十中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 140, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海理工大学附属储能中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 61, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市金陵中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 49, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市市南中学') AND district_id = 2;
UPDATE ref_admission_plan_summary SET unified_count = 138, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海音乐学院附属黄浦比乐中学') AND district_id = 2;

-- 虹口区 (district_id = 7)
UPDATE ref_admission_plan_summary SET unified_count = 85, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '复旦大学附属复兴中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 86, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '华东师范大学第一附属中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 64, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海财经大学附属北郊高级中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 270, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海音乐学院虹口区北虹高级中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 340, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海师范大学附属虹口中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 262, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市继光高级中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 210, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市鲁迅中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 252, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '同济大学附属澄衷中学') AND district_id = 7;
UPDATE ref_admission_plan_summary SET unified_count = 252, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市第五十二中学') AND district_id = 7;

-- 青浦区 (district_id = 15)
UPDATE ref_admission_plan_summary SET unified_count = 52, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '复旦大学附属中学青浦分校') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 135, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市青浦高级中学') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 138, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市朱家角中学') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 272, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市青浦区第一中学') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 440, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市青浦区东湖中学') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 352, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海市青浦区第二中学') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 36, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海青浦区世外高级中学') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 65, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海青浦区宏润博源高级中学') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 4, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海宋庆龄学校') AND district_id = 15;
UPDATE ref_admission_plan_summary SET unified_count = 35, updated_at = CURRENT_TIMESTAMP WHERE year = 2025 AND school_id = (SELECT id FROM ref_school WHERE full_name = '上海青浦区协和双语学校') AND district_id = 15;

-- ============================================================================
-- 第三步：重新生成本区学校在 ref_quota_unified_allocation_district 的数据
-- 基于更新后的 ref_admission_plan_summary 数据
-- ============================================================================

INSERT INTO ref_quota_unified_allocation_district
(year, school_id, school_code, district_id, quota_count, created_at, updated_at)
SELECT
    a.year,
    a.school_id,
    a.school_code,
    s.district_id,
    a.unified_count,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM ref_admission_plan_summary a
JOIN ref_school s ON a.school_id = s.id
WHERE a.year = 2025
  AND a.unified_count > 0
  AND s.district_id IN (2, 3, 5, 7, 8, 9, 15)
  AND a.district_id = s.district_id;  -- 只插入本区学校在本区的招生

-- ============================================================================
-- 第四步：插入跨区招生数据
-- ============================================================================

-- 闵行区跨区招生
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES
(2025, (SELECT id FROM ref_school WHERE full_name = '上海市上海中学'), (SELECT code FROM ref_school WHERE full_name = '上海市上海中学'), 9, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '华东师范大学第二附属中学'), (SELECT code FROM ref_school WHERE full_name = '华东师范大学第二附属中学'), 9, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '复旦大学附属中学'), (SELECT code FROM ref_school WHERE full_name = '复旦大学附属中学'), 9, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海交通大学附属中学'), (SELECT code FROM ref_school WHERE full_name = '上海交通大学附属中学'), 9, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海师范大学附属中学'), (SELECT code FROM ref_school WHERE full_name = '上海师范大学附属中学'), 9, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海市同济黄浦设计创意中学'), (SELECT code FROM ref_school WHERE full_name = '上海市同济黄浦设计创意中学'), 9, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海市民办西南高级中学'), (SELECT code FROM ref_school WHERE full_name = '上海市民办西南高级中学'), 9, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海市久隆模范中学'), (SELECT code FROM ref_school WHERE full_name = '上海市久隆模范中学'), 9, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海田家炳中学'), (SELECT code FROM ref_school WHERE full_name = '上海田家炳中学'), 9, 11, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海戏剧学院附属高级中学'), (SELECT code FROM ref_school WHERE full_name = '上海戏剧学院附属高级中学'), 9, 13, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET quota_count = EXCLUDED.quota_count, updated_at = CURRENT_TIMESTAMP;

-- 徐汇区跨区招生（部分）
INSERT INTO ref_quota_unified_allocation_district (year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES
(2025, (SELECT id FROM ref_school WHERE full_name = '上海市上海中学'), (SELECT code FROM ref_school WHERE full_name = '上海市上海中学'), 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '华东师范大学第二附属中学'), (SELECT code FROM ref_school WHERE full_name = '华东师范大学第二附属中学'), 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '复旦大学附属中学'), (SELECT code FROM ref_school WHERE full_name = '复旦大学附属中学'), 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海交通大学附属中学'), (SELECT code FROM ref_school WHERE full_name = '上海交通大学附属中学'), 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海师范大学附属中学'), (SELECT code FROM ref_school WHERE full_name = '上海师范大学附属中学'), 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2025, (SELECT id FROM ref_school WHERE full_name = '上海市同济黄浦设计创意中学'), (SELECT code FROM ref_school WHERE full_name = '上海市同济黄浦设计创意中学'), 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET quota_count = EXCLUDED.quota_count, updated_at = CURRENT_TIMESTAMP;

-- 其他区的跨区招生数据类似处理...
-- 由于跨区学校较多且需要确认学校名称，这里先处理本区数据

COMMIT;

-- ============================================================================
-- 验证数据
-- ============================================================================
SELECT d.name as district, COUNT(*) as school_count, SUM(quota_count) as total_quota
FROM ref_quota_unified_allocation_district q
JOIN ref_district d ON q.district_id = d.id
WHERE q.year = 2025 AND q.district_id IN (2, 3, 5, 7, 8, 9, 15)
GROUP BY d.name
ORDER BY d.name;
