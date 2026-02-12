-- ============================================================================
-- 2026-2027年上海中考报名人数预估 - 种子数据
-- 数据来源：基于出生人口数据和趋势预估
-- ============================================================================
-- 注：以下数据为预估值，非官方公布数据

-- 预估依据
-- - 2024年：11.8万人
-- - 2025年：12.7万人（+0.9万，+7.6%）
-- - 2027年：预计15.5万人（峰值）
-- - 2026年：推算约14.1万人（线性插值）
--
-- 受适龄入学高峰影响，2026-2027年将继续保持高位增长

-- 2026年全市中考报名人数（预估）
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    (2026,
     (SELECT id FROM ref_district WHERE code = 'SH'),
     141000,
     '预估：基于2025年12.7万到2027年15.5万的线性插值推算',
     2026)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 2027年全市中考报名人数（预估峰值）
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    (2027,
     (SELECT id FROM ref_district WHERE code = 'SH'),
     155000,
     '预估：适龄入学人口峰值年，官方预测约15.5万人',
     2027)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- ============================================================================
-- 数据趋势分析
-- ============================================================================
-- 1. 人数增长趋势：
--    2024 → 2025：+0.9万 (+7.6%)
--    2025 → 2026：+1.4万 (+11%) [预估]
--    2026 → 2027：+1.4万 (+10%) [预估]
--
-- 2. 峰值预测：
--    2027年达到峰值15.5万人后，预计将开始回落
--
-- 3. 教育资源压力：
--    2026-2027年需要持续扩容招生计划
--    名额分配（到区/到校）数量需同步增长
--    建议关注官方招生计划调整通知
-- ============================================================================
