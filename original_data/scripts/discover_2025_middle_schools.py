#!/usr/bin/env python3
"""
Discover and validate new middle schools from 2025 quota-to-school data

基于静安区正确数据模式，发现并验证新初中学校
"""

import csv
import os
import re
from pathlib import Path
from collections import defaultdict

# ============================================================================
# 配置
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")
SEEDS_DIR = os.path.join(BASE_DIR, "..", "db", "seeds")

# 区县代码映射
DISTRICT_MAP = {
    '黄浦': 'HP', '徐汇': 'XH', '长宁': 'CN', '静安': 'JA',
    '普陀': 'PT', '虹口': 'HK', '杨浦': 'YP', '闵行': 'MH',
    '宝山': 'BS', '嘉定': 'JD', '浦东': 'PD', '金山': 'JS',
    '松江': 'SJ', '青浦': 'QP', '奉贤': 'FX', '崇明': 'CM',
}

# ============================================================================
# 工具函数
# ============================================================================

def extract_district_from_filename(filename):
    """从文件名提取区名"""
    for zh, code in DISTRICT_MAP.items():
        if zh in filename:
            return zh, code
    return "未知", "UNK"


def clean_school_name(name):
    """清理学校名"""
    name = name.strip()
    name = re.sub(r'\s+', ' ', name)
    return name.strip()


def load_reference_schools():
    """从数据库加载已知学校（2025年）"""
    schools = {}
    try:
        with open('/Users/lance.wang/workspace/wzgown/highschool_new/db/seeds/002_seed_schools_2025_full.sql', 'r', encoding='utf-8') as f:
            content = f.read()
            # 提取INSERT语句中的学校名
            for match in re.finditer(r"'([^']+)'", content):
                school = match.group(1)
                if school:
                    KNOWN_HIGH_SCHOOLS.add(school)
        # 只提取前76所学校
        if len(KNOWN_HIGH_SCHOOLS) > 76:
            break
    except Exception as e:
        print(f"  警告: 无法加载参考数据: {e}")

    print(f"已加载 {len(KNOWN_HIGH_SCHOOLS)} 所已知高中学校")
    return schools


