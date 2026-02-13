# School Lifecycle Management

## School Changes Over Time

Shanghai schools are NOT static. Every year brings changes:

### New Schools (新建学校)

New schools open due to:
- Population growth in new districts
- Educational policy changes
- School restructuring/splitting

### School Mergers/Closures (合并/关闭)

Schools may:
- Merge into larger schools
- Close due to low enrollment

### Information Changes

- **School codes change** - Especially for new schools
- **Names change** - Rebranding, affiliation changes
- **District assignment changes** - Administrative boundary changes

## Examples

### 2024-2025 New Schools (根据用户反馈)

**Important Discovery**: Three specific middle schools in Jiading District:

| School Name | 2024 Code | 2025 Status | Note |
|-------------|-------------|-------------|------|
| 交大附中附属嘉定德富中学 | JD0015 | 继续存在 | 两所不同学校之一 |
| 交大附中附属嘉定洪德中学 | (新增) | 2025新增 | 两所不同学校之二（用户确认：真实存在）|
| 上海师范大学附属中学嘉定新城分校 | (可能是JD0018) | 已在数据库中 | 高中，非初中 |

**Key Insight**: These schools demonstrate the need for careful cross-referencing between:
- Quota-to-school data (名额分配到校) - Shows middle schools receiving quotas
- Quota-to-district data (名额分配到区) - Shows high schools with quotas
- School reference database - Should contain all active schools

### Historical Example

**2024 New High Schools:**
- 上海市上海中学东校 (浦东新区) - New campus of Shanghai High
- 华东师范大学第二附属中学闵行紫竹分校
- 华东师范大学第二附属中学松江分校

**2024 Name Changes:**
- "上海交通大学附属中学闵行分校" → "上海交通大学附属闵行实验中学"

## Discovery Strategy

### Primary Source: Quota-to-School Files (名额分配到校)

**Why**: The 16 district "quota allocation to school" PDFs contain:
- All middle schools in the district receiving quotas
- Which high schools they can apply to
- Complete coverage of middle school landscape

**Process**:```
1. Convert all 16 district PDFs → Markdown (using MarkItDown)
2. Parse each district's markdown → Extract middle schools and quota allocations
3. Compare with existing database → Discover new schools
4. Generate SQL for new schools and quota data
```

### Secondary Source: District Education Bureau Websites

**When to use**:
- Verify school details (official name, code, level)
- Confirm new schools not listed elsewhere
- Check for school status (opening/closing notices)

## New School Indicators

When parsing quota-to-school data, these patterns suggest NEW schools:

1. **Unknown school code** - Not in existing database
2. **Unknown school name** - Name pattern not seen before
3. **Experimental naming** - "某某实验学校", "某某外国语学校"
4. **Branch campus** - "某某中学XX校区"
5. **New code pattern** - District code + sequential number (e.g., PD001, PD002)

## Validation Checklist

When discovering new schools from quota-to-school data:

- [ ] School name is complete (no truncation by line breaks)
- [ ] School code follows official format (6 digits)
- [ ] District is correctly identified
- [ ] School level is correct (HIGH/MIDDLE)
- [ ] Cross-reference with district education bureau if uncertain
- [ ] Not a duplicate with slight name variation

## School Level Tracking

Schools can have multiple levels over time:
- **HIGH** (高中) - e.g., 上海市上海中学
- **MIDDLE** (初中) - e.g., 上海市文来中学
- **COMBINED** (完全中学) - Contains both levels
- **VOCATIONAL** (中职) - Not in Zhongkao admission system

**Database Schema**:
```sql
ref_school (
    code VARCHAR(20),
    full_name VARCHAR(200),
    school_level_id VARCHAR(50),  -- 'HIGH', 'MIDDLE', 'COMBINED'
    ...
)

ref_middle_school (
    code VARCHAR(20),
    name VARCHAR(200),
    level VARCHAR(50),  -- 'MIDDLE'
    ...
)
```

## Handling School Changes

### Year-Over-Year Data

Schools exist across multiple years with `data_year` field:
```sql
-- 2024 data
SELECT * FROM ref_school WHERE data_year = 2024;

-- 2025 data
SELECT * FROM ref_school WHERE data_year = 2025;
```

