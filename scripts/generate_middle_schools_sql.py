#!/usr/bin/env python3
"""
从名额分配到校数据中提取初中学校列表
生成初中学校 seed SQL
"""

import csv
import glob
import os
from pathlib import Path
from collections import defaultdict

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

# 从文件名提取区名的映射（处理带括号的文件名）
DISTRICT_FROM_FILENAME = {
    '嘉定区': ('JD', '嘉定区'),
    '奉贤区': ('FX', '奉贤区'),
    '宝山区': ('BS', '宝山区'),
    '普陀区': ('PT', '普陀区'),
    '松江区': ('SJ', '松江区'),
    '徐汇区': ('XH', '徐汇区'),
    '杨浦区': ('YP', '杨浦区'),
    '浦东区': ('PD', '浦东新区', '浦东区'),
    '闵行区': ('MH', '闵行区'),
    '青浦区': ('QP', '青浦区'),
    '静安区': ('JA', '静安区'),
    '黄浦区': ('HP', '黄浦区'),
    '金山区': ('JS', '金山区'),
    '崇明区': ('CM', '崇明区'),
}

# 办别映射
NATURE_CODE = 'PUBLIC'


def escape_sql(text):
    """转义SQL字符串"""
    if not text:
        return ''
    return text.replace("'", "''")


def detect_district_from_filename(filename):
    """从文件名检测所属区 - 优先匹配更长的区名"""
    # 按长度降序排列，优先匹配更具体的区名
    district_patterns = [
        ('嘉定区', 'JD'),
        ('奉贤区', 'FX'),
        ('宝山区', 'BS'),
        ('普陀区', 'PT'),
        ('松江区', 'SJ'),
        ('徐汇区', 'XH'),
        ('杨浦区', 'YP'),
        ('浦东新区', 'PD'),
        ('浦东区', 'PD'),
        ('闵行区', 'MH'),
        ('青浦区', 'QP'),
        ('静安区', 'JA'),
        ('黄浦区', 'HP'),
        ('金山区', 'JS'),
        ('崇明区', 'CM'),
        ('上海市', 'SH'),
    ]
    
    for district_name, code in district_patterns:
        if district_name in filename:
            return code
    
    return None


def parse_jiading_format(file_path):
    """解析嘉定区格式的文件"""
    middle_schools = set()

    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # 第一列"初中学校"的值就是学校名称
            middle_school_name = row.get('初中学校', '').strip()

            # 验证它看起来像学校名称（不是空或"初中学校"列名）
            if middle_school_name and middle_school_name not in ['', '初中学校']:
                # 进一步验证：不全是数字或逗号
                if not middle_school_name.replace(',', '').replace('.', '').isdigit():
                    middle_schools.add(middle_school_name)

    return middle_schools


def parse_fengxian_format(file_path, district_code):
    """解析奉贤区/通用格式的文件"""
    middle_schools = {}

    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # 查找初中学校代码列
            code = row.get('初中学校代码', '').strip() or row.get('校代码', '').strip()
            name = row.get('初中学校名称', '').strip()

            if code and name:
                middle_schools[code] = {
                    'name': name,
                    'short_name': name[:6] if len(name) > 6 else name,
                    'district_code': district_code,
                }

    return middle_schools


