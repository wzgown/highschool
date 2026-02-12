#!/usr/bin/env python3
"""统一并提取所有区的初中学校数据"""

import csv
import os
from pathlib import Path

# 配置
unified_dir = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/quota_school')

# 区名映射
DISTRICTS = {
    'HP': ('黄浦区', '黄浦'),
    'XH': ('徐汇区', '徐汇'),
    'CN': ('长宁区', '长宁'),
    'JA': ('静安区', '静安'),
    'PT': ('普陀区', '普陀'),
    'HK': ('虹口区', '虹口'),
    'YP': ('杨浦区', '杨浦'),
    'MH': ('闵行区', '闵行'),
    'BS': ('宝山区', '宝山'),
    'JD': ('嘉定区', '嘉定'),
    'PD': ('浦东新区', '浦东'),
    'JS': ('金山区', '金山'),
    'SJ': ('松江区', '松江'),
    'QP': ('青浦区', '青浦'),
    'FX': ('奉贤区', '奉贤'),
    'CM': ('崇明区', '崇明'),
}

def detect_district(filename):
    for code, names in DISTRICTS.items():
        for name in names:
            if name in filename:
                return code
    return None

def parse_standard(file_path):
    """解析标准格式"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row.get('学校编号', '').strip()
            name = row.get('学校名称', '').strip()
            if code and name:
                schools[code] = {
                    'name': name,
                    'short_name': name[:6] if len(name) > 6 else name,
                    'district_code': 'STANDARD',
                }

    return schools

def parse_info_format(file_path):
    """解析信息格式"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if not row.get('初中学校名称'):
                continue
            code = row.get('初中学校代码', '').strip()
            name = row.get('初中学校名称', '').strip()
            nature = 'PRIVATE' if '民办' in name else 'PUBLIC'
            if code and name:
                schools[code] = {
                    'name': name,
                    'short_name': name[:6] if len(name) > 6 else name,
                    'district_code': 'INFO',
                }

    return schools

def parse_jiading_format(file_path):
    """解析嘉定格式"""
    schools = set()
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('初中学校', '').strip()
            if name and name not in ['', '初中学校']:
                if not name.replace(',', '').replace('.', '').isdigit():
                    schools.add(name)

    return schools

def process_files():
    """处理所有文件"""
    all_schools = {}
    base_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/raw/2024/quota_school')
    csv_files = sorted(base_path.glob('*.csv'))

    for file_path in csv_files:
        filename = os.path.basename(file_path)
        district = detect(filename)

        if not district:
            print(f"跳过: {filename}")
            continue

        print(f"处理: {filename}")

        if district == 'STANDARD':
            schools = parse_standard(file_path)
        elif district == 'INFO':
            schools = parse_info_format(file_path)
        else:
            schools = parse_jiading_format(file_path)

        for code, info in schools.items():
            all_schools[code] = info

    return all_schools

# 处理文件并生成
all_schools = process_files()

output_file = unified_dir / 'middle_schools_2024_unified.csv'

with open(output_file, 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['序号', '学校代码', '学校名称', '办别', '所属区'])

    rows = []
    for code, info in sorted(all_schools.items(), key=lambda x: int(x[0])):
        rows.append([len(rows)+1, code, info['name'], info.get('nature', 'PUBLIC'), 'STANDARD'])

    writer.writerows(rows)

print(f"总学校数: {len(all_schools)}")
print(f"已生成: {output_file}")
