-- =============================================================================
-- 2025年嘉定区名额分配到校招生计划数据
-- =============================================================================
-- Generated: 2026-02-15 22:26:07
-- Source: 嘉定_2025_名额分配到校.csv
-- Records: 127

-- Delete existing 2025 Jiading data
DELETE FROM ref_quota_allocation_school WHERE year = 2025 AND district_id = (SELECT id FROM ref_district WHERE code = 'JD');

-- Insert 2025 quota allocation to school data for Jiading
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区启良中学' AND data_year = 2025),
    '上海市嘉定区启良中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区启良中学' AND data_year = 2025),
    '上海市嘉定区启良中学',
    7,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区启良中学' AND data_year = 2025),
    '上海市嘉定区启良中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '152003' AND data_year = 2025),
    '152003',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区方泰中学' AND data_year = 2025),
    '上海市嘉定区方泰中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '152003' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区方泰中学' AND data_year = 2025),
    '上海市嘉定区方泰中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区方泰中学' AND data_year = 2025),
    '上海市嘉定区方泰中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区方泰中学' AND data_year = 2025),
    '上海市嘉定区方泰中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市曹杨二中附属江桥实验中学' AND data_year = 2025),
    '上海市曹杨二中附属江桥实验中学',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市曹杨二中附属江桥实验中学' AND data_year = 2025),
    '上海市曹杨二中附属江桥实验中学',
    10,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市曹杨二中附属江桥实验中学' AND data_year = 2025),
    '上海市曹杨二中附属江桥实验中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区迎园中学' AND data_year = 2025),
    '上海市嘉定区迎园中学',
    11,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区迎园中学' AND data_year = 2025),
    '上海市嘉定区迎园中学',
    13,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区迎园中学' AND data_year = 2025),
    '上海市嘉定区迎园中学',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区南苑中学' AND data_year = 2025),
    '上海市嘉定区南苑中学',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区南苑中学' AND data_year = 2025),
    '上海市嘉定区南苑中学',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区南苑中学' AND data_year = 2025),
    '上海市嘉定区南苑中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '152003' AND data_year = 2025),
    '152003',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区黄渡中学' AND data_year = 2025),
    '上海市嘉定区黄渡中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '152003' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区黄渡中学' AND data_year = 2025),
    '上海市嘉定区黄渡中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区黄渡中学' AND data_year = 2025),
    '上海市嘉定区黄渡中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区黄渡中学' AND data_year = 2025),
    '上海市嘉定区黄渡中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区徐行中学' AND data_year = 2025),
    '上海市嘉定区徐行中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区徐行中学' AND data_year = 2025),
    '上海市嘉定区徐行中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区徐行中学' AND data_year = 2025),
    '上海市嘉定区徐行中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '152003' AND data_year = 2025),
    '152003',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区马陆育才联合中学' AND data_year = 2025),
    '上海市嘉定区马陆育才联合中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '152003' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区马陆育才联合中学' AND data_year = 2025),
    '上海市嘉定区马陆育才联合中学',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区马陆育才联合中学' AND data_year = 2025),
    '上海市嘉定区马陆育才联合中学',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区马陆育才联合中学' AND data_year = 2025),
    '上海市嘉定区马陆育才联合中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '042032' AND data_year = 2025),
    '042032',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办嘉一联合中学' AND data_year = 2025),
    '上海市民办嘉一联合中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '042032' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办嘉一联合中学' AND data_year = 2025),
    '上海市民办嘉一联合中学',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办嘉一联合中学' AND data_year = 2025),
    '上海市民办嘉一联合中学',
    11,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办嘉一联合中学' AND data_year = 2025),
    '上海市民办嘉一联合中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '042032' AND data_year = 2025),
    '042032',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区丰庄中学' AND data_year = 2025),
    '上海市嘉定区丰庄中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '042032' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区丰庄中学' AND data_year = 2025),
    '上海市嘉定区丰庄中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区丰庄中学' AND data_year = 2025),
    '上海市嘉定区丰庄中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区丰庄中学' AND data_year = 2025),
    '上海市嘉定区丰庄中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区外冈中学' AND data_year = 2025),
    '上海市嘉定区外冈中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区外冈中学' AND data_year = 2025),
    '上海市嘉定区外冈中学',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区外冈中学' AND data_year = 2025),
    '上海市嘉定区外冈中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海民办华曜嘉定初级中学' AND data_year = 2025),
    '上海民办华曜嘉定初级中学',
    7,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海民办华曜嘉定初级中学' AND data_year = 2025),
    '上海民办华曜嘉定初级中学',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海民办华曜嘉定初级中学' AND data_year = 2025),
    '上海民办华曜嘉定初级中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区震川中学' AND data_year = 2025),
    '上海市嘉定区震川中学',
    12,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区震川中学' AND data_year = 2025),
    '上海市嘉定区震川中学',
    14,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区震川中学' AND data_year = 2025),
    '上海市嘉定区震川中学',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海大学附属嘉定留云中学' AND data_year = 2025),
    '上海大学附属嘉定留云中学',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海大学附属嘉定留云中学' AND data_year = 2025),
    '上海大学附属嘉定留云中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海大学附属嘉定留云中学' AND data_year = 2025),
    '上海大学附属嘉定留云中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '交大附中附属嘉定德富中学' AND data_year = 2025),
    '交大附中附属嘉定德富中学',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '交大附中附属嘉定德富中学' AND data_year = 2025),
    '交大附中附属嘉定德富中学',
    9,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '交大附中附属嘉定德富中学' AND data_year = 2025),
    '交大附中附属嘉定德富中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '同济大学附属实验中学' AND data_year = 2025),
    '同济大学附属实验中学',
    7,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '同济大学附属实验中学' AND data_year = 2025),
    '同济大学附属实验中学',
    9,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '同济大学附属实验中学' AND data_year = 2025),
    '同济大学附属实验中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区华江中学' AND data_year = 2025),
    '上海市嘉定区华江中学',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区华江中学' AND data_year = 2025),
    '上海市嘉定区华江中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区华江中学' AND data_year = 2025),
    '上海市嘉定区华江中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区新城实验中学' AND data_year = 2025),
    '上海市嘉定区新城实验中学',
    7,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区新城实验中学' AND data_year = 2025),
    '上海市嘉定区新城实验中学',
    9,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区新城实验中学' AND data_year = 2025),
    '上海市嘉定区新城实验中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区南翔中学' AND data_year = 2025),
    '上海市嘉定区南翔中学',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区南翔中学' AND data_year = 2025),
    '上海市嘉定区南翔中学',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区南翔中学' AND data_year = 2025),
    '上海市嘉定区南翔中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '102056' AND data_year = 2025),
    '102056',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区疁城实验学校' AND data_year = 2025),
    '上海市嘉定区疁城实验学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '102056' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区疁城实验学校' AND data_year = 2025),
    '上海市嘉定区疁城实验学校',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区疁城实验学校' AND data_year = 2025),
    '上海市嘉定区疁城实验学校',
    11,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区疁城实验学校' AND data_year = 2025),
    '上海市嘉定区疁城实验学校',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '042032' AND data_year = 2025),
    '042032',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区戬浜学校' AND data_year = 2025),
    '上海市嘉定区戬浜学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '042032' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区戬浜学校' AND data_year = 2025),
    '上海市嘉定区戬浜学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区戬浜学校' AND data_year = 2025),
    '上海市嘉定区戬浜学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区戬浜学校' AND data_year = 2025),
    '上海市嘉定区戬浜学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '102056' AND data_year = 2025),
    '102056',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区朱桥学校' AND data_year = 2025),
    '上海市嘉定区朱桥学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '102056' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区朱桥学校' AND data_year = 2025),
    '上海市嘉定区朱桥学校',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区朱桥学校' AND data_year = 2025),
    '上海市嘉定区朱桥学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区朱桥学校' AND data_year = 2025),
    '上海市嘉定区朱桥学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '102057' AND data_year = 2025),
    '102057',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区苏民学校' AND data_year = 2025),
    '上海市嘉定区苏民学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '102057' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区苏民学校' AND data_year = 2025),
    '上海市嘉定区苏民学校',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区苏民学校' AND data_year = 2025),
    '上海市嘉定区苏民学校',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区苏民学校' AND data_year = 2025),
    '上海市嘉定区苏民学校',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办远东学校' AND data_year = 2025),
    '上海市民办远东学校',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办远东学校' AND data_year = 2025),
    '上海市民办远东学校',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办远东学校' AND data_year = 2025),
    '上海市民办远东学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '102057' AND data_year = 2025),
    '102057',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办桃李园实验学校' AND data_year = 2025),
    '上海市民办桃李园实验学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '102057' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办桃李园实验学校' AND data_year = 2025),
    '上海市民办桃李园实验学校',
    11,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办桃李园实验学校' AND data_year = 2025),
    '上海市民办桃李园实验学校',
    12,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市民办桃李园实验学校' AND data_year = 2025),
    '上海市民办桃李园实验学校',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区华亭学校' AND data_year = 2025),
    '上海市嘉定区华亭学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区华亭学校' AND data_year = 2025),
    '上海市嘉定区华亭学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区华亭学校' AND data_year = 2025),
    '上海市嘉定区华亭学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区娄塘学校' AND data_year = 2025),
    '上海市嘉定区娄塘学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区娄塘学校' AND data_year = 2025),
    '上海市嘉定区娄塘学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区娄塘学校' AND data_year = 2025),
    '上海市嘉定区娄塘学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海外国语大学嘉定外国语学校' AND data_year = 2025),
    '上海外国语大学嘉定外国语学校',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海外国语大学嘉定外国语学校' AND data_year = 2025),
    '上海外国语大学嘉定外国语学校',
    10,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海外国语大学嘉定外国语学校' AND data_year = 2025),
    '上海外国语大学嘉定外国语学校',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '102057' AND data_year = 2025),
    '102057',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区练川实验学校' AND data_year = 2025),
    '上海市嘉定区练川实验学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '102057' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区练川实验学校' AND data_year = 2025),
    '上海市嘉定区练川实验学校',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区练川实验学校' AND data_year = 2025),
    '上海市嘉定区练川实验学校',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区练川实验学校' AND data_year = 2025),
    '上海市嘉定区练川实验学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '152006' AND data_year = 2025),
    '152006',
    (SELECT id FROM ref_middle_school WHERE name = '上海华旭双语学校' AND data_year = 2025),
    '上海华旭双语学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '152006' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海华旭双语学校' AND data_year = 2025),
    '上海华旭双语学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海华旭双语学校' AND data_year = 2025),
    '上海华旭双语学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海华旭双语学校' AND data_year = 2025),
    '上海华旭双语学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '中科院上海实验学校' AND data_year = 2025),
    '中科院上海实验学校',
    10,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '中科院上海实验学校' AND data_year = 2025),
    '中科院上海实验学校',
    13,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '中科院上海实验学校' AND data_year = 2025),
    '中科院上海实验学校',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海嘉定区世界外国语学校' AND data_year = 2025),
    '上海嘉定区世界外国语学校',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海嘉定区世界外国语学校' AND data_year = 2025),
    '上海嘉定区世界外国语学校',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海嘉定区世界外国语学校' AND data_year = 2025),
    '上海嘉定区世界外国语学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区金鹤学校' AND data_year = 2025),
    '上海市嘉定区金鹤学校',
    7,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区金鹤学校' AND data_year = 2025),
    '上海市嘉定区金鹤学校',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区金鹤学校' AND data_year = 2025),
    '上海市嘉定区金鹤学校',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海师范大学附属第五嘉定实验学校' AND data_year = 2025),
    '上海师范大学附属第五嘉定实验学校',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海师范大学附属第五嘉定实验学校' AND data_year = 2025),
    '上海师范大学附属第五嘉定实验学校',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海师范大学附属第五嘉定实验学校' AND data_year = 2025),
    '上海师范大学附属第五嘉定实验学校',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '同济大学附属嘉定实验中学' AND data_year = 2025),
    '同济大学附属嘉定实验中学',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '同济大学附属嘉定实验中学' AND data_year = 2025),
    '同济大学附属嘉定实验中学',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '同济大学附属嘉定实验中学' AND data_year = 2025),
    '同济大学附属嘉定实验中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '102056' AND data_year = 2025),
    '102056',
    (SELECT id FROM ref_middle_school WHERE name = '交大附中附属嘉定洪德中学' AND data_year = 2025),
    '交大附中附属嘉定洪德中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '102056' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '交大附中附属嘉定洪德中学' AND data_year = 2025),
    '交大附中附属嘉定洪德中学',
    4,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '交大附中附属嘉定洪德中学' AND data_year = 2025),
    '交大附中附属嘉定洪德中学',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '交大附中附属嘉定洪德中学' AND data_year = 2025),
    '交大附中附属嘉定洪德中学',
    1,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区嘉二实验学校' AND data_year = 2025),
    '上海市嘉定区嘉二实验学校',
    5,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区嘉二实验学校' AND data_year = 2025),
    '上海市嘉定区嘉二实验学校',
    6,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海市嘉定区嘉二实验学校' AND data_year = 2025),
    '上海市嘉定区嘉二实验学校',
    2,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142001' AND data_year = 2025),
    '142001',
    (SELECT id FROM ref_middle_school WHERE name = '上海嘉定区民办华盛怀少学校' AND data_year = 2025),
    '上海嘉定区民办华盛怀少学校',
    8,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142001' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142002' AND data_year = 2025),
    '142002',
    (SELECT id FROM ref_middle_school WHERE name = '上海嘉定区民办华盛怀少学校' AND data_year = 2025),
    '上海嘉定区民办华盛怀少学校',
    9,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142002' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '142004' AND data_year = 2025),
    '142004',
    (SELECT id FROM ref_middle_school WHERE name = '上海嘉定区民办华盛怀少学校' AND data_year = 2025),
    '上海嘉定区民办华盛怀少学校',
    3,
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '142004' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;

-- Verification query
SELECT d.name as district,
       COUNT(*) as total_records,
       SUM(q.quota_count) as total_quotas
FROM ref_quota_allocation_school q
JOIN ref_district d ON q.district_id = d.id
WHERE q.year = 2025 AND d.code = 'JD'
GROUP BY d.name;

-- Check Hongde Middle School data
SELECT q.year, s.full_name as high_school, q.middle_school_name, q.quota_count
FROM ref_quota_allocation_school q
JOIN ref_school s ON q.high_school_id = s.id
WHERE q.year = 2025 AND q.middle_school_name LIKE '%洪德%';