-- ============================================================================
-- 2024-2025年上海中考报名人数对比 - 种子数据
-- 数据来源：上海市教育考试院及各区教育行政部门公布数据
-- ============================================================================
-- 注：人数数据为官方公布数据的四舍五入值

-- 2024年全市中考报名人数
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    (2024,
     (SELECT id FROM ref_district WHERE code = 'SH'),
     118000,
     '上海市教育考试院公布：2024年中考约11.8万人',
     2024)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 2025年全市中考报名人数
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    (2025,
     (SELECT id FROM ref_district WHERE code = 'SH'),
     127000,
     '上海市教育考试院公布：2025年中考约12.7万人',
     2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- ============================================================================
-- 数据要点分析
-- ============================================================================
-- 1. 人数激增：2025年达12.7万人，受户籍政策调整及适龄入学高峰影响
-- 2. 录取规模同步扩大：教育资源同步扩容，维持66%左右录取率
-- 3. 未来趋势：根据出生人口数据，2026-2027年预计保持高位，2027年可能达15.5万人峰值
--
-- 2024年对比：
--   - 报名人数增加0.8万人（+7.3%）
--   - 高中招生计划7.56万人，录取率约64%
--
-- 2025年对比：
--   - 报名人数增加0.9万人（+7.6%）
--   - 高中招生计划8.4万人，录取率约66%
--   - "名额分配到校"计划招生12,140人，录取完成率98.34%
-- ============================================================================
