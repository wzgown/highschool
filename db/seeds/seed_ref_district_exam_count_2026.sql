-- 2026年各区中考报名人数(民间估算, 官方仅公布全市138000人)
BEGIN;

INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 12, 33348, '2026民间估算(haoxue360): haoxue360 2026各区预计中考人数') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 9, 17374, '2026民间估算(haoxue360): haoxue360；搜狐称考生超1.5万') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 10, 11555, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 3, 8754, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 11, 8675, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 8, 7289, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 5, 7351, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 6, 7206, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 14, 10263, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 15, 5551, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 16, 5637, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 2, 4153, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 7, 4158, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 4, 3791, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 13, 4298, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source) VALUES (2026, 17, 2768, '2026民间估算(haoxue360): haoxue360') ON CONFLICT (year, district_id) DO UPDATE SET exam_count=EXCLUDED.exam_count, data_source=EXCLUDED.data_source;

COMMIT;
