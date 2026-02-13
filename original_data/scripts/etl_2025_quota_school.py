#!/usr/bin/env python3
"""
ETL脚本：处理2025年名额分配到校招生计划数据

Source: original_data/processed/2025/quota_school/2025年名额分配到校.csv
Output: db/seeds/035_seed_quota_allocation_school_2025.sql

This script processes the quota allocation to school data and generates SQL seed file.
Also discovers new middle schools from the data.
"""

import csv
import os
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# ============================================================================
# Configuration
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")
SEEDS_DIR = os.path.join(BASE_DIR, "..", "db", "seeds")
PROCESSED_OUTPUT_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school_clean")

# Create directories
Path(SEEDS_DIR).mkdir(parents=True, exist_ok=True)
Path(PROCESSED_OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# District code mapping (Chinese name -> code)
DISTRICT_MAP = {
    '黄浦': 'HP',
    '徐汇': 'XH',
    '长宁': 'CN',
    '静安': 'JA',
    '普陀': 'PT',
    '虹口': 'HK',
    '杨浦': 'YP',
    '闵行': 'MH',
    '宝山': 'BS',
    '嘉定': 'JD',
    '浦东': 'PD',
    '金山': 'JS',
    '松江': 'SJ',
    '青浦': 'QP',
    '奉贤': 'FX',
    '崇明': 'CM',
}

# ============================================================================
# ETL Functions
# ============================================================================

def extract_quota_school():
    """Extract quota allocation to school data from CSV"""
    input_file = os.path.join(PROCESSED_DIR, "2025年名额分配到校.csv")

    print("=" * 60)
    print("Step 1: Extract Quota Allocation to School Data")
    print("=" * 60)

    records = []
    middle_schools = set()
    high_schools = set()
    districts = set()

    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            year = int(row['年份'].strip())
            batch = row['批次'].strip()
            district_name = row['区名称'].strip()
            middle_code = row['初中学校代码'].strip()
            middle_name = row['初中学校'].strip()
            high_code = row['高中学校代码'].strip()
            quota = int(row['名额'].strip())
            source_file = row['文件来源'].strip()

            district_code = DISTRICT_MAP.get(district_name, '')

            if district_code:
                districts.add(district_name)
                middle_schools.add((middle_code, middle_name, district_name))
                high_schools.add(high_code)

                records.append({
                    'year': year,
                    'batch': batch,
                    'district_name': district_name,
                    'district_code': district_code,
                    'middle_code': middle_code,
                    'middle_name': middle_name,
                    'high_code': high_code,
                    'quota': quota,
                    'source_file': source_file
                })

    print(f"Extracted {len(records)} records")
    print(f"Districts: {len(districts)} - {sorted(districts)}")
    print(f"Middle schools: {len(middle_schools)}")
    print(f"High schools: {len(high_schools)}")
    print(f"Total quota: {sum(r['quota'] for r in records):,}")

    return records, list(middle_schools)


def transform_quota_school(records):
    """Transform data for SQL generation"""
    print("\n" + "=" * 60)
    print("Step 2: Transform Data")
    print("=" * 60)

    transformed = []
    district_quota = defaultdict(int)

    for record in records:
        district_quota[record['district_code']] += record['quota']
        transformed.append({
            'year': record['year'],
            'district_code': record['district_code'],
            'high_code': record['high_code'],
            'middle_name': record['middle_name'],
            'quota': record['quota']
        })

    print(f"Transformed {len(transformed)} records")
    print("Quota by district:")
    for district in sorted(district_quota.keys()):
        print(f"  {district}: {district_quota[district]:,}")

    return transformed


def generate_sql_seed_quota_school(records):
    """Generate SQL seed file for quota allocation to school"""
    print("\n" + "=" * 60)
    print("Step 3: Generate SQL Seed File - Quota to School")
    print("=" * 60)

    output_file = os.path.join(SEEDS_DIR, "035_seed_quota_allocation_school_2025.sql")

    sql_lines = [
        "-- =============================================================================",
        "-- 2025年名额分配到校招生计划数据",
        "-- =============================================================================",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"-- Source: 2025年名额分配到校.csv",
        "",
        "-- Delete existing 2025 data",
        "DELETE FROM ref_quota_allocation_school WHERE year = 2025;",
        "",
        "-- Insert 2025 quota allocation to school data",
    ]

    for record in records:
        # Use INSERT with ON CONFLICT for upsert
        sql = (
            f"INSERT INTO ref_quota_allocation_school "
            f"(year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at) "
            f"SELECT "
            f"{record['year']}, "
            f"(SELECT id FROM ref_district WHERE code = '{record['district_code']}'), "
            f"(SELECT id FROM ref_school WHERE code = '{record['high_code']}' AND data_year = 2025), "
            f"'{record['high_code']}', "
            f"(SELECT id FROM ref_middle_school WHERE name = '{record['middle_name']}' AND data_year = 2025), "
            f"'{record['middle_name']}', "
            f"{record['quota']}, "
            f"{record['year']}, "
            f"CURRENT_TIMESTAMP, "
            f"CURRENT_TIMESTAMP "
            f"WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = '{record['district_code']}') "
            f"AND EXISTS (SELECT 1 FROM ref_school WHERE code = '{record['high_code']}' AND data_year = 2025) "
            f"ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET "
            f"quota_count = EXCLUDED.quota_count, "
            f"updated_at = CURRENT_TIMESTAMP;"
        )
        sql_lines.append(sql)

    # Add verification query
    sql_lines.extend([
        "",
        "-- Verify insert - show quota by district",
        "SELECT d.code, d.name, COUNT(*) as school_count, SUM(qas.quota_count) as total_quota",
        "FROM ref_quota_allocation_school qas",
        "JOIN ref_district d ON qas.district_id = d.id",
        "WHERE qas.year = 2025",
        "GROUP BY d.code, d.name",
        "ORDER BY d.code;",
    ])

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"Output: {output_file}")
    print(f"Generated {len(records)} INSERT statements")


