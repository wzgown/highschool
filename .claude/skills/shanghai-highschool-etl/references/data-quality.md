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

## Data Validation Checklist

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
