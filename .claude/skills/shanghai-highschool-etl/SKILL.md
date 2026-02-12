---
name: shanghai-highschool-etl
description: Shanghai high school admission data ETL pipeline. Use when working with Shanghai Zhongkao (中考) data. Handles PDF/Excel/CSV sources through MarkItDown/makeitdown conversion, extracts structured data, cleans and transforms it, then generates SQL seed files for PostgreSQL. Follows incremental script strategy - create specialized scripts for each data batch (e.g., etl_2025_quota_district.py, transform_2025_cutoff_scores.py).
---

# Shanghai High School ETL Pipeline

## Overview

ETL pipeline for Shanghai high school admission (Zhongkao) data. Processes raw documents (PDFs, Excel files, CSVs) into clean SQL seed files for the `highschool` project database.

**Base directory**: `original_data/` in project root

## Incremental Script Strategy

**Core principle**: Don't use a unified script to process all data.

**Rationale**:
- Data sources are diverse but **limited and fixed** (official PDFs, district notices)
- Only **incremental data** enters (by year: 2024 → 2025 → 2026...)
- Create **specialized scripts for each batch of incremental data**

**Benefits**:
- Simple, focused, easy to maintain
- Each script handles one specific data format
- Easy to debug and fix issues

**Examples**:
- `etl_2025_quota_district.py` - Handles 2025 quota-to-district PDF
- `etl_2025_cutoff_scores.py` - Handles 2025 cutoff scores CSV
- `extract_middle_schools.py` - Handles 2024 middle school data (16 districts)

## Data Types

| Type | Chinese | Source | Output Table |
|------|---------|--------|-------------|
| Cutoff scores | 录取分数线 | Official PDF/Excel | `cutoff_scores` |
| Quota by district | 名额分配到区 | Official PDF | `quota_allocation_district` |
| Quota by school | 名额分配到校 | District PDFs (16 files) | `quota_allocation_school` |
| School info | 学校信息 | Various sources | `ref_school` |
| District counts | 各区中考人数 | Statistics CSV | `district_exam_count` |

## ETL Workflow

```
0. Preprocess → 1. Extract → 2. Transform → 3. Load
   (makeitdown)      (parse MD)     (clean CSV)     (generate SQL)
```

### Step 0: Preprocess (makeitdown)

Convert non-text documents to markdown for easier parsing:

**Using Docker with MarkItDown**:
```bash
# Pull MarkItDown Docker image (official Microsoft tool)
docker pull adeuxy/markitdown:latest

# Convert PDF/Excel to markdown
docker run --rm -v "$(pwd)/data:/data" adeuxy/markitdown:latest "/data/input.pdf" > "/data/output.md"
```

