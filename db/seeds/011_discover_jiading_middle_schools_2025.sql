-- =============================================================================
-- 嘉定区名额分配到校 - 初中学校发现
-- 生成时间: 2026-02-13 10:21:26

-- 新发现的初中学校
-- 新学校: 上海市嘉定区南翔中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区南翔中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区震川中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区震川中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区外冈中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区外冈中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区华江中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区华江中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区丰庄中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区丰庄中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区马陆育才联合中学 152003
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区马陆育才联合中学 152003', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区黄渡中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区黄渡中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区南苑中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区南苑中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区徐行中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区徐行中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区新城实验中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区新城实验中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区启良中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区启良中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区迎园中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区迎园中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';

-- 新学校: 上海市嘉定区方泰中学
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)
SELECT 'JD0013', '上海市嘉定区方泰中学', d.id, 'MIDDLE', TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM ref_district d WHERE d.code = 'JD';


-- 验证特别关注的学校

-- 交大附中附属嘉定洪德中学/德富中学
SELECT id, code, name FROM ref_middle_school
WHERE name LIKE '%交大附中附属嘉定%' AND district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND data_year = 2025;

-- 上海师范大学附属中学嘉定新城分校
SELECT id, code, name FROM ref_middle_school
WHERE name LIKE '%上海师范大学附属中学嘉定新城%' AND district_id = (SELECT id FROM ref_district WHERE code = 'JD')
  AND data_year = 2025;
