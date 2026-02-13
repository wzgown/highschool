#!/usr/bin/env python3
"""
Comprehensive ETL script to process 名额分配到校 (quota allocation to school) data
Handles multiple CSV formats from different districts.

Usage:
    python scripts/etl_quota_allocation_school_v2.py
"""

import csv
import re
from pathlib import Path
from collections import defaultdict

# District code mapping
DISTRICT_CODES = {
    '黄浦区': 'HP',
    '徐汇区': 'XH',
    '长宁区': 'CN',
    '静安区': 'JA',
    '普陀区': 'PT',
    '虹口区': 'HK',
    '杨浦区': 'YP',
    '闵行区': 'MH',
    '宝山区': 'BS',
    '嘉定区': 'JD',
    '浦东新区': 'PD',
    '浦东区': 'PD',
    '金山区': 'JS',
    '松江区': 'SJ',
    '青浦区': 'QP',
    '奉贤区': 'FX',
    '崇明区': 'CM',
}

# High school code to short name mapping (common schools)
HIGH_SCHOOL_CODES = {
    '上海中学': '042032',
    '华二': '152003',
    '华东师范大学第二附属中学': '152003',
    '华二普陀': '152003PT',
    '交附': '102056',
    '上海交通大学附属中学': '102056',
    '复附': '102057',
    '复旦大学附属中学': '102057',
    '上师大': '152006',
    '上海师范大学附属中学': '152006',
    '格致': '012001',
    '格致奉贤': '012002',
    '大同': '012003',
    '向明': '012005',
    '向明浦江': '012006',
    '大境': '012007',
    '光明': '012008',
    '敬业': '012009',
    '卢高': '012010',
    '市西': '062001',
    '育才': '062002',
    '新中': '062003',
    '市北': '062004',
    '回民': '062011',
    '六十': '063004',
    '华模': '064001',
    '二中': '042001',
    '晋元': '042004',
    '宜川': '042007',
}

def extract_district_name(filename: str) -> str:
    """Extract district name from filename."""
    for district in DISTRICT_CODES.keys():
        if district in filename:
            return district
    return None

def extract_high_school_code(text: str) -> str:
    """Extract high school code from text (e.g., '格致 (012001)' -> '012001')"""
    match = re.search(r'\((\d{6})\)', text)
    if match:
        return match.group(1)
    # Try lookup by name
    for name, code in HIGH_SCHOOL_CODES.items():
        if name in text:
            return code
    return ''

