-- =============================================================================
-- 上海中考招生模拟系统 - 参考数据种子数据
-- =============================================================================

-- =============================================================================
-- 1. 区县数据 (ref_district)
-- 上海16个区
-- =============================================================================
INSERT INTO ref_district (code, name, name_en, display_order) VALUES
('HP', '黄浦区', 'Huangpu', 1),
('XH', '徐汇区', 'Xuhui', 2),
('CN', '长宁区', 'Changning', 3),
('JA', '静安区', 'Jingan', 4),
('PT', '普陀区', 'Putuo', 5),
('HK', '虹口区', 'Hongkou', 6),
('YP', '杨浦区', 'Yangpu', 7),
('MH', '闵行区', 'Minhang', 8),
('BS', '宝山区', 'Baoshan', 9),
('JD', '嘉定区', 'Jiading', 10),
('PD', '浦东新区', 'Pudong', 11),
('JS', '金山区', 'Jinshan', 12),
('SJ', '松江区', 'Songjiang', 13),
('QP', '青浦区', 'Qingpu', 14),
('FX', '奉贤区', 'Fengxian', 15),
('CM', '崇明区', 'Chongming', 16)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 2. 学校类型数据 (ref_school_type)
-- =============================================================================
INSERT INTO ref_school_type (code, name, description, display_order) VALUES
('CITY_MODEL', '市实验性示范性高中', '上海市实验性、示范性高中', 1),
('CITY_FEATURED', '市特色普通高中', '上海市特色普通高中', 2),
('CITY_POLICY', '享受市实验性示范性高中招生政策高中', '享受市实验性示范性高中招生政策的高中', 3),
('DISTRICT_MODEL', '区实验性示范性高中', '区实验性、示范性高中', 4),
('DISTRICT_FEATURED', '区特色普通高中', '区特色普通高中', 5),
('GENERAL', '一般高中', '一般普通高中', 6),
('MUNICIPAL', '委属市实验性示范性高中', '市教委直属的市实验性示范性高中', 7)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 3. 办别数据 (ref_school_nature)
-- =============================================================================
INSERT INTO ref_school_nature (code, name, display_order) VALUES
('PUBLIC', '公办', 1),
('PRIVATE', '民办', 2),
('COOPERATION', '中外合作', 3)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 4. 寄宿情况数据 (ref_boarding_type)
-- =============================================================================
INSERT INTO ref_boarding_type (code, name, description, display_order) VALUES
('FULL', '全部寄宿', '学校提供全部寄宿', 1),
('PARTIAL', '部分寄宿', '学校提供部分寄宿', 2),
('NONE', '无寄宿', '学校不提供寄宿', 3)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 5. 招生批次数据 (ref_admission_batch)
-- =============================================================================
INSERT INTO ref_admission_batch (code, name, description, display_order) VALUES
('AUTONOMOUS', '自主招生录取', '最先执行，本系统不支持', 1),
('QUOTA_DISTRICT', '名额分配到区', '名额分配综合评价录取-到区，1个志愿，总分800分', 2),
('QUOTA_SCHOOL', '名额分配到校', '名额分配综合评价录取-到校，2个平行志愿，总分800分', 3),
('UNIFIED_1_15', '统一招生1-15志愿', '15个平行志愿，总分750分', 4),
('UNIFIED_CONSULT', '统一招生征求志愿', '征求志愿，总分750分', 5)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 6. 科目数据 (ref_subject)
-- =============================================================================
INSERT INTO ref_subject (code, name, max_score, description, display_order) VALUES
('chinese', '语文', 150, '闭卷笔试', 1),
('math', '数学', 150, '闭卷笔试', 2),
('foreign', '外语', 150, '笔试140分（含听力25分）+ 听说测试10分', 3),
('integrated', '综合测试', 150, '物理70分 + 化学50分 + 跨学科案例分析15分 + 物理实验操作10分 + 化学实验操作5分', 4),
('ethics', '道德与法治', 60, '统一考试30分（开卷笔试）+ 日常考核30分', 5),
('history', '历史', 60, '统一考试30分（开卷笔试）+ 日常考核30分', 6),
('pe', '体育与健身', 30, '统一测试15分 + 日常考核15分', 7),
('comprehensive_quality', '综合素质评价', 50, '仅名额分配批次计入，合格即赋50分', 8)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 7. 2025年最低投档控制分数线 (ref_control_score)
-- 数据来源: https://www.shmeea.edu.cn/page/08000/20250708/19584.html
-- =============================================================================
INSERT INTO ref_control_score (year, admission_batch_id, category, min_score, description, data_year) VALUES
-- 2025年各批次最低投档控制分数线
(2025,
 (SELECT id FROM ref_admission_batch WHERE code = 'AUTONOMOUS'),
 '普通高中自主招生录取', 605, '含委属市实验性示范性高中、市特色普通高中', 2025),

(2025,
 (SELECT id FROM ref_admission_batch WHERE code = 'QUOTA_DISTRICT'),
 '名额分配综合评价录取', 605, '含综合素质评价50分，总分800分', 2025),

(2025,
 (SELECT id FROM ref_admission_batch WHERE code = 'UNIFIED_1_15'),
 '普通高中统一招生录取', 513, '1-15平行志愿', 2025),

(2025,
 (SELECT id FROM ref_admission_batch WHERE code = 'UNIFIED_1_15'),
 '中本贯通录取', 513, '须达普高线', 2025),

(2025,
 (SELECT id FROM ref_admission_batch WHERE code = 'UNIFIED_1_15'),
 '五年一贯制和中高职贯通录取', 400, NULL, 2025),

(2025,
 (SELECT id FROM ref_admission_batch WHERE code = 'UNIFIED_1_15'),
 '普通中专录取', 350, NULL, 2025)
ON CONFLICT (year, admission_batch_id, category) DO NOTHING;
