# SQL Generation Patterns

## Standard INSERT with ON CONFLICT

The idempotent pattern for all seed files:

```sql
-- Table: ref_school
-- Source: processed/2025/schools/2025年学校信息.csv
-- Generated: 2025-02-12

INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES
    ('042032', '上海市上海中学',
     (SELECT id FROM ref_district WHERE code = 'SH'),
     (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC'),
     (SELECT id FROM ref_school_type WHERE code = 'GENERAL'),
     (SELECT id FROM ref_boarding_type WHERE code = 'NONE'),
     FALSE, 2025, TRUE)
ON CONFLICT (code) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    short_name = EXCLUDED.short_name,
    district_id = EXCLUDED.district_id,
    school_nature_id = EXCLUDED.school_nature_id,
    school_type_id = EXCLUDED.school_type_id,
    boarding_type_id = EXCLUDED.boarding_type_id,
    has_international_course = EXCLUDED.has_international_course,
    data_year = EXCLUDED.data_year,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;
```

## Foreign Key Lookups

### District

```sql
-- For school data: district comes from ref_district table
district_id = (SELECT id FROM ref_district WHERE code = 'XH')
```

### School Nature

```sql
-- Values: PUBLIC (公办), PRIVATE (民办)
school_nature_id = (SELECT id FROM ref_school_nature WHERE code = 'PUBLIC')
```

### School Type

```sql
-- Values: GENERAL (普通高中), VOCATIONAL (中职)
school_type_id = (SELECT id FROM ref_school_type WHERE code = 'GENERAL')
```

### Boarding Type

```sql
-- Values: NONE (无), FULL (全寄宿), PARTIAL (部分寄宿)
boarding_type_id = (SELECT id FROM ref_boarding_type WHERE code = 'NONE')
```

## Multi-Column Unique Constraints

For tables with composite keys:

```sql
-- quota_allocation_district has unique(school_id, district_id, year)
INSERT INTO quota_allocation_district (school_id, district_id, year, quota) VALUES
    ((SELECT id FROM ref_school WHERE code = '042032'),
     (SELECT id FROM ref_district WHERE code = 'HP'),
     2025, 10)
ON CONFLICT (school_id, district_id, year) DO UPDATE SET
    quota = EXCLUDED.quota,
    updated_at = CURRENT_TIMESTAMP;
```

## Batch Inserts

For multiple rows, use batch format:

```sql
INSERT INTO cutoff_scores (year, batch_type, district_id, school_id, score, is_tie_preferred) VALUES
    (2025, 'QUOTA_DISTRICT',
     (SELECT id FROM ref_district WHERE code = 'HP'),
     (SELECT id FROM ref_school WHERE code = '042032'),
     680.5, TRUE),
    (2025, 'QUOTA_DISTRICT',
     (SELECT id FROM ref_district WHERE code = 'XH'),
     (SELECT id FROM ref_school WHERE code = '042033'),
     685.0, FALSE);
```

## SQL File Header Template

```sql
-- ==========================================================================
-- [Descriptive Title]
-- ==========================================================================
-- Table: [table_name]
-- Source: [path to source CSV]
-- Data Year: [year]
-- Generated: [timestamp]
--
-- Description: [Brief description of what this data represents]
--
-- Primary Key: [primary_key_columns]
-- Unique Constraint: [unique_constraint_columns]
-- ==========================================================================

BEGIN;

-- [SQL statements here]

COMMIT;
```

## Python SQL Generation Template

```python
#!/usr/bin/env python3
"""Generate SQL seed file for [data_type]"""

import csv
import os
from datetime import datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SCRIPT_DIR)
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "[type]")
OUTPUT_FILE = os.path.join(BASE_DIR, "..", "db", "seeds", "XXX_seed_[type]_2025.sql")

def generate_sql():
    """Generate SQL from CSV"""

    header = f"""-- ==========================================================================
-- [Title] - 2025
-- ==========================================================================
-- Table: [table_name]
-- Source: original_data/processed/2025/[type]/[source_file].csv
-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
-- ==========================================================================

"""

    with open(INPUT_FILE, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            sql = format_sql_row(row)
            header += sql + "\n\n"

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(header)

    print(f"Generated: {OUTPUT_FILE}")
    print(f"Rows: {reader.line_num - 1}")

def format_sql_row(row):
    """Format a single row as SQL INSERT"""
    return f"""-- {row.get('school_name', '')}
INSERT INTO [table_name] (field1, field2, ...) VALUES
    ('{row['field1']}', '{row['field2']}', ...)
ON CONFLICT (unique_key) DO UPDATE SET
    field1 = EXCLUDED.field1,
    updated_at = CURRENT_TIMESTAMP;
"""

if __name__ == '__main__':
    generate_sql()
```

## Data Type Conversions

| CSV Type | SQL Type | Example |
|----------|----------|---------|
| String (UTF-8) | VARCHAR/TEXT | `'上海市格致中学'` |
| Integer | INTEGER | `750` |
| Decimal/Float | NUMERIC | `680.5` |
| Boolean | BOOLEAN | `TRUE` / `FALSE` |
| Code (lookup) | Subquery | `(SELECT id FROM ref_x WHERE code = 'XXX')` |

## Null Handling

```sql
-- For nullable fields
INSERT INTO ref_school (code, full_name, short_name) VALUES
    ('042032', '上海市上海中学', NULL);

-- Or use COALESCE in subqueries
district_id = COALESCE(
    (SELECT id FROM ref_district WHERE code = 'UNKNOWN'),
    (SELECT id FROM ref_district WHERE code = 'SH')  -- default
)
```
