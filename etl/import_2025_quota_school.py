#!/usr/bin/env python3
"""
2025年名额分配到校数据导入ETL脚本

数据源: original_data/processed/2025/quota_school/*.csv
目标表: ref_quota_allocation_school

CSV格式:
  year,district,district_code,middle_school_name,high_school_code,high_school_name,quota_count,source

运行方法:
  python etl/import_2025_quota_school.py
"""

import csv
import os
import glob
from pathlib import Path
from datetime import datetime

# 区县代码映射
DISTRICT_CODE_MAP = {
    'HP': '黄浦区',
    'XH': '徐汇区',
    'CN': '长宁区',
    'JA': '静安区',
    'PT': '普陀区',
    'HK': '虹口区',
    'YP': '杨浦区',
    'MH': '闵行区',
    'BS': '宝山区',
    'JD': '嘉定区',
    'PD': '浦东新区',
    'JS': '金山区',
    'SJ': '松江区',
    'QP': '青浦区',
    'FX': '奉贤区',
    'CM': '崇明区',
}

# 数据目录
DATA_DIR = Path(__file__).parent.parent / 'original_data' / 'processed' / '2025' / 'quota_school'
OUTPUT_DIR = Path(__file__).parent.parent / 'db' / 'seeds'


def read_quota_csv(file_path):
    """读取名额分配到校CSV文件"""
    records = []
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            records.append({
                'year': int(row.get('year', 2025)),
                'district': row.get('district', ''),
                'district_code': row.get('district_code', ''),
                'middle_school_name': row.get('middle_school_name', ''),
                'high_school_code': row.get('high_school_code', ''),
                'high_school_name': row.get('high_school_name', ''),
                'quota_count': int(row.get('quota_count', 0)),
                'source': row.get('source', ''),
            })
    return records


def generate_sql(records, district_name):
    """生成SQL插入语句"""
    sql_statements = []

    for rec in records:
        if not rec['quota_count'] or rec['quota_count'] <= 0:
            continue

        # 转义单引号
        middle_school_name = rec['middle_school_name'].replace("'", "''")
        high_school_name = rec['high_school_name'].replace("'", "''")
        high_school_code = rec['high_school_code']
        district_code = rec['district_code']

        # 构建INSERT语句，使用子查询获取外键ID
        sql = f"""INSERT INTO ref_quota_allocation_school (year, district_id, high_school_id, high_school_code, middle_school_id, middle_school_name, quota_count, data_year, created_at, updated_at) SELECT {rec['year']}, (SELECT id FROM ref_district WHERE code = '{district_code}'), (SELECT id FROM ref_school WHERE code = '{high_school_code}' AND is_active = true LIMIT 1), '{high_school_code}', (SELECT id FROM ref_middle_school WHERE name = '{middle_school_name}' AND district_id = (SELECT id FROM ref_district WHERE code = '{district_code}') LIMIT 1), '{middle_school_name}', {rec['quota_count']}, {rec['year']}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP WHERE EXISTS (SELECT 1 FROM ref_district WHERE code = '{district_code}') AND EXISTS (SELECT 1 FROM ref_school WHERE code = '{high_school_code}' AND is_active = true) ON CONFLICT (year, high_school_code, middle_school_name) DO UPDATE SET quota_count = EXCLUDED.quota_count, high_school_id = COALESCE(EXCLUDED.high_school_id, ref_quota_allocation_school.high_school_id), middle_school_id = COALESCE(EXCLUDED.middle_school_id, ref_quota_allocation_school.middle_school_id), updated_at = CURRENT_TIMESTAMP;"""
        sql_statements.append(sql)

    return sql_statements


def main():
    print("=" * 60)
    print("2025年名额分配到校数据导入")
    print("=" * 60)

    all_sql = []
    total_records = 0
    districts_processed = []

    # 查找所有CSV文件
    csv_files = list(DATA_DIR.glob('*名额分配到校*.csv'))

    if not csv_files:
        print(f"\n警告: 在 {DATA_DIR} 中未找到名额分配到校CSV文件")
        print("请确保数据文件存在，格式如下:")
        print("  year,district,district_code,middle_school_name,high_school_code,high_school_name,quota_count,source")
        return

    for csv_file in csv_files:
        print(f"\n处理: {csv_file.name}")
        records = read_quota_csv(csv_file)

        if not records:
            print("  无有效记录")
            continue

        district_name = records[0]['district'] if records else 'Unknown'
        valid_records = [r for r in records if r['quota_count'] > 0]

        print(f"  原始记录: {len(records)}, 有效记录: {len(valid_records)}")

        if valid_records:
            sql_statements = generate_sql(valid_records, district_name)
            all_sql.extend(sql_statements)
            total_records += len(sql_statements)
            districts_processed.append(district_name)

    # 生成输出文件
    output_file = OUTPUT_DIR / '061_seed_quota_allocation_school_2025_from_csv.sql'

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"-- =============================================================================\n")
        f.write(f"-- 2025年名额分配到校招生计划 - 从CSV导入\n")
        f.write(f"-- 自动生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"-- 数据来源: original_data/processed/2025/quota_school/\n")
        f.write(f"-- 总记录数: {total_records}\n")
        f.write(f"-- 覆盖区县: {', '.join(districts_processed)}\n")
        f.write(f"-- =============================================================================\n\n")

        # 删除旧的2025数据（可选）
        f.write("-- 清理已有2025年数据（取消注释以启用）\n")
        f.write(f"-- DELETE FROM ref_quota_allocation_school WHERE data_year = 2025 AND district_id IN (SELECT id FROM ref_district WHERE name IN ('{', '.join(districts_processed)}'));\n\n")

        for sql in all_sql:
            f.write(sql + '\n')

        # 添加估算学生人数的更新语句
        f.write("\n-- 更新初中学校估算人数\n")
        f.write("-- 参考: db/seeds/050_update_estimated_student_count.sql\n")

    print(f"\n{'=' * 60}")
    print(f"完成! 共处理 {len(districts_processed)} 个区, {total_records} 条记录")
    print(f"输出文件: {output_file}")
    print(f"{'=' * 60}")

    # 打印统计
    print("\n区县统计:")
    for district in districts_processed:
        print(f"  - {district}")

    print("\n下一步:")
    print("1. 检查生成的SQL文件")
    print("2. 运行: docker compose exec -T postgres psql -U highschool -d highschool -f /path/to/061_seed_quota_allocation_school_2025_from_csv.sql")
    print("3. 运行估算学生人数SQL: db/seeds/050_update_estimated_student_count.sql")


if __name__ == '__main__':
    main()
