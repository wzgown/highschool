-- 修复崇明区 3 行 2026 平行志愿：线上原值(559.5/624/544)与官方 2026 线(524.5/522/441.5)差异大，
-- 疑似 2025 年分数误标为 2026（其余 15 行崇明 2026 数据与官方完全一致），且 school_id 为 NULL。
-- 按 sh_zhongkao_2026 数据集(官方源)修正并补挂 school_id。

BEGIN;

UPDATE ref_admission_score_unified
SET school_id = 291, min_score = 524.5, chinese_math_foreign_sum = 311.5, math_score = 88, chinese_score = 108
WHERE year = 2026 AND district_id = 17 AND school_name = '上海市崇明区城桥中学';

UPDATE ref_admission_score_unified
SET school_id = 294, min_score = 522, chinese_math_foreign_sum = 285, math_score = 98, chinese_score = 104
WHERE year = 2026 AND district_id = 17 AND school_name = '上海市崇明区堡镇中学';

UPDATE ref_admission_score_unified
SET school_id = 295, min_score = 441.5, chinese_math_foreign_sum = 228, math_score = 40, chinese_score = 100
WHERE year = 2026 AND district_id = 17 AND school_name = '上海民办民一中学';

-- 奉贤区列表中同样出现这 3 所崇明学校(跨区招生, 2026 线 559.5/624/544 与 zip 一致)，
-- 但历史行 school_id 为 NULL，补挂：
UPDATE ref_admission_score_unified SET school_id = 291 WHERE year=2026 AND district_id=16 AND school_name='上海市崇明区城桥中学' AND school_id IS NULL;
UPDATE ref_admission_score_unified SET school_id = 294 WHERE year=2026 AND district_id=16 AND school_name='上海市崇明区堡镇中学' AND school_id IS NULL;
UPDATE ref_admission_score_unified SET school_id = 295 WHERE year=2026 AND district_id=16 AND school_name='上海民办民一中学' AND school_id IS NULL;

COMMIT;
