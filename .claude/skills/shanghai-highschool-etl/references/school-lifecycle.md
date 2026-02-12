# School Lifecycle Management

## School Changes Over Time

Shanghai schools are NOT static. Every year brings changes:

### New Schools (新建学校)

New schools open due to:
- Population growth in new districts
- Educational policy changes
- School restructuring/splitting

**Examples**:
- 2024-2025: Multiple new high schools in Pudong, Minhang
- New "experimental" schools (实验学校)
- Branch campuses of famous schools

### School Mergers/Closures (合并/关停)

Schools may:
- Merge into larger schools
- Close due to low enrollment
- Change grade levels (high school → middle school only)

### Information Changes

- **School codes change** - Especially for new schools
- **Names change** - Rebranding, affiliation changes
- **District assignment changes** - Administrative boundary changes

## Discovery Strategy

### Primary Source: Quota-to-School Files

**Why**: The 16 district "quota allocation to school" (名额分配到校) PDFs contain:

- All middle schools receiving quotas
- High school - middle school pairings
- District-by-district coverage

**Process**:
```python
# 1. Extract from all 16 district PDFs
district_files = [
    "raw/2025/quota_school/黄浦区.pdf",
    "raw/2025/quota_school/徐汇区.pdf",
    # ... all 16 districts
]

# 2. Parse each file
for district_file in district_files:
    middle_schools = extract_middle_schools(district_file)
    all_middle_schools.update(middle_schools)

# 3. Compare with existing database
new_schools = find_new_schools(all_middle_schools, existing_db)
```

### Secondary Sources

| Source | For | Reliability |
|---------|------|-------------|
| District education bureau websites | Verifying new school details | High |
| School official WeChat accounts | News about openings/closings | Medium |
| Shanghai Education Commission | Official announcements | High |
| News reports | Early notice of planned schools | Low |

## Database Update Pattern

### Yearly School Data Refresh

```sql
-- Step 1: Deactivate all schools for new year
UPDATE ref_school SET is_active = FALSE WHERE data_year = 2024;

-- Step 2: Reactivate schools appearing in 2025 data
UPDATE ref_school SET is_active = TRUE
WHERE code IN (
    -- List of school codes from 2025 data
) AND data_year = 2025;

-- Step 3: Insert new schools (not yet in database)
INSERT INTO ref_school (code, full_name, district_id, ...) VALUES
    ('NEW001', '上海市某某中学', (SELECT id FROM ref_district WHERE code = 'PD'), ...)
ON CONFLICT (code) DO UPDATE SET
    is_active = TRUE,
    data_year = 2025;
```

### School Status Tracking

```sql
-- A school exists in multiple years with different status
-- Example: School opened in 2024
Year 2023: Not present (school didn't exist)
Year 2024: is_active = TRUE (opening year)
Year 2025: is_active = TRUE (normal operation)
```

## New School Indicators

When parsing quota-to-school data, these patterns suggest NEW schools:

1. **Unknown school name** - Not in existing database
2. **New school code** - Code format suggests new assignment
3. **Experimental school naming** - "某某实验学校"
4. **Branch campus naming** - "某某中学XX校区"
5. **Year in school name** - "某某中学(2024年新建)"

## Validation Checklist

When discovering new schools:

- [ ] School name is complete (no OCR errors)
- [ ] District is correctly identified
- [ ] School level is correct (HIGH / MIDDLE)
- [ ] School code follows official format
- [ ] Not a duplicate with slightly different name
- [ ] Cross-reference with district education bureau if unsure

## Python Implementation Example

```python
#!/usr/bin/env python3
"""
Discover and update schools from quota-to-school data
"""

import csv
import psycopg2
from pathlib import Path

def load_existing_schools(conn):
    """Load all existing schools from database"""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT code, full_name, level, is_active, data_year
            FROM ref_school
            ORDER BY full_name
        """)
        return {row['code']: row for row in cur.fetchall()}

def discover_new_schools(quota_csv, existing_schools):
    """Find schools in quota data that aren't in database"""
    new_schools = []

    with open(quota_csv) as f:
        reader = csv.DictReader(f)
        for row in reader:
            middle_name = row['初中学校']
            district = row['区名称']

            # Skip if already exists
            if any(s['full_name'] == middle_name for s in existing_schools.values()):
                continue

            # Extract district code
            district_code = normalize_district(district)

            # Generate provisional code (will be updated when official data available)
            provisional_code = f"{district_code}_{len(new_schools):04d}"

            new_schools.append({
                'code': provisional_code,
                'full_name': middle_name,
                'district_code': district_code,
                'level': 'MIDDLE',
                'is_active': True,
                'data_year': 2025,
                'source': 'discovered_from_quota_school'
            })

    return new_schools

def generate_new_schools_sql(new_schools, output_file):
    """Generate SQL for new school inserts"""
    with open(output_file, 'w') as f:
        for school in new_schools:
            f.write(f"""
-- New school discovered: {school['full_name']}
INSERT INTO ref_school (code, full_name, district_id, school_level_id, is_active, data_year)
VALUES (
    '{school['code']}',
    '{school['full_name']}',
    (SELECT id FROM ref_district WHERE code = '{school['district_code']}'),
    (SELECT id FROM ref_school_level WHERE code = 'MIDDLE'),
    TRUE,
    2025
)
ON CONFLICT (full_name, district_id) DO UPDATE SET
    is_active = TRUE,
    data_year = 2025,
    updated_at = CURRENT_TIMESTAMP;
""")

if __name__ == '__main__':
    conn = psycopg2.connect("dbname=highschool user=highschool")
    existing = load_existing_schools(conn)

    quota_files = Path('processed/2025/quota_school/').glob('*.csv')
    all_new = []

    for quota_file in quota_files:
        new = discover_new_schools(quota_file, existing)
        all_new.extend(new)

    if all_new:
        print(f"Discovered {len(all_new)} new schools")
        generate_new_schools_sql(all_new, 'db/seeds/XXX_seed_new_schools_2025.sql')
    else:
        print("No new schools discovered")
```

## Common Issues

### Duplicate School Names

Same school with slight name variations:
- "上海市格致中学" vs "格致中学"
- "上海市上海中学" vs "上海中学"

**Solution**: Use fuzzy matching and manual verification

### District Ambiguity

Some schools serve multiple districts:
- City-wide schools (四大名校)
- Schools near district borders

**Solution**: Check official school affiliation documents

### School Level Changes

School may change from middle to high school (or add levels):
- New high schools expanding to include middle school grades
- Middle schools adding high school division

**Solution**: Track school_level separately, allow multiple levels per school
