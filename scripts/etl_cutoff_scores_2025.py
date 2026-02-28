#!/usr/bin/env python3
"""
ETL script to import 2025 cutoff scores for all 16 districts.

Imports:
1. Control scores (各批次最低投档控制分数线) -> ref_control_score
2. Quota District scores (名额分配到区分数线) -> ref_admission_score_quota_district
3. Quota School scores (名额分配到校分数线详细) -> ref_admission_score_quota_school
4. Unified admission scores (统一招生1-15志愿分数线) -> ref_admission_score_unified

Usage:
    python scripts/etl_cutoff_scores_2025.py
"""

import csv
import os
import psycopg2
from psycopg2.extras import execute_values

# Database connection
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'highschool',
    'user': 'highschool',
    'password': 'HS2025!db#SecurePass88'
}

# Data directory
DATA_DIR = '/Users/lance.wang/workspace/wzgown/highschool_new/original_data/raw/2025/Kimi_Agent_上海中考分数 '

# District name to ID mapping
DISTRICT_MAP = {
    '黄浦区': 2, '徐汇区': 3, '长宁区': 4, '静安区': 5,
    '普陀区': 6, '虹口区': 7, '杨浦区': 8, '闵行区': 9,
    '宝山区': 10, '嘉定区': 11, '浦东新区': 12, '浦东区': 12,
    '金山区': 13, '松江区': 14, '青浦区': 15, '奉贤区': 16, '崇明区': 17
}

YEAR = 2025
DATA_YEAR = 2025

# Batch name mapping
BATCH_NAME_MAP = {
    '自主招生录取': 'AUTONOMOUS',
    '名额分配综合评价录取': 'QUOTA_DISTRICT',
    '普通高中统一招生录取': 'UNIFIED_1_15',
    '中本贯通录取': 'ZHONGBEN',
    '五年一贯制和中高职贯通录取': 'WUNIAN_ZHIGAO',
    '普通中专录取': 'ZHONGZHUAN'
}


def parse_score(score_str):
    """Parse score string to float, return None if invalid."""
    if not score_str or score_str.strip() == '':
        return None
    try:
        return float(score_str.strip())
    except ValueError:
        return None


def parse_bool(bool_str):
    """Parse boolean string (是/否) to boolean."""
    if not bool_str:
        return False
    return bool_str.strip() == '是'


def find_school_id(cursor, school_name, district_id=None):
    """Find school ID by name, optionally filtered by district."""
    if not school_name:
        return None

    school_name = school_name.strip()

    # Try exact match first
    if district_id:
        cursor.execute("""
            SELECT id FROM ref_school
            WHERE (full_name = %s OR short_name = %s)
            AND (district_id = %s OR district_id = 1)
            LIMIT 1
        """, (school_name, school_name, district_id))
    else:
        cursor.execute("""
            SELECT id FROM ref_school
            WHERE full_name = %s OR short_name = %s
            LIMIT 1
        """, (school_name, school_name))

    result = cursor.fetchone()
    return result[0] if result else None


def import_control_scores(cursor):
    """Import 各批次最低投档控制分数线 -> ref_control_score."""
    print("\n📊 Importing Control Scores (各批次最低投档控制分数线)...")

    filepath = os.path.join(DATA_DIR, '2025年上海市中考各批次最低投档控制分数线.csv')

    if not os.path.exists(filepath):
        print(f"  ⚠️ File not found: {filepath}")
        return 0

    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)

    records = []
    for row in rows[1:]:  # Skip header
        if len(row) < 2:
            continue

        batch_name = row[0].strip()
        min_score = parse_score(row[1])

        if not batch_name or min_score is None:
            continue

        batch_id = BATCH_NAME_MAP.get(batch_name)
        if not batch_id:
            print(f"  ⚠️ Unknown batch: {batch_name}")
            continue

        records.append((
            YEAR, batch_id, batch_name, min_score, DATA_YEAR
        ))

    if records:
        execute_values(cursor, """
            INSERT INTO ref_control_score
            (year, admission_batch_id, category, min_score, data_year)
            VALUES %s
            ON CONFLICT (year, admission_batch_id, category)
            DO UPDATE SET
                min_score = EXCLUDED.min_score
        """, records)
        print(f"  ✅ Imported {len(records)} control score records")

    return len(records)


