-- 恢复 8 所被 patch_2026_school_list_update.sql 误标停招的学校
-- 证据：2026 年各校均有统一招生计划（见 original_data/raw/2026/tongyi_plan/）
--       且 ref_admission_score_unified 已有其 2026 录取线
BEGIN;
UPDATE ref_school SET is_active = true, updated_at = CURRENT_TIMESTAMP WHERE code IN
  ('014004', -- 比乐中学（黄浦，2026统招144人）
   '064004', -- 上戏附中（静安，80）
   '093003', -- 北虹高级（虹口，270）
   '124024', -- 古美高级（闵行，270）
   '135034', -- 宝山世外（宝山，22；另嘉定官方2026计划外区5人，铁证）
   '153013', -- 华师临港（浦东，270）
   '155055', -- 未来科技（浦东，50）
   '182002');-- 复附青浦（青浦，63）
COMMIT;
