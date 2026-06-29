-- ============================================================================
-- 导入 2026 自主招生与国际课程结构化数据
-- 日期: 2026-06-28
-- 来源:
--   original_data/raw/2026/pdfs/2026_autonomous_plan.pdf
--   original_data/raw/2026/pdfs/2026_autonomous_admission_plan.pdf
--   original_data/raw/2026/pdfs/2026_international_course_plan.pdf
--   original_data/raw/2026/pdfs/2026_private_international_admission.pdf
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS ref_autonomous_admission_plan (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  display_order INTEGER NOT NULL,
  school_id INTEGER NOT NULL REFERENCES ref_school(id),
  school_code VARCHAR(20) NOT NULL,
  school_name VARCHAR(200) NOT NULL,
  district_id INTEGER REFERENCES ref_district(id),
  district_name VARCHAR(50),
  school_nature_name VARCHAR(50),
  school_type_name VARCHAR(200),
  boarding_type_name VARCHAR(50),
  total_count INTEGER NOT NULL,
  sports_count INTEGER NOT NULL DEFAULT 0,
  arts_count INTEGER NOT NULL DEFAULT 0,
  data_source VARCHAR(200) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(year, school_code)
);

CREATE INDEX IF NOT EXISTS idx_autonomous_admission_plan_year ON ref_autonomous_admission_plan(year);
CREATE INDEX IF NOT EXISTS idx_autonomous_admission_plan_school ON ref_autonomous_admission_plan(school_id);
CREATE INDEX IF NOT EXISTS idx_autonomous_admission_plan_district ON ref_autonomous_admission_plan(district_id);

CREATE TABLE IF NOT EXISTS ref_autonomous_admission_scheme (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  display_order INTEGER NOT NULL,
  school_id INTEGER NOT NULL REFERENCES ref_school(id),
  school_code VARCHAR(20) NOT NULL,
  school_name VARCHAR(200) NOT NULL,
  district_id INTEGER REFERENCES ref_district(id),
  district_name VARCHAR(50),
  school_nature_name VARCHAR(50),
  has_international_course_note BOOLEAN NOT NULL DEFAULT FALSE,
  remarks VARCHAR(200),
  scheme_label VARCHAR(100),
  data_source VARCHAR(200) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(year, school_code)
);

CREATE INDEX IF NOT EXISTS idx_autonomous_admission_scheme_year ON ref_autonomous_admission_scheme(year);
CREATE INDEX IF NOT EXISTS idx_autonomous_admission_scheme_school ON ref_autonomous_admission_scheme(school_id);
CREATE INDEX IF NOT EXISTS idx_autonomous_admission_scheme_district ON ref_autonomous_admission_scheme(district_id);

CREATE TABLE IF NOT EXISTS ref_international_course_plan (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  display_order INTEGER NOT NULL,
  school_id INTEGER NOT NULL REFERENCES ref_school(id),
  school_code VARCHAR(20) NOT NULL,
  school_name VARCHAR(200) NOT NULL,
  district_id INTEGER REFERENCES ref_district(id),
  school_nature_name VARCHAR(50),
  total_count INTEGER NOT NULL,
  local_student_count INTEGER NOT NULL,
  nonlocal_student_count INTEGER NOT NULL,
  data_source VARCHAR(200) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(year, school_code)
);

CREATE INDEX IF NOT EXISTS idx_international_course_plan_year ON ref_international_course_plan(year);
CREATE INDEX IF NOT EXISTS idx_international_course_plan_school ON ref_international_course_plan(school_id);
CREATE INDEX IF NOT EXISTS idx_international_course_plan_district ON ref_international_course_plan(district_id);

CREATE TABLE IF NOT EXISTS ref_private_international_admission_scheme (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  display_order INTEGER NOT NULL,
  school_id INTEGER NOT NULL REFERENCES ref_school(id),
  school_code VARCHAR(20) NOT NULL,
  school_name VARCHAR(200) NOT NULL,
  district_id INTEGER REFERENCES ref_district(id),
  district_name VARCHAR(50),
  school_nature_name VARCHAR(50),
  scheme_label VARCHAR(100),
  data_source VARCHAR(200) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(year, school_code)
);

CREATE INDEX IF NOT EXISTS idx_private_international_admission_scheme_year ON ref_private_international_admission_scheme(year);
CREATE INDEX IF NOT EXISTS idx_private_international_admission_scheme_school ON ref_private_international_admission_scheme(school_id);
CREATE INDEX IF NOT EXISTS idx_private_international_admission_scheme_district ON ref_private_international_admission_scheme(district_id);

CREATE TABLE IF NOT EXISTS backup_import_2026_international_ref_school AS
SELECT *
FROM ref_school
WHERE has_international_course
   OR code IN ('012001', '012003', '012010', '041363', '044162', '062001', '072002', '102056', '102057', '124108', '124111', '125113', '128100', '152001', '152003', '155004', '155008', '155043', '164006', '175018', '175021');

