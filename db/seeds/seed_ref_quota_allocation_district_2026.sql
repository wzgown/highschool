-- ============================================================
-- 2026年名额分配到区招生计划
-- 生成时间: 2026-06-01 10:03:10.752687
-- 数据来源: original_data/raw/2026/pdfs/2026_quota_district.pdf
-- 总学校数: 77
-- 可导入: 73 条 (区属/全市型学校)
-- 待补充: 4 所学校 × 16区 = 64 条 (全市分配型学校)
-- 注意: 4所全市分配型学校(上海中学、交大附中、复旦附中、华二)
--       的按区分配数据尚未公布，需要从各区教育局获取详细分配数字
-- ============================================================

-- 先确保新学校 012011 同济大学科技中学 已在 ref_school 中
-- INSERT INTO ref_school (id, code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, remarks, is_active)
-- VALUES (347, '012011', '同济大学科技中学', '同济科技', 2, 'PUBLIC', 'CITY_POLICY', 'PARTIAL', false, '参照探索建立拔尖创新人才培养基地项目高中', true);

-- 即时可导入的 73 条记录
-- ID范围: 218 ~ 290
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (218, 2026, 5, '152006', 1, 208, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (219, 2026, 6, '155001', 1, 52, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (220, 2026, 31, '012001', 2, 126, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (221, 2026, 32, '012003', 2, 136, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (222, 2026, 33, '012005', 2, 59, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (223, 2026, 34, '012007', 2, 96, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (224, 2026, 35, '012008', 2, 86, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (225, 2026, 36, '012009', 2, 76, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (226, 2026, 37, '012010', 2, 96, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (227, 2026, 38, '012002', 2, 40, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (228, 2026, 39, '012006', 2, 38, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (229, 2026, 347, '012011', 2, 47, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (230, 2026, 48, '042001', 3, 52, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (231, 2026, 49, '042008', 3, 90, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (232, 2026, 50, '042035', 3, 90, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (233, 2026, 51, '043015', 3, 82, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (234, 2026, 52, '042002', 3, 53, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (235, 2026, 53, '042036', 3, 31, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (236, 2026, 66, '052001', 4, 78, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (237, 2026, 67, '052002', 4, 72, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (238, 2026, 68, '053004', 4, 53, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (239, 2026, 75, '062001', 5, 74, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (240, 2026, 76, '062002', 5, 74, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (241, 2026, 77, '062003', 5, 74, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (242, 2026, 78, '062004', 5, 82, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (243, 2026, 79, '062011', 5, 59, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (244, 2026, 80, '063004', 5, 56, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (245, 2026, 81, '064001', 5, 44, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (246, 2026, 96, '072001', 6, 84, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (247, 2026, 97, '072002', 6, 82, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (248, 2026, 98, '073003', 6, 89, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (249, 2026, 99, '073082', 6, 53, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (250, 2026, 110, '092001', 7, 77, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (251, 2026, 111, '092002', 7, 71, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (252, 2026, 112, '093001', 7, 56, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (253, 2026, 120, '102004', 8, 103, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (254, 2026, 121, '102032', 8, 103, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (255, 2026, 122, '103002', 8, 86, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (256, 2026, 134, '122001', 9, 120, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (257, 2026, 135, '123001', 9, 120, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (258, 2026, 136, '122002', 9, 82, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (259, 2026, 137, '122003', 9, 86, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (260, 2026, 138, '122004', 9, 70, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (261, 2026, 164, '132001', 10, 115, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (262, 2026, 165, '132002', 10, 119, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (263, 2026, 166, '133001', 10, 100, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (264, 2026, 167, '132003', 10, 51, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (265, 2026, 168, '133003', 10, 67, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (266, 2026, 183, '142001', 11, 89, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (267, 2026, 184, '142002', 11, 107, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (268, 2026, 185, '142004', 11, 58, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (269, 2026, 193, '152001', 12, 109, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (270, 2026, 194, '152002', 12, 109, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (271, 2026, 195, '152004', 12, 140, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (272, 2026, 196, '153001', 12, 109, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (273, 2026, 197, '153004', 12, 94, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (274, 2026, 198, '153005', 12, 94, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (275, 2026, 199, '151078', 12, 94, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (276, 2026, 200, '152005', 12, 70, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (277, 2026, 244, '162000', 13, 74, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (278, 2026, 245, '163002', 13, 78, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (279, 2026, 252, '172001', 14, 84, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (280, 2026, 253, '173001', 14, 84, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (281, 2026, 254, '172002', 14, 50, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (282, 2026, 255, '172004', 14, 31, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (283, 2026, 256, '174003', 14, 84, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (284, 2026, 271, '182001', 15, 135, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (285, 2026, 272, '183002', 15, 129, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (286, 2026, 273, '182002', 15, 62, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (287, 2026, 281, '202001', 16, 94, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (288, 2026, 282, '202002', 16, 64, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (289, 2026, 289, '512000', 17, 62, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');
INSERT INTO ref_quota_allocation_district (id, year, school_id, school_code, district_id, quota_count, created_at, updated_at) VALUES (290, 2026, 290, '512001', 17, 31, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687');

-- ============================================================
-- 待补充: 4 所全市分配型学校的按区分配数据
-- 总名额: 1178
-- 每所学校需分配到 district_id 2~17 (黄浦~崇明, 共16区)
-- ============================================================
-- 042032 上海市上海中学: 总计划数 291
--   TODO: INSERT ... VALUES (291, 2026, 1, '042032', 2, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HP
--   TODO: INSERT ... VALUES (292, 2026, 1, '042032', 3, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- XH
--   TODO: INSERT ... VALUES (293, 2026, 1, '042032', 4, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CN
--   TODO: INSERT ... VALUES (294, 2026, 1, '042032', 5, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JA
--   TODO: INSERT ... VALUES (295, 2026, 1, '042032', 6, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PT
--   TODO: INSERT ... VALUES (296, 2026, 1, '042032', 7, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HK
--   TODO: INSERT ... VALUES (297, 2026, 1, '042032', 8, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- YP
--   TODO: INSERT ... VALUES (298, 2026, 1, '042032', 9, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- MH
--   TODO: INSERT ... VALUES (299, 2026, 1, '042032', 10, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- BS
--   TODO: INSERT ... VALUES (300, 2026, 1, '042032', 11, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JD
--   TODO: INSERT ... VALUES (301, 2026, 1, '042032', 12, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PD
--   TODO: INSERT ... VALUES (302, 2026, 1, '042032', 13, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JS
--   TODO: INSERT ... VALUES (303, 2026, 1, '042032', 14, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- SJ
--   TODO: INSERT ... VALUES (304, 2026, 1, '042032', 15, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- QP
--   TODO: INSERT ... VALUES (305, 2026, 1, '042032', 16, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- FX
--   TODO: INSERT ... VALUES (306, 2026, 1, '042032', 17, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CM

-- 102056 上海交通大学附属中学: 总计划数 336
--   TODO: INSERT ... VALUES (307, 2026, 2, '102056', 2, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HP
--   TODO: INSERT ... VALUES (308, 2026, 2, '102056', 3, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- XH
--   TODO: INSERT ... VALUES (309, 2026, 2, '102056', 4, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CN
--   TODO: INSERT ... VALUES (310, 2026, 2, '102056', 5, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JA
--   TODO: INSERT ... VALUES (311, 2026, 2, '102056', 6, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PT
--   TODO: INSERT ... VALUES (312, 2026, 2, '102056', 7, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HK
--   TODO: INSERT ... VALUES (313, 2026, 2, '102056', 8, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- YP
--   TODO: INSERT ... VALUES (314, 2026, 2, '102056', 9, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- MH
--   TODO: INSERT ... VALUES (315, 2026, 2, '102056', 10, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- BS
--   TODO: INSERT ... VALUES (316, 2026, 2, '102056', 11, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JD
--   TODO: INSERT ... VALUES (317, 2026, 2, '102056', 12, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PD
--   TODO: INSERT ... VALUES (318, 2026, 2, '102056', 13, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JS
--   TODO: INSERT ... VALUES (319, 2026, 2, '102056', 14, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- SJ
--   TODO: INSERT ... VALUES (320, 2026, 2, '102056', 15, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- QP
--   TODO: INSERT ... VALUES (321, 2026, 2, '102056', 16, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- FX
--   TODO: INSERT ... VALUES (322, 2026, 2, '102056', 17, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CM

-- 102057 复旦大学附属中学: 总计划数 271
--   TODO: INSERT ... VALUES (323, 2026, 3, '102057', 2, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HP
--   TODO: INSERT ... VALUES (324, 2026, 3, '102057', 3, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- XH
--   TODO: INSERT ... VALUES (325, 2026, 3, '102057', 4, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CN
--   TODO: INSERT ... VALUES (326, 2026, 3, '102057', 5, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JA
--   TODO: INSERT ... VALUES (327, 2026, 3, '102057', 6, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PT
--   TODO: INSERT ... VALUES (328, 2026, 3, '102057', 7, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HK
--   TODO: INSERT ... VALUES (329, 2026, 3, '102057', 8, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- YP
--   TODO: INSERT ... VALUES (330, 2026, 3, '102057', 9, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- MH
--   TODO: INSERT ... VALUES (331, 2026, 3, '102057', 10, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- BS
--   TODO: INSERT ... VALUES (332, 2026, 3, '102057', 11, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JD
--   TODO: INSERT ... VALUES (333, 2026, 3, '102057', 12, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PD
--   TODO: INSERT ... VALUES (334, 2026, 3, '102057', 13, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JS
--   TODO: INSERT ... VALUES (335, 2026, 3, '102057', 14, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- SJ
--   TODO: INSERT ... VALUES (336, 2026, 3, '102057', 15, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- QP
--   TODO: INSERT ... VALUES (337, 2026, 3, '102057', 16, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- FX
--   TODO: INSERT ... VALUES (338, 2026, 3, '102057', 17, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CM

-- 152003 华东师范大学第二附属中学: 总计划数 280
--   TODO: INSERT ... VALUES (339, 2026, 4, '152003', 2, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HP
--   TODO: INSERT ... VALUES (340, 2026, 4, '152003', 3, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- XH
--   TODO: INSERT ... VALUES (341, 2026, 4, '152003', 4, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CN
--   TODO: INSERT ... VALUES (342, 2026, 4, '152003', 5, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JA
--   TODO: INSERT ... VALUES (343, 2026, 4, '152003', 6, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PT
--   TODO: INSERT ... VALUES (344, 2026, 4, '152003', 7, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- HK
--   TODO: INSERT ... VALUES (345, 2026, 4, '152003', 8, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- YP
--   TODO: INSERT ... VALUES (346, 2026, 4, '152003', 9, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- MH
--   TODO: INSERT ... VALUES (347, 2026, 4, '152003', 10, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- BS
--   TODO: INSERT ... VALUES (348, 2026, 4, '152003', 11, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JD
--   TODO: INSERT ... VALUES (349, 2026, 4, '152003', 12, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- PD
--   TODO: INSERT ... VALUES (350, 2026, 4, '152003', 13, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- JS
--   TODO: INSERT ... VALUES (351, 2026, 4, '152003', 14, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- SJ
--   TODO: INSERT ... VALUES (352, 2026, 4, '152003', 15, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- QP
--   TODO: INSERT ... VALUES (353, 2026, 4, '152003', 16, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- FX
--   TODO: INSERT ... VALUES (354, 2026, 4, '152003', 17, ??, '2026-06-01 10:03:10.752687', '2026-06-01 10:03:10.752687'); -- CM
