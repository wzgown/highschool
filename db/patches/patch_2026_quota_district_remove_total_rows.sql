-- 修复: 2026到区计划 152006/155001 冗余"上海市"总计行导致汇总双倍计数
BEGIN;

-- 2026 到区计划中 152006/155001 同时存在按区明细行和 district='上海市' 的校级总计行，
-- 按校汇总会双倍计数（其余75校均无此行）。后端按 student district 查询，不受影响。
DELETE FROM ref_quota_allocation_district WHERE year=2026 AND district_id=1 AND school_code IN ('152006','155001');

COMMIT;