**Image source**: `adeuxy/markitdown:latest` - [Docker Hub](https://hub.docker.com/r/adeuxy/markitdown)

**Why MarkItDown?** Official Microsoft tool for reliable document conversion

### Step 1: Extract (markdown → CSV)

Parse markdown files and extract structured data:

```python
# Create extraction script in original_data/scripts/
# Naming: etl_{year}_{data_type}.py

# Example: etl_2025_quota_district.py
import csv
import re
from pathlib import Path

def extract_from_markdown(md_file):
    """Parse markdown and extract data"""
    with open(md_file) as f:
        content = f.read()
    # Parse tables, extract fields...
    return parsed_data

def save_to_csv(data, output_file):
    """Save to CSV in processed/"""
    Path(output_file).parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=[...])
        writer.writeheader()
        writer.writerows(data)
```

**Output**: CSV files in `processed/{year}/{type}/`

### Step 2: Transform (clean/merge CSVs)

Clean data, standardize fields, merge multiple sources:

```python
# Transform script naming: transform_{year}_{type}.py

def clean_school_name(name):
    """Remove OCR errors, standardize naming"""
    # Remove common OCR artifacts
    name = re.sub(r'^院\s*', '', name)  # Remove "院" prefix
    name = re.sub(r'\s*院$', '', name)   # Remove "院" suffix
    return name.strip()

def normalize_district(name):
    """Standardize district names"""
    district_map = {
        '黄浦': 'Huangpu',
        '徐汇': 'Xuhui',
        # ... full mapping in references/districts.md
    }
    return district_map.get(name, name)

def merge_district_files(input_dir, output_file):
    """Merge 16 district files into one"""
    # Process each district's CSV
    # Standardize fields
    # Write combined output
```

**Output**: Clean, standardized CSV files in `processed/{year}/`

### Step 3: Load (CSV → SQL)

Generate SQL seed files from cleaned CSV:

```python
# Load script naming: generate_{year}_{type}_sql.py

def generate_sql_insert(csv_file, table_name):
    """Generate INSERT statements with ON CONFLICT"""
    sql = []
    sql.append(f"-- {table_name} from {csv_file}")
    sql.append(f"-- Generated: {datetime.now()}")

    for row in read_csv(csv_file):
        sql.append(f"""
INSERT INTO {table_name} (field1, field2, ...) VALUES
    ('{row["field1"]}', '{row["field2"]}', ...)
ON CONFLICT (unique_key) DO UPDATE SET
    field1 = EXCLUDED.field1,
    updated_at = CURRENT_TIMESTAMP;
""")

    return '\n'.join(sql)
```

**Output**: SQL files in `db/seeds/`

## Script Naming Conventions

```
scripts/
├── etl_{year}_{type}.py           # Step 1: Extract (markdown → CSV)
├── transform_{year}_{type}.py      # Step 2: Transform (clean/merge)
└── generate_{year}_{type}_sql.py   # Step 3: Load (CSV → SQL)
```

Examples:
- `etl_2025_quota_district.py` - Extract 2025 quota district data
- `transform_2025_cutoff_scores.py` - Clean 2025 cutoff scores
- `generate_2025_schools_sql.py` - Generate 2025 schools SQL

## School Data Management

### Annual School Changes

**Important**: Schools change every year in Shanghai!

- **New schools open** - New high schools and middle schools are established
- **Schools close** - Some schools may cease operations
- **School info updates** - Codes, names, or affiliations may change

### Discovering New Schools from Quota-to-School Data

The **quota allocation to school** (名额分配到校) data is the primary source for discovering new middle schools:

```python
def extract_and_discover_schools(quota_school_csv, existing_schools_db):
    """
    Extract quota-to-school data and discover new schools

    Returns: (quota_records, new_middle_schools)
    """
    quota_records = []
    new_middle_schools = set()
    existing_middle_names = {s['full_name'] for s in existing_schools_db if s['level'] == 'MIDDLE'}

    for row in read_csv(quota_school_csv):
        middle_name = row['初中学校']
        high_name = row['高中学校']

        # Discover new middle schools
        if middle_name and middle_name not in existing_middle_names:
            new_middle_schools.add({
                'full_name': middle_name,
                'district': row['区名称'],
                'level': 'MIDDLE',
                'discovered_from': 'quota_school_2025'
            })

        quota_records.append(row)

    return quota_records, list(new_middle_schools)
```

### School Data Sources Priority

When building school reference data, use this priority order:

1. **Quota-to-school PDFs** - Most reliable for middle schools (16 district files)
2. **Official admission plan PDFs** - High school info with codes
3. **Previous year's database** - Carry over existing schools, mark inactive if missing
4. **District education bureau websites** - For verifying new school details

### Handling School Status

Schools have a lifecycle status:

```sql
-- ref_school table has is_active field
is_active = TRUE   -- School appears in current year data
is_active = FALSE  -- School not in current year data (may have closed)
```

**Strategy**: When generating school SQL:
- Set `is_active = TRUE` for schools in current year data
- Set `is_active = FALSE` for schools from previous years that don't appear
- Always preserve historical records for cutoff score lookup

## Data Quality Checks

After each step, verify:

1. **Row counts match** - Compare source and output row counts
2. **No null keys** - Essential fields (school code, district) must not be null
3. **Reference validation** - School names match reference list
4. **New school discovery** - Check quota-to-school for unknown middle schools
5. **Sum verification** - District totals sum to city total
6. **No duplicates** - Check for duplicate primary keys

## Common OCR Issues

Shanghai official PDFs often have these OCR errors:

| Issue | Pattern | Fix |
|-------|---------|-----|
| "院" prefix | `院上海市格致中学` | Remove prefix |
| "院" suffix | `复旦中学 院` | Remove suffix |
| Standalone "院" | `院` alone | Cross-reference with other rows |
| Merged cells | `黄浦徐汇` (should be 2 rows) | Split by district |
| Table headers in body | `区名称` repeated | Skip header rows |

See `references/data-quality.md` for detailed patterns.

## Directory Structure

```
original_data/
├── raw/{year}/              # Source documents (immutable)
│   ├── policies/            # Official policy PDFs
│   ├── quota_district/       # Quota by district
│   └── quota_school/         # Quota by school (16 district files)
├── processed/{year}/         # ETL output (reproducible)
│   ├── cutoff_scores/        # Cleaned cutoff data
│   ├── quota_district/       # Cleaned quota district
│   └── quota_school/        # Cleaned quota school
└── scripts/                 # ETL scripts
    ├── etl_*.py             # Extract scripts
    ├── transform_*.py        # Transform scripts
    └── generate_*.py        # Load scripts
```

## References

- [references/districts.md](references/districts.md) - District code/name mappings
- [references/data-quality.md](references/data-quality.md) - Common data issues and fixes
- [references/sql-patterns.md](references/sql-patterns.md) - SQL generation templates
- [references/school-lifecycle.md](references/school-lifecycle.md) - **School change management and new school discovery**
- [references/quota-to-school-formats.md](references/quota-to-school-formats.md) - **Format analysis for quota-to-school files**
