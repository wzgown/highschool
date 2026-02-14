-- =============================================================================
-- 2025年上海市高中招生计划汇总 - 种子数据
-- =============================================================================
-- 数据来源:
--   - 自主招生计划: 2025年上海市高中自主招生计划.pdf
--   - 名额分配到区: 2025年名额分配到区招生计划
-- 说明:
--   - 名额分配比例: 委属约65%（80%到区+20%到校），区属约65%（30%到区+70%到校）
--   - 统一招生名额 = 总计划 - 自主招生 - 名额分配到区 - 名额分配到校
-- =============================================================================

-- 清除2025年现有数据
DELETE FROM ref_admission_plan_summary WHERE year = 2025;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '042032' AND data_year = 2025 LIMIT 1),
    '042032',
    '上海市上海中学',
    (SELECT id FROM ref_district WHERE code = 'SH' LIMIT 1),
    'CITY_MODEL',
    TRUE,
    165, 0, 0,
    286, 71, 27,
    549, 357, 65.03, 30.05, 4.92,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '042032' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '102056' AND data_year = 2025 LIMIT 1),
    '102056',
    '上海交通大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH' LIMIT 1),
    'CITY_MODEL',
    TRUE,
    203, 0, 10,
    319, 79, 11,
    612, 398, 65.03, 33.17, 1.8,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102056' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '102057' AND data_year = 2025 LIMIT 1),
    '102057',
    '复旦大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH' LIMIT 1),
    'CITY_MODEL',
    TRUE,
    161, 0, 2,
    255, 63, 10,
    489, 318, 65.03, 32.92, 2.04,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102057' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '152003' AND data_year = 2025 LIMIT 1),
    '152003',
    '华东师范大学第二附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH' LIMIT 1),
    'CITY_MODEL',
    TRUE,
    163, 0, 0,
    280, 70, 25,
    538, 350, 65.06, 30.3, 4.65,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '152006' AND data_year = 2025 LIMIT 1),
    '152006',
    '上海师范大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'SH' LIMIT 1),
    'CITY_MODEL',
    TRUE,
    46, 0, 5,
    187, 46, 79,
    358, 233, 65.08, 12.85, 22.07,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152006' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '155001' AND data_year = 2025 LIMIT 1),
    '155001',
    '上海市实验学校',
    (SELECT id FROM ref_district WHERE code = 'SH' LIMIT 1),
    'CITY_MODEL',
    TRUE,
    30, 0, 6,
    52, 13, 5,
    100, 65, 65.0, 30.0, 5.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '155001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012001' AND data_year = 2025 LIMIT 1),
    '012001',
    '上海市格致中学',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    36, 4, 4,
    126, 294, 190,
    646, 420, 65.02, 5.57, 29.41,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012003' AND data_year = 2025 LIMIT 1),
    '012003',
    '上海市大同中学',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    40, 10, 2,
    136, 317, 203,
    696, 453, 65.09, 5.75, 29.17,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012005' AND data_year = 2025 LIMIT 1),
    '012005',
    '上海市向明中学',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    34, 4, 7,
    59, 137, 71,
    301, 196, 65.12, 11.3, 23.59,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012005' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012007' AND data_year = 2025 LIMIT 1),
    '012007',
    '上海外国语大学附属大境中学',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    37, 5, 3,
    96, 224, 135,
    492, 320, 65.04, 7.52, 27.44,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012007' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012008' AND data_year = 2025 LIMIT 1),
    '012008',
    '上海市光明中学',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    25, 7, 2,
    86, 200, 129,
    440, 286, 65.0, 5.68, 29.32,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012008' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012009' AND data_year = 2025 LIMIT 1),
    '012009',
    '上海市敬业中学',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    20, 3, 2,
    76, 177, 116,
    389, 253, 65.04, 5.14, 29.82,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012009' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012010' AND data_year = 2025 LIMIT 1),
    '012010',
    '上海市卢湾高级中学',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    30, 2, 4,
    96, 224, 142,
    492, 320, 65.04, 6.1, 28.86,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012010' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012002' AND data_year = 2025 LIMIT 1),
    '012002',
    '上海市格致中学（奉贤校区）',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    61, 0, 2,
    40, 93, 10,
    204, 133, 65.2, 29.9, 4.9,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '012006' AND data_year = 2025 LIMIT 1),
    '012006',
    '上海市向明中学（浦江校区）',
    (SELECT id FROM ref_district WHERE code = 'HP' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    54, 0, 0,
    38, 88, 13,
    193, 126, 65.28, 27.98, 6.74,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '012006' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '042001' AND data_year = 2025 LIMIT 1),
    '042001',
    '上海市第二中学',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    50, 5, 8,
    52, 121, 43,
    266, 173, 65.04, 18.8, 16.17,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '042001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '042008' AND data_year = 2025 LIMIT 1),
    '042008',
    '上海市南洋模范中学',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    33, 6, 6,
    90, 210, 128,
    461, 300, 65.08, 7.16, 27.77,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '042008' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '042035' AND data_year = 2025 LIMIT 1),
    '042035',
    '上海市位育中学',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    16, 0, 0,
    89, 207, 143,
    455, 296, 65.05, 3.52, 31.43,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '042035' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '043015' AND data_year = 2025 LIMIT 1),
    '043015',
    '上海市南洋中学',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    65, 8, 5,
    78, 182, 75,
    400, 260, 65.0, 16.25, 18.75,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '043015' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '042002' AND data_year = 2025 LIMIT 1),
    '042002',
    '上海市第二中学（梅陇校区）',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    31, 6, 6,
    53, 123, 63,
    270, 176, 65.19, 11.48, 23.33,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '042002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '042036' AND data_year = 2025 LIMIT 1),
    '042036',
    '复旦大学附属中学徐汇分校',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    48, 0, 0,
    31, 72, 7,
    158, 103, 65.19, 30.38, 4.43,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '042036' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '044109' AND data_year = 2025 LIMIT 1),
    '044109',
    '上海市徐汇中学',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0, 0, 0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '044109' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '044223' AND data_year = 2025 LIMIT 1),
    '044223',
    '上海市紫竹园中学',
    (SELECT id FROM ref_district WHERE code = 'XH' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    0, 0, 0,
    0, 0, 0,
    0, 0, 0, 0, 0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '044223' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '052001' AND data_year = 2025 LIMIT 1),
    '052001',
    '上海市第三女子中学',
    (SELECT id FROM ref_district WHERE code = 'CN' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    85, 2, 6,
    51, 119, 6,
    261, 170, 65.13, 32.57, 2.3,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '052001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '052002' AND data_year = 2025 LIMIT 1),
    '052002',
    '上海市延安中学',
    (SELECT id FROM ref_district WHERE code = 'CN' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    57, 0, 3,
    72, 168, 72,
    369, 240, 65.04, 15.45, 19.51,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '052002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '053004' AND data_year = 2025 LIMIT 1),
    '053004',
    '上海市复旦中学',
    (SELECT id FROM ref_district WHERE code = 'CN' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    38, 10, 2,
    53, 123, 56,
    270, 176, 65.19, 14.07, 20.74,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '053004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '054013' AND data_year = 2025 LIMIT 1),
    '054013',
    '华东政法大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'CN' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    24, 0, 0,
    0, 0, 176,
    200, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '054013' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '062001' AND data_year = 2025 LIMIT 1),
    '062001',
    '上海市市西中学',
    (SELECT id FROM ref_district WHERE code = 'JA' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    52, 4, 12,
    70, 163, 73,
    358, 233, 65.08, 14.53, 20.39,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '062001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '062002' AND data_year = 2025 LIMIT 1),
    '062002',
    '上海市育才中学',
    (SELECT id FROM ref_district WHERE code = 'JA' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    38, 2, 2,
    67, 156, 82,
    343, 223, 65.01, 11.08, 23.91,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '062002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '062003' AND data_year = 2025 LIMIT 1),
    '062003',
    '上海市新中高级中学',
    (SELECT id FROM ref_district WHERE code = 'JA' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    50, 11, 0,
    67, 156, 70,
    343, 223, 65.01, 14.58, 20.41,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '062003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '062004' AND data_year = 2025 LIMIT 1),
    '062004',
    '上海市市北中学',
    (SELECT id FROM ref_district WHERE code = 'JA' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    48, 4, 4,
    74, 172, 84,
    378, 246, 65.08, 12.7, 22.22,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '062004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '062011' AND data_year = 2025 LIMIT 1),
    '062011',
    '上海市回民中学',
    (SELECT id FROM ref_district WHERE code = 'JA' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    35, 8, 1,
    53, 123, 59,
    270, 176, 65.19, 12.96, 21.85,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '062011' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '063004' AND data_year = 2025 LIMIT 1),
    '063004',
    '上海市第六十中学',
    (SELECT id FROM ref_district WHERE code = 'JA' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    33, 4, 0,
    53, 123, 61,
    270, 176, 65.19, 12.22, 22.59,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '063004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '064001' AND data_year = 2025 LIMIT 1),
    '064001',
    '上海市华东模范中学',
    (SELECT id FROM ref_district WHERE code = 'JA' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    31, 8, 0,
    44, 102, 47,
    224, 146, 65.18, 13.84, 20.98,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '064001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '072001' AND data_year = 2025 LIMIT 1),
    '072001',
    '上海市晋元高级中学',
    (SELECT id FROM ref_district WHERE code = 'PT' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    49, 4, 0,
    84, 196, 101,
    430, 280, 65.12, 11.4, 23.49,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '072001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '072002' AND data_year = 2025 LIMIT 1),
    '072002',
    '上海市曹杨第二中学',
    (SELECT id FROM ref_district WHERE code = 'PT' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    51, 5, 0,
    82, 191, 96,
    420, 273, 65.0, 12.14, 22.86,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '072002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '073003' AND data_year = 2025 LIMIT 1),
    '073003',
    '上海市宜川中学',
    (SELECT id FROM ref_district WHERE code = 'PT' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    46, 2, 4,
    84, 196, 104,
    430, 280, 65.12, 10.7, 24.19,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '073003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '073082' AND data_year = 2025 LIMIT 1),
    '073082',
    '华东师范大学第二附属中学（普陀校区）',
    (SELECT id FROM ref_district WHERE code = 'PT' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    16, 0, 1,
    30, 70, 37,
    153, 100, 65.36, 10.46, 24.18,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '073082' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '073004' AND data_year = 2025 LIMIT 1),
    '073004',
    '上海市曹杨中学',
    (SELECT id FROM ref_district WHERE code = 'PT' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    60, 0, 0,
    0, 0, 440,
    500, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '073004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '074005' AND data_year = 2025 LIMIT 1),
    '074005',
    '同济大学第二附属中学',
    (SELECT id FROM ref_district WHERE code = 'PT' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    63, 0, 2,
    0, 0, 462,
    525, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '074005' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '074007' AND data_year = 2025 LIMIT 1),
    '074007',
    '上海市甘泉外国语中学',
    (SELECT id FROM ref_district WHERE code = 'PT' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    69, 3, 0,
    0, 0, 506,
    575, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '074007' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '092001' AND data_year = 2025 LIMIT 1),
    '092001',
    '复旦大学附属复兴中学',
    (SELECT id FROM ref_district WHERE code = 'HK' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    51, 3, 2,
    76, 177, 85,
    389, 253, 65.04, 13.11, 21.85,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '092001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '092002' AND data_year = 2025 LIMIT 1),
    '092002',
    '华东师范大学第一附属中学',
    (SELECT id FROM ref_district WHERE code = 'HK' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    42, 2, 0,
    71, 165, 85,
    363, 236, 65.01, 11.57, 23.42,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '092002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '093001' AND data_year = 2025 LIMIT 1),
    '093001',
    '上海财经大学附属北郊高级中学',
    (SELECT id FROM ref_district WHERE code = 'HK' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    37, 5, 1,
    56, 130, 63,
    286, 186, 65.03, 12.94, 22.03,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '093001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '102004' AND data_year = 2025 LIMIT 1),
    '102004',
    '上海市杨浦高级中学',
    (SELECT id FROM ref_district WHERE code = 'YP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    61, 3, 0,
    100, 233, 118,
    512, 333, 65.04, 11.91, 23.05,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '102032' AND data_year = 2025 LIMIT 1),
    '102032',
    '上海市控江中学',
    (SELECT id FROM ref_district WHERE code = 'YP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    64, 2, 1,
    100, 233, 115,
    512, 333, 65.04, 12.5, 22.46,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102032' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '103002' AND data_year = 2025 LIMIT 1),
    '103002',
    '同济大学第一附属中学',
    (SELECT id FROM ref_district WHERE code = 'YP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    75, 21, 0,
    84, 196, 75,
    430, 280, 65.12, 17.44, 17.44,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '103002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '103039' AND data_year = 2025 LIMIT 1),
    '103039',
    '上海理工大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'YP' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    52, 0, 0,
    0, 0, 381,
    433, 0, 0.0, 12.01, 87.99,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '103039' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '122001' AND data_year = 2025 LIMIT 1),
    '122001',
    '上海市七宝中学',
    (SELECT id FROM ref_district WHERE code = 'MH' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    98, 1, 6,
    120, 280, 117,
    615, 400, 65.04, 15.93, 19.02,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '122001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '123001' AND data_year = 2025 LIMIT 1),
    '123001',
    '上海市闵行中学',
    (SELECT id FROM ref_district WHERE code = 'MH' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    82, 27, 2,
    120, 280, 133,
    615, 400, 65.04, 13.33, 21.63,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '123001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '122002' AND data_year = 2025 LIMIT 1),
    '122002',
    '华东师范大学第二附属中学闵行紫竹分校',
    (SELECT id FROM ref_district WHERE code = 'MH' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    50, 19, 3,
    69, 161, 73,
    353, 230, 65.16, 14.16, 20.68,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '122002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '122003' AND data_year = 2025 LIMIT 1),
    '122003',
    '上海师范大学附属中学闵行分校',
    (SELECT id FROM ref_district WHERE code = 'MH' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    54, 3, 6,
    86, 200, 100,
    440, 286, 65.0, 12.27, 22.73,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '122003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '122004' AND data_year = 2025 LIMIT 1),
    '122004',
    '上海交通大学附属中学闵行分校',
    (SELECT id FROM ref_district WHERE code = 'MH' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    38, 10, 2,
    69, 161, 85,
    353, 230, 65.16, 10.76, 24.08,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '122004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '124006' AND data_year = 2025 LIMIT 1),
    '124006',
    '上海市闵行第三中学',
    (SELECT id FROM ref_district WHERE code = 'MH' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    81, 0, 0,
    0, 0, 594,
    675, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '124006' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '132001' AND data_year = 2025 LIMIT 1),
    '132001',
    '上海市行知中学',
    (SELECT id FROM ref_district WHERE code = 'BS' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    62, 6, 0,
    101, 235, 118,
    516, 336, 65.12, 12.02, 22.87,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '132001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '132002' AND data_year = 2025 LIMIT 1),
    '132002',
    '上海大学附属中学',
    (SELECT id FROM ref_district WHERE code = 'BS' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    62, 8, 0,
    101, 235, 118,
    516, 336, 65.12, 12.02, 22.87,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '132002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '133001' AND data_year = 2025 LIMIT 1),
    '133001',
    '上海市吴淞中学',
    (SELECT id FROM ref_district WHERE code = 'BS' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    66, 10, 4,
    98, 228, 109,
    501, 326, 65.07, 13.17, 21.76,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '133001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '132003' AND data_year = 2025 LIMIT 1),
    '132003',
    '上海师范大学附属中学宝山分校',
    (SELECT id FROM ref_district WHERE code = 'BS' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    17, 0, 2,
    34, 79, 43,
    173, 113, 65.32, 9.83, 24.86,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '132003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '133003' AND data_year = 2025 LIMIT 1),
    '133003',
    '华东师范大学第二附属中学（宝山校区）',
    (SELECT id FROM ref_district WHERE code = 'BS' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    25, 0, 0,
    49, 114, 62,
    250, 163, 65.2, 10.0, 24.8,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '133003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '133002' AND data_year = 2025 LIMIT 1),
    '133002',
    '上海师范大学附属宝山罗店中学',
    (SELECT id FROM ref_district WHERE code = 'BS' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    76, 0, 2,
    0, 0, 557,
    633, 0, 0.0, 12.01, 87.99,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '133002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025 LIMIT 1),
    '142001',
    '上海市嘉定区第一中学',
    (SELECT id FROM ref_district WHERE code = 'JD' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    59, 12, 0,
    87, 203, 97,
    446, 290, 65.02, 13.23, 21.75,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025 LIMIT 1),
    '142002',
    '上海交通大学附属中学嘉定分校',
    (SELECT id FROM ref_district WHERE code = 'JD' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    74, 8, 0,
    105, 245, 114,
    538, 350, 65.06, 13.75, 21.19,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025 LIMIT 1),
    '142004',
    '上海师范大学附属中学嘉定新城分校',
    (SELECT id FROM ref_district WHERE code = 'JD' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    18, 0, 2,
    35, 81, 44,
    178, 116, 65.17, 10.11, 24.72,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '143001' AND data_year = 2025 LIMIT 1),
    '143001',
    '上海市嘉定区第二中学',
    (SELECT id FROM ref_district WHERE code = 'JD' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    81, 0, 0,
    0, 0, 594,
    675, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '143001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '152001' AND data_year = 2025 LIMIT 1),
    '152001',
    '上海市建平中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    75, 9, 10,
    109, 254, 120,
    558, 363, 65.05, 13.44, 21.51,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '152002' AND data_year = 2025 LIMIT 1),
    '152002',
    '上海市进才中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    73, 6, 5,
    109, 254, 122,
    558, 363, 65.05, 13.08, 21.86,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '152004' AND data_year = 2025 LIMIT 1),
    '152004',
    '上海南汇中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    80, 3, 6,
    140, 326, 170,
    716, 466, 65.08, 11.17, 23.74,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '153001' AND data_year = 2025 LIMIT 1),
    '153001',
    '上海市洋泾中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    65, 3, 3,
    109, 254, 130,
    558, 363, 65.05, 11.65, 23.3,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '153001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '153004' AND data_year = 2025 LIMIT 1),
    '153004',
    '上海市高桥中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    54, 6, 4,
    94, 219, 114,
    481, 313, 65.07, 11.23, 23.7,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '153004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '153005' AND data_year = 2025 LIMIT 1),
    '153005',
    '上海市川沙中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    58, 2, 6,
    94, 219, 110,
    481, 313, 65.07, 12.06, 22.87,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '153005' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '151078' AND data_year = 2025 LIMIT 1),
    '151078',
    '上海中学东校',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    56, 3, 3,
    94, 219, 112,
    481, 313, 65.07, 11.64, 23.28,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '151078' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '152005' AND data_year = 2025 LIMIT 1),
    '152005',
    '上海市浦东复旦附中分校',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    32, 0, 0,
    56, 130, 68,
    286, 186, 65.03, 11.19, 23.78,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152005' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '153002' AND data_year = 2025 LIMIT 1),
    '153002',
    '华东师范大学附属东昌中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    90, 0, 0,
    0, 0, 660,
    750, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '153002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '154009' AND data_year = 2025 LIMIT 1),
    '154009',
    '上海市香山中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    72, 0, 0,
    0, 0, 528,
    600, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '154009' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '154013' AND data_year = 2025 LIMIT 1),
    '154013',
    '上海海事大学附属北蔡高级中学',
    (SELECT id FROM ref_district WHERE code = 'PD' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    48, 0, 2,
    0, 0, 352,
    400, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '154013' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '162000' AND data_year = 2025 LIMIT 1),
    '162000',
    '上海市金山中学',
    (SELECT id FROM ref_district WHERE code = 'JS' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    44, 2, 2,
    78, 182, 96,
    400, 260, 65.0, 11.0, 24.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '162000' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '163002' AND data_year = 2025 LIMIT 1),
    '163002',
    '华东师范大学第三附属中学',
    (SELECT id FROM ref_district WHERE code = 'JS' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    53, 11, 5,
    78, 182, 87,
    400, 260, 65.0, 13.25, 21.75,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '163002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '163001' AND data_year = 2025 LIMIT 1),
    '163001',
    '上海师范大学第二附属中学',
    (SELECT id FROM ref_district WHERE code = 'JS' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    54, 0, 2,
    0, 0, 396,
    450, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '163001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '164000' AND data_year = 2025 LIMIT 1),
    '164000',
    '华东师范大学附属枫泾中学',
    (SELECT id FROM ref_district WHERE code = 'JS' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    38, 0, 0,
    0, 0, 278,
    316, 0, 0.0, 12.03, 87.97,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '164000' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '172001' AND data_year = 2025 LIMIT 1),
    '172001',
    '上海市松江二中',
    (SELECT id FROM ref_district WHERE code = 'SJ' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    54, 0, 2,
    82, 191, 93,
    420, 273, 65.0, 12.86, 22.14,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '172001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '173001' AND data_year = 2025 LIMIT 1),
    '173001',
    '上海市松江一中',
    (SELECT id FROM ref_district WHERE code = 'SJ' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    56, 9, 1,
    82, 191, 91,
    420, 273, 65.0, 13.33, 21.67,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '173001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '172002' AND data_year = 2025 LIMIT 1),
    '172002',
    '华东师范大学第二附属中学松江分校',
    (SELECT id FROM ref_district WHERE code = 'SJ' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    22, 5, 3,
    33, 77, 37,
    169, 110, 65.09, 13.02, 21.89,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '172002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '172004' AND data_year = 2025 LIMIT 1),
    '172004',
    '上海师范大学附属中学松江分校',
    (SELECT id FROM ref_district WHERE code = 'SJ' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    9, 3, 0,
    18, 42, 23,
    92, 60, 65.22, 9.78, 25.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '172004' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '174003' AND data_year = 2025 LIMIT 1),
    '174003',
    '上海外国语大学附属外国语学校松江云间中学',
    (SELECT id FROM ref_district WHERE code = 'SJ' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    49, 0, 2,
    82, 191, 98,
    420, 273, 65.0, 11.67, 23.33,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '174003' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '182001' AND data_year = 2025 LIMIT 1),
    '182001',
    '上海市青浦高级中学',
    (SELECT id FROM ref_district WHERE code = 'QP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    65, 7, 1,
    112, 261, 135,
    573, 373, 65.1, 11.34, 23.56,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '182001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '183002' AND data_year = 2025 LIMIT 1),
    '183002',
    '上海市朱家角中学',
    (SELECT id FROM ref_district WHERE code = 'QP' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    62, 3, 2,
    112, 261, 138,
    573, 373, 65.1, 10.82, 24.08,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '183002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '182002' AND data_year = 2025 LIMIT 1),
    '182002',
    '复旦大学附属中学青浦分校',
    (SELECT id FROM ref_district WHERE code = 'QP' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    36, 0, 0,
    49, 114, 51,
    250, 163, 65.2, 14.4, 20.4,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '182002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '184005' AND data_year = 2025 LIMIT 1),
    '184005',
    '上海市青浦区第一中学',
    (SELECT id FROM ref_district WHERE code = 'QP' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    52, 0, 3,
    0, 0, 381,
    433, 0, 0.0, 12.01, 87.99,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '184005' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '202001' AND data_year = 2025 LIMIT 1),
    '202001',
    '上海市奉贤中学',
    (SELECT id FROM ref_district WHERE code = 'FX' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    55, 6, 2,
    87, 203, 101,
    446, 290, 65.02, 12.33, 22.65,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '202001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '202002' AND data_year = 2025 LIMIT 1),
    '202002',
    '华东师范大学第二附属中学临港奉贤分校',
    (SELECT id FROM ref_district WHERE code = 'FX' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    26, 0, 0,
    43, 100, 51,
    220, 143, 65.0, 11.82, 23.18,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '202002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '203002' AND data_year = 2025 LIMIT 1),
    '203002',
    '华东理工大学附属奉贤曙光中学',
    (SELECT id FROM ref_district WHERE code = 'FX' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    66, 3, 2,
    0, 0, 484,
    550, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '203002' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '512000' AND data_year = 2025 LIMIT 1),
    '512000',
    '上海市崇明中学',
    (SELECT id FROM ref_district WHERE code = 'CM' LIMIT 1),
    'CITY_MODEL',
    FALSE,
    38, 4, 2,
    62, 144, 72,
    316, 206, 65.19, 12.03, 22.78,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '512001' AND data_year = 2025 LIMIT 1),
    '512001',
    '上海市实验学校东滩高级中学',
    (SELECT id FROM ref_district WHERE code = 'CM' LIMIT 1),
    'CITY_POLICY',
    FALSE,
    16, 0, 0,
    31, 72, 39,
    158, 103, 65.19, 10.13, 24.68,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

INSERT INTO ref_admission_plan_summary (
    year, school_id, school_code, school_name, district_id, school_type_id, is_municipal,
    autonomous_count, autonomous_sports_count, autonomous_arts_count,
    quota_district_count, quota_school_count, unified_count,
    total_plan_count, quota_total_count, quota_ratio, autonomous_ratio, unified_ratio,
    data_year, data_source
) SELECT 
    2025,
    (SELECT id FROM ref_school WHERE code = '514001' AND data_year = 2025 LIMIT 1),
    '514001',
    '上海市崇明区城桥中学',
    (SELECT id FROM ref_district WHERE code = 'CM' LIMIT 1),
    'CITY_FEATURED',
    FALSE,
    54, 0, 0,
    0, 0, 396,
    450, 0, 0.0, 12.0, 88.0,
    2025, '2025年上海市高中自主招生计划.pdf + 名额分配到区招生计划'
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '514001' AND data_year = 2025)
ON CONFLICT (year, school_code) DO UPDATE SET
    autonomous_count = EXCLUDED.autonomous_count,
    autonomous_sports_count = EXCLUDED.autonomous_sports_count,
    autonomous_arts_count = EXCLUDED.autonomous_arts_count,
    quota_district_count = EXCLUDED.quota_district_count,
    quota_school_count = EXCLUDED.quota_school_count,
    unified_count = EXCLUDED.unified_count,
    total_plan_count = EXCLUDED.total_plan_count,
    quota_total_count = EXCLUDED.quota_total_count,
    quota_ratio = EXCLUDED.quota_ratio,
    autonomous_ratio = EXCLUDED.autonomous_ratio,
    unified_ratio = EXCLUDED.unified_ratio,
    updated_at = CURRENT_TIMESTAMP;

-- =============================================================================
-- 验证数据完整性
-- =============================================================================
SELECT
    is_municipal AS 委属,
    COUNT(*) AS 学校数,
    SUM(autonomous_count) AS 自主招生总计,
    SUM(quota_district_count) AS 名额到区总计,
    SUM(quota_school_count) AS 名额到校总计,
    SUM(unified_count) AS 统一招生总计,
    SUM(total_plan_count) AS 总计划,
    ROUND(AVG(quota_ratio), 2) AS 平均名额分配比例
FROM ref_admission_plan_summary
WHERE year = 2025
GROUP BY is_municipal
ORDER BY is_municipal DESC;