### Status Management

When a school appears in quota data but not in previous year:
- **New school** → Set `is_active = TRUE` for current year
- **Verify** → Check if it's truly new or just missing from 2024 data

When a school from 2024 does NOT appear in 2025 data:
- **Possible closure** → Set `is_active = FALSE` for 2025
- **Investigate** → Check for merger or name change

## Special Cases

### 交大附中附属嘉定洪德中学 / 德富中学

**Status**: Two separate schools (用户确认：两所不同的真实学校)
- 2024: 交大附中附属嘉定德富中学 (JD0015)
- 2025: 交大附中附属嘉定洪德中学 (新学校)

**Important**: These are TWO DIFFERENT, REAL middle schools. NOT an OCR error or name variation.

### 上海师范大学附属中学嘉定新城分校

**Status**: ✅ Already in 2025 school database
- Located in `db/seeds/002_seed_schools_2025_full.sql`
- Code likely: JD0018 or similar

## Incremental Script Strategy (核心原则)

**DON'T** use unified scripts for all data.

**DO** create specialized scripts for each data batch:

```
scripts/
├── extract_2025_quota_to_school_jingan.py      # 静安区专用
├── extract_2025_quota_to_school_minhang.py     # 闵行区专用
├── extract_2025_quota_to_school_qingpu.py      # 青浦区专用
├── extract_2025_quota_to_school_jiading.py      # 嘉定区专用
├── extract_2025_quota_to_school_huangpu.py     # 黄浦区专用
├── extract_2025_quota_to_school_songjiang.py   # 松江区专用
├── ... (one per district as needed)
```

### Benefits of Specialized Scripts

1. **Format-Specific Parsing** - Each script handles its district's unique format
2. **Easy Debugging** - Issues isolated to one district/script
3. **Incremental Updates** - Update one district without reprocessing others
4. **Clear Documentation** - Each script documents its specific format

## District Format Variations (已发现的格式)

| District | Format Type | Key Characteristics | Script Pattern |
|----------|-------------|---------------------|---------------|
| 闵行 | 列式 | 初中列表 + 高中代码(列) | extract_minhang_style.py |
| 青浦 | 表格式 | 高中代码\|高中名称\|初中代码\|初中名称\|计划数 | extract_qingpu_table.py |
| 嘉定 | 两段式 | 初中学校表 + 分配表 | extract_jiading_twopart.py |
| 静安 | 现有格式 | 已由etl_2025_quota_to_school_from_md.py处理 | extract_jingan_existing.py |
| 其他区 | 待确认 | 需要检查具体格式 | to_be_determined.py |

## Common Parsing Issues

### Issue 1: School Name Split Across Lines

**Problem**: "上海师范大学附属中学嘉定新城分校" becomes:
```
上海师范大学附属中
学嘉定新城分校
```

**Solution**: Join lines intelligently:
```python
# Detect if line ends with partial name
if line.endswith(('附属', '附属中', '分校', '实验')):
    # Might be continuation
    # Merge with next non-empty line
```

### Issue 2: OCR Variations

**Problem**: Same school has different names in different files due to OCR errors or name changes.

**Solution**: Create canonical name mapping to consolidate variations:
```python
SCHOOL_NAME_VARIATIONS = {
    # Example: OCR might split school names across lines
    '上海师范大学附属中': '上海师范大学附属中学',
    '学嘉定新城分校': '上海师范大学附属中学嘉定新城分校',
}
```

**Important Note**: When schools appear to be variations, verify with user or official sources. DO NOT assume they are the same school without confirmation.
- Example: "交大附中附属嘉定洪德中学" and "交大附中附属嘉定德富中学" are TWO DIFFERENT schools (user confirmed)
- Always verify before consolidating school names

### Issue 3: Missing Data Segments

**Problem**: Some PDFs have missing pages or sections

**Detection**:
- Row counts don't match expected
- Known schools missing from output
- Sudden end of data mid-table

**Solution**:
```python
# Log warnings for suspicious patterns
if len(records) < expected_count:
    print(f"⚠ Warning: Only {len(records)} records extracted, expected {expected_count}")
```

## Best Practices

### 1. Format Detection (自动检测格式)

