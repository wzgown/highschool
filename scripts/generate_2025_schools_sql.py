#!/usr/bin/env python3
"""
ETL流程 Step 3: Load - 从processed数据生成2025年学校全量SQL种子文件
"""

import csv
from pathlib import Path

# 办别、类型、寄宿代码映射（需要从中文名称映射到代码）
NATURE_CODE_MAP = {
    '公办': 'PUBLIC',
    '民办': 'PRIVATE',
    '中外合作': 'COOPERATION',
}

TYPE_CODE_MAP = {
    '市实验性示范性高中': 'CITY_MODEL',
    '享受市实验性示范性高中招生政策高中': 'CITY_POLICY',
    '区实验性示范性高中': 'DISTRICT_MODEL',
}

BOARDING_CODE_MAP = {
    '全部寄宿': 'FULL',
    '部分寄宿': 'PARTIAL',
    '无寄宿': 'NONE',
}

def generate_sql():
    """从processed目录的CSV生成SQL"""
    csv_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/schools/2025年学校信息.csv')
    output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds')
    output_file = output_path / '002_seed_schools_2025_full.sql'

    print(f"读取: {csv_path}")

    schools = []
    with open(csv_path, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row.get('招生代码', '').strip()
            name = row.get('学校名称', '').strip()
            district = row.get('所属区', '上海市')
            district_code = row.get('区代码', 'SH')

            if not code or not name:
                continue

            # 解析学校类型（需要映射）
            school_type_cn = row.get('学校类型', '')
            school_type_code = TYPE_CODE_MAP.get(school_type_cn, 'GENERAL')

            # 解析办别
            nature_cn = row.get('办别', '')
            # 如果CSV中是空，默认为公办
            nature_code = NATURE_CODE_MAP.get(nature_cn, 'PUBLIC')

            # 解析寄宿情况
            boarding_cn = row.get('寄宿情况', '')
            boarding_code = 'NONE'
            if '全部' in boarding_cn:
                boarding_code = 'FULL'
            elif '部分' in boarding_cn:
                boarding_code = 'PARTIAL'

            schools.append({
                'code': code,
                'name': name,
                'district': district,
                'district_code': district_code,
                'school_type_code': school_type_code,
                'school_nature_code': nature_code,
                'boarding_code': boarding_code,
                'source': row.get('备注', ''),
            })

    print(f"读取到 {len(schools)} 所学校的数据")

    # 生成SQL
    sql_lines = []
    sql_lines.append("-- ==========================================================================")
    sql_lines.append("-- 2025年学校全量数据 - 种子数据")
    sql_lines.append("-- 数据来源：original_data/processed/2025/schools/2025年学校信息.csv")
    sql_lines.append("-- 来源：基于2025年名额分配到区招生计划（76所）")
    sql_lines.append("-- 注：全量更新2025年学校信息，覆盖ref_school表")
    sql_lines.append("-- ==========================================================================")
    sql_lines.append("")

    for s in schools:
        name = s['name'].replace("'", "''")
        sql_lines.append(f"-- {s['name']}")
        sql_lines.append("INSERT INTO ref_school (code, full_name, short_name, district_id, school_nature_id, school_type_id, boarding_type_id, has_international_course, data_year, is_active) VALUES")
        sql_lines.append(f"    '{s['code']}',")
        sql_lines.append(f"    '{name}',")
        sql_lines.append(f"    (SELECT id FROM ref_district WHERE code = '{s['district_code']}'),")
        sql_lines.append(f"    (SELECT id FROM ref_school_nature WHERE code = '{s['school_nature_code']}'),")
        sql_lines.append(f"    (SELECT id FROM ref_school_type WHERE code = '{s['school_type_code']}'),")
        sql_lines.append(f"    (SELECT id FROM ref_boarding_type WHERE code = '{s['boarding_code']}'),")
        sql_lines.append(f"    FALSE,")
        sql_lines.append(f"    2025,")
        sql_lines.append(f"    '{s['source']}'")
        sql_lines.append(f"    2025)")
        sql_lines.append("ON CONFLICT (code) DO UPDATE SET")
        sql_lines.append("    full_name = EXCLUDED.full_name,")
        sql_lines.append("    short_name = EXCLUDED.short_name,")
        sql_lines.append("    district_id = EXCLUDED.district_id,")
        sql_lines.append("    school_nature_id = EXCLUDED.school_nature_id,")
        sql_lines.append("    school_type_id = EXCLUDED.school_type_id,")
        sql_lines.append("    boarding_type_id = EXCLUDED.boarding_type_id,")
        sql_lines.append("    updated_at = CURRENT_TIMESTAMP")
        sql_lines.append("")

        # 添加空行
        sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"\\n已生成: {output_file}")
    print(f"包含 {len(schools)} 条INSERT语句")

if __name__ == '__main__':
    generate_sql()