def scan_quota_school_files():
    """扫描所有名额分配到校文件，提取初中学校"""
    base_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/raw/2024/quota_school')

    all_middle_schools = {}

    # 使用 glob 获取所有 CSV 文件
    csv_files = list(base_path.glob('*.csv'))

    print(f"📂 找到 {len(csv_files)} 个文件")

    for file_path in sorted(csv_files):
        filename = os.path.basename(file_path)
        print(f"📖 处理: {filename}")

        # 检测区名
        district_code = detect_district_from_filename(filename)

        if not district_code:
            print(f"  ⚠️  无法识别区名，跳过")
            continue

        # 选择解析方式
        if district_code == 'JD':  # 嘉定区格式
            schools = parse_jiading_format(file_path)
            for name in schools:
                code = f'JD{len(all_middle_schools)+1:04d}'
                all_middle_schools[code] = {
                    'name': name,
                    'short_name': name[:6] if len(name) > 6 else name,
                    'district_code': district_code,
                    'district_name': '嘉定区',
                }
        elif district_code == 'FX':  # 奉贤区格式
            schools = parse_fengxian_format(file_path, district_code)
            for code, info in schools.items():
                all_middle_schools[code] = info
        else:
            # 其他区使用嘉定区格式（默认）
            schools = parse_jiading_format(file_path)
            for name in schools:
                code = f'{district_code}{len(all_middle_schools)+1:04d}'
                all_middle_schools[code] = {
                    'name': name,
                    'short_name': name[:6] if len(name) > 6 else name,
                    'district_code': district_code,
                    'district_name': DISTRICT_FROM_FILENAME.get(district_code, [''])[0],
                }

    return all_middle_schools


def generate_middle_school_sql():
    """生成初中学校 SQL"""
    middle_schools = scan_quota_school_files()

    output_file = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds/040_seed_middle_schools_2024.sql')

    sql_lines = []
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 2024年初中学校名单 - 种子数据（从名额分配到校数据提取）")
    sql_lines.append("-- 数据来源: raw/2024/quota_school/*.csv（共12个区文件）")
    sql_lines.append("-- 注：不选择生源初中默认为TRUE，适用于名额分配到校填报资格判断")
    sql_lines.append("-- 注：此数据仅包含有名额分配到校的初中学校")
    sql_lines.append("-- ============================================================================")
    sql_lines.append("")

    # 按区县分组
    district_groups = defaultdict(list)
    for code, info in middle_schools.items():
        district_groups[info['district_code']].append((code, info))

    # 按区县代码顺序生成
    district_order = ['HP', 'XH', 'CN', 'JA', 'PT', 'HK', 'YP', 'MH', 'BS', 'JD', 'PD', 'JS', 'SJ', 'QP', 'FX', 'CM']

    for district_code in district_order:
        if district_code not in district_groups:
            continue

        schools = district_groups[district_code]
        if not schools:
            continue

        # 获取中文名称
        district_cn = next((k for k, v in DISTRICT_FROM_FILENAME.items() if v == district_code), '')

        sql_lines.append(f"-- {district_cn}")

        for code, info in sorted(schools, key=lambda x: x[1]['name']):
            school_name = escape_sql(info['name'])
            short_name = school_name[:6] if len(school_name) > 6 else school_name

            sql_lines.append(f"-- {school_name}")
            sql_lines.append("INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES")
            sql_lines.append(f"    '{code}', '{school_name}', '{short_name}',")
            sql_lines.append(f"    (SELECT id FROM ref_district WHERE code = '{district_code}'), '{NATURE_CODE}', TRUE, 2024, TRUE)")
            sql_lines.append("ON CONFLICT (code, data_year) DO UPDATE SET")
            sql_lines.append("    name = EXCLUDED.name,")
            sql_lines.append("    short_name = EXCLUDED.short_name,")
            sql_lines.append("    district_id = EXCLUDED.district_id,")
            sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
            sql_lines.append("")

    # 写入文件
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"✅ 已生成: {output_file}")

    # 统计输出
    print("\n📊 各区学校统计:")
    district_counts = {}
    for code, info in middle_schools.items():
        district_counts[info['district_code']] = district_counts.get(info['district_code'], 0) + 1

    for district_code in district_order:
        count = district_counts.get(district_code, 0)
        if count > 0:
            district_cn = next((k for k, v in DISTRICT_CODE_MAP.items() if v == district_code), '')
            print(f"   {district_cn}: {count} 所")


if __name__ == '__main__':
    generate_middle_school_sql()
