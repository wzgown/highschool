# Data Quality Patterns

## Common OCR Errors from Official PDFs

### "院" Character Errors

The most common OCR artifact in Shanghai Zhongkao PDFs is the stray "院" (yuan) character.

| Pattern | Example | Fix |
|---------|---------|-----|
| Prefix | `院上海市格致中学` | Remove prefix: `上海市格致中学` |
| Suffix with space | `复旦中学 院` | Remove suffix: `复旦中学` |
| Suffix no space | `上海师范大学附属中学闵行分校院` | Remove suffix: `上海师范大学附属中学闵行分校` |
| Middle separator | `格致初级中学   院    上海市格致中学` | Replace with spaces: `格致初级中学    上海市格致中学` |
| Standalone | `院` | Cross-reference with adjacent rows |

### Python Fix Implementation

```python
import re

def clean_yuan_prefix_suffix(name):
    """
    清理"院"前缀和后缀
    返回 (清洗后名称, 是否为独立院)
    """
    name = name.strip()

    # 独立"院"
    if name == '院':
        return name, True

    # "院"作为前缀
    if name.startswith('院') and len(name) > 1:
        cleaned = name[1:].strip()
        return cleaned, False

    # "院"作为后缀（含空格）
    if name.endswith(' 院') or name.endswith('　院'):
        cleaned = name[:-2].strip()
        return cleaned, False

    # "院"作为后缀（无空格），但保留"学院"
    if name.endswith('院') and not name.endswith('学院'):
        cleaned = name[:-1].strip()
        return cleaned, False

    return name, False


def clean_yuan_in_text(text):
    """清理文本中的"院"OCR错误"""
    # "院" + 空格 + 学校名 的模式（在中间）
    text = re.sub(r'\s+院\s+', '    ', text)

    # "院" 在开头
    text = re.sub(r'^院\s+', '', text)

    # "院" 在结尾
    text = re.sub(r'\s*院$', '', text)

    return text.strip()
```

### School Name Standardization

High schools have full names and short names:

| Full Name | Short Name |
|-----------|------------|
| 上海市格致中学 | 格致中学 |
| 上海市大同中学 | 大同中学 |
| 上海市上海中学 | 上海中学 |

```python
def normalize_school_name(name, reference_list):
    """
    标准化学校名称

    1. Check if already in reference list
    2. Try adding "上海市" prefix
    3. Try removing "上海市" for short name match
    """
    if name in reference_list:
        return name

    # Add prefix
    with_prefix = f"上海市{name}"
    if with_prefix in reference_list:
        return with_prefix

    # Remove prefix for short name matching
    if name.startswith('上海市'):
        short = name[3:]
        # Return original as it's valid
        return name

    return name  # Return as-is if no match
```

## Table Parsing Issues

### Merged Cells

District PDFs often have merged cells showing multiple districts in one row:

```markdown
| 黄浦徐汇 | 100 | 200 |
```

Fix: Split by known district names:

```python
def split_merged_districts(cell_value):
    """Split merged district cell"""
    districts = []
    for district in DISTRICT_NAMES:
        if district in cell_value:
            districts.append(district)
    return districts if districts else [cell_value]
```

### Repeated Headers

Headers appear mid-document in multi-page tables:

```python
def is_header_row(row):
    """Check if row is a header"""
    header_indicators = ['区名称', '招生学校', '录取最低分', '计划区域']
    return any(indicator in str(row) for indicator in header_indicators)
```

## Schema/DDL Discovery Issues

### Table Structure Mismatches

**Critical**: Seed SQL scripts may reference columns that don't exist in the actual table schema. Always verify table structure before generating INSERT statements.

#### ref_district_exam_count

**Expected** (from seed script):
```sql
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_year, ...)
```

**Actual** (from migration 002_create_history_tables_v2.sql):
```sql
CREATE TABLE ref_district_exam_count (
    year INTEGER NOT NULL,
    district_id INTEGER NOT NULL,
    exam_count INTEGER NOT NULL,
    data_source VARCHAR(255),  -- NOT data_year!
    ...
);
```

**Issue**: Seed script uses `data_year` but table only has `year` field.

**Fix**: Remove `data_year` from INSERT statements:
```sql
-- WRONG
INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_year, ...)
SELECT 2025, district_id, 3788, 2025, ...

-- CORRECT
INSERT INTO ref_district_exam_count (year, district_id, exam_count, ...)
SELECT 2025, district_id, 3788, ...
```

#### ref_middle_school

**Expected** (from seed script):
```sql
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, ...)
```

**Actual** (from migration 002_create_history_tables_v2.sql):
```sql
CREATE TABLE ref_middle_school (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20),
    name VARCHAR(200) NOT NULL,
    short_name VARCHAR(100),
    district_id INTEGER NOT NULL,
    school_nature_id VARCHAR(50),  -- NOT school_level_id!
    is_non_selective BOOLEAN NOT NULL DEFAULT TRUE,
    data_year INTEGER NOT NULL DEFAULT 2025,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    ...
);
```

**Issue**: Seed script uses `school_level_id` but table only has `school_nature_id`.

**Fix**: Remove or correct the field name:
```sql
-- WRONG
INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, ...)
SELECT 'JD0016', '交大附中附属嘉定洪德中学', district_id, 'MIDDLE', TRUE, ...

-- CORRECT
INSERT INTO ref_middle_school (code, name, district_id, is_active, data_year, ...)
SELECT 'JD0016', '交大附中附属嘉定洪德中学', district_id, TRUE, 2025, ...
```

### How to Verify Table Structure

Before generating seed SQL, always check the actual schema:

```bash
# Check table structure
psql -h localhost -U username -d database -c "\d table_name"

# Or read the migration file
cat db/migrations/XXX_create_XXX_tables_v2.sql
```

### Pattern: Year vs data_year

Different tables use different conventions:

| Table | Year Field | Convention |
|--------|-------------|------------|
| ref_district_exam_count | `year` | Year is the primary dimension |
| ref_quota_allocation_district | `year` | Year is the primary dimension |
| ref_quota_allocation_school | `year` | Year is the primary dimension |
| ref_admission_score_quota_district | `year` | Year is the primary dimension |
| ref_school | `data_year` | Multi-year history support |
| ref_middle_school | `data_year` | Multi-year history support |
| ref_control_score | `data_year` | Multi-year history support |

**Rule**: If table has UNIQUE(code, data_year) constraint, it supports multi-year history and uses `data_year`. If table only has `year` without `data_year`, the year field is the primary dimension.



### After Extract
- [ ] Row count matches source (visible rows)
- [ ] No empty school codes
- [ ] District names are valid
- [ ] Numeric fields parsed correctly

### After Transform
- [ ] All "院" artifacts cleaned
- [ ] School names in reference list
- [ ] District codes standardized
- [ ] No duplicate primary keys
- [ ] Numeric fields (scores, quotas) are reasonable

### After Load
- [ ] SQL runs without errors
- [ ] Record count matches CSV
- [ ] ON CONFLICT working (re-run is safe)
- [ ] Foreign keys valid (schools, districts exist)

## Common Data Issues by Type

### Cutoff Scores
- Missing scores: check if school exists that year
- Negative scores: data entry error
- Scores > 750: validation error (max is 750)
- Same school multiple times in same district: dedupe by code

### Quota Allocation
- Quota values not summing correctly across districts
- District name variations (黄浦 vs 黄浦区)
- School code mismatch with reference table

### District Exam Counts
- Total not equal to sum of districts
- Year mismatch in filename vs data
- Encoding issues (BOM in CSV)
