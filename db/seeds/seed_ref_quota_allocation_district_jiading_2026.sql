-- ============================================================
-- Seed: ref_quota_allocation_district - 嘉定区 2026 名额分配到区
-- Source: 2026_quota_district_jiading.pdf
-- Generated: 65 schools, total quota = 378
-- Updates: 3 existing records
-- Inserts: 62 new records (ids 291-352)
-- ============================================================

BEGIN;

-- UPDATE existing records (嘉定区 schools with corrected quota from district PDF)
UPDATE ref_quota_allocation_district SET quota_count = 14, updated_at = NOW() WHERE id = 266;  -- 142001 上海市嘉定区第一中学 (89 -> 14)
UPDATE ref_quota_allocation_district SET quota_count = 10, updated_at = NOW() WHERE id = 267;  -- 142002 上海交通大学附属中学嘉定分校 (107 -> 10)
UPDATE ref_quota_allocation_district SET quota_count = 6, updated_at = NOW() WHERE id = 268;  -- 142004 上海师范大学附属中学嘉定新城分校 (58 -> 6)

-- INSERT new records for 嘉定区 (district_id=11) - 62 rows
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (291, 2026, 1, '042032', 11, 11, NOW(), NOW());  -- 上海市上海中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (292, 2026, 2, '102056', 11, 14, NOW(), NOW());  -- 上海交通大学附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (293, 2026, 3, '102057', 11, 10, NOW(), NOW());  -- 复旦大学附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (294, 2026, 4, '152003', 11, 10, NOW(), NOW());  -- 华东师范大学第二附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (295, 2026, 5, '152006', 11, 1, NOW(), NOW());  -- 上海师范大学附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (296, 2026, 31, '012001', 11, 5, NOW(), NOW());  -- 上海市格致中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (297, 2026, 32, '012003', 11, 3, NOW(), NOW());  -- 上海市大同中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (298, 2026, 34, '012007', 11, 2, NOW(), NOW());  -- 上海外国语大学附属大境中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (299, 2026, 35, '012008', 11, 2, NOW(), NOW());  -- 上海市光明中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (300, 2026, 37, '012010', 11, 10, NOW(), NOW());  -- 上海市卢湾高级中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (301, 2026, 347, '012011', 11, 4, NOW(), NOW());  -- 同济大学科技中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (302, 2026, 48, '042001', 11, 3, NOW(), NOW());  -- 上海市第二中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (303, 2026, 49, '042008', 11, 3, NOW(), NOW());  -- 上海市南洋模范中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (304, 2026, 50, '042035', 11, 1, NOW(), NOW());  -- 上海市位育中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (305, 2026, 51, '043015', 11, 2, NOW(), NOW());  -- 上海市南洋中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (306, 2026, 66, '052001', 11, 6, NOW(), NOW());  -- 上海市第三女子中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (307, 2026, 67, '052002', 11, 5, NOW(), NOW());  -- 上海市延安中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (308, 2026, 68, '053004', 11, 4, NOW(), NOW());  -- 上海市复旦中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (309, 2026, 76, '062002', 11, 9, NOW(), NOW());  -- 上海市育才中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (310, 2026, 77, '062003', 11, 3, NOW(), NOW());  -- 上海市新中高级中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (311, 2026, 78, '062004', 11, 2, NOW(), NOW());  -- 上海市市北中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (312, 2026, 79, '062011', 11, 4, NOW(), NOW());  -- 上海市回民中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (313, 2026, 81, '064001', 11, 6, NOW(), NOW());  -- 上海市华东模范中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (314, 2026, 96, '072001', 11, 16, NOW(), NOW());  -- 上海市晋元高级中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (315, 2026, 97, '072002', 11, 9, NOW(), NOW());  -- 上海市曹杨第二中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (316, 2026, 98, '073003', 11, 10, NOW(), NOW());  -- 上海市宜川中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (317, 2026, 99, '073082', 11, 10, NOW(), NOW());  -- 华东师范大学第二附属中学（普陀校区）
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (318, 2026, 110, '092001', 11, 5, NOW(), NOW());  -- 复旦大学附属复兴中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (319, 2026, 111, '092002', 11, 3, NOW(), NOW());  -- 华东师范大学第一附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (320, 2026, 112, '093001', 11, 2, NOW(), NOW());  -- 上海财经大学附属北郊高级中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (321, 2026, 120, '102004', 11, 3, NOW(), NOW());  -- 上海市杨浦高级中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (322, 2026, 121, '102032', 11, 5, NOW(), NOW());  -- 上海市控江中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (323, 2026, 122, '103002', 11, 1, NOW(), NOW());  -- 同济大学第一附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (324, 2026, 134, '122001', 11, 5, NOW(), NOW());  -- 上海市七宝中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (325, 2026, 135, '123001', 11, 10, NOW(), NOW());  -- 上海市闵行中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (326, 2026, 136, '122002', 11, 4, NOW(), NOW());  -- 华东师范大学第二附属中学闵行紫竹分校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (327, 2026, 137, '122003', 11, 2, NOW(), NOW());  -- 上海师范大学附属中学闵行分校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (328, 2026, 164, '132001', 11, 8, NOW(), NOW());  -- 上海市行知中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (329, 2026, 165, '132002', 11, 12, NOW(), NOW());  -- 上海大学附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (330, 2026, 166, '133001', 11, 9, NOW(), NOW());  -- 上海市吴淞中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (331, 2026, 167, '132003', 11, 6, NOW(), NOW());  -- 上海师范大学附属中学宝山分校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (332, 2026, 168, '133003', 11, 6, NOW(), NOW());  -- 华东师范大学第二附属中学（宝山校区）
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (333, 2026, 193, '152001', 11, 3, NOW(), NOW());  -- 上海市建平中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (334, 2026, 194, '152002', 11, 7, NOW(), NOW());  -- 上海市进才中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (335, 2026, 195, '152004', 11, 14, NOW(), NOW());  -- 上海南汇中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (336, 2026, 196, '153001', 11, 5, NOW(), NOW());  -- 上海市洋泾中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (337, 2026, 197, '153004', 11, 5, NOW(), NOW());  -- 上海市高桥中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (338, 2026, 198, '153005', 11, 6, NOW(), NOW());  -- 上海市川沙中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (339, 2026, 199, '151078', 11, 2, NOW(), NOW());  -- 上海中学东校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (340, 2026, 200, '152005', 11, 4, NOW(), NOW());  -- 上海市浦东复旦附中分校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (341, 2026, 244, '162000', 11, 2, NOW(), NOW());  -- 上海市金山中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (342, 2026, 245, '163002', 11, 3, NOW(), NOW());  -- 华东师范大学第三附属中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (343, 2026, 252, '172001', 11, 1, NOW(), NOW());  -- 上海市松江二中
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (344, 2026, 253, '173001', 11, 4, NOW(), NOW());  -- 上海市松江一中
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (345, 2026, 254, '172002', 11, 2, NOW(), NOW());  -- 华东师范大学第二附属中学松江分校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (346, 2026, 255, '172004', 11, 3, NOW(), NOW());  -- 上海师范大学附属中学松江分校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (347, 2026, 256, '174003', 11, 5, NOW(), NOW());  -- 上海外国语大学附属外国语学校松江云间中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (348, 2026, 271, '182001', 11, 14, NOW(), NOW());  -- 上海市青浦高级中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (349, 2026, 272, '183002', 11, 10, NOW(), NOW());  -- 上海市朱家角中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (350, 2026, 273, '182002', 11, 6, NOW(), NOW());  -- 复旦大学附属中学青浦分校
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (351, 2026, 281, '202001', 11, 3, NOW(), NOW());  -- 上海市奉贤中学
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (352, 2026, 289, '512000', 11, 3, NOW(), NOW());  -- 上海市崇明中学

-- Verification queries
-- SELECT COUNT(*) FROM ref_quota_allocation_district WHERE year = 2026 AND district_id = 11;  -- Expected: 65
-- SELECT SUM(quota_count) FROM ref_quota_allocation_district WHERE year = 2026 AND district_id = 11;  -- Expected: 378

COMMIT;