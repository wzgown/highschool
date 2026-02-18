#!/usr/bin/env python3
"""
2024年统一招生（1-15志愿）分数线数据导入ETL脚本

数据源: original_data/raw/2024/cutoff_scores/ 下各区CSV文件
目标表: ref_admission_score_unified

功能:
1. 读取所有16个区的原始分数线CSV
2. 匹配学校ID (通过学校代码或名称)
3. 生成SQL seed文件

运行方法:
  python etl/import_2024_unified_scores.py
"""

import csv
import os
import re
from pathlib import Path
from datetime import datetime

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
    '浦东区': 'PD',  # 文件名可能有这个变体
    '金山区': 'JS',
    '松江区': 'SJ',
    '青浦区': 'QP',
    '奉贤区': 'FX',
    '崇明区': 'CM',
}

# 原始数据目录
RAW_DATA_DIR = Path(__file__).parent.parent / 'original_data' / 'raw' / '2024' / 'cutoff_scores'
OUTPUT_DIR = Path(__file__).parent.parent / 'db' / 'seeds'


def parse_score(score_str):
    """解析分数字符串，返回float或None"""
    if not score_str or score_str.strip() == '':
        return None
    try:
        # 处理可能的格式问题
        score_str = score_str.strip().replace(' ', '')
        return float(score_str)
    except ValueError:
        return None


def parse_district_from_filename(filename):
    """从文件名提取区县名称"""
    # 文件名格式: 2024中考1-15志愿录取分数线XX区.csv
    match = re.search(r'分数线(\S+区)\.csv$', filename)
    if match:
        return match.group(1)
    return None


def read_raw_scores(file_path):
    """读取原始分数线CSV文件"""
    scores = []
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # 不同区的CSV格式可能略有不同
            # 尝试多种列名

            # 学校代码列名变体
            school_code = row.get('招生代码', row.get('学校代码', ''))

            # 学校名称列名变体
            school_name = row.get('招生学校', row.get('学校名称', row.get('招生学校名称', '')))

            # 分数列名变体 (多种格式)
            min_score = row.get('录取最低分', row.get('录取分数线', row.get('投档分数线', row.get('录取最低分 (含政策性加分)', ''))))

            # 同分比较字段
            chinese_math_foreign = row.get('语数外', row.get('语数外三科合计', row.get('末位录取考生成绩', '')))
            math_score = row.get('数学', '')
            chinese_score = row.get('语文', '')
            comprehensive = row.get('综合测试', '')

            if school_name and school_name.strip():
                scores.append({
                    'school_code': school_code.strip() if school_code else '',
                    'school_name': school_name.strip(),
                    'min_score': parse_score(min_score),
                    'chinese_math_foreign': parse_score(chinese_math_foreign),
                    'math_score': parse_score(math_score),
                    'chinese_score': parse_score(chinese_score),
                    'comprehensive': parse_score(comprehensive),
                })
    return scores


def generate_sql(district_name, scores):
    """生成SQL插入语句"""
    district_code = DISTRICT_CODE_MAP.get(district_name)
    if not district_code:
        print(f"  警告: 未找到区县代码: {district_name}")
        return []

    sql_statements = []

    for score in scores:
        if score['min_score'] is None:
            continue  # 跳过没有分数的记录

        # 转义单引号
        school_name = score['school_name'].replace("'", "''")
        school_code = score['school_code']

        # 构建字段和值
        fields = ['year', 'district_id', 'school_name', 'min_score', 'data_year']
        values = [
            '2024',
            f"(SELECT id FROM ref_district WHERE code = '{district_code}')",
            f"'{school_name}'",
            str(score['min_score']),
            '2024'
        ]

        # 添加同分比较字段
        if score['chinese_math_foreign'] is not None:
            fields.append('chinese_math_foreign_sum')
            values.append(str(score['chinese_math_foreign']))
        if score['math_score'] is not None:
            fields.append('math_score')
            values.append(str(score['math_score']))
        if score['chinese_score'] is not None:
            fields.append('chinese_score')
            values.append(str(score['chinese_score']))

        # 添加学校ID关联（通过学校代码）
        if school_code:
            fields.insert(2, 'school_id')
            values.insert(2, f"(SELECT id FROM ref_school WHERE code = '{school_code}' AND is_active = true LIMIT 1)")

        sql = f"""INSERT INTO ref_admission_score_unified ({', '.join(fields)}) SELECT {', '.join(values)} WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = '{district_code}') ON CONFLICT (year, district_id, school_name) DO UPDATE SET min_score = EXCLUDED.min_score, school_id = COALESCE(EXCLUDED.school_id, ref_admission_score_unified.school_id), updated_at = CURRENT_TIMESTAMP;"""
        sql_statements.append(sql)

    return sql_statements


def main():
    print("=" * 60)
    print("2024年统一招生分数线数据导入")
    print("=" * 60)

    all_sql = []
    total_records = 0
    districts_processed = []

    # 遍历所有分数线文件
    for file_path in sorted(RAW_DATA_DIR.glob('2024中考1-15志愿录取分数线*.csv')):
        district_name = parse_district_from_filename(file_path.name)
        if not district_name:
            print(f"跳过无法解析区县的文件: {file_path.name}")
            continue

        print(f"\n处理: {district_name}")
        scores = read_raw_scores(file_path)
        valid_scores = [s for s in scores if s['min_score'] is not None]

        print(f"  原始记录: {len(scores)}, 有效记录: {len(valid_scores)}")

        if valid_scores:
            sql_statements = generate_sql(district_name, valid_scores)
            all_sql.extend(sql_statements)
            total_records += len(sql_statements)
            districts_processed.append(district_name)

    # 生成输出文件
    output_file = OUTPUT_DIR / '060_seed_admission_score_unified_2024_all_districts.sql'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"-- =============================================================================\n")
        f.write(f"-- 2024年统一招生（1-15志愿）录取分数线 - 全市所有区\n")
        f.write(f"-- 自动生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"-- 数据来源: original_data/raw/2024/cutoff_scores/\n")
        f.write(f"-- 总记录数: {total_records}\n")
        f.write(f"-- 覆盖区县: {', '.join(districts_processed)}\n")
        f.write(f"-- =============================================================================\n\n")

        # 删除旧的2024数据（可选）
        f.write("-- 清理已有2024年数据（取消注释以启用）\n")
        f.write("-- DELETE FROM ref_admission_score_unified WHERE data_year = 2024;\n\n")

        for sql in all_sql:
            f.write(sql + '\n')

    print(f"\n{'=' * 60}")
    print(f"完成! 共处理 {len(districts_processed)} 个区, {total_records} 条记录")
    print(f"输出文件: {output_file}")
    print(f"{'=' * 60}")

    # 打印统计
    print("\n区县统计:")
    for district in districts_processed:
        print(f"  - {district}")


if __name__ == '__main__':
    main()
