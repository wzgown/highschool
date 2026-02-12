-- ============================================================================
-- 2023年上海中考总体概况 - 种子数据
-- 数据来源：用户提供（估算值）
-- ============================================================================
-- 注：人数数据为估算值（约11.9万人 = 119,000人）

-- 2023年全市中考人数
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    (2023,
     (SELECT id FROM ref_district WHERE code = 'SH'),
     119000,
     '用户提供：2023年中考约11.9万人（估算值）',
     2023)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 2023年最低投档控制分数线

-- 自主招生录取
INSERT INTO ref_control_score (year, admission_batch_id, category, min_score, description, data_year) VALUES
    (2023,
     (SELECT id FROM ref_admission_batch WHERE code = 'AUTONOMOUS'),
     '自主招生录取',
     605,
     '普通高中自主招生录取控制分数线',
     2023)
ON CONFLICT (year, admission_batch_id, category) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- 名额分配综合评价录取
INSERT INTO ref_control_score (year, admission_batch_id, category, min_score, description, data_year) VALUES
    (2023,
     (SELECT id FROM ref_admission_batch WHERE code = 'QUOTA_DISTRICT'),
     '名额分配综合评价录取',
     605,
     '含综合素质评价50分，总分800分',
     2023)
ON CONFLICT (year, admission_batch_id, category) DO UPDATE SET
    min_score = EXCLUDED.min_score,
     description = EXCLUDED.description,
     updated_at = CURRENT_TIMESTAMP;

-- 公办普通高中录取
INSERT INTO ref_control_score (year, admission_batch_id, category, min_score, description, data_year) VALUES
    (2023,
     (SELECT id FROM ref_admission_batch WHERE code = 'UNIFIED_GENERAL_PUBLIC'),
     '公办普通高中录取',
     513,
     '统一招生录取，总分750分',
     2023)
ON CONFLICT (year, admission_batch_id, category) DO UPDATE SET
    min_score = EXCLUDED.min_score,
    description = EXCLUDED.description,
     updated_at = CURRENT_TIMESTAMP;

-- ============================================================================
-- 招生计划统计说明
-- 总招生计划: 约7.33万人
-- 市重点高中招生: 约2.61万人，录取率约23.7%
-- 整体录取率: 约66.6%
-- ============================================================================