def import_quota_district_scores(cursor):
    """Import 名额分配到区分数线 -> ref_admission_score_quota_district."""
    print("\n📊 Importing Quota District Scores (名额分配到区)...")

    filepath = os.path.join(DATA_DIR, '2025年上海市中考名额分配到区录取分数线.csv')

    if not os.path.exists(filepath):
        print(f"  ⚠️ File not found: {filepath}")
        return 0

    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)

    # Header: 区名,招生学校,录取最低分,是否同分优待,综合素质评价,语数外,数学,语文,综合测试
    # Use dict to deduplicate by (district_id, school_name)
    records_dict = {}
    for row in rows[1:]:  # Skip header
        if len(row) < 3:
            continue

        district_name = row[0].strip()
        school_name = row[1].strip()
        min_score = parse_score(row[2])
        is_tie_preferred = parse_bool(row[3]) if len(row) > 3 else False
        comprehensive_quality = parse_score(row[4]) if len(row) > 4 else 50
        chinese_math_foreign = parse_score(row[5]) if len(row) > 5 else None
        math_score = parse_score(row[6]) if len(row) > 6 else None
        chinese_score = parse_score(row[7]) if len(row) > 7 else None
        integrated_score = parse_score(row[8]) if len(row) > 8 else None

        if not district_name or not school_name or min_score is None:
            continue

        district_id = DISTRICT_MAP.get(district_name)
        if not district_id:
            print(f"  ⚠️ Unknown district: {district_name}")
            continue

        # Skip duplicates
        key = (district_id, school_name)
        if key in records_dict:
            continue

        school_id = find_school_id(cursor, school_name, district_id)

        records_dict[key] = (
            YEAR, district_id, school_id, school_name, min_score,
            is_tie_preferred, chinese_math_foreign, math_score,
            chinese_score, integrated_score, comprehensive_quality, DATA_YEAR
        )

    records = list(records_dict.values())

    if records:
        execute_values(cursor, """
            INSERT INTO ref_admission_score_quota_district
            (year, district_id, school_id, school_name, min_score,
             is_tie_preferred, chinese_math_foreign_sum, math_score,
             chinese_score, integrated_test_score, comprehensive_quality_score, data_year)
            VALUES %s
            ON CONFLICT (year, district_id, school_name)
            DO UPDATE SET
                min_score = EXCLUDED.min_score,
                is_tie_preferred = EXCLUDED.is_tie_preferred,
                school_id = EXCLUDED.school_id,
                chinese_math_foreign_sum = EXCLUDED.chinese_math_foreign_sum,
                math_score = EXCLUDED.math_score,
                chinese_score = EXCLUDED.chinese_score,
                integrated_test_score = EXCLUDED.integrated_test_score,
                comprehensive_quality_score = EXCLUDED.comprehensive_quality_score
        """, records)
        print(f"  ✅ Imported {len(records)} quota district records")

    return len(records)


def import_quota_school_scores(cursor):
    """Import 名额分配到校分数线详细 -> ref_admission_score_quota_school."""
    print("\n📊 Importing Quota School Scores (名额分配到校详细)...")

    filepath = os.path.join(DATA_DIR, '2025年上海市中考名额分配到校录取分数线详细.csv')

    if not os.path.exists(filepath):
        print(f"  ⚠️ File not found: {filepath}")
        return 0

    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)

    # Header: 区名,初中学校,招生学校,录取最低分,是否同分优待,综合素质评价,语数外,数学,语文,综合测试
    # Use dict to deduplicate by (district_id, school_name, middle_school_name)
    records_dict = {}
    for row in rows[1:]:  # Skip header
        if len(row) < 4:
            continue

        district_name = row[0].strip()
        middle_school_name = row[1].strip()
        school_name = row[2].strip()
        min_score = parse_score(row[3])
        is_tie_preferred = parse_bool(row[4]) if len(row) > 4 else False
        comprehensive_quality = parse_score(row[5]) if len(row) > 5 else 50
        chinese_math_foreign = parse_score(row[6]) if len(row) > 6 else None
        math_score = parse_score(row[7]) if len(row) > 7 else None
        chinese_score = parse_score(row[8]) if len(row) > 8 else None
        integrated_score = parse_score(row[9]) if len(row) > 9 else None

        if not district_name or not middle_school_name or not school_name or min_score is None:
            continue

        district_id = DISTRICT_MAP.get(district_name)
        if not district_id:
            print(f"  ⚠️ Unknown district: {district_name}")
            continue

        # Skip duplicates
        key = (district_id, school_name, middle_school_name)
        if key in records_dict:
            continue

        school_id = find_school_id(cursor, school_name, district_id)

        records_dict[key] = (
            YEAR, district_id, school_id, school_name, middle_school_name,
            min_score, is_tie_preferred, chinese_math_foreign, math_score,
            chinese_score, integrated_score, comprehensive_quality, DATA_YEAR
        )

    records = list(records_dict.values())

    if records:
        execute_values(cursor, """
            INSERT INTO ref_admission_score_quota_school
            (year, district_id, school_id, school_name, middle_school_name,
             min_score, is_tie_preferred, chinese_math_foreign_sum, math_score,
             chinese_score, integrated_test_score, comprehensive_quality_score, data_year)
            VALUES %s
            ON CONFLICT (year, district_id, school_name, middle_school_name)
            DO UPDATE SET
                min_score = EXCLUDED.min_score,
                is_tie_preferred = EXCLUDED.is_tie_preferred,
                school_id = EXCLUDED.school_id,
                chinese_math_foreign_sum = EXCLUDED.chinese_math_foreign_sum,
                math_score = EXCLUDED.math_score,
                chinese_score = EXCLUDED.chinese_score,
                integrated_test_score = EXCLUDED.integrated_test_score,
                comprehensive_quality_score = EXCLUDED.comprehensive_quality_score
        """, records)
        print(f"  ✅ Imported {len(records)} quota school records")

    return len(records)


