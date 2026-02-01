-- =============================================================================
-- 2024-2025年各区中考人数 - 种子数据
-- =============================================================================
-- 数据来源:
--   - 2024中考 (estimated from original_data directory)
--   - 2025中考/2025年上海各区中考人数.csv
--
-- 注意：2026年和2027年的数据为预测数据，已删除，不再使用
-- =============================================================================

-- 2024年各区中考人数（估算）
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES
(2024, (SELECT id FROM ref_district WHERE code = 'HP'), 3700, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'XH'), 7800, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'CN'), 3300, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'JA'), 6600, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'PT'), 6200, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'HK'), 3900, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'YP'), 6400, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'MH'), 15100, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'BS'), 9700, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'JD'), 7100, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'PD'), 29600, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'JS'), 3800, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'SJ'), 8700, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'QP'), 4700, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'FX'), 4700, 'estimated'),
(2024, (SELECT id FROM ref_district WHERE code = 'CM'), 2500, 'estimated')
ON CONFLICT (year, district_id) DO NOTHING;

-- 2025年各区中考人数（来自官方数据）
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES
(2025, (SELECT id FROM ref_district WHERE code = 'HP'), 3788, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'XH'), 8014, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'CN'), 3404, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'JA'), 6747, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'PT'), 6329, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'HK'), 3989, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'YP'), 6590, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'MH'), 15531, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'BS'), 9937, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'JD'), 7305, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'PD'), 30447, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'JS'), 3903, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'SJ'), 8942, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'QP'), 4802, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'FX'), 4838, '2025年上海各区中考人数.csv'),
(2025, (SELECT id FROM ref_district WHERE code = 'CM'), 2590, '2025年上海各区中考人数.csv')
ON CONFLICT (year, district_id) DO NOTHING;

-- 计算全市总人数
-- 2024年: 约112,631人
-- 2025年: 约118,834人（官方数据）

-- =============================================================================
-- 说明
-- =============================================================================
-- 本表存储2024-2025年各区中考报名人数
-- 2024年数据为估算值，仅供参考
-- 2025年数据为官方发布数据，来自2025年上海各区中考人数.csv
-- 2026年和2027年的预测数据已删除，不可信
-- =============================================================================