def parse_format_1(content: str, district_code: str) -> list:
    """
    Format 1 (静安区 style):
    Middle school code in col 0, name in col 1, high school codes/names in header rows
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 4:
        return records

    # Find high school codes from header rows
    high_school_codes = []
    for row in rows[:5]:
        if not row:
            continue
        for i, cell in enumerate(row[2:], start=2):
            cell = cell.strip().strip('"')
            if cell and len(cell) == 6 and cell.isdigit():
                while i >= len(high_school_codes):
                    high_school_codes.append('')
                high_school_codes[i] = cell

    # Find data rows
    for row in rows:
        if not row or len(row) < 3:
            continue

        middle_code = row[0].strip().strip('"')
        middle_name = row[1].strip().strip('"') if len(row) > 1 else ''

        if middle_code and len(middle_code) == 6 and middle_code.isdigit():
            for i in range(2, len(row)):
                if i < len(row):
                    quota_str = row[i].strip().strip('"')
                    if quota_str and quota_str.isdigit():
                        quota_count = int(quota_str)
                        if quota_count > 0 and i < len(high_school_codes) and high_school_codes[i]:
                            records.append({
                                'middle_school_code': middle_code,
                                'middle_school_name': middle_name,
                                'high_school_code': high_school_codes[i],
                                'quota_count': quota_count,
                                'district_code': district_code,
                            })
    return records

def parse_format_2(content: str, district_code: str) -> list:
    """
    Format 2 (嘉定区 style):
    Middle school name in col 0, then groups of (code, name, quota)
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 2:
        return records

    for row in rows[1:]:  # Skip header
        if not row or len(row) < 4:
            continue

        middle_name = row[0].strip().strip('"')
        if not middle_name or '学校' not in middle_name and '中学' not in middle_name:
            continue

        # Parse groups of 3 columns: code, name, quota
        col = 1
        while col + 2 < len(row):
            hs_code = row[col].strip().strip('"')
            hs_name = row[col + 1].strip().strip('"') if col + 1 < len(row) else ''
            quota_str = row[col + 2].strip().strip('"') if col + 2 < len(row) else ''

            if hs_code and len(hs_code) == 6 and hs_code.isdigit():
                try:
                    quota_count = int(quota_str)
                    if quota_count > 0:
                        records.append({
                            'middle_school_code': '',  # No code in this format
                            'middle_school_name': middle_name,
                            'high_school_code': hs_code,
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
                except ValueError:
                    pass
            col += 3

    return records

def parse_format_3(content: str, district_code: str) -> list:
    """
    Format 3 (普陀区 style):
    Middle school code in col 0, name in col 1, quota columns with high school short names in header
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 3:
        return records

    # Extract high school codes from header row 2
    header_row = rows[1] if len(rows) > 1 else rows[0]
    high_school_codes = []

    for i, cell in enumerate(header_row[2:], start=2):
        cell = cell.strip().strip('"')
        # Extract code from text like '格致 (012001)'
        code = extract_high_school_code(cell)
        while i >= len(high_school_codes):
            high_school_codes.append('')
        high_school_codes[i] = code

    # Parse data rows
    for row in rows[2:]:
        if not row or len(row) < 3:
            continue

        middle_code = row[0].strip().strip('"')
        middle_name = row[1].strip().strip('"') if len(row) > 1 else ''

        if not middle_code or not (len(middle_code) == 5 or len(middle_code) == 6) or not middle_code.isdigit():
            continue

        for i in range(2, len(row)):
            if i < len(row) and i < len(high_school_codes):
                quota_str = row[i].strip().strip('"')
                if quota_str and quota_str.isdigit():
                    quota_count = int(quota_str)
                    if quota_count > 0 and high_school_codes[i]:
                        records.append({
                            'middle_school_code': middle_code,
                            'middle_school_name': middle_name,
                            'high_school_code': high_school_codes[i],
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
    return records

def parse_format_4(content: str, district_code: str) -> list:
    """
    Format 4 (黄浦区 style):
    '011001 格致初级中学' in col 0 (code + name combined), quotas with school names in header
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 2:
        return records

    # Extract high school codes from header
    header_row = rows[0]
    high_school_codes = []

    for i, cell in enumerate(header_row[1:], start=1):
        cell = cell.strip().strip('"')
        code = extract_high_school_code(cell)
        while i >= len(high_school_codes):
            high_school_codes.append('')
        high_school_codes[i] = code

    # Parse data rows
    for row in rows[1:]:
        if not row or len(row) < 2:
            continue

        # Parse "011001 格致初级中学" format
        first_col = row[0].strip().strip('"')
        match = re.match(r'^(\d{6})\s+(.+)$', first_col)
        if not match:
            continue

        middle_code = match.group(1)
        middle_name = match.group(2)

        for i in range(1, len(row)):
            if i < len(row) and i < len(high_school_codes):
                quota_str = row[i].strip().strip('"')
                if quota_str and quota_str.isdigit():
                    quota_count = int(quota_str)
                    if quota_count > 0 and high_school_codes[i]:
                        records.append({
                            'middle_school_code': middle_code,
                            'middle_school_name': middle_name,
                            'high_school_code': high_school_codes[i],
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
    return records

def parse_format_5(content: str, district_code: str) -> list:
    """
    Format 5 (宝山区 style):
    序号, 学校代码, 学校名称, high school names in header (no codes)
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 3:
        return records

    # Header row 0 has high school names, need to map to codes
    header_row = rows[0]
    high_school_codes = []

    # Create a mapping from names to codes
    name_to_code = {v: k for k, v in HIGH_SCHOOL_CODES.items()}

    for i, cell in enumerate(header_row[3:], start=3):
        cell = cell.strip().strip('"')
        code = ''
        # Try to find matching code
        for name, c in HIGH_SCHOOL_CODES.items():
            if name in cell or cell in name:
                code = c
                break
        while i >= len(high_school_codes):
            high_school_codes.append('')
        high_school_codes[i] = code

    # Parse data rows (starting from row 1)
    for row in rows[1:]:
        if not row or len(row) < 4:
            continue

        middle_code = row[1].strip().strip('"') if len(row) > 1 else ''
        middle_name = row[2].strip().strip('"') if len(row) > 2 else ''

        if not middle_code or not (len(middle_code) == 5 or len(middle_code) == 6) or not middle_code.isdigit():
            continue

        for i in range(3, len(row)):
            if i < len(row) and i < len(high_school_codes):
                quota_str = row[i].strip().strip('"')
                if quota_str and quota_str.isdigit():
                    quota_count = int(quota_str)
                    if quota_count > 0 and high_school_codes[i]:
                        records.append({
                            'middle_school_code': middle_code,
                            'middle_school_name': middle_name,
                            'high_school_code': high_school_codes[i],
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
    return records

def parse_format_6(content: str, district_code: str) -> list:
    """
    Format 6 (闵行区 style):
    Header spans multiple rows, codes embedded like '招生代码 122001'
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 5:
        return records

    # Find the row with '招生代码 XXXXXX' pattern
    code_row = None
    for row in rows[:5]:
        for cell in row:
            if '招生代码' in cell:
                code_row = row
                break
        if code_row:
            break

    if not code_row:
        return records

    # Extract codes from the code row
    high_school_codes = []
    for i, cell in enumerate(code_row):
        cell = cell.strip().strip('"')
        match = re.search(r'(\d{6})', cell)
        if match:
            while i >= len(high_school_codes):
                high_school_codes.append('')
            high_school_codes[i] = match.group(1)

    # Find data rows (start with 6-digit code)
    for row in rows:
        if not row or len(row) < 3:
            continue

        first = row[0].strip().strip('"')
        if not (len(first) == 6 and first.isdigit()):
            continue

        middle_code = first
        middle_name = row[1].strip().strip('"') if len(row) > 1 else ''

        for i in range(2, len(row)):
            if i < len(row) and i < len(high_school_codes):
                quota_str = row[i].strip().strip('"')
                if quota_str and quota_str.isdigit():
                    quota_count = int(quota_str)
                    if quota_count > 0 and high_school_codes[i]:
                        records.append({
                            'middle_school_code': middle_code,
                            'middle_school_name': middle_name,
                            'high_school_code': high_school_codes[i],
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
    return records

def parse_format_7(content: str, district_code: str) -> list:
    """
    Format 7 (松江区 style):
    Header has 委属名额, 区属名额数
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 4:
        return records

    # Header row 1 has high school names
    header_row = rows[1] if len(rows) > 1 else rows[0]
    high_school_codes = []

    # Find the high school codes/names from header
    for i, cell in enumerate(header_row[2:], start=2):
        cell = cell.strip().strip('"').replace('\n', '')
        code = ''
        for name, c in HIGH_SCHOOL_CODES.items():
            if name in cell or cell in name:
                code = c
                break
        while i >= len(high_school_codes):
            high_school_codes.append('')
        high_school_codes[i] = code

    # Also check 委属名额 column (column 2) for embedded school names
    # This column may contain names like "上海交通大学附属中学"
    weishu_col = 2  # Column index for 委属名额

    # Parse data rows
    for row in rows[2:]:
        if not row or len(row) < 4:
            continue

        middle_code = row[0].strip().strip('"')
        middle_name = row[1].strip().strip('"').replace('\n', '') if len(row) > 1 else ''

        if not middle_code or not (len(middle_code) == 5 or len(middle_code) == 6) or not middle_code.isdigit():
            continue

        # Process 委属名额 column (may have school name)
        if len(row) > weishu_col:
            weishu_val = row[weishu_col].strip().strip('"').replace('\n', '')
            if weishu_val and not weishu_val.isdigit() and '中学' in weishu_val:
                # Extract school name and quota
                # Format: "上海交通大学附属中学" - but no quota?
                pass

        # Process 区属名额 columns (starting from column 3)
        for i in range(3, len(row)):
            if i < len(row) and i < len(high_school_codes):
                quota_str = row[i].strip().strip('"').replace('\n', '')
                if quota_str and quota_str.isdigit():
                    quota_count = int(quota_str)
                    if quota_count > 0 and high_school_codes[i]:
                        records.append({
                            'middle_school_code': middle_code,
                            'middle_school_name': middle_name,
                            'high_school_code': high_school_codes[i],
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
    return records

def parse_format_8(content: str, district_code: str) -> list:
    """
    Format 8 (徐汇区 style):
    Header has codes in newlines like "042001\n市二中学"
    """
    records = []
    lines = content.split('\n')
    reader = csv.reader(lines)
    rows = list(reader)

    if len(rows) < 10:
        return records

    # Find all codes in the first 10 rows (they span multiple lines)
    high_school_codes = []
    current_col = 0

    # Process header rows to extract codes
    for row_idx, row in enumerate(rows[:11]):
        for col_idx, cell in enumerate(row[3:], start=3):
            cell = cell.strip().strip('"')
            # Check for 6-digit code
            match = re.search(r'(\d{6})', cell)
            if match:
                while col_idx >= len(high_school_codes):
                    high_school_codes.append('')
                high_school_codes[col_idx] = match.group(1)

    # Parse data rows (starting from row 11)
    for row in rows[11:]:
        if not row or len(row) < 4:
            continue

        # Row format: index, middle_school_code, middle_school_name, quotas...
        middle_code = row[1].strip().strip('"') if len(row) > 1 else ''
        middle_name = row[2].strip().strip('"') if len(row) > 2 else ''

        if not middle_code or not (len(middle_code) == 5 or len(middle_code) == 6) or not middle_code.isdigit():
            continue

        for i in range(3, len(row)):
            if i < len(row) and i < len(high_school_codes):
                quota_str = row[i].strip().strip('"')
                if quota_str and quota_str.isdigit():
                    quota_count = int(quota_str)
                    if quota_count > 0 and high_school_codes[i]:
                        records.append({
                            'middle_school_code': middle_code,
                            'middle_school_name': middle_name,
                            'high_school_code': high_school_codes[i],
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
    return records

def parse_format_9(content: str, district_code: str) -> list:
    """
    Format 9 (奉贤区 style):
    Long format - each row is one middle school + one high school combination
    序号, 初中学校代码, 初中学校名称, 招生学校代码, 学校名称, 所属区, 计划数
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 5:
        return records

    # Skip header rows (first 4 lines in this format)
    for row in rows[4:]:
        if not row or len(row) < 7:
            continue

        try:
            # Format: 序号, 初中学校代码, 初中学校名称, 招生学校代码, 学校名称, 所属区, 计划数
            seq = row[0].strip().strip('"')
            middle_code = row[1].strip().strip('"').replace('\n', '')
            middle_name = row[2].strip().strip('"').replace('\n', '')
            high_code = row[3].strip().strip('"').replace('\n', '')
            high_name = row[4].strip().strip('"').replace('\n', '')
            district = row[5].strip().strip('"').replace('\n', '')
            quota_str = row[6].strip().strip('"').replace('\n', '')

            if not seq.isdigit():
                continue

            if middle_code and len(middle_code) == 6 and middle_code.isdigit():
                if high_code and len(high_code) == 6 and high_code.isdigit():
                    try:
                        quota_count = int(quota_str)
                        if quota_count > 0:
                            records.append({
                                'middle_school_code': middle_code,
                                'middle_school_name': middle_name,
                                'high_school_code': high_code,
                                'quota_count': quota_count,
                                'district_code': district_code,
                            })
                    except ValueError:
                        pass
        except (IndexError, ValueError):
            continue

    return records

def parse_format_10(content: str, district_code: str) -> list:
    """
    Format 10 (浦东区 style):
    序号, 初中学校名称, then high school names in header (no codes for middle or high schools)
    """
    records = []
    reader = csv.reader(content.split('\n'))
    rows = list(reader)

    if len(rows) < 3:
        return records

    # Header row 0 has high school names
    header_row = rows[0]
    high_school_codes = []

    for i, cell in enumerate(header_row[2:], start=2):
        cell = cell.strip().strip('"')
        code = ''
        for name, c in HIGH_SCHOOL_CODES.items():
            if name in cell or cell in name:
                code = c
                break
        while i >= len(high_school_codes):
            high_school_codes.append('')
        high_school_codes[i] = code

    # Parse data rows
    for row in rows[1:]:
        if not row or len(row) < 3:
            continue

        # Row format: 序号, middle_school_name, quotas...
        seq = row[0].strip().strip('"')
        middle_name = row[1].strip().strip('"') if len(row) > 1 else ''

        if not seq.isdigit():
            continue

        for i in range(2, len(row)):
            if i < len(row) and i < len(high_school_codes):
                quota_str = row[i].strip().strip('"')
                if quota_str and quota_str.isdigit():
                    quota_count = int(quota_str)
                    if quota_count > 0 and high_school_codes[i]:
                        records.append({
                            'middle_school_code': '',  # No code in this format
                            'middle_school_name': middle_name,
                            'high_school_code': high_school_codes[i],
                            'quota_count': quota_count,
                            'district_code': district_code,
                        })
    return records

def detect_and_parse(filepath: Path, district_code: str) -> list:
    """Detect CSV format and parse accordingly."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    first_lines = content.split('\n')[:5]

    # Detect format 9 (奉贤区) - long format with 所属区 and 计划数 columns
    if '所属区' in content and '计划' in content and '数' in content:
        return parse_format_9(content, district_code)

    # Detect format 8 (徐汇区) - 序号,学校编号 pattern
    if '学校编号' in content and '序号' in content:
        return parse_format_8(content, district_code)

    # Detect format 7 (松江区) - 委属名额 in header
    if '委属名额' in content:
        return parse_format_7(content, district_code)

    # Detect format 6 (闵行区) - has 招生代码 in header
    if '招生代码' in content and '初中代码' in content:
        return parse_format_6(content, district_code)

    # Detect format 10 (浦东区) - 序号,初中学校名称 (no school codes)
    if '初中学校名称' in content and '学校代码' not in content:
        return parse_format_10(content, district_code)

    # Detect format 5 (宝山区) - 序号,学校代码 in header
    if '序号' in content and '学校代码' in content:
        return parse_format_5(content, district_code)

    # Detect format 4 (黄浦区) - 学校代码名称 or code+name in col 0
    if '学校代码名称' in content or any(re.match(r'^\d{6}\s+', line.split(',')[0] if line else '') for line in first_lines):
        return parse_format_4(content, district_code)

    # Detect format 2 (嘉定区) - 招生学校代码1
    if '招生学校代码1' in content or '招生学校名称1' in content:
        return parse_format_2(content, district_code)

    # Detect format 3 (普陀区) - 委属市示范性高中
    if any('委属市示范性高中' in line or '区属市示范性高中' in line for line in first_lines):
        return parse_format_3(content, district_code)

    # Default to format 1
    return parse_format_1(content, district_code)

def generate_sql_seed(records: list, year: int, output_path: Path):
    """Generate SQL seed file."""
    by_district = defaultdict(list)
    for rec in records:
        by_district[rec['district_code']].append(rec)

    sql_lines = [
        f"-- =============================================================================",
        f"-- {year}年名额分配到校招生计划",
        f"-- Generated by etl_quota_allocation_school_v2.py",
        f"-- Total Records: {len(records)} across {len(by_district)} districts",
        f"-- =============================================================================",
        "",
        f"-- Delete existing {year} data",
        f"DELETE FROM ref_quota_allocation_school WHERE year = {year};",
        "",
    ]

    for district_code, district_records in sorted(by_district.items()):
        sql_lines.append(f"-- {district_code}: {len(district_records)} records")

        for rec in district_records:
            middle_name_escaped = rec['middle_school_name'].replace("'", "''")
            sql = f"""INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT {year}, (SELECT id FROM ref_district WHERE code = '{district_code}'), (SELECT id FROM ref_school WHERE code = '{rec['high_school_code']}' AND data_year = 2025), '{rec['high_school_code']}', (SELECT id FROM ref_middle_school WHERE name = '{middle_name_escaped}' AND district_id = (SELECT id FROM ref_district WHERE code = '{district_code}') LIMIT 1), '{middle_name_escaped}', {rec['quota_count']}, {year}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = '{district_code}')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '{rec['high_school_code']}' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET quota_count = EXCLUDED.quota_count, updated_at = CURRENT_TIMESTAMP;"""
            sql_lines.append(sql)
        sql_lines.append("")

    sql_lines.append(f"-- Verify: SELECT year, d.code, COUNT(*) FROM ref_quota_allocation_school q JOIN ref_district d ON q.district_id = d.id WHERE year = {year} GROUP BY year, d.code;")

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"Generated: {output_path} ({len(records)} records)")

def main():
    base_path = Path(__file__).parent.parent
    raw_data_path = base_path / 'original_data' / 'raw'
    seeds_path = base_path / 'db' / 'seeds'

    # Process 2024 data
    print("\n=== Processing 2024 data ===")
    raw_2024_path = raw_data_path / '2024' / 'quota_school'
    all_records_2024 = []

    if raw_2024_path.exists():
        for csv_file in sorted(raw_2024_path.glob('*.csv')):
            district_name = extract_district_name(csv_file.name)
            if not district_name:
                print(f"  Skipping {csv_file.name} - district not detected")
                continue

            district_code = DISTRICT_CODES.get(district_name)
            if not district_code:
                print(f"  Skipping {csv_file.name} - unknown district: {district_name}")
                continue

            print(f"  Processing {csv_file.name} -> {district_code}")
            records = detect_and_parse(csv_file, district_code)
            print(f"    Found {len(records)} records")
            all_records_2024.extend(records)

    if all_records_2024:
        output_file = seeds_path / '034_seed_quota_allocation_school_2024_complete.sql'
        generate_sql_seed(all_records_2024, 2024, output_file)

    print(f"\n=== Summary ===")
    print(f"2024: {len(all_records_2024)} records")

if __name__ == '__main__':
    main()
