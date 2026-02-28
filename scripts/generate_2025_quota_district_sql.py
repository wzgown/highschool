#!/usr/bin/env python3
"""
ETL流程：从processed数据生成SQL种子文件（Transform -> Load第二步）
"""

import csv
from pathlib import Path

def generate_sql():
    """从processed目录的CSV生成SQL"""
    csv_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/quota_district/2025年名额分配到区招生计划.csv')
    output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds')
    output_file = output_path / '003_seed_quota_allocation_district_2025.sql'

    print(f"读取: {csv_path}")

    schools = []
    with open(csv_path, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # 计划数可能为空或非数字
            plan_count = 0
            try:
                plan_count = int(row['计划数']) if row['计划数'] else 0
            except (ValueError, TypeError):
                plan_count = 0

            schools.append({
                'seq_no': row['序号'],
                'code': row['招生代码'],
                'name': row['学校名称'],
                'district': row['所属区'],
                'district_code': row['区代码'],
                'plan_count': plan_count,
            })

    print(f"读取到 {len(schools)} 所学校")

    # 生成SQL
    sql_lines = []
    sql_lines.append("-- ========================================================================")
    sql_lines.append("-- 2025年名额分配到区招生计划 - 种子数据")
    sql_lines.append("-- 数据来源: PDF解析后提取的数据")
    sql_lines.append("-- 注：76所市实验性示范性高中，6724个名额")
    sql_lines.append("-- ========================================================================")
    sql_lines.append("")

    for school in schools:
        name = school['name'].replace("'", "''")
        sql_lines.append(f"-- {school['name']}")
        sql_lines.append("INSERT INTO ref_quota_allocation_district (year, school_id, school_code, district_id, quota_count, data_year) VALUES")
        sql_lines.append(f"    2025,")
        sql_lines.append(f"    (SELECT id FROM ref_school WHERE code = '{school['code']}'),")
        sql_lines.append(f"    '{school['code']}',")
        sql_lines.append(f"    (SELECT id FROM ref_district WHERE code = '{school['district_code']}'),")
        sql_lines.append(f"    {school['plan_count']},")
        sql_lines.append(f"    2025)")
        sql_lines.append("ON CONFLICT (year, school_id, district_id) DO UPDATE SET")
        sql_lines.append("    quota_count = EXCLUDED.quota_count,")
        sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
        sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"\n已生成: {output_file}")
    print(f"包含 {len(schools)} 条INSERT语句")

if __name__ == '__main__':
    generate_sql()