def import_unified_scores(cursor):
    """Import 统一招生1-15志愿分数线 -> ref_admission_score_unified."""
    print("\n📊 Importing Unified Admission Scores (统一招生1-15志愿)...")

    filepath = os.path.join(DATA_DIR, '2025年上海市中考1-15志愿统一招生录取分数线.csv')

    if not os.path.exists(filepath):
        print(f"  ⚠️ File not found: {filepath}")
        return 0

    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)

    # Header: 区名,学校代码,学校名称,录取最低分,语数外,数学,语文,综合测试
    records = []
    seen = set()  # Deduplicate by (district_id, school_name)

    for row in rows[1:]:  # Skip header
        if len(row) < 4:
            continue

        district_name = row[0].strip()
        school_code = row[1].strip()
        school_name = row[2].strip()
        min_score = parse_score(row[3])
        chinese_math_foreign = parse_score(row[4]) if len(row) > 4 else None
        math_score = parse_score(row[5]) if len(row) > 5 else None
        chinese_score = parse_score(row[6]) if len(row) > 6 else None
        integrated_score = parse_score(row[7]) if len(row) > 7 else None

        if not district_name or not school_name or min_score is None:
            continue

        district_id = DISTRICT_MAP.get(district_name)
        if not district_id:
            print(f"  ⚠️ Unknown district: {district_name}")
            continue

        # Skip duplicates
        key = (district_id, school_name)
        if key in seen:
            continue
        seen.add(key)

        school_id = find_school_id(cursor, school_name, district_id)

        records.append((
            YEAR, district_id, school_id, school_name, min_score,
            chinese_math_foreign, math_score, chinese_score, DATA_YEAR
        ))

    if records:
        execute_values(cursor, """
            INSERT INTO ref_admission_score_unified
            (year, district_id, school_id, school_name, min_score,
             chinese_math_foreign_sum, math_score, chinese_score, data_year)
            VALUES %s
            ON CONFLICT (year, district_id, school_name)
            DO UPDATE SET
                min_score = EXCLUDED.min_score,
                school_id = EXCLUDED.school_id,
                chinese_math_foreign_sum = EXCLUDED.chinese_math_foreign_sum,
                math_score = EXCLUDED.math_score,
                chinese_score = EXCLUDED.chinese_score
        """, records)
        print(f"  ✅ Imported {len(records)} unified admission records")

    return len(records)


def main():
    print("🚀 Starting 2025 Cutoff Scores ETL...")

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        # Clear existing 2025 data first
        print("\n🧹 Clearing existing 2025 data...")
        cursor.execute("DELETE FROM ref_control_score WHERE year = %s", (YEAR,))
        cursor.execute("DELETE FROM ref_admission_score_quota_district WHERE year = %s", (YEAR,))
        cursor.execute("DELETE FROM ref_admission_score_quota_school WHERE year = %s", (YEAR,))
        cursor.execute("DELETE FROM ref_admission_score_unified WHERE year = %s", (YEAR,))
        print("  ✅ Cleared existing 2025 data")

        # Import all types of scores
        control_count = import_control_scores(cursor)
        quota_district_count = import_quota_district_scores(cursor)
        quota_school_count = import_quota_school_scores(cursor)
        unified_count = import_unified_scores(cursor)

        conn.commit()

        print("\n" + "=" * 60)
        print("✅ 2025 ETL Complete!")
        print("=" * 60)
        print(f"  📊 Control Scores (控制分数线): {control_count} records")
        print(f"  📊 Quota District (名额分配到区): {quota_district_count} records")
        print(f"  📊 Quota School (名额分配到校): {quota_school_count} records")
        print(f"  📊 Unified (统一招生1-15志愿): {unified_count} records")
        print(f"  📈 Total: {control_count + quota_district_count + quota_school_count + unified_count} records")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ ETL Failed: {e}")
        raise
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    main()
