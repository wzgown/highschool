#!/usr/bin/env python3
"""
生成2024年分数线数据SQL
从 processed/cutoff_scores/ 目录读取CSV数据并生成SQL INSERT语句
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
}

# 批次映射
BATCH_MAPPING = {
    '1-15志愿': 'unified',          # ref_admission_score_unified
    '平行志愿': 'unified',            # ref_admission_score_unified
    '名额分配到区': 'quota_district', # ref_admission_score_quota_district
    '分配到区': 'quota_district',      # ref_admission_score_quota_district
    '名额分配到校': 'quota_school', # ref_admission_score_quota_school
    '分配到校': 'quota_school',       # ref_admission_score_quota_school
}

# 批次表映射
TABLE_MAPPING = {
    'unified': 'ref_admission_score_unified',
    'quota_district': 'ref_admission_score_quota_district',
    'quota_school': 'ref_admission_score_quota_school',
}


def parse_cutoff_score(value):
    """解析分数线字符串，转换为数值"""
    if not value or value.strip() == '' or value.strip() == ',':
        return None
    try:
        return float(value.strip().rstrip(','))
    except ValueError:
        return None


def escape_sql(text):
    """转义SQL字符串"""
    if not text:
        return ''
    return text.replace("'", "''")


def generate_cutoff_scores_sql():
    """生成分数线SQL"""
    base_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/cutoff_scores')
    input_file = base_path / 'cutoff_scores_2024.csv'

    # 按批次分类数据
    unified_data = []
    quota_district_data = []
    quota_school_data = []

    print(f"📖 读取文件: {input_file}")

    with open(input_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            year = row.get('年份', '2024').strip()
            batch_type = row.get('批次', '').strip()
            district_name = row.get('区域', '').strip()
            school_name = row.get('学校名称', '').strip()
            school_code = row.get('学校代码', '').strip()
            cutoff_score = parse_cutoff_score(row.get('录取分数线', ''))

            # 跳过空行
            if not school_name or not school_code:
                continue

            # 映射区县代码
            district_code = DISTRICT_CODE_MAP.get(district_name, None)

            # 如果分数线为空，跳过
            if cutoff_score is None:
                continue

            data = {
                'year': year,
                'batch_type': batch_type,
                'district_name': district_name,
                'district_code': district_code,
                'school_name': school_name,
                'school_code': school_code,
                'cutoff_score': cutoff_score,
            }

            # 根据批次分类
            batch_key = BATCH_MAPPING.get(batch_type, 'unified')
            if batch_key == 'unified':
                unified_data.append(data)
            elif batch_key == 'quota_district':
                quota_district_data.append(data)
            elif batch_key == 'quota_school':
                quota_school_data.append(data)

    # 生成SQL文件
    generate_unified_sql(unified_data)
    generate_quota_district_sql(quota_district_data)
    generate_quota_school_sql(quota_school_data)

    print(f"✅ 统一招生: {len(unified_data)} 条")
    print(f"✅ 名额分配到区: {len(quota_district_data)} 条")
    print(f"✅ 名额分配到校: {len(quota_school_data)} 条")


def generate_unified_sql(data_list):
    """生成1-15志愿分数线SQL"""
    output_file = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds/030_seed_admission_score_unified_2024.sql')

    sql_lines = []
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 2024年1-15志愿录取分数线 - 种子数据")
    sql_lines.append("-- 数据来源: processed/cutoff_scores/cutoff_scores_2024.csv")
    sql_lines.append("-- 总分750分（学业考成绩）")
    sql_lines.append("-- ============================================================================")
    sql_lines.append("")

    for item in data_list:
        school_name = escape_sql(item['school_name'])
        district_code = item['district_code'] or 'UNKNOWN'
        district_name = escape_sql(item['district_name'])
        school_code = escape_sql(item['school_code'])
        min_score = item['cutoff_score']
        year = item['year']

        sql_lines.append(f"-- {school_name} ({school_code}) - {district_name}")
        sql_lines.append("INSERT INTO ref_admission_score_unified (")
        sql_lines.append("    year, district_id, school_name, min_score, data_year")
        sql_lines.append(") VALUES (")
        sql_lines.append(f"    {year}, (SELECT id FROM ref_district WHERE code = '{district_code}'), '{school_name}', {min_score}, {year}")
        sql_lines.append(") ON CONFLICT (year, district_id, school_name) DO UPDATE SET")
        sql_lines.append("    min_score = EXCLUDED.min_score,")
        sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
        sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"✅ 已生成: {output_file}")


def generate_quota_district_sql(data_list):
    """生成名额分配到区分数线SQL"""
    output_file = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds/031_seed_admission_score_quota_district_2024.sql')

    sql_lines = []
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 2024年名额分配到区录取分数线 - 种子数据")
    sql_lines.append("-- 数据来源: processed/cutoff_scores/cutoff_scores_2024.csv")
    sql_lines.append("-- 总分800分（学业考750分+综合素质评价50分）")
    sql_lines.append("-- ============================================================================")
    sql_lines.append("")

    for item in data_list:
        school_name = escape_sql(item['school_name'])
        district_code = item['district_code'] or 'UNKNOWN'
        district_name = escape_sql(item['district_name'])
        school_code = escape_sql(item['school_code'])
        min_score = item['cutoff_score']
        year = item['year']

        sql_lines.append(f"-- {school_name} ({school_code}) - {district_name}")
        sql_lines.append("INSERT INTO ref_admission_score_quota_district (")
        sql_lines.append("    year, district_id, school_name, min_score, data_year")
        sql_lines.append(") VALUES (")
        sql_lines.append(f"    {year}, (SELECT id FROM ref_district WHERE code = '{district_code}'), '{school_name}', {min_score}, {year}")
        sql_lines.append(") ON CONFLICT (year, district_id, school_name) DO UPDATE SET")
        sql_lines.append("    min_score = EXCLUDED.min_score,")
        sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
        sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"✅ 已生成: {output_file}")


def generate_quota_school_sql(data_list):
    """生成名额分配到校分数线SQL"""
    output_file = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds/032_seed_admission_score_quota_school_2024.sql')

    sql_lines = []
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 2024年名额分配到校录取分数线 - 种子数据")
    sql_lines.append("-- 数据来源: processed/cutoff_scores/cutoff_scores_2024.csv")
    sql_lines.append("-- 总分800分（学业考750分+综合素质评价50分）")
    sql_lines.append("-- 注: CSV中未包含初中学校信息，middle_school_name设为NULL")
    sql_lines.append("-- ============================================================================")
    sql_lines.append("")

    for item in data_list:
        school_name = escape_sql(item['school_name'])
        district_code = item['district_code'] or 'UNKNOWN'
        district_name = escape_sql(item['district_name'])
        school_code = escape_sql(item['school_code'])
        min_score = item['cutoff_score']
        year = item['year']

        sql_lines.append(f"-- {school_name} ({school_code}) - {district_name}")
        sql_lines.append("INSERT INTO ref_admission_score_quota_school (")
        sql_lines.append("    year, district_id, school_name, middle_school_name, min_score, data_year")
        sql_lines.append(") VALUES (")
        sql_lines.append(f"    {year}, (SELECT id FROM ref_district WHERE code = '{district_code}'), '{school_name}', NULL, {min_score}, {year}")
        sql_lines.append(") ON CONFLICT (year, district_id, school_name, middle_school_name) DO UPDATE SET")
        sql_lines.append("    min_score = EXCLUDED.min_score,")
        sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
        sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"✅ 已生成: {output_file}")


if __name__ == '__main__':
    generate_cutoff_scores_sql()
