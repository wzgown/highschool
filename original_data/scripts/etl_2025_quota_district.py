#!/usr/bin/env python3
"""
ETL脚本：处理2025年名额分配到区招生计划数据

Source: original_data/processed/2025/quota_district/2025年名额分配到区招生计划.csv
Output: db/seeds/010_seed_quota_allocation_district_2025.sql

This script processes the quota allocation to district data and generates SQL seed file.
"""

import csv
import os
from pathlib import Path
from datetime import datetime

# ============================================================================
# Configuration
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_district")
SEEDS_DIR = os.path.join(BASE_DIR, "..", "db", "seeds")

# Create directories
Path(SEEDS_DIR).mkdir(parents=True, exist_ok=True)

# District code mapping
DISTRICT_MAP = {
    '上海市': 'SH',  # Special case for city-wide schools
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
    '金山区': 'JS',
    '松江区': 'SJ',
    '青浦区': 'QP',
    '奉贤区': 'FX',
    '崇明区': 'CM',
}

# ============================================================================
# ETL Functions
# ============================================================================

def extract_quota_district():
    """Extract quota allocation to district data from CSV"""
    input_file = os.path.join(PROCESSED_DIR, "2025年名额分配到区招生计划.csv")

    print("=" * 60)
    print("Step 1: Extract Quota Allocation to District Data")
    print("=" * 60)

    records = []
    school_codes = set()

    with open(input_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            school_code = row['招生代码'].strip()
            school_name = row['学校名称'].strip()
            district_name = row['所属区'].strip()
            district_code = row['区代码'].strip()
            quota_count = int(row['计划数'].strip())

            school_codes.add(school_code)

            records.append({
                'year': 2025,
                'school_code': school_code,
                'school_name': school_name,
                'district_name': district_name,
                'district_code': district_code,
                'quota_count': quota_count
            })

    print(f"Extracted {len(records)} records")
    print(f"Unique schools: {len(school_codes)}")
    print(f"Total quota: {sum(r['quota_count'] for r in records):,}")

    return records


def transform_quota_district(records):
    """Transform data for SQL generation"""
    print("\n" + "=" * 60)
    print("Step 2: Transform Data")
    print("=" * 60)

    transformed = []
    for record in records:
        transformed.append({
            'year': record['year'],
            'school_code': record['school_code'],
            'district_code': record['district_code'],
            'quota_count': record['quota_count']
        })

    # Group by school to show quota distribution
    school_quota = {}
    for t in transformed:
        key = (t['school_code'], t['district_code'])
        school_quota[key] = t['quota_count']

    print(f"Transformed {len(transformed)} records")
    print(f"Unique school-district pairs: {len(school_quota)}")

    return transformed


def generate_sql_seed(records):
    """Generate SQL seed file for quota allocation to district"""
    print("\n" + "=" * 60)
    print("Step 3: Generate SQL Seed File")
    print("=" * 60)

    output_file = os.path.join(SEEDS_DIR, "010_seed_quota_allocation_district_2025.sql")

    sql_lines = [
        "-- =============================================================================",
        "-- 2025年名额分配到区招生计划数据",
        "-- =============================================================================",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"-- Source: 2025年名额分配到区招生计划.csv",
        "",
        "-- Delete existing 2025 data",
        "DELETE FROM ref_quota_allocation_district WHERE year = 2025;",
        "",
        "-- Insert 2025 quota allocation to district data",
    ]

    for record in records:
        # Use INSERT with ON CONFLICT for upsert
        sql = (
            f"INSERT INTO ref_quota_allocation_district "
            f"(year, school_id, school_code, district_id, quota_count, data_year, created_at, updated_at) "
            f"SELECT "
            f"{record['year']}, "
            f"(SELECT id FROM ref_school WHERE code = '{record['school_code']}' AND data_year = 2025), "
            f"'{record['school_code']}', "
            f"(SELECT id FROM ref_district WHERE code = '{record['district_code']}'), "
            f"{record['quota_count']}, "
            f"{record['year']}, "
            f"CURRENT_TIMESTAMP, "
            f"CURRENT_TIMESTAMP "
            f"WHERE EXISTS (SELECT 1 FROM ref_school WHERE code = '{record['school_code']}' AND data_year = 2025) "
            f"AND EXISTS (SELECT 1 FROM ref_district WHERE code = '{record['district_code']}') "
            f"ON CONFLICT (year, school_code, district_id) DO UPDATE SET "
            f"quota_count = EXCLUDED.quota_count, "
            f"updated_at = CURRENT_TIMESTAMP;"
        )
        sql_lines.append(sql)

    # Add verification query
    sql_lines.extend([
        "",
        "-- Verify insert - show quota by school",
        "SELECT s.code, s.full_name, d.code as district_code, qad.quota_count",
        "FROM ref_quota_allocation_district qad",
        "JOIN ref_school s ON qad.school_code = s.code AND s.data_year = 2025",
        "JOIN ref_district d ON qad.district_id = d.id",
        "WHERE qad.year = 2025",
        "ORDER BY s.code, d.code;",
    ])

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"Output: {output_file}")
    print(f"Generated {len(records)} INSERT statements")


# ============================================================================
# Main
# ============================================================================

def main():
    print("\n" + "=" * 60)
    print("ETL Pipeline: 2025 Quota Allocation to District Data")
    print("=" * 60)

    # Step 1: Extract
    records = extract_quota_district()

    # Step 2: Transform
    transformed = transform_quota_district(records)

    # Step 3: Load (Generate SQL)
    generate_sql_seed(transformed)

    print("\n" + "=" * 60)
    print("ETL Pipeline Complete!")
    print("=" * 60)


if __name__ == '__main__':
    main()
