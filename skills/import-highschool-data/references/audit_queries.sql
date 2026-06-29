-- Adapt these checks to the current schema before use.

WITH issue_counts AS (
  SELECT 'quota_school_allocation_null_middle_id' AS issue, COUNT(*)::bigint AS count
  FROM ref_quota_allocation_school
  WHERE middle_school_id IS NULL

  UNION ALL
  SELECT 'quota_school_allocation_cross_district', COUNT(*)
  FROM ref_quota_allocation_school q
  JOIN ref_middle_school m ON m.id = q.middle_school_id
  WHERE q.district_id <> m.district_id

  UNION ALL
  SELECT 'quota_school_allocation_high_school_code_mismatch', COUNT(*)
  FROM ref_quota_allocation_school q
  JOIN ref_school s ON s.id = q.high_school_id
  WHERE q.high_school_code IS DISTINCT FROM s.code

  UNION ALL
  SELECT 'quota_district_allocation_school_code_mismatch', COUNT(*)
  FROM ref_quota_allocation_district q
  JOIN ref_school s ON s.id = q.school_id
  WHERE q.school_code IS DISTINCT FROM s.code

  UNION ALL
  SELECT 'quota_unified_school_code_mismatch', COUNT(*)
  FROM ref_quota_unified_allocation_district q
  JOIN ref_school s ON s.id = q.school_id
  WHERE q.school_code IS DISTINCT FROM s.code

  UNION ALL
  SELECT 'quota_district_score_null_school_id', COUNT(*)
  FROM ref_admission_score_quota_district
  WHERE school_id IS NULL

  UNION ALL
  SELECT 'quota_school_score_null_school_id', COUNT(*)
  FROM ref_admission_score_quota_school
  WHERE school_id IS NULL

  UNION ALL
  SELECT 'plan_summary_school_code_mismatch', COUNT(*)
  FROM ref_admission_plan_summary p
  JOIN ref_school s ON s.id = p.school_id
  WHERE p.school_code IS DISTINCT FROM s.code

  UNION ALL
  SELECT 'plan_summary_school_name_mismatch', COUNT(*)
  FROM ref_admission_plan_summary p
  JOIN ref_school s ON s.id = p.school_id
  WHERE p.school_name IS DISTINCT FROM s.full_name

  UNION ALL
  SELECT 'plan_summary_total_mismatch', COUNT(*)
  FROM ref_admission_plan_summary
  WHERE total_plan_count <> autonomous_count + quota_district_count + quota_school_count + unified_count
)
SELECT *
FROM issue_counts
ORDER BY issue;
