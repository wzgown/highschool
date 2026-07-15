-- 2026年上海市高中阶段学校招生最低投档控制分数线
-- Source: https://www.shmeea.edu.cn/page/03600/20260714/20441.html
-- Published: 2026-07-14
-- Generated: 2026-07-15

TRUNCATE ref_control_score;

INSERT INTO ref_control_score (id, year, admission_batch_id, category, min_score, description, created_at, updated_at) VALUES
(1, 2025, 'AUTONOMOUS', '自主招生录取', 605, '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 2025, 'QUOTA_DISTRICT', '名额分配综合评价录取', 605, '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 2025, 'UNIFIED_1_15', '普通高中统一招生录取', 513, '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 2025, 'ZHONGBEN', '中本贯通录取', 513, '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 2025, 'WUNIAN_ZHIGAO', '五年一贯制和中高职贯通录取', 400, '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, 2025, 'ZHONGZHUAN', '普通中专录取', 350, '', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(19, 2026, 'AUTONOMOUS', '自主招生录取', 615, '来源：shmeea.edu.cn/page/03600/20260714/20441.html', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(20, 2026, 'QUOTA_DISTRICT', '名额分配综合评价录取', 615, '同自主招生', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(21, 2026, 'UNIFIED_1_15', '普通高中统一招生录取', 501, '普通高中统一招生最低投档控制分数线', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(22, 2026, 'ZHONGBEN', '中本贯通录取', 501, '中本贯通录取最低投档控制分数线', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(23, 2026, 'WUNIAN_ZHIGAO', '五年一贯制和中高职贯通录取', 400, '五年一贯制和中高职贯通录取最低投档控制分数线', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(24, 2026, 'ZHONGZHUAN', '普通中专录取', 300, '普通中专录取最低投档控制分数线', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;
