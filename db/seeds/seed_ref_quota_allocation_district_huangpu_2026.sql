-- 黄浦区 到区 allocation 2026
-- Generated from doc_1ddfc85f52a7_2026.pdf
-- 60 schools allocating TO 黄浦区 (district_id=2)
-- 10 existing records UPDATED, 50 new records INSERTED

BEGIN;

-- UPDATE existing records for 黄浦区 local schools
UPDATE ref_quota_allocation_district SET quota_count = 3, updated_at = NOW() WHERE id = 220;  -- 012001 格致中学
UPDATE ref_quota_allocation_district SET quota_count = 20, updated_at = NOW() WHERE id = 227; -- 012002 格致奉贤
UPDATE ref_quota_allocation_district SET quota_count = 3, updated_at = NOW() WHERE id = 221;  -- 012003 大同中学
UPDATE ref_quota_allocation_district SET quota_count = 2, updated_at = NOW() WHERE id = 222;  -- 012005 向明中学
UPDATE ref_quota_allocation_district SET quota_count = 15, updated_at = NOW() WHERE id = 228; -- 012006 向明浦江
UPDATE ref_quota_allocation_district SET quota_count = 3, updated_at = NOW() WHERE id = 223;  -- 012007 大境中学
UPDATE ref_quota_allocation_district SET quota_count = 3, updated_at = NOW() WHERE id = 224;  -- 012008 光明中学
UPDATE ref_quota_allocation_district SET quota_count = 3, updated_at = NOW() WHERE id = 225;  -- 012009 敬业中学
UPDATE ref_quota_allocation_district SET quota_count = 3, updated_at = NOW() WHERE id = 226;  -- 012010 卢湾高级中学
UPDATE ref_quota_allocation_district SET quota_count = 5, updated_at = NOW() WHERE id = 229;  -- 012011 同济科技中学

-- INSERT new records (external schools allocating to 黄浦 + city-wide schools)
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (353, 2026, 1, '042032', 2, 8, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (354, 2026, 2, '102056', 2, 10, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (355, 2026, 3, '102057', 2, 10, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (356, 2026, 4, '152003', 2, 11, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (357, 2026, 48, '042001', 2, 6, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (358, 2026, 49, '042008', 2, 8, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (359, 2026, 50, '042035', 2, 3, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (360, 2026, 51, '043015', 2, 4, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (361, 2026, 66, '052001', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (362, 2026, 67, '052002', 2, 3, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (363, 2026, 68, '053004', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (364, 2026, 75, '062001', 2, 6, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (365, 2026, 76, '062002', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (366, 2026, 78, '062004', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (367, 2026, 79, '062011', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (368, 2026, 80, '063004', 2, 3, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (369, 2026, 81, '064001', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (370, 2026, 97, '072002', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (371, 2026, 98, '073003', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (372, 2026, 99, '073082', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (373, 2026, 111, '092002', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (374, 2026, 121, '102032', 2, 8, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (375, 2026, 134, '122001', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (376, 2026, 135, '123001', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (377, 2026, 136, '122002', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (378, 2026, 137, '122003', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (379, 2026, 164, '132001', 2, 4, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (380, 2026, 165, '132002', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (381, 2026, 167, '132003', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (382, 2026, 168, '133003', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (383, 2026, 183, '142001', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (384, 2026, 184, '142002', 2, 6, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (385, 2026, 193, '152001', 2, 11, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (386, 2026, 194, '152002', 2, 7, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (387, 2026, 195, '152004', 2, 6, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (388, 2026, 196, '153001', 2, 8, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (389, 2026, 197, '153004', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (390, 2026, 198, '153005', 2, 8, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (391, 2026, 200, '152005', 2, 12, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (392, 2026, 244, '162000', 2, 1, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (393, 2026, 245, '163002', 2, 3, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (394, 2026, 252, '172001', 2, 3, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (395, 2026, 253, '173001', 2, 5, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (396, 2026, 256, '174003', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (397, 2026, 271, '182001', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (398, 2026, 272, '183002', 2, 3, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (399, 2026, 273, '182002', 2, 3, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (400, 2026, 281, '202001', 2, 2, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (401, 2026, 282, '202002', 2, 6, NOW(), NOW());
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (402, 2026, 289, '512000', 2, 2, NOW(), NOW());

COMMIT;
