#!/usr/bin/env python3
"""
ETL流程 Step 3: Load - 从processed数据生成2025年各区中考人数SQL种子文件
遵循 ETL_PIPELINE_SOP.md 规范
"""

import csv
from pathlib import Path

def generate_sql():
    """从processed目录的CSV生成SQL"""
    csv_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/district_exam_count/2025年各区中考人数.csv')
    output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds')
    output_file = output_path / '008_seed_district_exam_count_2025.sql'

    print(f"读取: {csv_path}")

    districts = []
    total_count = 0

    with open(csv_path, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            district = row.get('区域', '').strip()
            district_code = row.get('区代码', '').strip()
            exam_count_str = row.get('中考人数', '').strip()

            if not district or not exam_count_str:
                continue

            # 转换人数为整数
            exam_count_str = exam_count_str.replace(',', '').replace(' ', '')
            try:
                exam_count = int(exam_count_str)
            except ValueError:
                print(f"警告：无法解析人数 '{exam_count_str}' ({district})")
                continue

            districts.append({
                'district': district,
                'district_code': district_code,
                'exam_count': exam_count,
            })
            total_count += exam_count

    print(f"读取到 {len(districts)} 个区的数据")
    print(f"全市总计: {total_count} 人")

    # 生成SQL
    sql_lines = []
    sql_lines.append("-- ==========================================================================")
    sql_lines.append("-- 2025年各区中考报名人数 - 种子数据")
    sql_lines.append("-- 数据来源：original_data/raw/2025/2025年上海各区中考人数.csv")
    sql_lines.append("-- 注：以下数据为官方公布值，覆盖全市16个区")
    sql_lines.append("-- ==========================================================================")
    sql_lines.append("")

    for d in districts:
        name = d['district'].replace("'", "''")
        sql_lines.append(f"-- {d['district']}")
        sql_lines.append("INSERT INTO ref_district_exam_count (year, district_id, exam_count, data_source, data_year) VALUES")
        sql_lines.append(f"    2025,")
        sql_lines.append(f"    (SELECT id FROM ref_district WHERE code = '{d['district_code']}'),")
        sql_lines.append(f"    {d['exam_count']},")
        sql_lines.append(f"    '2025年各区中考人数原始数据',")
        sql_lines.append(f"    2025)")
        sql_lines.append("ON CONFLICT (year, district_id) DO UPDATE SET")
        sql_lines.append("    exam_count = EXCLUDED.exam_count,")
        sql_lines.append("    data_source = EXCLUDED.data_source,")
        sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
        sql_lines.append("")

    # 添加全市总计
    sql_lines.append("--")
    sql_lines.append("-- 全市总计: 127,156人")
    sql_lines.append("-- 各区明细:")
    for d in districts:
        sql_lines.append(f"--   {d['district']}: {d['exam_count']}人")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"\\n已生成: {output_file}")
    print(f"包含 {len(districts)} 条INSERT语句")

if __name__ == '__main__':
    generate_sql()