def parse_quota_to_school_csv(csv_file):
    """解析名额分配到校CSV，提取初中学校"""
    records = []
    middle_schools = set()

    with open(csv_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            district = row['区名称']
            middle_code = row['初中学校代码'].strip()
            middle_name = row['初中学校'].strip()
            high_code = row['高中学校代码']

            # 添加到初中学校集合
            if middle_code and middle_name:
                key = f"{district}_{middle_name}"
                if key not in middle_schools:
                    middle_schools.add(key)

            records.append({
                '年份': 2025,
                '批次': '名额分配到校',
                '区名称': district,
                '初中学校代码': middle_code,
                '初中学校': middle_name,
                '高中学校代码': high_code,
                '名额': row.get('名额', 0),
                '文件来源': row.get('文件来源', ''),
            })

    return records, middle_schools


def validate_and_discover(reference_schools, quota_records):
    """验证并发现新学校"""
    new_schools = []

    # 检查用户提到的两所嘉定学校
    target_jiading_schools = [
        ('交大附中附属嘉定', 'JD0015'),
        ('上海师范大学附属中学', 'JD0018'),
    ]

    found_schools = set()

    # 按区统计初中学校
    district_middle_count = defaultdict(int)
    for record in quota_records:
        district = record['区名称']
        middle_name = record['初中学校']
        if middle_name:
            district_middle_count[district] += 1

    print(f"\n各区的初中学校数量:")
    for district, count in sorted(district_middle_count.items()):
        print(f"  {district}: {count}")

    # 查找用户特别提到的学校
    print(f"\n查找目标学校:")

    # 在参考数据中查找
    for code, name in reference_schools.items():
        for target_code, target_name in target_jiading_schools:
            similarity_score = 0
            # 精确匹配
            if name == target_name:
                similarity_score = 100
            # 包含匹配
            elif target_code in code:
                similarity_score = 80
            # 部分匹配
            # 包含关键词
            elif target_code in code or target_code in name:
                similarity_score = 60
            # 名称相似
            elif name in code or code in name:
                similarity_score = 40

        if similarity_score > 80:
            found_schools.add((target_code, name))
            print(f"  ✓ 找到: {name} (代码: {target_code})")

    # 在配额数据中查找
    for record in quota_records:
        middle_name = record['初中学校']
        # 清理名称，移除可能的OCR错误
        clean_name = re.sub(r'^院\s*', '', middle_name)
        clean_name = re.sub(r'院$', '', clean_name)

        # 检查是否在已知学校中
        for ref_code, ref_name in reference_schools.items():
            # 代码或名称匹配
            if (ref_code == middle_name or
                ref_name in middle_name or
                middle_name in ref_name or
                ref_code in clean_name):

                # 找到匹配
                found_schools.add((ref_code, ref_name))
                break

    print(f"\n已知学校中: {len(found_schools)}")

    # 发现新学校（不在参考数据中的）
    new_schools_list = []
    for key, middle_schools in middle_schools:
        if key not in found_schools:
            # 这是一个新发现的学校
            # 从quota_records中提取完整信息
            matching_records = [r for r in quota_records
                             if r['初中学校'] == key]

            if matching_records:
                new_schools_list.append({
                    '代码': key.split('_')[1],
                    '名称': key.split('_')[1],
                    '区县': key.split('_')[0],
                    '来源': '2025名额分配到校数据',
                    '验证状态': '待验证',
                })

    if new_schools_list:
        print(f"\n发现 {len(new_schools_list)} 所新初中学校")
        for school in sorted(new_schools_list, key=lambda x: x['名称']):
            print(f"  - {school['名称']} (区: {school['区县']})")

    return new_schools_list


def generate_sql(middle_schools, quota_records):
    """生成SQL语句"""
    sql_lines = []

    # 1. 插入新发现的初中学校
    if middle_schools:
        print(f"\n生成新初中学校SQL:")
        for school in middle_schools:
            code = school['代码']
            name = school['名称']
            district_code = school['区县']

            sql_lines.extend([
                f"-- 新发现初中学校: {name}",
                f"INSERT INTO ref_middle_school (code, name, district_id, school_level_id, is_active, data_year, created_at, updated_at)",
                f"SELECT (SELECT id FROM ref_district WHERE code = '{district_code}');",
                f"VALUES ('{code}', '{name}', (SELECT id FROM ref_district WHERE code = '{district_code}'),",
                f"'MIDDLE', TRUE, TRUE, 2025, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);",
                "",
                f"-- ON CONFLICT (code, data_year) DO UPDATE SET is_active = TRUE, updated_at = CURRENT_TIMESTAMP;",
            ])

    print(f"  生成 {len(sql_lines)} 条SQL语句")

    # 2. 更新配额数据中的初中学校ID
    if quota_records:
        print(f"\n更新配额数据中的初中学校引用:")
        update_count = 0
        for record in quota_records:
            middle_name = record['初中学校']
            # 清理名称
            clean_name = re.sub(r'^院\s*', '', middle_name)
            clean_name = re.sub(r'院$', '', clean_name)

            sql_lines.extend([
                f"-- 更新: {middle_name}",
                f"UPDATE ref_quota_allocation_school SET middle_school_id = (",
                f"(SELECT id FROM ref_middle_school WHERE code = '{record['初中学校代码']}'",
                f"AND district_id = (SELECT id FROM ref_district WHERE code = '{record['区名称']}'),",
                f"AND data_year = 2025);",
                f"WHERE middle_school_name = '{clean_name}';",
            ])
            update_count += 1

        print(f"  更新了 {update_count} 条记录")

    sql_lines.extend([
        "",
        "-- 验证特定学校（用户提到的）",
        "-- 交大附中附属嘉定德富/洪德中学",
        "SELECT id, code, full_name, district_id FROM ref_middle_school WHERE code LIKE '%交大%' AND name LIKE '%附属%' AND district_id = (SELECT id FROM ref_district WHERE code = 'JD') AND data_year = 2025);",
        "",
        "-- 上海师范大学附属中学嘉定新城分校",
        "SELECT id, code, full_name, district_id FROM ref_middle_school WHERE code LIKE '%上海师范%' AND name LIKE '%嘉定新城分校%' AND district_id = (SELECT id FROM ref_district WHERE code = 'JD') AND data_year = 2025);",
    ])

    return '\n'.join(sql_lines)


def main():
    print("=" * 60)
    print("2025年名额分配到校数据处理 - 新学校发现")
    print("=" * 60)
    print()
    print("策略：")
    print("1. 基于2025正确处理的静安区数据模式")
    print("2. 从参考数据库加载已知高中学校")
    print("3. 解析所有区的名额分配到校CSV")
    print("4. 验证并发现新学校（特别是用户提到的两所嘉定学校）")
    print("=" * 60)

    # 加载参考学校
    reference_schools = load_reference_schools()

    # 查找配额CSV文件
    csv_files = list(Path(PROCESSED_DIR).glob('*名额分配到校*.csv'))

    if not csv_files:
        print("错误：未找到配额CSV文件")
        print("请先运行其他ETL脚本生成配额数据")
        return

    # 使用第一个CSV文件
    quota_csv = csv_files[0]
    print(f"\n处理配额文件: {quota_csv}")

    # 解析配额数据
    quota_records = parse_quota_to_school_csv(quota_csv)

    if not quota_records:
        print("错误：未能解析配额数据")
        return

    print(f"解析到 {len(quota_records)} 条配额记录")

    # 验证和发现新学校
    new_middle_schools, sql_lines = validate_and_discover(reference_schools, quota_records)

    # 生成SQL
    output_sql = os.path.join(SEEDS_DIR, "010_discover_and_update_2025_quota_school.sql")

    with open(output_sql, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"\nSQL文件: {output_sql}")
    print(f"\n总结:")
    print(f"  - 已知高中学校: {len(reference_schools)}")
    print(f"  - 配额记录: {len(quota_records)}")
    print(f"  - 新发现初中学校: {len(new_middle_schools)}")
    print(f"  - SQL输出: {output_sql}")
    print()
    print("处理完成！")


if __name__ == '__main__':
    main()
