#!/usr/bin/env python3
"""
ETL script to import 2024 cutoff scores for all 16 districts.

Imports:
1. Quota District scores (名额分配到区分数线)
2. Quota School scores (名额分配到校分数线)
3. Unified admission scores (统一招生1-15志愿分数线)

Usage:
    python scripts/etl_cutoff_scores_2024.py
"""

import csv
import os
import re
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
DATA_DIR = '/Users/lance.wang/workspace/wzgown/highschool_new/original_data/raw/2024/cutoff_scores'

# District name to ID mapping
DISTRICT_MAP = {
    '黄浦区': 2, '徐汇区': 3, '长宁区': 4, '静安区': 5,
    '普陀区': 6, '虹口区': 7, '杨浦区': 8, '闵行区': 9,
    '宝山区': 10, '嘉定区': 11, '浦东新区': 12, '浦东区': 12,  # alias
    '金山区': 13, '松江区': 14, '青浦区': 15, '奉贤区': 16, '崇明区': 17
}

YEAR = 2024
DATA_YEAR = 2024


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


def find_middle_school_id(cursor, school_name, district_id):
    """Find middle school ID by name and district."""
    if not school_name:
        return None

    school_name = school_name.strip()

    cursor.execute("""
        SELECT id FROM ref_middle_school
        WHERE name = %s AND district_id = %s
        LIMIT 1
    """, (school_name, district_id))

    result = cursor.fetchone()
    return result[0] if result else None


