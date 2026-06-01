-- 徐汇区 (district_id=3) 2026年 名额分配到区
-- Source: 2026_quota_district_xuhui.pdf
-- Generated: 2026-06-01
-- 69 schools allocating TO 徐汇区

-- Set sequence to start after max existing ID (402)
SELECT setval('ref_quota_allocation_district_id_seq', 402);

BEGIN;

-- Existing 6 records need UPDATE (these are 徐汇区 local schools)
-- Their quota changed from total to the per-徐汇 portion
-- 042001 上海市第二中学: 52 -> 7
UPDATE ref_quota_allocation_district SET quota_count = 7, updated_at = CURRENT_TIMESTAMP
WHERE year = 2026 AND school_code = '042001' AND district_id = 3;

-- 042002 上海市第二中学（梅陇校区）: 53 -> 22
UPDATE ref_quota_allocation_district SET quota_count = 22, updated_at = CURRENT_TIMESTAMP
WHERE year = 2026 AND school_code = '042002' AND district_id = 3;

-- 042008 上海市南洋模范中学: 90 -> 9
UPDATE ref_quota_allocation_district SET quota_count = 9, updated_at = CURRENT_TIMESTAMP
WHERE year = 2026 AND school_code = '042008' AND district_id = 3;

-- 042035 上海市位育中学: 90 -> 9
UPDATE ref_quota_allocation_district SET quota_count = 9, updated_at = CURRENT_TIMESTAMP
WHERE year = 2026 AND school_code = '042035' AND district_id = 3;

-- 042036 复旦大学附属中学徐汇分校: 31 -> 3
UPDATE ref_quota_allocation_district SET quota_count = 3, updated_at = CURRENT_TIMESTAMP
WHERE year = 2026 AND school_code = '042036' AND district_id = 3;

-- 043015 上海市南洋中学: 82 -> 9
UPDATE ref_quota_allocation_district SET quota_count = 9, updated_at = CURRENT_TIMESTAMP
WHERE year = 2026 AND school_code = '043015' AND district_id = 3;

