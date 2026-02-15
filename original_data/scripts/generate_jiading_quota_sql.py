#!/usr/bin/env python3
"""
生成嘉定区 2025 年名额分配到校 SQL 种子文件

Author: Claude
Date: 2025-02-15
"""

import csv
import os
from datetime import datetime
from pathlib import Path

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(BASE_DIR, "processed", "2025", "quota_school", "嘉定_2025_名额分配到校.csv")
OUTPUT_SQL = os.path.join(BASE_DIR, "..", "db", "seeds", "053_seed_2025_jiading_quota_school.sql")

def generate_sql():
    """生成 SQL INSERT 语句"""
    records = []

    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            records.append(row)

    sql_lines = [
        "-- =============================================================================",
        "-- 2025年嘉定区名额分配到校招生计划数据",
        "-- =============================================================================",
        f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"-- Source: 嘉定_2025_名额分配到校.csv",
        f"-- Records: {len(records)}",
        "",
        "-- Delete existing 2025 Jiading data",
        "DELETE FROM ref_quota_allocation_school WHERE year = 2025 AND district_id = (SELECT id FROM ref_district WHERE code = 'JD');",
        "",
        "-- Insert 2025 quota allocation to school data for Jiading",
    ]

    for r in records:
        middle_name = r['middle_school_name'].replace("'", "''")
        high_code = r['high_school_code']
        high_name = r['high_school_name'].replace("'", "''")
        quota = r['quota_count']

        sql = f"""INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at)
SELECT 2025,
    (SELECT id FROM ref_district WHERE code = 'JD'),
    (SELECT id FROM ref_school WHERE code = '{high_code}' AND data_year = 2025),
    '{high_code}',
    (SELECT id FROM ref_middle_school WHERE name = '{middle_name}' AND data_year = 2025),
    '{middle_name}',
    {quota},
    2025,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = 'JD')
AND EXISTS (SELECT 1 FROM ref_school WHERE code = '{high_code}' AND data_year = 2025)
ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET
    quota_count = EXCLUDED.quota_count,
    updated_at = CURRENT_TIMESTAMP;"""

        sql_lines.append(sql)

    # 添加统计信息
    sql_lines.extend([
        "",
        "-- Verification query",
        "SELECT d.name as district,",
        "       COUNT(*) as total_records,",
        "       SUM(q.quota_count) as total_quotas",
        "FROM ref_quota_allocation_school q",
        "JOIN ref_district d ON q.district_id = d.id",
        "WHERE q.year = 2025 AND d.code = 'JD'",
        "GROUP BY d.name;",
        "",
        "-- Check Hongde Middle School data",
        "SELECT q.year, s.full_name as high_school, q.middle_school_name, q.quota_count",
        "FROM ref_quota_allocation_school q",
        "JOIN ref_school s ON q.high_school_id = s.id",
        "WHERE q.year = 2025 AND q.middle_school_name LIKE '%洪德%';",
    ])

    output = '\n'.join(sql_lines)

    Path(OUTPUT_SQL).parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_SQL, 'w', encoding='utf-8') as f:
        f.write(output)

    print(f"Generated SQL file: {OUTPUT_SQL}")
    print(f"Total records: {len(records)}")

    # 显示洪德中学数据
    hongde = [r for r in records if '洪德' in r['middle_school_name']]
    if hongde:
        print("\n洪德中学数据:")
        for r in hongde:
            print(f"  {r['high_school_code']} - {r['high_school_name']}: {r['quota_count']}")

if __name__ == '__main__':
    generate_sql()
