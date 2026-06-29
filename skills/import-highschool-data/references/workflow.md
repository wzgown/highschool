# High School Data Import Workflow

## Sources and Targets

Common source locations:

- `original_data/raw/<year>/`: crawled PDFs, HTML, JSON, XLSX, and raw SQL.
- `original_data/processed/<year>/`: CSV/SQL generated from raw files.
- `db/seeds/`: durable seed SQL used for rebuilds.
- `db/patches/`: transactional fixes and imports.

Common target tables:

- `ref_school`: high school/admissions item reference data.
- `ref_middle_school`: middle school reference data.
- `ref_quota_allocation_district`: 名额分配到区计划.
- `ref_quota_allocation_school`: 名额分配到校计划.
- `ref_quota_unified_allocation_district`: 统一招生分区计划.
- `ref_admission_plan_summary`: per-school plan summary.
- `ref_admission_score_*`: historical cutoff scores.
- `ref_autonomous_admission_plan`, `ref_autonomous_admission_scheme`, `ref_international_course_plan`, `ref_private_international_admission_scheme`: 2026+ reference tables for published autonomous/international plan artifacts when present.

## Source Inspection And Parsing

Do not use universal extraction scripts as the import authority. Shanghai admissions sources come from different districts and systems; PDF layouts, HTML DOMs, XLSX sheets, CSV delimiters, JSON key paths, raw SQL target tables, encodings, merged cells, watermarks, and OCR artifacts vary enough that reusable parsers will silently corrupt data.

Use this sequence instead:

1. Inspect the actual source with LLM-readable evidence:

```bash
pdftotext -layout -f 1 -l 3 path/to/file.pdf -
python - <<'PY'
from pathlib import Path
print(Path('path/to/file.csv').read_text(encoding='utf-8', errors='replace')[:2000])
PY
```

For scanned/visual PDFs, render sample pages or use screenshots/PDF page views. For HTML, inspect relevant DOM/table fragments. For XLSX, inspect workbook sheet names, dimensions, merged cells, and first rows. For JSON, inspect key structure and representative records. For SQL, inspect target table, columns, conflict keys, and whether IDs are stale.

2. Decide the extraction strategy:

- Small/simple source: let the LLM structure it directly, then manually cross-check.
- Repeated machine-readable layout: generate a **source-specific parser** for that exact family/year/district/source type.
- Scanned/OCR-heavy or malformed source: use OCR/repair only with explicit row-level verification, or stop and report that manual review is needed.

3. Use `scripts/probe_pdf_tables.py` only as a diagnostic probe:

```bash
python skills/import-highschool-data/scripts/probe_pdf_tables.py \
  path/to/file.pdf \
  --out /tmp/probe.csv \
  --first-column-digits
```

The probe output can reveal table boundaries, but it is not final data. For non-PDF sources, ad hoc shell/Python snippets may reveal headers and records, but their output is also only diagnostic until a source-specific parser and validation are in place.

4. Validate before writing SQL:

- Compare extracted row count against the source.
- Compare published totals such as `合计`, `计划数`, or per-district totals.
- Verify first row, last row, and at least one row at each page/sheet/group boundary.
- Verify all `school_code` values preserve leading zeros.
- Query live DB to confirm every code/name maps to the intended `school_id`.

Keep source-specific parsers in `/tmp` while exploring. If the parser becomes part of a reproducible import path, save it under a clear project path such as `scripts/import_<year>_<source>.py` or document the generated CSV/SQL under `original_data/processed/<year>/`.

## ID Mapping

Use live DB mapping as source of truth:

```sql
SELECT id, code, full_name, district_id, is_active
FROM ref_school
WHERE code IN (...);

SELECT id, name, district_id, is_active
FROM ref_middle_school
WHERE name IN (...);
```

When mapping by school name, confirm code and district. Names change; codes and live IDs are more reliable.

## Patch Shape

Use this shape for remote DB changes:

```sql
BEGIN;

CREATE TABLE IF NOT EXISTS backup_<scope>_<yyyymmdd> AS
SELECT * FROM target_table WHERE ...;

WITH src(...) AS (
VALUES
  (...)
)
INSERT INTO target_table (...)
SELECT ...
FROM src
JOIN ref_school s ON s.code = src.school_code
ON CONFLICT (...) DO UPDATE SET ...;

DO $$
DECLARE
  v_count integer;
BEGIN
  SELECT COUNT(*) INTO v_count FROM ... WHERE ...;
  IF v_count <> 0 THEN
    RAISE EXCEPTION 'validation failed: %', v_count;
  END IF;
END $$;

COMMIT;
```

For remote writes:

- Run read-only checks first.
- Ask for escalation/approval when network or write access requires it.
- Execute a single transaction with `-v ON_ERROR_STOP=1`.
- Re-run all checks after `COMMIT`.

## Local Sync

After remote success:

- Add or update a patch under `db/patches/`.
- Update stale seed SQL when a rebuild would reintroduce the issue.
- Keep generated processed SQL in `original_data/processed/<year>/` aligned when it was the import source.
- Run `git diff --check`.

Do not commit credentials, dumps, or one-off scratch files.