-- INSERT new records for non-徐汇 schools (id starts at 403)
-- Row 1: 042032 上海市上海中学 (上海市/徐汇) -> 93
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (403, 2026, 1, '042032', 3, 93, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 2: 102056 上海交通大学附属中学 (上海市) -> 22
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (404, 2026, 2, '102056', 3, 22, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 3: 102057 复旦大学附属中学 (上海市) -> 18
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (405, 2026, 3, '102057', 3, 18, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 4: 152003 华东师范大学第二附属中学 (上海市) -> 20
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (406, 2026, 4, '152003', 3, 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 5: 152006 上海师范大学附属中学 (上海市) -> 25
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (407, 2026, 5, '152006', 3, 25, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 6: 012001 上海市格致中学 (黄浦区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (408, 2026, 31, '012001', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 7: 012003 上海市大同中学 (黄浦区) -> 14
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (409, 2026, 32, '012003', 3, 14, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 8: 012005 上海市向明中学 (黄浦区) -> 8
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (410, 2026, 33, '012005', 3, 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 9: 012007 上海外国语大学附属大境中学 (黄浦区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (411, 2026, 34, '012007', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 10: 012008 上海市光明中学 (黄浦区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (412, 2026, 35, '012008', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 11: 012009 上海市敬业中学 (黄浦区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (413, 2026, 36, '012009', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 12: 012010 上海市卢湾高级中学 (黄浦区) -> 13
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (414, 2026, 37, '012010', 3, 13, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 13: 012011 同济大学科技中学 (黄浦区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (415, 2026, 347, '012011', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 20: 052001 上海市第三女子中学 (长宁区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (416, 2026, 66, '052001', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 21: 052002 上海市延安中学 (长宁区) -> 7
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (417, 2026, 67, '052002', 3, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 22: 053004 上海市复旦中学 (长宁区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (418, 2026, 68, '053004', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 23: 062001 上海市市西中学 (静安区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (419, 2026, 75, '062001', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 24: 062002 上海市育才中学 (静安区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (420, 2026, 76, '062002', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 25: 062003 上海市新中高级中学 (静安区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (421, 2026, 77, '062003', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 26: 062004 上海市市北中学 (静安区) -> 2
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (422, 2026, 78, '062004', 3, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 27: 062011 上海市回民中学 (静安区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (423, 2026, 79, '062011', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 28: 063004 上海市第六十中学 (静安区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (424, 2026, 80, '063004', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 29: 064001 上海市华东模范中学 (静安区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (425, 2026, 81, '064001', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 30: 072002 上海市曹杨第二中学 (普陀区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (426, 2026, 97, '072002', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 31: 073003 上海市宜川中学 (普陀区) -> 7
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (427, 2026, 98, '073003', 3, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 32: 073082 华东师范大学第二附属中学（普陀校区） (普陀区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (428, 2026, 99, '073082', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 33: 093001 上海财经大学附属北郊高级中学 (虹口区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (429, 2026, 112, '093001', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 34: 102004 上海市杨浦高级中学 (杨浦区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (430, 2026, 120, '102004', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 35: 102032 上海市控江中学 (杨浦区) -> 8
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (431, 2026, 121, '102032', 3, 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 36: 122001 上海市七宝中学 (闵行区) -> 16
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (432, 2026, 134, '122001', 3, 16, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 37: 123001 上海市闵行中学 (闵行区) -> 10
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (433, 2026, 135, '123001', 3, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 38: 122002 华东师范大学第二附属中学闵行紫竹分校 (闵行区) -> 15
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (434, 2026, 136, '122002', 3, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 39: 122003 上海师范大学附属中学闵行分校 (闵行区) -> 10
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (435, 2026, 137, '122003', 3, 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 40: 122004 上海交通大学附属中学闵行分校 (闵行区) -> 15
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (436, 2026, 138, '122004', 3, 15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 41: 132001 上海市行知中学 (宝山区) -> 1
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (437, 2026, 164, '132001', 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 42: 132002 上海大学附属中学 (宝山区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (438, 2026, 165, '132002', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 43: 133001 上海市吴淞中学 (宝山区) -> 1
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (439, 2026, 166, '133001', 3, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 44: 132003 上海师范大学附属中学宝山分校 (宝山区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (440, 2026, 167, '132003', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 45: 133003 华东师范大学第二附属中学（宝山校区） (宝山区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (441, 2026, 168, '133003', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 46: 142001 上海市嘉定区第一中学 (嘉定区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (442, 2026, 183, '142001', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 47: 142002 上海交通大学附属中学嘉定分校 (嘉定区) -> 7
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (443, 2026, 184, '142002', 3, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 48: 142004 上海师范大学附属中学嘉定新城分校 (嘉定区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (444, 2026, 185, '142004', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 49: 152001 上海市建平中学 (浦东新区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (445, 2026, 193, '152001', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 50: 152002 上海市进才中学 (浦东新区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (446, 2026, 194, '152002', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 51: 152004 上海南汇中学 (浦东新区) -> 7
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (447, 2026, 195, '152004', 3, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 52: 153001 上海市洋泾中学 (浦东新区) -> 7
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (448, 2026, 196, '153001', 3, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 53: 153004 上海市高桥中学 (浦东新区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (449, 2026, 197, '153004', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 54: 153005 上海市川沙中学 (浦东新区) -> 6
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (450, 2026, 198, '153005', 3, 6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 55: 151078 上海中学东校 (浦东新区) -> 13
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (451, 2026, 199, '151078', 3, 13, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 56: 152005 上海市浦东复旦附中分校 (浦东新区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (452, 2026, 200, '152005', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 57: 162000 上海市金山中学 (金山区) -> 7
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (453, 2026, 244, '162000', 3, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 58: 163002 华东师范大学第三附属中学 (金山区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (454, 2026, 245, '163002', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 59: 172001 上海市松江二中 (松江区) -> 7
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (455, 2026, 252, '172001', 3, 7, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 60: 173001 上海市松江一中 (松江区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (456, 2026, 253, '173001', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 61: 172002 华东师范大学第二附属中学松江分校 (松江区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (457, 2026, 254, '172002', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 62: 172004 上海师范大学附属中学松江分校 (松江区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (458, 2026, 255, '172004', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 63: 174003 上海外国语大学附属外国语学校松江云间中学 (松江区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (459, 2026, 256, '174003', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 64: 182001 上海市青浦高级中学 (青浦区) -> 5
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (460, 2026, 271, '182001', 3, 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 65: 183002 上海市朱家角中学 (青浦区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (461, 2026, 272, '183002', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 66: 182002 复旦大学附属中学青浦分校 (青浦区) -> 4
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (462, 2026, 273, '182002', 3, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 67: 202001 上海市奉贤中学 (奉贤区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (463, 2026, 281, '202001', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 68: 202002 华东师范大学第二附属中学临港奉贤分校 (奉贤区) -> 8
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (464, 2026, 282, '202002', 3, 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Row 69: 512000 上海市崇明中学 (崇明区) -> 3
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at)
VALUES (465, 2026, 289, '512000', 3, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Update sequence
SELECT setval('ref_quota_allocation_district_id_seq', 465);

COMMIT;
