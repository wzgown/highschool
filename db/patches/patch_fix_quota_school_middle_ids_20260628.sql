-- Fix missing middle_school_id values in ref_quota_allocation_school.
-- IDs are sourced from ref_middle_school in the production DB on 2026-06-28.

BEGIN;

CREATE TABLE IF NOT EXISTS backup_ref_quota_allocation_school_mid_20260628 AS
SELECT *
FROM ref_quota_allocation_school
WHERE id IN (
  1226, 1227, 1228, 1229, 1230, 1231, 1232,
  2075, 2076, 2177,
  2345, 2346,
  2596, 2597, 2598, 2599,
  2633, 2634, 2635
);

WITH fixes(id, middle_school_id) AS (
  VALUES
    (1226, 765),
    (1227, 765),
    (1228, 765),
    (1229, 765),
    (1230, 765),
    (1231, 765),
    (1232, 765),
    (2075, 760),
    (2076, 760),
    (2177, 757),
    (2345, 805),
    (2346, 805),
    (2596, 767),
    (2597, 767),
    (2598, 767),
    (2599, 767),
    (2633, 766),
    (2634, 766),
    (2635, 766)
)
UPDATE ref_quota_allocation_school q
SET middle_school_id = fixes.middle_school_id,
    updated_at = CURRENT_TIMESTAMP
FROM fixes
WHERE q.id = fixes.id
  AND q.middle_school_id IS DISTINCT FROM fixes.middle_school_id;

COMMIT;
