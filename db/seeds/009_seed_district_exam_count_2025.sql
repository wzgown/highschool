-- =============================================================================
-- 2025年各区中考人数数据
-- =============================================================================
-- Generated: 2026-02-12 23:22:50
-- Source: 2025_shanghai_district_exam_count.csv

-- Delete existing 2025 data
DELETE FROM ref_district_exam_count WHERE year = 2025;

-- Insert 2025 district exam count data
INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'HP'), 3788, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'HP');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'XH'), 8014, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'XH');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'CN'), 3404, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'CN');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'JA'), 6747, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JA');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'PT'), 6329, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'PT');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'HK'), 3989, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'HK');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'YP'), 6590, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'YP');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'MH'), 15531, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'MH');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'BS'), 9937, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'BS');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'JD'), 7305, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'PD'), 30447, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'PD');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'JS'), 3903, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JS');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'SJ'), 8942, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'SJ');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'QP'), 4802, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'QP');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'FX'), 4838, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'FX');

INSERT INTO ref_district_exam_count (year, district_id, exam_count, created_at, updated_at)
SELECT 2025, (SELECT id FROM ref_district WHERE code = 'CM'), 2590, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'CM');


-- Verify insert
SELECT d.code, d.name, dec.exam_count
FROM ref_district_exam_count dec
JOIN ref_district d ON dec.district_id = d.id
WHERE dec.year = 2025
ORDER BY d.display_order;