def import_quota_district_scores(cursor):
    """Import 名额分配到区分数线."""
    print("\n📊 Importing Quota District Scores (名额分配到区)...")

    pattern = re.compile(r'2024年上海市高中学校名额分配到区招生录取最低分数线（(.+)）\.csv')
    imported_count = 0
    skipped_count = 0

    for filename in os.listdir(DATA_DIR):
        match = pattern.match(filename)
        if not match:
            continue

        district_name = match.group(1)
        district_id = DISTRICT_MAP.get(district_name)
        if not district_id:
            print(f"  ⚠️ Unknown district: {district_name}")
            continue

        filepath = os.path.join(DATA_DIR, filename)
        print(f"  📁 Processing: {district_name} (district_id={district_id})")

        with open(filepath, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            rows = list(reader)

        # Skip header rows
        data_rows = [r for r in rows if len(r) >= 5 and r[0] not in ['区名称', '']]

        records = []
        for row in data_rows:
            if len(row) < 5:
                continue

            school_name = row[1].strip()
            min_score = parse_score(row[2])
            is_tie_preferred = parse_bool(row[3])
            chinese_math_foreign = parse_score(row[4])
            math_score = parse_score(row[5]) if len(row) > 5 else None
            chinese_score = parse_score(row[6]) if len(row) > 6 else None
            integrated_score = parse_score(row[7]) if len(row) > 7 else None

            if not school_name or min_score is None:
                continue

            school_id = find_school_id(cursor, school_name)

            records.append((
                YEAR, district_id, school_id, school_name, min_score,
                is_tie_preferred, chinese_math_foreign, math_score,
                chinese_score, integrated_score, DATA_YEAR
            ))

        if records:
            try:
                execute_values(cursor, """
                    INSERT INTO ref_admission_score_quota_district
                    (year, district_id, school_id, school_name, min_score,
                     is_tie_preferred, chinese_math_foreign_sum, math_score,
                     chinese_score, integrated_test_score, data_year)
                    VALUES %s
                    ON CONFLICT (year, district_id, school_name)
                    DO UPDATE SET
                        min_score = EXCLUDED.min_score,
                        is_tie_preferred = EXCLUDED.is_tie_preferred,
                        school_id = EXCLUDED.school_id,
                        chinese_math_foreign_sum = EXCLUDED.chinese_math_foreign_sum,
                        math_score = EXCLUDED.math_score,
                        chinese_score = EXCLUDED.chinese_score,
                        integrated_test_score = EXCLUDED.integrated_test_score
                """, records)
                imported_count += len(records)
                print(f"    ✅ Imported {len(records)} records")
            except Exception as e:
                print(f"    ❌ Error: {e}")
                skipped_count += len(records)

    print(f"\n  📈 Quota District: {imported_count} imported, {skipped_count} skipped")
    return imported_count


def import_quota_school_scores(cursor):
    """Import 名额分配到校分数线."""
    print("\n📊 Importing Quota School Scores (名额分配到校)...")

    pattern = re.compile(r'2024年上海市高中学校名额分配到校招生录取最低分数线（(.+)）\.csv')
    imported_count = 0
    skipped_count = 0

    for filename in os.listdir(DATA_DIR):
        match = pattern.match(filename)
        if not match:
            continue

        district_name = match.group(1)
        district_id = DISTRICT_MAP.get(district_name)
        if not district_id:
            print(f"  ⚠️ Unknown district: {district_name}")
            continue

        filepath = os.path.join(DATA_DIR, filename)
        print(f"  📁 Processing: {district_name} (district_id={district_id})")

        with open(filepath, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            rows = list(reader)

        # Skip header rows
        data_rows = [r for r in rows if len(r) >= 5 and r[0] not in ['初中学校', '']]

        records = []
        for row in data_rows:
            if len(row) < 5:
                continue

            middle_school_name = row[0].strip()
            school_name = row[1].strip()
            min_score = parse_score(row[2])
            is_tie_preferred = parse_bool(row[3])
            chinese_math_foreign = parse_score(row[4])
            math_score = parse_score(row[5]) if len(row) > 5 else None
            chinese_score = parse_score(row[6]) if len(row) > 6 else None
            integrated_score = parse_score(row[7]) if len(row) > 7 else None

            if not school_name or not middle_school_name or min_score is None:
                continue

            school_id = find_school_id(cursor, school_name)

            records.append((
                YEAR, district_id, school_id, school_name, middle_school_name,
                min_score, is_tie_preferred, chinese_math_foreign, math_score,
                chinese_score, integrated_score, DATA_YEAR
            ))

        if records:
            try:
                execute_values(cursor, """
                    INSERT INTO ref_admission_score_quota_school
                    (year, district_id, school_id, school_name, middle_school_name,
                     min_score, is_tie_preferred, chinese_math_foreign_sum, math_score,
                     chinese_score, integrated_test_score, data_year)
                    VALUES %s
                    ON CONFLICT (year, district_id, school_name, middle_school_name)
                    DO UPDATE SET
                        min_score = EXCLUDED.min_score,
                        is_tie_preferred = EXCLUDED.is_tie_preferred,
                        school_id = EXCLUDED.school_id,
                        chinese_math_foreign_sum = EXCLUDED.chinese_math_foreign_sum,
                        math_score = EXCLUDED.math_score,
                        chinese_score = EXCLUDED.chinese_score,
                        integrated_test_score = EXCLUDED.integrated_test_score
                """, records)
                imported_count += len(records)
                print(f"    ✅ Imported {len(records)} records")
            except Exception as e:
                print(f"    ❌ Error: {e}")
                skipped_count += len(records)

    print(f"\n  📈 Quota School: {imported_count} imported, {skipped_count} skipped")
    return imported_count


def import_unified_scores(cursor):
    """Import 统一招生1-15志愿分数线."""
    print("\n📊 Importing Unified Admission Scores (统一招生1-15志愿)...")

    imported_count = 0
    skipped_count = 0

    for filename in os.listdir(DATA_DIR):
        if not filename.startswith('2024中考1-15志愿录取分数线'):
            continue

        # Extract district name
        match = re.match(r'2024中考1-15志愿录取分数线(.+)\.csv', filename)
        if not match:
            continue

        district_name = match.group(1)
        district_id = DISTRICT_MAP.get(district_name)
        if not district_id:
            print(f"  ⚠️ Unknown district: {district_name}")
            continue

        filepath = os.path.join(DATA_DIR, filename)
        print(f"  📁 Processing: {district_name} (district_id={district_id})")

        with open(filepath, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            rows = list(reader)

        # Skip header rows
        data_rows = [r for r in rows if len(r) >= 3 and r[0] not in ['招生代码', '']]

        # Use dict to deduplicate by school_name
        records_dict = {}
        for row in data_rows:
            if len(row) < 3:
                continue

            school_name = row[1].strip()
            min_score = parse_score(row[2])
            chinese_math_foreign = parse_score(row[4]) if len(row) > 4 else None
            math_score = parse_score(row[5]) if len(row) > 5 else None
            chinese_score = parse_score(row[6]) if len(row) > 6 else None

            if not school_name or min_score is None:
                continue

            # Skip if already have this school
            if school_name in records_dict:
                continue

            school_id = find_school_id(cursor, school_name)

            records_dict[school_name] = (
                YEAR, district_id, school_id, school_name, min_score,
                chinese_math_foreign, math_score, chinese_score, DATA_YEAR
            )

        records = list(records_dict.values())
        if records:
            try:
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
                imported_count += len(records)
                print(f"    ✅ Imported {len(records)} records")
            except Exception as e:
                print(f"    ❌ Error: {e}")
                skipped_count += len(records)

    print(f"\n  📈 Unified: {imported_count} imported, {skipped_count} skipped")
    return imported_count


def main():
    print("🚀 Starting 2024 Cutoff Scores ETL...")

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    try:
        # Import all three types of scores
        quota_district_count = import_quota_district_scores(cursor)
        quota_school_count = import_quota_school_scores(cursor)
        unified_count = import_unified_scores(cursor)

        conn.commit()

        print("\n" + "=" * 50)
        print("✅ ETL Complete!")
        print("=" * 50)
        print(f"  📊 Quota District (名额分配到区): {quota_district_count} records")
        print(f"  📊 Quota School (名额分配到校): {quota_school_count} records")
        print(f"  📊 Unified (统一招生1-15志愿): {unified_count} records")
        print(f"  📈 Total: {quota_district_count + quota_school_count + unified_count} records")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ ETL Failed: {e}")
        raise
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    main()
