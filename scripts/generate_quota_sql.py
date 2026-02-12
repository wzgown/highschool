#!/usr/bin/env python3
"""
生成2024年名额分配数据SQL
从 processed/quota/ 目录读取CSV数据并生成SQL INSERT语句
"""

import csv
import os
from pathlib import Path

# 区县代码映射
DISTRICT_CODE_MAP = {
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
    '上海市': 'SH',
}

# 办别映射
NATURE_MAP = {
    '公办': 'PUBLIC',
    '民办': 'PRIVATE',
}

# 学校类型映射
SCHOOL_TYPE_MAP = {
    '市实验性示范性高中': 'CITY_MODEL',
    '市实验性示范性高中（教委直属）': 'CITY_MODEL',
    '区实验性示范性高中': 'DISTRICT_MODEL',
    '享受市实验性示范性高中招生政策高中': 'CITY_POLICY',
    '一般高中': 'GENERAL',
    '中职校': 'VOCATIONAL',
}


def escape_sql(text):
    """转义SQL字符串"""
    if not text:
        return ''
    return text.replace("'", "''")


def generate_quota_district_sql():
    """生成名额分配到区数据SQL"""
    base_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/quota')
    input_file = base_path / 'quota_to_district_2024.csv'
    output_file = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds/033_seed_quota_allocation_district_2024.sql')

    print(f"📖 读取文件: {input_file}")

    sql_lines = []
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 2024年名额分配到区招生计划 - 种子数据")
    sql_lines.append("-- 数据来源: processed/quota/quota_to_district_2024.csv")
    sql_lines.append("-- ============================================================================")
    sql_lines.append("")

    school_count = 0

    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            school_code = row.get('学校 招生代码', '').strip()
            if not school_code:
                continue

            school_name = escape_sql(row.get('学校名称', '').strip())
            belong_district = escape_sql(row.get('所属区', '').strip())
            school_nature = escape_sql(row.get('办别', '').strip())
            school_type = escape_sql(row.get('学校类型', '').strip())
            boarding_type = escape_sql(row.get('寄宿情况', '').strip())
            plan_district = escape_sql(row.get('计划区域', '').strip())
            quota_count = row.get('计划数', '0').strip()

            # 映射字段值
            nature_code = NATURE_MAP.get(school_nature, 'PUBLIC')

            # 跳过空记录
            if not school_name:
                continue

            school_count += 1

            # 根据计划区域决定district_id
            if plan_district == '全市':
                district_code = 'SH'
            else:
                district_code = DISTRICT_CODE_MAP.get(belong_district, 'UNKNOWN')

            sql_lines.append(f"-- {school_name} ({school_code}) - {belong_district}")
            sql_lines.append("INSERT INTO ref_quota_allocation_district (")
            sql_lines.append("    year, school_id, school_code, district_id, quota_count, data_year")
            sql_lines.append(") VALUES (")
            sql_lines.append(f"    2024, (SELECT id FROM ref_school WHERE code = '{school_code}' AND data_year = 2024), '{school_code}',")
            sql_lines.append(f"    (SELECT id FROM ref_district WHERE code = '{district_code}'), {quota_count}, 2024")
            sql_lines.append(") ON CONFLICT (year, school_code, district_id) DO UPDATE SET")
            sql_lines.append("    quota_count = EXCLUDED.quota_count,")
            sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
            sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"✅ 已生成: {output_file}")
    print(f"✅ 总计: {school_count} 条记录")


def generate_quota_school_sql():
    """生成名额分配到校数据SQL"""
    base_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/quota')
    input_file = base_path / 'quota_to_school_2024.csv'
    output_file = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds/034_seed_quota_allocation_school_2024.sql')

    print(f"📖 读取文件: {input_file}")

    if not input_file.exists():
        print(f"⚠️  文件不存在: {input_file}")
        return

    sql_lines = []
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 2024年名额分配到校招生计划 - 种子数据")
    sql_lines.append("-- 数据来源: processed/quota/quota_to_school_2024.csv")
    sql_lines.append("-- ============================================================================")
    sql_lines.append("")

    school_count = 0

    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            high_school_code = row.get('高中学校代码', '').strip()
            if not high_school_code:
                continue

            high_school_name = escape_sql(row.get('高中学校名称', '').strip())
            district_name = escape_sql(row.get('区县', '').strip())
            middle_school_name = escape_sql(row.get('初中学校名称', '').strip())
            quota_count = row.get('名额数', '0').strip()

            # 跳过空记录
            if not high_school_name:
                continue

            school_count += 1

            district_code = DISTRICT_CODE_MAP.get(district_name, 'UNKNOWN')

            sql_lines.append(f"-- {high_school_name} ({high_school_code}) -> {middle_school_name}")
            sql_lines.append("INSERT INTO ref_quota_allocation_school (")
            sql_lines.append("    year, district_id, high_school_id, high_school_code, middle_school_name, quota_count, data_year")
            sql_lines.append(") VALUES (")
            sql_lines.append(f"    2024, (SELECT id FROM ref_district WHERE code = '{district_code}'),")
            sql_lines.append(f"    (SELECT id FROM ref_school WHERE code = '{high_school_code}' AND data_year = 2024), '{high_school_code}', '{middle_school_name}', {quota_count}, 2024")
            sql_lines.append(") ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET")
            sql_lines.append("    quota_count = EXCLUDED.quota_count,")
            sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
            sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"✅ 已生成: {output_file}")
    print(f"✅ 总计: {school_count} 条记录")


if __name__ == '__main__':
    generate_quota_district_sql()
    generate_quota_school_sql()