def generate_sql_seed_middle_schools(middle_schools):
    """Generate SQL seed file for middle schools"""
    print("\n" + "=" * 60)
    print("Step 4: Generate SQL Seed File - Middle Schools")
    print("=" * 60)

    output_file = os.path.join(SEEDS_DIR, "041_seed_middle_schools_2025.sql")

    sql_lines = [
        "-- =============================================================================",
        "-- 2025年初中学校数据（从名额分配到校数据中提取）",
        "-- =============================================================================",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"-- Source: 2025年名额分配到校.csv",
        "",
        "-- Delete existing 2025 data",
        "DELETE FROM ref_middle_school WHERE data_year = 2025;",
        "",
        "-- Insert 2025 middle school data",
    ]

    for code, name, district_name in sorted(middle_schools):
        district_code = DISTRICT_MAP.get(district_name, '')

        # Generate short name (remove "上海市" and "区" prefix if exists)
        short_name = name
        if short_name.startswith('上海市'):
            short_name = short_name[3:]
        if '区' in short_name and short_name.index('区') < 5:
            # Remove district name prefix if exists
            for dist in ['黄浦', '徐汇', '长宁', '静安', '普陀', '虹口', '杨浦',
                        '闵行', '宝山', '嘉定', '浦东', '金山', '松江', '青浦', '奉贤', '崇明']:
                if short_name.startswith(dist + '区'):
                    short_name = short_name[len(dist)+1:]
                    break

        sql = (
            f"INSERT INTO ref_middle_school "
            f"(code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active, created_at, updated_at) "
            f"SELECT "
            f"'{code}', "
            f"'{name}', "
            f"'{short_name}', "
            f"(SELECT id FROM ref_district WHERE code = '{district_code}'), "
            f"'PUBLIC', "
            f"TRUE, "
            f"2025, "
            f"TRUE, "
            f"CURRENT_TIMESTAMP, "
            f"CURRENT_TIMESTAMP "
            f"WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = '{district_code}') "
            f"ON CONFLICT (code, data_year) DO UPDATE SET "
            f"name = EXCLUDED.name, "
            f"short_name = EXCLUDED.short_name, "
            f"district_id = EXCLUDED.district_id, "
            f"is_active = TRUE, "
            f"updated_at = CURRENT_TIMESTAMP;"
        )
        sql_lines.append(sql)

    # Add verification query
    sql_lines.extend([
        "",
        "-- Verify insert - show middle schools by district",
        "SELECT d.code, d.name, COUNT(*) as school_count",
        "FROM ref_middle_school ms",
        "JOIN ref_district d ON ms.district_id = d.id",
        "WHERE ms.data_year = 2025",
        "GROUP BY d.code, d.name",
        "ORDER BY d.code;",
    ])

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"Output: {output_file}")
    print(f"Generated {len(middle_schools)} INSERT statements")


# ============================================================================
# Main
# ============================================================================

def main():
    print("\n" + "=" * 60)
    print("ETL Pipeline: 2025 Quota Allocation to School Data")
    print("=" * 60)

    # Step 1: Extract
    records, middle_schools = extract_quota_school()

    # Step 2: Transform
    transformed = transform_quota_school(records)

    # Step 3: Generate SQL for quota to school
    generate_sql_seed_quota_school(transformed)

    # Step 4: Generate SQL for middle schools
    generate_sql_seed_middle_schools(middle_schools)

    print("\n" + "=" * 60)
    print("ETL Pipeline Complete!")
    print("=" * 60)


if __name__ == '__main__':
    main()
