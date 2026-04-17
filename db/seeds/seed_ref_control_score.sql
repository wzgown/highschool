-- ============================================================
-- Seed: ref_control_score
-- Generated: 2026-04-18 from DB (highschool_postgres)
-- Rows: 6
-- ============================================================

SET search_path TO public;

-- Truncate and re-insert (idempotent)
TRUNCATE ref_control_score CASCADE;

INSERT INTO ref_control_score (id, year, admission_batch_id, category, min_score, description, created_at, updated_at) VALUES (13, 2025, 'AUTONOMOUS', '自主招生录取', 605.00, NULL, '2026-02-19 19:13:48.860158', '2026-02-19 19:13:48.860158');
INSERT INTO ref_control_score (id, year, admission_batch_id, category, min_score, description, created_at, updated_at) VALUES (14, 2025, 'QUOTA_DISTRICT', '名额分配综合评价录取', 605.00, NULL, '2026-02-19 19:13:48.860158', '2026-02-19 19:13:48.860158');
INSERT INTO ref_control_score (id, year, admission_batch_id, category, min_score, description, created_at, updated_at) VALUES (15, 2025, 'UNIFIED_1_15', '普通高中统一招生录取', 513.00, NULL, '2026-02-19 19:13:48.860158', '2026-02-19 19:13:48.860158');
INSERT INTO ref_control_score (id, year, admission_batch_id, category, min_score, description, created_at, updated_at) VALUES (16, 2025, 'ZHONGBEN', '中本贯通录取', 513.00, NULL, '2026-02-19 19:13:48.860158', '2026-02-19 19:13:48.860158');
INSERT INTO ref_control_score (id, year, admission_batch_id, category, min_score, description, created_at, updated_at) VALUES (17, 2025, 'WUNIAN_ZHIGAO', '五年一贯制和中高职贯通录取', 400.00, NULL, '2026-02-19 19:13:48.860158', '2026-02-19 19:13:48.860158');
INSERT INTO ref_control_score (id, year, admission_batch_id, category, min_score, description, created_at, updated_at) VALUES (18, 2025, 'ZHONGZHUAN', '普通中专录取', 350.00, NULL, '2026-02-19 19:13:48.860158', '2026-02-19 19:13:48.860158');
