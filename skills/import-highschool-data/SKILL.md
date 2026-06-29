---
name: import-highschool-data
description: Clean, normalize, validate, and import local Shanghai high school admissions data into PostgreSQL. Use when Codex needs to process this repo's original_data/raw or original_data/processed files, inspect raw sources such as PDF, HTML, XLSX, CSV, JSON, or SQL, generate source-specific parsers, map school_id or middle_school_id from the live/reference database, generate transactional SQL patches, update seed SQL, or audit remote DB associations, references, and logical constraints for quota allocation, admission plans, scores, autonomous admission, international course plans, or unified admission data.
---

# Import Highschool Data

## Overview

Use this skill to turn locally crawled admissions artifacts into reproducible SQL and verified database state. Treat the live/reference DB as the source of truth for IDs, and treat raw source files as the source of truth for published admissions facts.

## Core Workflow

1. **Scope the import.** List raw and processed files with `rg --files` or `find`, then decide the target table. Do not force a source into an existing table if the schema cannot represent it without losing facts.
2. **Read current schema and IDs.** Query `information_schema`, `pg_constraint`, `ref_school`, `ref_middle_school`, and affected business tables before generating SQL. Use remote `school_id` and `middle_school_id`; do not infer IDs from local stale seed files.
3. **Inspect and parse the source.** Do not trust generic scripts for raw sources. First inspect the actual file shape with LLM-readable evidence, identify the table/schema grammar, then either parse manually with LLM for small sources or generate a source-specific parser for that exact source family. Normalize district/school names, preserve published `school_code`, and record row counts/totals from the source.
4. **Generate SQL as patches.** Put durable SQL under `db/patches/`. Use `BEGIN`, backup tables, `INSERT ... ON CONFLICT`, `UPDATE ... FROM`, and `DO $$` assertions. Never embed database passwords.
5. **Validate before writes.** Run read-only mismatch queries first. For remote writes, request approval/escalation, execute one transaction, and fail closed with assertions.
6. **Verify after writes.** Re-run association, reference, count, and logical checks. Report exact row counts and remaining gaps.
7. **Sync local reproducibility.** Update seed SQL or processed SQL so a rebuild does not reintroduce fixed issues. Run `git diff --check`.

Read `references/workflow.md` when creating or reviewing an import plan. Use `references/audit_queries.sql` as a starting point for DB checks; adapt table names if the schema has evolved.

## Project Rules

- `ref_school.code` is the stable admissions code; `school_id` must match the live DB row for that code.
- `ref_quota_allocation_school.middle_school_id` must be non-null when the middle school exists, and its district must match `district_id`.
- For special招生代码 such as art-class codes, model a distinct admissions item when a table stores `school_code` and requires code-to-school consistency.
- In `ref_admission_plan_summary`, `autonomous_sports_count` and `autonomous_arts_count` are “其中” counts unless the source explicitly says otherwise; `total_plan_count` should close against `autonomous_count + quota_district_count + quota_school_count + unified_count`.
- Do not fabricate unreleased data. If raw data exists but there is no schema for it, create a focused reference table or report the gap instead of overloading another table.
- Treat scripts for raw-source parsing as probes or one-off generated parsers only. Reusable scripts may help inspect files or transform already-verified normalized CSV into SQL, but they are never sufficient evidence for import correctness.

## Tools

- `scripts/probe_pdf_tables.py`: best-effort PDF table probe for inspection only; do not use its output as final import data without a source-specific parser and independent validation.
- `scripts/csv_to_values.py`: convert already-verified normalized CSV rows into a SQL `VALUES` block for patch CTEs. Do not use it as a raw CSV parser or validator.
- `references/audit_queries.sql`: reusable SQL checks for known association and logical constraints.
