-- ==========================================================================
-- 2025年各区中考报名人数 - 种子数据
-- 数据来源：original_data/raw/2025/2025年上海各区中考人数.csv
-- 注：以下数据为官方公布值，覆盖全市16个区
-- ==========================================================================

-- 黄浦
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'HP'),
    3788,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 徐汇
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'XH'),
    8014,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 长宁
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'CN'),
    3404,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 静安
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'JA'),
    6747,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 普陀
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'PT'),
    6329,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 虹口
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'HK'),
    3989,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 杨浦
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'YP'),
    6590,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 闵行
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'MH'),
    15531,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 宝山
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'BS'),
    9937,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 嘉定
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    7305,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 浦东
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'PD'),
    30447,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 金山
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'JS'),
    3903,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 松江
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    8942,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 青浦
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'QP'),
    4802,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 奉贤
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'FX'),
    4838,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

-- 崇明
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES
    2025,
    (SELECT id FROM ref_district WHERE code = 'CM'),
    2590,
    '2025年各区中考人数原始数据',
    2025)
ON CONFLICT (year, district_id) DO UPDATE SET
    exam_count = EXCLUDED.exam_count,
    data_source = EXCLUDED.data_source,
    updated_at = CURRENT_TIMESTAMP;

--
-- 全市总计: 127,156人
-- 各区明细:
--   黄浦: 3788人
--   徐汇: 8014人
--   长宁: 3404人
--   静安: 6747人
--   普陀: 6329人
--   虹口: 3989人
--   杨浦: 6590人
--   闵行: 15531人
--   宝山: 9937人
--   嘉定: 7305人
--   浦东: 30447人
--   金山: 3903人
--   松江: 8942人
--   青浦: 4802人
--   奉贤: 4838人
--   崇明: 2590人