```python
def detect_format(lines):
    # Check for format markers
    if '委属名额' in '\n'.join(lines[:100]):
        return 'SONGJIANG_TABLE'  # 松江格式
    elif '初中学校信息' in '\n'.join(lines[:100]):
        return 'MINHANG_COLUMN'  # 闵行格式
    elif '招生学校代码' in '\n'.join(lines[:50]):
        return 'QINGPU_TABLE'  # 青浦格式
    elif '分配到初中学校的招生学校' in '\n'.join(lines[:100]):
        return 'JIADING_TWO_PART'  # 嘉定格式
    else:
        return 'UNKNOWN'
```

### 2. Data Validation (数据验证)

```python
def validate_middle_school(code, name, district):
    # Check format
    if not re.match(r'^\d{6}$', code):
        return False, "Invalid code format"

    # Check name completeness
    if not name or len(name) < 5:
        return False, "Name too short"

    # Check district match
    expected_district = get_district_from_name(name)
    if district != expected_district:
        return False, f"District mismatch: {district} != {expected_district}"

    return True, "Valid"

# Usage in main parser
for record in records:
    is_valid, message = validate_middle_school(
        record['code'],
        record['name'],
        record['district']
    )
    if not is_valid:
        print(f"⚠ Validation failed: {record['name']} - {message}")
```

### 3. Cross-Reference Checking (交叉验证)

```python
def cross_reference_with_existing(new_schools, existing_db):
    """Find truly new schools"""
    existing_set = {(s['code'], s['name']) for s in existing_db}

    new_schools_list = []
    for new_school in new_schools:
        key = (new_school['code'], new_school['name'])
        if key not in existing_set:
            # Check for similar names (fuzzy match)
            similar = find_similar_schools(new_school['name'], existing_db)
            if similar:
                print(f"⚠ Similar school found: {new_school['name']} ≈ {similar}")
                # May be name variation or duplicate
            else:
                new_schools_list.append(new_school)

    return new_schools_list
```

### 4. Progressive Parsing (渐进式解析)

When dealing with complex formats, parse in stages:

```python
def parse_progressively(md_file):
    # Stage 1: Extract middle schools (always succeed)
    middle_schools = extract_middle_schools(md_file)
    print(f"Stage 1: Found {len(middle_schools)} middle schools")

    # Stage 2: Extract quota allocations (may fail partially)
    try:
        allocations = extract_quota_allocations(md_file)
        print(f"Stage 2: Extracted {len(allocations)} quota records")
    except Exception as e:
        print(f"Stage 2: Partial failure - {e}")
        allocations = []

    # Stage 3: Validate and merge
    validated = validate_and_merge(middle_schools, allocations)
    print(f"Stage 3: Validated {len(validated)} complete records")

    return middle_schools, validated
```

## Script Template (脚本模板)

```python
#!/usr/bin/env python3
"""
ETL脚本：提取{YEAR}年{DISTRICT}名额分配到校数据

Step 1: Extract (markdown → CSV)

专门处理{DISTRICT}区的特定格式。
基于对原始markdown的分析，该区使用{FORMAT_TYPE}格式。

Author: Claude
Date: {DATE}
"""

import csv
import os
import re
from pathlib import Path

# ============================================================================
# 配置
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DIR = os.path.join(BASE_DIR, "raw", "{YEAR}", "quota_district")
MD_DIR = os.path.join(RAW_DIR, "markdown")
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "{YEAR}", "quota_school")
SEEDS_DIR = os.path.join(BASE_DIR, "..", "db", "seeds")

# 区县代码映射
DISTRICT_MAP = {{
    '{DISTRICT_CHINESE}': '{DISTRICT_CODE}',
}}

Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)

# ============================================================================
# {DISTRICT}区特定解析函数
# ============================================================================

def parse_{DISTRICT}_format(lines, filename):
    """
    解析{DISTRICT}区格式

    格式说明：
    {FORMAT_DESCRIPTION}
    """
    # TODO: Implement format-specific parsing logic
    pass


def main():
    print("=" * 60)
    print("{YEAR}年{DISTRICT}名额分配到校数据提取")
    print("=" * 60)

    md_file = os.path.join(MD_DIR, "{INPUT_FILENAME}")

    if not os.path.exists(md_file):
        print(f"错误：文件不存在 - {{md_file}}")
        return

    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.split('\n')

    # 提取数据
    records = parse_{DISTRICT}_format(lines, os.path.basename(md_file))

    # 保存结果
    if records:
        output_file = os.path.join(PROCESSED_DIR, "{OUTPUT_FILENAME}")
        with open(output_file, 'w', encoding='utf-8', newline='') as f:
            # TODO: Write CSV output
            pass

        print(f"\n输出: {{output_file}}")
        print(f"总记录数: {{len(records)}}")
    else:
        print("未提取到任何数据")


if __name__ == '__main__':
    main()
```

