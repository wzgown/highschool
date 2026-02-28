-- 2025年崇明区名额分配到校数据导入
-- 数据来源: 2025_quota_to_school_chongming.md

-- 更新/插入初中学校信息
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511002', '上海市崇明区三星中学', 17, TRUE, 16)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511007', '上海市崇明区建设中学', 17, TRUE, 32)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511014', '上海市崇明区合兴中学', 17, TRUE, 49)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511015', '上海市崇明区向化中学', 17, TRUE, 49)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511016', '上海市崇明区崇东中学', 17, TRUE, 65)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511017', '上海市崇明区裕安中学', 17, TRUE, 296)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511018', '上海市崇明区实验中学', 17, TRUE, 428)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511021', '上海市崇明区凌云中学', 17, TRUE, 49)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511022', '上海市崇明区长兴中学', 17, TRUE, 131)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511024', '上海市崇明区长明中学', 17, TRUE, 98)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('511025', '上海师范大学附属崇明正大中学', 17, TRUE, 412)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('514000', '上海市崇明区庙镇学校', 17, TRUE, 65)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('514002', '上海市崇明区大新中学', 17, TRUE, 65)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('514005', '上海市崇明区大公中学', 17, TRUE, 131)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('514010', '上海民办民一中学', 17, TRUE, 247)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('514013', '上海市崇明区横沙中学', 17, TRUE, 82)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('514014', '上海新纪元双语学校', 17, TRUE, 65)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('514015', '上海市崇明区长江学校', 17, TRUE, 16)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('515003', '上海市崇明区新海学校', 17, TRUE, 32)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;
INSERT INTO ref_middle_school (code, name, district_id, is_active, estimated_student_count)
VALUES ('515007', '上海市实验学校附属东滩学校', 17, TRUE, 247)
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    district_id = EXCLUDED.district_id,
    is_active = TRUE,
    estimated_student_count = EXCLUDED.estimated_student_count;

-- 插入名额分配到校记录
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511002' LIMIT 1),
    '上海市崇明区三星中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511007' LIMIT 1),
    '上海市崇明区建设中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '102056' LIMIT 1),
    '102056',
    (SELECT id FROM ref_middle_school WHERE code = '511007' LIMIT 1),
    '上海市崇明区建设中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102056')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511014' LIMIT 1),
    '上海市崇明区合兴中学',
    3,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511015' LIMIT 1),
    '上海市崇明区向化中学',
    2,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511015' LIMIT 1),
    '上海市崇明区向化中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511016' LIMIT 1),
    '上海市崇明区崇东中学',
    2,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511016' LIMIT 1),
    '上海市崇明区崇东中学',
    2,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511017' LIMIT 1),
    '上海市崇明区裕安中学',
    11,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511017' LIMIT 1),
    '上海市崇明区裕安中学',
    7,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511018' LIMIT 1),
    '上海市崇明区实验中学',
    20,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511018' LIMIT 1),
    '上海市崇明区实验中学',
    6,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511021' LIMIT 1),
    '上海市崇明区凌云中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511021' LIMIT 1),
    '上海市崇明区凌云中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '102056' LIMIT 1),
    '102056',
    (SELECT id FROM ref_middle_school WHERE code = '511021' LIMIT 1),
    '上海市崇明区凌云中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '102056')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511022' LIMIT 1),
    '上海市崇明区长兴中学',
    8,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511024' LIMIT 1),
    '上海市崇明区长明中学',
    4,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511024' LIMIT 1),
    '上海市崇明区长明中学',
    2,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '511025' LIMIT 1),
    '上海师范大学附属崇明正大中学',
    16,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '511025' LIMIT 1),
    '上海师范大学附属崇明正大中学',
    9,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '514000' LIMIT 1),
    '上海市崇明区庙镇学校',
    3,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '514000' LIMIT 1),
    '上海市崇明区庙镇学校',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '514002' LIMIT 1),
    '上海市崇明区大新中学',
    3,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '514002' LIMIT 1),
    '上海市崇明区大新中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '514005' LIMIT 1),
    '上海市崇明区大公中学',
    4,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '514005' LIMIT 1),
    '上海市崇明区大公中学',
    3,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '152003' LIMIT 1),
    '152003',
    (SELECT id FROM ref_middle_school WHERE code = '514005' LIMIT 1),
    '上海市崇明区大公中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '152003')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '514010' LIMIT 1),
    '上海民办民一中学',
    11,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '514010' LIMIT 1),
    '上海民办民一中学',
    4,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '514013' LIMIT 1),
    '上海市崇明区横沙中学',
    4,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '514013' LIMIT 1),
    '上海市崇明区横沙中学',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '514014' LIMIT 1),
    '上海新纪元双语学校',
    3,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '514014' LIMIT 1),
    '上海新纪元双语学校',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '514015' LIMIT 1),
    '上海市崇明区长江学校',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '515003' LIMIT 1),
    '上海市崇明区新海学校',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '515003' LIMIT 1),
    '上海市崇明区新海学校',
    1,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512000' LIMIT 1),
    '512000',
    (SELECT id FROM ref_middle_school WHERE code = '515007' LIMIT 1),
    '上海市实验学校附属东滩学校',
    3,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512000')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;
INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count)
SELECT
    
    17,
    (SELECT id FROM ref_school WHERE code = '512001' LIMIT 1),
    '512001',
    (SELECT id FROM ref_middle_school WHERE code = '515007' LIMIT 1),
    '上海市实验学校附属东滩学校',
    12,
    2025
WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '512001')
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count;