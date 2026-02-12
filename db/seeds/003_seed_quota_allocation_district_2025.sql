-- ========================================================================
-- 2025年名额分配到区招生计划 - 种子数据
-- 数据来源: PDF解析后提取的数据
-- 注：76所市实验性示范性高中，6724个名额
-- ========================================================================

-- 上海市上海中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '042032'),
    '042032',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    286,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '102056'),
    '102056',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    319,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '102057'),
    '102057',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    255,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '152003'),
    '152003',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    280,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '152006'),
    '152006',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    187,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '155001'),
    '155001',
    (SELECT id FROM ref_district WHERE code = 'SH'),
    52,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012001'),
    '012001',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    126,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市大同中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012003'),
    '012003',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    136,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市向明中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012005'),
    '012005',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    59,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学附属大境中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012007'),
    '012007',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    96,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市光明中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012008'),
    '012008',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    86,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市敬业中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012009'),
    '012009',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    76,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市卢湾高级中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012010'),
    '012010',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    96,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市格致中学（奉贤校区）
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012002'),
    '012002',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    40,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市向明中学（浦江校区）
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '012006'),
    '012006',
    (SELECT id FROM ref_district WHERE code = 'HP'),
    38,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第二中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '042001'),
    '042001',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    52,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南洋模范中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '042008'),
    '042008',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    90,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市位育中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '042035'),
    '042035',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    89,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市南洋中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '043015'),
    '043015',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    78,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第二中学（梅陇校区）
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '042002'),
    '042002',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    53,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学徐汇分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '042036'),
    '042036',
    (SELECT id FROM ref_district WHERE code = 'XH'),
    31,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第三女子中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '052001'),
    '052001',
    (SELECT id FROM ref_district WHERE code = 'CN'),
    51,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市延安中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '052002'),
    '052002',
    (SELECT id FROM ref_district WHERE code = 'CN'),
    72,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市复旦中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '053004'),
    '053004',
    (SELECT id FROM ref_district WHERE code = 'CN'),
    53,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市市西中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '062001'),
    '062001',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    70,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市育才中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '062002'),
    '062002',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    67,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市新中高级中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '062003'),
    '062003',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    67,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市市北中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '062004'),
    '062004',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    74,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市回民中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '062011'),
    '062011',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    53,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市第六十中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '063004'),
    '063004',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    53,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市华东模范中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '064001'),
    '064001',
    (SELECT id FROM ref_district WHERE code = 'JA'),
    44,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市晋元高级中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '072001'),
    '072001',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    84,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市曹杨第二中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '072002'),
    '072002',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    82,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市宜川中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '073003'),
    '073003',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    84,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学（普陀校区）
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '073082'),
    '073082',
    (SELECT id FROM ref_district WHERE code = 'PT'),
    30,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属复兴中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '092001'),
    '092001',
    (SELECT id FROM ref_district WHERE code = 'HK'),
    76,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第一附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '092002'),
    '092002',
    (SELECT id FROM ref_district WHERE code = 'HK'),
    71,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海财经大学附属北郊高级中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '093001'),
    '093001',
    (SELECT id FROM ref_district WHERE code = 'HK'),
    56,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市杨浦高级中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '102004'),
    '102004',
    (SELECT id FROM ref_district WHERE code = 'YP'),
    100,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市控江中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '102032'),
    '102032',
    (SELECT id FROM ref_district WHERE code = 'YP'),
    100,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 同济大学第一附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '103002'),
    '103002',
    (SELECT id FROM ref_district WHERE code = 'YP'),
    84,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市七宝中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '122001'),
    '122001',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    120,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市闵行中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '123001'),
    '123001',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    120,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学闵行紫竹分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '122002'),
    '122002',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    69,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学闵行分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '122003'),
    '122003',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    86,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学闵行分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '122004'),
    '122004',
    (SELECT id FROM ref_district WHERE code = 'MH'),
    69,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市行知中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '132001'),
    '132001',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    101,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海大学附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '132002'),
    '132002',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    101,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市吴淞中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '133001'),
    '133001',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    98,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学宝山分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '132003'),
    '132003',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    34,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学（宝山校区）
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '133003'),
    '133003',
    (SELECT id FROM ref_district WHERE code = 'BS'),
    49,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市嘉定区第一中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '142001'),
    '142001',
    (SELECT id FROM ref_district WHERE code = 'JD'),
    87,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海交通大学附属中学嘉定分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '142002'),
    '142002',
    (SELECT id FROM ref_district WHERE code = 'JD'),
    105,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学嘉定新城分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '142004'),
    '142004',
    (SELECT id FROM ref_district WHERE code = 'JD'),
    35,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市建平中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '152001'),
    '152001',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    109,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市进才中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '152002'),
    '152002',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    109,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海南汇中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '152004'),
    '152004',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    140,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市洋泾中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '153001'),
    '153001',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    109,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市高桥中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '153004'),
    '153004',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    94,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市川沙中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '153005'),
    '153005',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    94,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海中学东校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '151078'),
    '151078',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    94,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市浦东复旦附中分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '152005'),
    '152005',
    (SELECT id FROM ref_district WHERE code = 'PD'),
    56,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市金山中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '162000'),
    '162000',
    (SELECT id FROM ref_district WHERE code = 'JS'),
    78,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第三附属中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '163002'),
    '163002',
    (SELECT id FROM ref_district WHERE code = 'JS'),
    78,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江二中
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '172001'),
    '172001',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    82,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市松江一中
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '173001'),
    '173001',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    82,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学松江分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '172002'),
    '172002',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    33,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海师范大学附属中学松江分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '172004'),
    '172004',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    18,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海外国语大学附属外国语学校松江云间中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '174003'),
    '174003',
    (SELECT id FROM ref_district WHERE code = 'SJ'),
    82,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市青浦高级中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '182001'),
    '182001',
    (SELECT id FROM ref_district WHERE code = 'QP'),
    112,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市朱家角中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '183002'),
    '183002',
    (SELECT id FROM ref_district WHERE code = 'QP'),
    112,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 复旦大学附属中学青浦分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '182002'),
    '182002',
    (SELECT id FROM ref_district WHERE code = 'QP'),
    49,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市奉贤中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '202001'),
    '202001',
    (SELECT id FROM ref_district WHERE code = 'FX'),
    87,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 华东师范大学第二附属中学临港奉贤分校
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '202002'),
    '202002',
    (SELECT id FROM ref_district WHERE code = 'FX'),
    43,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市崇明中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '512000'),
    '512000',
    (SELECT id FROM ref_district WHERE code = 'CM'),
    62,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- 上海市实验学校东滩高级中学
INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES
    2025,
    (SELECT id FROM ref_school WHERE code = '512001'),
    '512001',
    (SELECT id FROM ref_district WHERE code = 'CM'),
    31,
    2025)
ON CONFLICT (year, school_id, district_id) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