## District-Specific Scripts (按区定制的脚本)

Based on format analysis, create one script per district:

```bash
scripts/
├── extract_2025_quota_to_school_jingan.py      # 静安区 (已有)
├── extract_2025_quota_to_school_minhang.py     # 闵行区 (需要创建)
├── extract_2025_quota_to_school_qingpu.py      # 青浦区 (需要创建)
├── extract_2025_quota_to_school_jiading.py      # 嘉定区 (需要创建)
├── extract_2025_quota_to_school_huangpu.py     # 黄浦区 (需要创建)
├── extract_2025_quota_to_school_songjiang.py   # 松江区 (需要创建)
├── extract_2025_quota_to_school_xuhui.py      # 徐汇区 (需要创建)
├── extract_2025_quota_to_school_cn.py         # 长宁区 (需要创建)
├── extract_2025_quota_to_school_putuo.py     # 普陀区 (需要创建)
├── extract_2025_quota_to_school_hongkou.py     # 虹口区 (需要创建)
├── extract_2025_quota_to_school_yangpu.py      # 杨浦区 (需要创建)
├── extract_2025_quota_to_school_baoshan.py     # 宝山区 (需要创建)
├── extract_2025_quota_to_school_jiading.py      # 嘉定区 (需要创建)
├── extract_2025_quota_to_school_pudong.py      # 浦东新区 (需要创建)
├── extract_2025_quota_to_school_jinshan.py     # 金山区 (需要创建)
├── extract_2025_quota_to_school_songjiang.py   # 松江区 (需要创建)
├── extract_2025_quota_to_school_qingpu.py      # 青浦区 (需要创建)
├── extract_2025_quota_to_school_fengxian.py    # 奉贤区 (需要创建)
├── extract_2025_quota_to_school_chongming.py   # 崇明区 (需要创建)
```

## Quality Assurance (质量保证)

### Before Running Scripts
1. Verify markdown file exists and is not empty
2. Check expected row counts based on source PDF
3. Test with sample data first

### After Running Scripts
1. Check CSV output row count
2. Verify middle schools discovered vs expected
3. Check specific schools mentioned in requirements

### Known Data Quality Issues by District

| District | Issue | Severity | Workaround |
|-----------|--------|------------|-------------|
| 静安 | OCR "院"字符 | 已处理 | etl_2025_cutoff_scores.py |
| 闵行 | 列式数据，需逐列解析 | 中等 | 创建专用脚本 |
| 嘉定 | 两段式，学校名称可能跨行 | 高 | 创建专用脚本 |
| 青浦 | 表格式，5列结构 | 中等 | 已有基础解析 |
| 黄浦 | 两段式，类似嘉定 | 高 | 需创建专用脚本 |

## Update Process (更新skill流程)

When updating the shanghai-highschool-etl skill:

1. Add new format discoveries to `references/school-lifecycle.md`
2. Create example scripts for different format types
3. Update best practices section
4. Document specific district requirements
5. Track validation checklist improvements

## Summary (总结)

**Key Principle**: Incremental, specialized scripts over monolithic solutions.

**每个数据源文件都应该有专门的解析脚本**，因为：
- 格式变化（每年都可能不同）
- 易于调试和更新
- 可以独立测试和验证
- 文档清晰

This approach ensures:
- ✅ 所有16个区的数据都能正确处理
- ✅ 新学校能被准确发现
- ✅ 数据质量问题能快速定位到特定区/文件
- ✅ 符合用户要求的"为每个源数据定制专门的解析脚本"
