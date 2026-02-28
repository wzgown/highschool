# 2025 ETL Pipeline Status

## Summary

This document tracks the ETL (Extract, Transform, Load) progress for 2025 Shanghai Zhongkao data.

## Completed Tasks

### 1. District Exam Count Data ✅
- **Source**: `raw/2025/2025_shanghai_district_exam_count.csv`
- **Output**: `db/seeds/009_seed_district_exam_count_2025.sql`
- **Status**: COMPLETE
- **Records**: 16 districts, 127,156 students total

### 2. Quota Allocation to District Data ✅
- **Source**: `processed/2025/quota_district/2025年名额分配到区招生计划.csv`
- **Output**: `db/seeds/010_seed_quota_allocation_district_2025.sql`
- **Status**: COMPLETE
- **Records**: 76 school-district pairs, 6,724 total quota

## In Progress / Manual Work Required

### 3. Quota Allocation to School Data ⚠️
- **Source**: 16 PDF files in `raw/2025/quota_district/`
- **Current Output**: `processed/2025/quota_school/2025年名额分配到校.csv`
- **Status**: PARTIAL (only Jing'an District data extracted)
- **Issue**: PDF to Markdown conversion produces poorly formatted tables (image-based PDFs)

**Files Converted to Markdown:**
- ✅ 2025年上海市高中名额分配到校招生计划（松江区）.md
- ✅ 2025年上海市高中名额分配到校招生计划（静安区）.md
- ✅ 2025年上海市高中阶段学校名额分配综合评价"名额分配到校"招生计划（闵行区）公示用.md
- ✅ 2025年黄浦区名额分配综合评价录取到校计划公示.md
- ✅ 松江区.md
- ✅ 闵行区.md
- ✅ 静安区.md
- ✅ 嘉定区名额分配到校.md
- ✅ 奉贤区名额分配到校.md
- ✅ 宝山区名额分配到校.md
- ✅ 崇明区名额分配到校.md
- ✅ 徐汇区名额分配到校.md
- ✅ 普陀区名额分配到校.md
- ✅ 杨浦区名额分配到校.md
- ✅ 浦东新区名额分配到校.md
- ✅ 金山区名额分配到校.md
- ✅ 长宁区名额分配到校.md
- ✅ 青浦区名额分配到校.md
- ✅ 黄浦区名额分配到校.md

**Problem**: The markdown files contain poorly formatted tables because the original PDFs are image-based. The MarkItDown tool cannot reliably extract table structure from these files.

**Recommendation**: Manual data entry or alternative OCR solution required for quota-to-school data.

## Files Generated

### ETL Scripts
- `scripts/etl_2025_district_exam_count.py` - District exam count ETL
- `scripts/etl_2025_quota_district.py` - Quota to district ETL
- `scripts/etl_2025_quota_school.py` - Quota to school ETL (partial)
- `scripts/convert_all_quota_to_school_pdfs.py` - PDF to Markdown converter
- `scripts/etl_2025_quota_school_all.py` - Multi-format parser (needs work)

### SQL Seed Files
- `db/seeds/009_seed_district_exam_count_2025.sql` ✅
- `db/seeds/010_seed_quota_allocation_district_2025.sql` ✅
- `db/seeds/035_seed_quota_allocation_school_2025.sql` ⚠️ (Jing'an only)
- `db/seeds/041_seed_middle_schools_2025.sql` ⚠️ (Jing'an only)

## Next Steps

1. **Manual Data Entry**: Manually extract quota-to-school data from the 16 PDF files
2. **Alternative OCR**: Try Tabula or similar tool for table extraction
3. **Data Verification**: Verify extracted data against original PDFs
4. **SQL Import**: Run generated SQL seed files to populate database

## Districts Processed

| District | Quota to District | Quota to School | Middle Schools |
|-----------|-------------------|-------------------|----------------|
| 黄浦 | ✅ | ⚠️ | ⚠️ |
| 徐汇 | ✅ | ⚠️ | ⚠️ |
| 长宁 | ✅ | ⚠️ | ⚠️ |
| 静安 | ✅ | ⚠️ (partial) | ⚠️ (37 schools) |
| 普陀 | ✅ | ⚠️ | ⚠️ |
| 虹口 | ✅ | ⚠️ | ⚠️ |
| 杨浦 | ✅ | ⚠️ | ⚠️ |
| 闵行 | ✅ | ⚠️ | ⚠️ |
| 宝山 | ✅ | ⚠️ | ⚠️ |
| 嘉定 | ✅ | ⚠️ | ⚠️ |
| 浦东 | ✅ | ⚠️ | ⚠️ |
| 金山 | ✅ | ⚠️ | ⚠️ |
| 松江 | ✅ | ⚠️ | ⚠️ |
| 青浦 | ✅ | ⚠️ | ⚠️ |
| 奉贤 | ✅ | ⚠️ | ⚠️ |
| 崇明 | ✅ | ⚠️ | ⚠️ |

## Technical Notes

### District Code Mapping
```python
DISTRICT_MAP = {
    '黄浦': 'HP',  '徐汇': 'XH',  '长宁': 'CN',  '静安': 'JA',
    '普陀': 'PT',  '虹口': 'HK',  '杨浦': 'YP',  '闵行': 'MH',
    '宝山': 'BS',  '嘉定': 'JD',  '浦东': 'PD',  '金山': 'JS',
    '松江': 'SJ',  '青浦': 'QP',  '奉贤': 'FX',  '崇明': 'CM',
}
```

### Database Schema
- `ref_district_exam_count` - District exam counts
- `ref_quota_allocation_district` - Quota allocation to district
- `ref_quota_allocation_school` - Quota allocation to school
- `ref_middle_school` - Middle school reference

### Data Quality Issues
1. OCR errors with "院" character in existing processed data
2. Inconsistent table formats across districts
3. Image-based PDFs not suitable for automated parsing
