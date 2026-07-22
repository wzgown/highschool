-- 2026年8所民办高中降低最低投档控制分数线
-- Source: shmeea.edu.cn/page/03600/20260721/20476.html
-- Date: 2026-07-21

INSERT INTO ref_school_control_score (year, school_id, school_code, school_name, district_id, district_name, min_score, score_type, data_source) VALUES
(2026, 175, '134010', '上海民办行中中学', 10, '宝山区', 480.00, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html'),
(2026, 178, '134014', '上海创艺高级中学', 10, '宝山区', 485.00, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html'),
(2026, 191, '145018', '上海华旭双语学校', 11, '嘉定区', 491.00, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html'),
(2026, 227, '154048', '民办上海工商外国语职业学院附属中学', 12, '浦东新区', 490.00, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html'),
(2026, 234, '155041', '上海浦东新区民办东鼎外国语学校', 12, '浦东新区', 480.00, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html'),
(2026, 278, '184007', '上海青浦区宏润博源高级中学', 15, '青浦区', 491.00, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html'),
(2026, 295, '514010', '上海民办民一中学', 17, '崇明区', 441.50, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html'),
(2026, 365, '514014', '上海新纪元双语学校', 17, '崇明区', 462.00, 'LOWERED_PRIVATE', 'shmeea.edu.cn/page/03600/20260721/20476.html')
ON CONFLICT (year, school_code) DO UPDATE SET min_score = EXCLUDED.min_score, updated_at = CURRENT_TIMESTAMP;
