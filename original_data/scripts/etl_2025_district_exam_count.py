#!/usr/bin/env python3
"""
ETL脚本：处理2025年上海各区中考人数数据

Source: original_data/raw/2025/2025_shanghai_district_exam_count.csv
Output: db/seeds/009_seed_district_exam_count_2025.sql

This script processes the district exam count data and generates SQL seed file.
"""

import csv
import os
from pathlib import Path
from datetime import datetime

# ============================================================================
# Configuration
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW_DIR = os.path.join(BASE_DIR, "raw", "2025")
SEEDS_DIR = os.path.join(BASE_DIR, "..", "db", "seeds")
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "district_exam_count")

# Create directories
Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)
Path(SEEDS_DIR).mkdir(parents=True, exist_ok=True)

# District code mapping (Chinese -> Code)
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

def extract_district_exam_count():
    """Extract district exam count data from CSV"""
    input_file = os.path.join(RAW_DIR, "2025_shanghai_district_exam_count.csv")

    print("=" * 60)
    print("Step 1: Extract District Exam Count Data")
    print("=" * 60)

    records = []
    total_students = 0

    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            district = row['区域'].strip()
            count = int(row[' 25年中考人数'].strip())

            # Get district code
            district_code = DISTRICT_MAP.get(district)

            if district_code:
                records.append({
                    'year': 2025,
                    'district_name': district,
                    'district_code': district_code,
                    'exam_count': count
                })
                total_students += count
                print(f"  {district}: {count:,}")
            else:
                print(f"  ⚠ Unknown district: {district}")

    print(f"\nTotal students: {total_students:,}")

    # Save to processed CSV
    processed_csv = os.path.join(PROCESSED_DIR, "2025年各区中考人数_processed.csv")
    with open(processed_csv, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['year', 'district_name', 'district_code', 'exam_count']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)

    print(f"\nOutput: {processed_csv}")
    return records


def transform_district_exam_count(records):
    """Transform data for SQL generation"""
    print("\n" + "=" * 60)
    print("Step 2: Transform Data")
    print("=" * 60)

    transformed = []
    for record in records:
        transformed.append({
            'year': record['year'],
            'district_code': record['district_code'],
            'exam_count': record['exam_count']
        })

    print(f"Transformed {len(transformed)} records")
    return transformed


def generate_sql_seed(records):
    """Generate SQL seed file for district exam count"""
    print("\n" + "=" * 60)
    print("Step 3: Generate SQL Seed File")
    print("=" * 60)

    output_file = os.path.join(SEEDS_DIR, "009_seed_district_exam_count_2025.sql")

    sql_lines = [
        "-- =============================================================================",
        "-- 2025年各区中考人数数据",
        "-- =============================================================================",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"-- Source: 2025_shanghai_district_exam_count.csv",
        "",
        "-- Delete existing 2025 data",
        "DELETE FROM ref_district_exam_count WHERE year = 2025;",
        "",
        "-- Insert 2025 district exam count data",
    ]

    for record in records:
        sql_lines.append(
            f"INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_year, created_at, updated_at)"
        )
        sql_lines.append(
            f"SELECT "
            f"{record['year']}, "
            f"(SELECT id FROM ref_district WHERE code = '{record['district_code']}'), "
            f"{record['exam_count']}, "
            f"{record['year']}, "
            f"CURRENT_TIMESTAMP, "
            f"CURRENT_TIMESTAMP"
        )
        sql_lines.append(
            f"WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = '{record['district_code']}');"
        )
        sql_lines.append("")

    # Add summary
    sql_lines.extend([
        "",
        "-- Verify insert",
        "SELECT d.code, d.name, dec.exam_count",
        "FROM ref_district_exam_count dec",
        "JOIN ref_district d ON dec.district_id = d.id",
        "WHERE dec.year = 2025",
        "ORDER BY d.display_order;",
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
    print("ETL Pipeline: 2025 District Exam Count Data")
    print("=" * 60)

    # Step 1: Extract
    records = extract_district_exam_count()

    # Step 2: Transform
    transformed = transform_district_exam_count(records)

    # Step 3: Load (Generate SQL)
    generate_sql_seed(transformed)

    print("\n" + "=" * 60)
    print("ETL Pipeline Complete!")
    print("=" * 60)


if __name__ == '__main__':
    main()
