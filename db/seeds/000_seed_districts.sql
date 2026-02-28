-- =============================================================================
-- 上海16个区县基础数据
-- =============================================================================

INSERT INTO ref_district (code, name, name_en, display_order) VALUES
('SH', '上海市', 'Shanghai', 0),
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