WITH src(display_order, school_code, school_name, district_name, school_nature_name, school_type_name, boarding_type_name, total_count, sports_count, arts_count) AS (
VALUES
  (1, '042032', '上海市上海中学', '上海市', '公办', '市实验性示范性高中', '全部寄宿', 168, 0, 0),
  (2, '102056', '上海交通大学附属中学', '上海市', '公办', '市实验性示范性高中', '部分寄宿', 204, 5, 5),
  (3, '102057', '复旦大学附属中学', '上海市', '公办', '市实验性示范性高中', '部分寄宿', 169, 4, 8),
  (4, '152003', '华东师范大学第二附属中学', '上海市', '公办', '市实验性示范性高中', '部分寄宿', 163, 3, 2),
  (5, '152006', '上海师范大学附属中学', '上海市', '公办', '市实验性示范性高中', '部分寄宿', 94, 6, 8),
  (6, '155001', '上海市实验学校', '上海市', '公办', '市实验性示范性高中', '部分寄宿', 27, 1, 1),
  (7, '012001', '上海市格致中学', '黄浦区', '公办', '市实验性示范性高中', '部分寄宿', 40, 4, 7),
  (8, '012003', '上海市大同中学', '黄浦区', '公办', '市实验性示范性高中', '部分寄宿', 45, 9, 7),
  (9, '012005', '上海市向明中学', '黄浦区', '公办', '市实验性示范性高中', '无寄宿', 29, 3, 3),
  (10, '012007', '上海外国语大学附属大境中学', '黄浦区', '公办', '市实验性示范性高中', '部分寄宿', 36, 5, 2),
  (11, '012008', '上海市光明中学', '黄浦区', '公办', '市实验性示范性高中', '无寄宿', 40, 7, 4),
  (12, '012009', '上海市敬业中学', '黄浦区', '公办', '市实验性示范性高中', '无寄宿', 36, 5, 2),
  (13, '012010', '上海市卢湾高级中学', '黄浦区', '公办', '市实验性示范性高中', '部分寄宿', 37, 2, 6),
  (14, '012002', '上海市格致中学（奉贤校区）', '黄浦区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 25, 2, 2),
  (15, '012006', '上海市向明中学（浦江校区）', '黄浦区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 20, 0, 0),
  (16, '012011', '同济大学科技中学', '黄浦区', '公办', '参照“探索建立拔尖创新人才培养基地”项目高中招生政策高中', '部分寄宿', 27, 0, 0),
  (17, '042001', '上海市第二中学', '徐汇区', '公办', '市实验性示范性高中', '无寄宿', 30, 0, 3),
  (18, '042008', '上海市南洋模范中学', '徐汇区', '公办', '市实验性示范性高中', '部分寄宿', 61, 5, 10),
  (19, '042035', '上海市位育中学', '徐汇区', '公办', '市实验性示范性高中', '全部寄宿', 53, 5, 2),
  (20, '043015', '上海市南洋中学', '徐汇区', '公办', '市实验性示范性高中', '部分寄宿', 52, 8, 2),
  (21, '042002', '上海市第二中学（梅陇校区）', '徐汇区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 32, 5, 0),
  (22, '042036', '复旦大学附属中学徐汇分校', '徐汇区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 16, 0, 0),
  (23, '044109', '上海市徐汇中学', '徐汇区', '公办', '区实验性示范性高中（市特色普通高中）', '无寄宿', 66, 2, 8),
  (24, '044223', '上海市紫竹园中学', '徐汇区', '公办', '市特色普通高中', '无寄宿', 30, 0, 0),
  (25, '052001', '上海市第三女子中学', '长宁区', '公办', '市实验性示范性高中', '部分寄宿', 48, 10, 12),
  (26, '052002', '上海市延安中学', '长宁区', '公办', '市实验性示范性高中', '全部寄宿', 56, 9, 10),
  (27, '053004', '上海市复旦中学', '长宁区', '公办', '市实验性示范性高中', '全部寄宿', 43, 10, 6),
  (28, '054013', '华东政法大学附属中学', '长宁区', '公办', '区实验性示范性高中（市特色普通高中）', '无寄宿', 25, 0, 0),
  (29, '062001', '上海市市西中学', '静安区', '公办', '市实验性示范性高中', '部分寄宿', 54, 4, 12),
  (30, '062002', '上海市育才中学', '静安区', '公办', '市实验性示范性高中', '全部寄宿', 42, 2, 2),
  (31, '062003', '上海市新中高级中学', '静安区', '公办', '市实验性示范性高中', '部分寄宿', 54, 11, 5),
  (32, '062004', '上海市市北中学', '静安区', '公办', '市实验性示范性高中', '无寄宿', 60, 12, 6),
  (33, '062011', '上海市回民中学', '静安区', '公办', '市实验性示范性高中', '部分寄宿', 38, 8, 0),
  (34, '063004', '上海市第六十中学', '静安区', '公办', '市实验性示范性高中', '无寄宿', 35, 4, 2),
  (35, '064001', '上海市华东模范中学', '静安区', '公办', '市实验性示范性高中', '无寄宿', 31, 8, 0),
  (36, '072001', '上海市晋元高级中学', '普陀区', '公办', '市实验性示范性高中', '全部寄宿', 48, 3, 2),
  (37, '072002', '上海市曹杨第二中学', '普陀区', '公办', '市实验性示范性高中', '部分寄宿', 53, 5, 6),
  (38, '073003', '上海市宜川中学', '普陀区', '公办', '市实验性示范性高中', '无寄宿', 49, 2, 1),
  (39, '073082', '华东师范大学第二附属中学（普陀校区）', '普陀区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 27, 0, 0),
  (40, '073004', '上海市曹杨中学', '普陀区', '公办', '区实验性示范性高中（市特色普通高中）', '无寄宿', 60, 0, 1),
  (41, '074005', '同济大学第二附属中学', '普陀区', '公办', '区实验性示范性高中（市特色普通高中）', '无寄宿', 69, 4, 0),
  (42, '074007', '上海市甘泉外国语中学', '普陀区', '公办', '区实验性示范性高中（市特色普通高中）', '部分寄宿', 76, 11, 0),
  (43, '092001', '复旦大学附属复兴中学', '虹口区', '公办', '市实验性示范性高中', '部分寄宿', 52, 6, 6),
  (44, '092002', '华东师范大学第一附属中学', '虹口区', '公办', '市实验性示范性高中', '部分寄宿', 42, 3, 2),
  (45, '093001', '上海财经大学附属北郊高级中学', '虹口区', '公办', '市实验性示范性高中', '无寄宿', 37, 5, 3),
  (46, '102004', '上海市杨浦高级中学', '杨浦区', '公办', '市实验性示范性高中', '部分寄宿', 62, 3, 6),
  (47, '102032', '上海市控江中学', '杨浦区', '公办', '市实验性示范性高中', '部分寄宿', 65, 2, 10),
  (48, '103002', '同济大学第一附属中学', '杨浦区', '公办', '市实验性示范性高中', '部分寄宿', 76, 21, 11),
  (49, '103039', '上海理工大学附属中学', '杨浦区', '公办', '区实验性示范性高中（市特色普通高中）', '无寄宿', 52, 2, 2),
  (50, '122001', '上海市七宝中学', '闵行区', '公办', '市实验性示范性高中', '部分寄宿', 90, 19, 9),
  (51, '123001', '上海市闵行中学', '闵行区', '公办', '市实验性示范性高中', '部分寄宿', 82, 19, 1),
  (52, '122002', '华东师范大学第二附属中学闵行紫竹分校', '闵行区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 56, 11, 3),
  (53, '122003', '上海师范大学附属中学闵行分校', '闵行区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 54, 3, 7),
  (54, '122004', '上海交通大学附属中学闵行分校', '闵行区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 39, 3, 0),
  (55, '124006', '上海市闵行第三中学', '闵行区', '公办', '市特色普通高中', '部分寄宿', 81, 0, 0),
  (56, '132001', '上海市行知中学', '宝山区', '公办', '市实验性示范性高中', '部分寄宿', 69, 6, 4),
  (57, '132002', '上海大学附属中学', '宝山区', '公办', '市实验性示范性高中', '全部寄宿', 76, 12, 3),
  (58, '133001', '上海市吴淞中学', '宝山区', '公办', '市实验性示范性高中', '部分寄宿', 61, 6, 4),
  (59, '132003', '上海师范大学附属中学宝山分校', '宝山区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 26, 0, 0),
  (60, '133003', '华东师范大学第二附属中学（宝山校区）', '宝山区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 35, 0, 0),
  (61, '133002', '上海师范大学附属宝山罗店中学', '宝山区', '公办', '区实验性示范性高中（市特色普通高中）', '全部寄宿', 76, 0, 0),
  (62, '142001', '上海市嘉定区第一中学', '嘉定区', '公办', '市实验性示范性高中', '部分寄宿', 60, 11, 3),
  (63, '142002', '上海交通大学附属中学嘉定分校', '嘉定区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 72, 5, 12),
  (64, '142004', '上海师范大学附属中学嘉定新城分校', '嘉定区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 30, 0, 0),
  (65, '143001', '上海市嘉定区第二中学', '嘉定区', '公办', '区实验性示范性高中（市特色普通高中）', '部分寄宿', 81, 0, 0),
  (66, '152001', '上海市建平中学', '浦东新区', '公办', '市实验性示范性高中', '部分寄宿', 75, 9, 10),
  (67, '152002', '上海市进才中学', '浦东新区', '公办', '市实验性示范性高中', '部分寄宿', 75, 8, 11),
  (68, '152004', '上海南汇中学', '浦东新区', '公办', '市实验性示范性高中', '部分寄宿', 80, 3, 5),
  (69, '153001', '上海市洋泾中学', '浦东新区', '公办', '市实验性示范性高中', '部分寄宿', 69, 3, 10),
  (70, '153004', '上海市高桥中学', '浦东新区', '公办', '市实验性示范性高中', '部分寄宿', 54, 3, 3),
  (71, '153005', '上海市川沙中学', '浦东新区', '公办', '市实验性示范性高中', '部分寄宿', 65, 13, 4),
  (72, '151078', '上海中学东校', '浦东新区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 56, 2, 6),
  (73, '152005', '上海市浦东复旦附中分校', '浦东新区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 39, 0, 3),
  (74, '153002', '华东师范大学附属东昌中学', '浦东新区', '公办', '区实验性示范性高中（市特色普通高中）', '部分寄宿', 92, 8, 0),
  (75, '154009', '上海市香山中学', '浦东新区', '公办', '区实验性示范性高中（市特色普通高中）', '无寄宿', 72, 0, 0),
  (76, '154013', '上海海事大学附属北蔡高级中学', '浦东新区', '公办', '区实验性示范性高中（市特色普通高中）', '部分寄宿', 48, 0, 0),
  (77, '162000', '上海市金山中学', '金山区', '公办', '市实验性示范性高中', '全部寄宿', 42, 2, 2),
  (78, '163002', '华东师范大学第三附属中学', '金山区', '公办', '市实验性示范性高中', '全部寄宿', 53, 11, 2),
  (79, '163001', '上海师范大学第二附属中学', '金山区', '公办', '区实验性示范性高中（市特色普通高中）', '部分寄宿', 55, 2, 2),
  (80, '164000', '华东师范大学附属枫泾中学', '金山区', '公办', '区实验性示范性高中（市特色普通高中）', '部分寄宿', 38, 0, 0),
  (81, '172001', '上海市松江二中', '松江区', '公办', '市实验性示范性高中', '部分寄宿', 56, 10, 3),
  (82, '173001', '上海市松江一中', '松江区', '公办', '市实验性示范性高中', '部分寄宿', 57, 11, 3),
  (83, '172002', '华东师范大学第二附属中学松江分校', '松江区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 30, 4, 0),
  (84, '172004', '上海师范大学附属中学松江分校', '松江区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 16, 0, 0),
  (85, '174003', '上海外国语大学附属外国语学校松江云间中学', '松江区', '公办', '享受市实验性示范性高中招生政策高中', '部分寄宿', 52, 5, 4),
  (86, '182001', '上海市青浦高级中学', '青浦区', '公办', '市实验性示范性高中', '部分寄宿', 77, 7, 1),
  (87, '183002', '上海市朱家角中学', '青浦区', '公办', '市实验性示范性高中', '部分寄宿', 71, 3, 2),
  (88, '182002', '复旦大学附属中学青浦分校', '青浦区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 49, 11, 6),
  (89, '184005', '上海市青浦区第一中学', '青浦区', '公办', '区实验性示范性高中（市特色普通高中）', '部分寄宿', 69, 3, 0),
  (90, '202001', '上海市奉贤中学', '奉贤区', '公办', '市实验性示范性高中', '全部寄宿', 62, 8, 6),
  (91, '202002', '华东师范大学第二附属中学临港奉贤分校', '奉贤区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 36, 2, 1),
  (92, '203002', '华东理工大学附属奉贤曙光中学', '奉贤区', '公办', '区实验性示范性高中（市特色普通高中）', '全部寄宿', 73, 0, 0),
  (93, '512000', '上海市崇明中学', '崇明区', '公办', '市实验性示范性高中', '全部寄宿', 38, 4, 2),
  (94, '512001', '上海市实验学校东滩高级中学', '崇明区', '公办', '享受市实验性示范性高中招生政策高中', '全部寄宿', 17, 1, 0)
)
INSERT INTO ref_autonomous_admission_plan (
  year, display_order, school_id, school_code, school_name, district_id, district_name,
  school_nature_name, school_type_name, boarding_type_name, total_count, sports_count,
  arts_count, data_source, created_at, updated_at
)
SELECT
  2026, src.display_order, s.id, src.school_code, src.school_name, d.id, src.district_name,
  src.school_nature_name, src.school_type_name, src.boarding_type_name, src.total_count,
  src.sports_count, src.arts_count, '2026_autonomous_plan.pdf', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM src
JOIN ref_school s ON s.code = src.school_code
LEFT JOIN ref_district d ON d.name = src.district_name
ON CONFLICT (year, school_code) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  school_id = EXCLUDED.school_id,
  school_name = EXCLUDED.school_name,
  district_id = EXCLUDED.district_id,
  district_name = EXCLUDED.district_name,
  school_nature_name = EXCLUDED.school_nature_name,
  school_type_name = EXCLUDED.school_type_name,
  boarding_type_name = EXCLUDED.boarding_type_name,
  total_count = EXCLUDED.total_count,
  sports_count = EXCLUDED.sports_count,
  arts_count = EXCLUDED.arts_count,
  data_source = EXCLUDED.data_source,
  updated_at = CURRENT_TIMESTAMP;

WITH src(display_order, school_code, district_name, school_nature_name, school_name, has_international_course_note, remarks, scheme_label) AS (
VALUES
  (1, '042032', '上海市', '公办', '上海市上海中学', False, NULL, '点击查看'),
  (2, '102056', '上海市', '公办', '上海交通大学附属中学', True, '含国际课程班', '点击查看'),
  (3, '102057', '上海市', '公办', '复旦大学附属中学', True, '含国际课程班', '点击查看'),
  (4, '152003', '上海市', '公办', '华东师范大学第二附属中学', True, '含国际课程班', '点击查看'),
  (5, '152006', '上海市', '公办', '上海师范大学附属中学', False, NULL, '点击查看'),
  (6, '155001', '上海市', '公办', '上海市实验学校', False, NULL, '点击查看'),
  (7, '012001', '黄浦区', '公办', '上海市格致中学', True, '含国际课程班', '点击查看'),
  (8, '012002', '黄浦区', '公办', '上海市格致中学（奉贤校区）', False, NULL, '点击查看'),
  (9, '012003', '黄浦区', '公办', '上海市大同中学', True, '含国际课程班', '点击查看'),
  (10, '012005', '黄浦区', '公办', '上海市向明中学', False, NULL, '点击查看'),
  (11, '012006', '黄浦区', '公办', '上海市向明中学（浦江校区）', False, NULL, '点击查看'),
  (12, '012007', '黄浦区', '公办', '上海外国语大学附属大境中学', False, NULL, '点击查看'),
  (13, '012008', '黄浦区', '公办', '上海市光明中学', False, NULL, '点击查看'),
  (14, '012009', '黄浦区', '公办', '上海市敬业中学', False, NULL, '点击查看'),
  (15, '012010', '黄浦区', '公办', '上海市卢湾高级中学', True, '含国际课程班', '点击查看'),
  (16, '012011', '黄浦区', '公办', '同济大学科技中学', False, NULL, '点击查看'),
  (17, '042001', '徐汇区', '公办', '上海市第二中学', False, NULL, '点击查看'),
  (18, '042002', '徐汇区', '公办', '上海市第二中学（梅陇校区）', False, NULL, '点击查看'),
  (19, '042008', '徐汇区', '公办', '上海市南洋模范中学', False, NULL, '点击查看'),
  (20, '042035', '徐汇区', '公办', '上海市位育中学', False, NULL, '点击查看'),
  (21, '042036', '徐汇区', '公办', '复旦大学附属中学徐汇分校', False, NULL, '点击查看'),
  (22, '043015', '徐汇区', '公办', '上海市南洋中学', False, NULL, '点击查看'),
  (23, '044109', '徐汇区', '公办', '上海市徐汇中学', False, NULL, '点击查看'),
  (24, '044223', '徐汇区', '公办', '上海市紫竹园中学', False, NULL, '点击查看'),
  (25, '052001', '长宁区', '公办', '上海市第三女子中学', False, NULL, '点击查看'),
  (26, '052002', '长宁区', '公办', '上海市延安中学', False, NULL, '点击查看'),
  (27, '053004', '长宁区', '公办', '上海市复旦中学', False, NULL, '点击查看'),
  (28, '054013', '长宁区', '公办', '华东政法大学附属中学', False, NULL, '点击查看'),
  (29, '062001', '静安区', '公办', '上海市市西中学', True, '含国际课程班', '点击查看'),
  (30, '062002', '静安区', '公办', '上海市育才中学', False, NULL, '点击查看'),
  (31, '062003', '静安区', '公办', '上海市新中高级中学', False, NULL, '点击查看'),
  (32, '062004', '静安区', '公办', '上海市市北中学', False, NULL, '点击查看'),
  (33, '062011', '静安区', '公办', '上海市回民中学', False, NULL, '点击查看'),
  (34, '063004', '静安区', '公办', '上海市第六十中学', False, NULL, '点击查看'),
  (35, '064001', '静安区', '公办', '上海市华东模范中学', False, NULL, '点击查看'),
  (36, '072001', '普陀区', '公办', '上海市晋元高级中学', False, NULL, '点击查看'),
  (37, '072002', '普陀区', '公办', '上海市曹杨第二中学', True, '含国际课程班', '点击查看'),
  (38, '073003', '普陀区', '公办', '上海市宜川中学', False, NULL, '点击查看'),
  (39, '073004', '普陀区', '公办', '上海市曹杨中学', False, NULL, '点击查看'),
  (40, '073082', '普陀区', '公办', '华东师范大学第二附属中学（普陀校区）', False, NULL, '点击查看'),
  (41, '074005', '普陀区', '公办', '同济大学第二附属中学', False, NULL, '点击查看'),
  (42, '074007', '普陀区', '公办', '上海市甘泉外国语中学', False, NULL, '点击查看'),
  (43, '092001', '虹口区', '公办', '复旦大学附属复兴中学', False, NULL, '点击查看'),
  (44, '092002', '虹口区', '公办', '华东师范大学第一附属中学', False, NULL, '点击查看'),
  (45, '093001', '虹口区', '公办', '上海财经大学附属北郊高级中学', False, NULL, '点击查看'),
  (46, '102004', '杨浦区', '公办', '上海市杨浦高级中学', False, NULL, '点击查看'),
  (47, '102032', '杨浦区', '公办', '上海市控江中学', False, NULL, '点击查看'),
  (48, '103002', '杨浦区', '公办', '同济大学第一附属中学', False, NULL, '点击查看'),
  (49, '103039', '杨浦区', '公办', '上海理工大学附属中学', False, NULL, '点击查看'),
  (50, '122001', '闵行区', '公办', '上海市七宝中学', False, NULL, '点击查看'),
  (51, '122002', '闵行区', '公办', '华东师范大学第二附属中学闵行紫竹分校', False, NULL, '点击查看'),
  (52, '122003', '闵行区', '公办', '上海师范大学附属中学闵行分校', False, NULL, '点击查看'),
  (53, '122004', '闵行区', '公办', '上海交通大学附属中学闵行分校', False, NULL, '点击查看'),
  (54, '123001', '闵行区', '公办', '上海市闵行中学', False, NULL, '点击查看'),
  (55, '124006', '闵行区', '公办', '上海市闵行第三中学', False, NULL, '点击查看'),
  (56, '132001', '宝山区', '公办', '上海市行知中学', False, NULL, '点击查看'),
  (57, '132002', '宝山区', '公办', '上海大学附属中学', False, NULL, '点击查看'),
  (58, '132003', '宝山区', '公办', '上海师范大学附属中学宝山分校', False, NULL, '点击查看'),
  (59, '133001', '宝山区', '公办', '上海市吴淞中学', False, NULL, '点击查看'),
  (60, '133002', '宝山区', '公办', '上海师范大学附属宝山罗店中学', False, NULL, '点击查看'),
  (61, '133003', '宝山区', '公办', '华东师范大学第二附属中学（宝山校区）', False, NULL, '点击查看'),
  (62, '142001', '嘉定区', '公办', '上海市嘉定区第一中学', False, NULL, '点击查看'),
  (63, '142002', '嘉定区', '公办', '上海交通大学附属中学嘉定分校', False, NULL, '点击查看'),
  (64, '142004', '嘉定区', '公办', '上海师范大学附属中学嘉定新城分校', False, NULL, '点击查看'),
  (65, '143001', '嘉定区', '公办', '上海市嘉定区第二中学', False, NULL, '点击查看'),
  (66, '151078', '浦东新区', '公办', '上海中学东校', False, NULL, '点击查看'),
  (67, '152001', '浦东新区', '公办', '上海市建平中学', True, '含国际课程班', '点击查看'),
  (68, '152002', '浦东新区', '公办', '上海市进才中学', False, NULL, '点击查看'),
  (69, '152004', '浦东新区', '公办', '上海南汇中学', False, NULL, '点击查看'),
  (70, '152005', '浦东新区', '公办', '上海市浦东复旦附中分校', False, NULL, '点击查看'),
  (71, '153001', '浦东新区', '公办', '上海市洋泾中学', False, NULL, '点击查看'),
  (72, '153002', '浦东新区', '公办', '华东师范大学附属东昌中学', False, NULL, '点击查看'),
  (73, '153004', '浦东新区', '公办', '上海市高桥中学', False, NULL, '点击查看'),
  (74, '153005', '浦东新区', '公办', '上海市川沙中学', False, NULL, '点击查看'),
  (75, '154009', '浦东新区', '公办', '上海市香山中学', False, NULL, '点击查看'),
  (76, '154013', '浦东新区', '公办', '上海海事大学附属北蔡高级中学', False, NULL, '点击查看'),
  (77, '155004', '浦东新区', '公办', '上海外国语大学附属浦东外国语学校', True, '含国际课程班', '点击查看'),
  (78, '162000', '金山区', '公办', '上海市金山中学', False, NULL, '点击查看'),
  (79, '163001', '金山区', '公办', '上海师范大学第二附属中学', False, NULL, '点击查看'),
  (80, '163002', '金山区', '公办', '华东师范大学第三附属中学', False, NULL, '点击查看'),
  (81, '164000', '金山区', '公办', '华东师范大学附属枫泾中学', False, NULL, '点击查看'),
  (82, '172001', '松江区', '公办', '上海市松江二中', False, NULL, '点击查看'),
  (83, '172002', '松江区', '公办', '华东师范大学第二附属中学松江分校', False, NULL, '点击查看'),
  (84, '172004', '松江区', '公办', '上海师范大学附属中学松江分校', False, NULL, '点击查看'),
  (85, '173001', '松江区', '公办', '上海市松江一中', False, NULL, '点击查看'),
  (86, '174003', '松江区', '公办', '上海外国语大学附属外国语学校松江云间中学', False, NULL, '点击查看'),
  (87, '182001', '青浦区', '公办', '上海市青浦高级中学', False, NULL, '点击查看'),
  (88, '182002', '青浦区', '公办', '复旦大学附属中学青浦分校', False, NULL, '点击查看'),
  (89, '183002', '青浦区', '公办', '上海市朱家角中学', False, NULL, '点击查看'),
  (90, '184005', '青浦区', '公办', '上海市青浦区第一中学', False, NULL, '点击查看'),
  (91, '202001', '奉贤区', '公办', '上海市奉贤中学', False, NULL, '点击查看'),
  (92, '202002', '奉贤区', '公办', '华东师范大学第二附属中学临港奉贤分校', False, NULL, '点击查看'),
  (93, '203002', '奉贤区', '公办', '华东理工大学附属奉贤曙光中学', False, NULL, '点击查看'),
  (94, '512000', '崇明区', '公办', '上海市崇明中学', False, NULL, '点击查看'),
  (95, '512001', '崇明区', '公办', '上海市实验学校东滩高级中学', False, NULL, '点击查看')
)
INSERT INTO ref_autonomous_admission_scheme (
  year, display_order, school_id, school_code, school_name, district_id, district_name,
  school_nature_name, has_international_course_note, remarks, scheme_label, data_source,
  created_at, updated_at
)
SELECT
  2026, src.display_order, s.id, src.school_code, src.school_name, d.id, src.district_name,
  src.school_nature_name, src.has_international_course_note, src.remarks, src.scheme_label,
  '2026_autonomous_admission_plan.pdf', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM src
JOIN ref_school s ON s.code = src.school_code
LEFT JOIN ref_district d ON d.name = src.district_name
ON CONFLICT (year, school_code) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  school_id = EXCLUDED.school_id,
  school_name = EXCLUDED.school_name,
  district_id = EXCLUDED.district_id,
  district_name = EXCLUDED.district_name,
  school_nature_name = EXCLUDED.school_nature_name,
  has_international_course_note = EXCLUDED.has_international_course_note,
  remarks = EXCLUDED.remarks,
  scheme_label = EXCLUDED.scheme_label,
  data_source = EXCLUDED.data_source,
  updated_at = CURRENT_TIMESTAMP;

WITH src(display_order, school_code, school_name, school_nature_name, total_count, local_student_count, nonlocal_student_count) AS (
VALUES
  (1, '102056', '上海交通大学附属中学', '公办', 30, 30, 0),
  (2, '102057', '复旦大学附属中学', '公办', 32, 32, 0),
  (3, '152003', '华东师范大学第二附属中学', '公办', 40, 40, 0),
  (4, '012001', '上海市格致中学', '公办', 40, 40, 0),
  (5, '012003', '上海市大同中学', '公办', 40, 40, 0),
  (6, '012010', '上海市卢湾高级中学', '公办', 40, 40, 0),
  (7, '041363', '上海市世外中学', '民办', 130, 120, 10),
  (8, '044162', '上海市西南位育中学', '民办', 100, 60, 40),
  (9, '062001', '上海市市西中学', '公办', 60, 60, 0),
  (10, '072002', '上海市曹杨第二中学', '公办', 118, 118, 0),
  (11, '124108', '上海市文来中学', '民办', 200, 175, 25),
  (12, '124111', '上海协和双语高级中学', '民办', 80, 75, 5),
  (13, '125113', '上海星河湾双语学校', '民办', 220, 196, 24),
  (14, '128100', '上海七宝德怀特高级中学', '中外合作', 175, 115, 60),
  (15, '152001', '上海市建平中学', '公办', 40, 40, 0),
  (16, '155004', '上海外国语大学附属浦东外国语学校', '公办', 25, 25, 0),
  (17, '155008', '上海市民办平和学校', '民办', 300, 260, 40),
  (18, '155043', '上海市民办尚德实验学校', '民办', 160, 80, 80),
  (19, '164006', '上海枫叶双语学校', '民办', 300, 240, 60),
  (20, '175018', '上海市西外外国语学校', '民办', 160, 80, 80),
  (21, '175021', '上海民办包玉刚实验高中', '民办', 165, 135, 30)
)
INSERT INTO ref_international_course_plan (
  year, display_order, school_id, school_code, school_name, district_id, school_nature_name,
  total_count, local_student_count, nonlocal_student_count, data_source, created_at, updated_at
)
SELECT
  2026, src.display_order, s.id, src.school_code, src.school_name, s.district_id, src.school_nature_name,
  src.total_count, src.local_student_count, src.nonlocal_student_count,
  '2026_international_course_plan.pdf', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM src
JOIN ref_school s ON s.code = src.school_code
ON CONFLICT (year, school_code) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  school_id = EXCLUDED.school_id,
  school_name = EXCLUDED.school_name,
  district_id = EXCLUDED.district_id,
  school_nature_name = EXCLUDED.school_nature_name,
  total_count = EXCLUDED.total_count,
  local_student_count = EXCLUDED.local_student_count,
  nonlocal_student_count = EXCLUDED.nonlocal_student_count,
  data_source = EXCLUDED.data_source,
  updated_at = CURRENT_TIMESTAMP;

WITH src(display_order, school_code, district_name, school_nature_name, school_name, scheme_label) AS (
VALUES
  (1, '041363', '徐汇区', '民办', '上海市世外中学', '点击查看'),
  (2, '044162', '徐汇区', '民办', '上海市西南位育中学', '点击查看'),
  (3, '124108', '闵行区', '民办', '上海市文来中学', '点击查看'),
  (4, '124111', '闵行区', '民办', '上海协和双语高级中学', '点击查看'),
  (5, '125113', '闵行区', '民办', '上海星河湾双语学校', '点击查看'),
  (6, '128100', '闵行区', '中外合作', '上海七宝德怀特高级中学', '点击查看'),
  (7, '155008', '浦东新区', '民办', '上海市民办平和学校', '点击查看'),
  (8, '155043', '浦东新区', '民办', '上海市民办尚德实验学校', '点击查看'),
  (9, '164006', '金山区', '民办', '上海枫叶双语学校', '点击查看'),
  (10, '175018', '松江区', '民办', '上海市西外外国语学校', '点击查看'),
  (11, '175021', '松江区', '民办', '上海民办包玉刚实验高中', '点击查看')
)
INSERT INTO ref_private_international_admission_scheme (
  year, display_order, school_id, school_code, school_name, district_id, district_name,
  school_nature_name, scheme_label, data_source, created_at, updated_at
)
SELECT
  2026, src.display_order, s.id, src.school_code, src.school_name, d.id, src.district_name,
  src.school_nature_name, src.scheme_label,
  '2026_private_international_admission.pdf', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM src
JOIN ref_school s ON s.code = src.school_code
LEFT JOIN ref_district d ON d.name = src.district_name
ON CONFLICT (year, school_code) DO UPDATE SET
  display_order = EXCLUDED.display_order,
  school_id = EXCLUDED.school_id,
  school_name = EXCLUDED.school_name,
  district_id = EXCLUDED.district_id,
  district_name = EXCLUDED.district_name,
  school_nature_name = EXCLUDED.school_nature_name,
  scheme_label = EXCLUDED.scheme_label,
  data_source = EXCLUDED.data_source,
  updated_at = CURRENT_TIMESTAMP;

UPDATE ref_school
SET has_international_course = (code IN ('012001', '012003', '012010', '041363', '044162', '062001', '072002', '102056', '102057', '124108', '124111', '125113', '128100', '152001', '152003', '155004', '155008', '155043', '164006', '175018', '175021')),
    updated_at = CURRENT_TIMESTAMP
WHERE has_international_course IS DISTINCT FROM (code IN ('012001', '012003', '012010', '041363', '044162', '062001', '072002', '102056', '102057', '124108', '124111', '125113', '128100', '152001', '152003', '155004', '155008', '155043', '164006', '175018', '175021'));

DO $$
DECLARE
  v_count integer;
BEGIN
  SELECT COUNT(*) INTO v_count FROM ref_autonomous_admission_plan WHERE year = 2026;
  IF v_count <> 94 THEN
    RAISE EXCEPTION 'ref_autonomous_admission_plan 2026 row count expected 94, got %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count FROM ref_autonomous_admission_scheme WHERE year = 2026;
  IF v_count <> 95 THEN
    RAISE EXCEPTION 'ref_autonomous_admission_scheme 2026 row count expected 95, got %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count FROM ref_international_course_plan WHERE year = 2026;
  IF v_count <> 21 THEN
    RAISE EXCEPTION 'ref_international_course_plan 2026 row count expected 21, got %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count FROM ref_private_international_admission_scheme WHERE year = 2026;
  IF v_count <> 11 THEN
    RAISE EXCEPTION 'ref_private_international_admission_scheme 2026 row count expected 11, got %', v_count;
  END IF;

  SELECT COUNT(*) INTO v_count FROM ref_school WHERE has_international_course;
  IF v_count <> 21 THEN
    RAISE EXCEPTION 'ref_school.has_international_course expected 21, got %', v_count;
  END IF;
END $$;

COMMIT;
