#!/usr/bin/env python3
"""
从各区名额分配到校CSV文件中提取初中学校数据
穷举法：为每个区单独处理
"""

import csv
import re
from pathlib import Path

# 区代码映射
DISTRICT_CODES = {
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
    '浦东区': 'PD',
    '金山区': 'JS',
    '松江区': 'SJ',
    '青浦区': 'QP',
    '奉贤区': 'FX',
    '崇明区': 'CM',
}

def get_district_from_filename(filename):
    """从文件名获取区代码"""
    for district_name, code in DISTRICT_CODES.items():
        if district_name in filename:
            return district_name, code
    return None, None

def parse_huangpu(file_path):
    """黄浦区格式：第一行是高中代码名称，后续是初中代码+名称"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        # 从第二行开始解析
        for line in lines[1:]:
            line = line.strip()
            if not line:
                continue
            parts = line.split(',')
            if len(parts) >= 2:
                # 第一列格式：代码 学校名称
                first_col = parts[0].strip()
                match = re.match(r'(\d+)\s+(.+)', first_col)
                if match:
                    code = match.group(1)
                    name = match.group(2).strip()
                    if code and name:
                        schools[code] = name
    return schools

def parse_xuhui(file_path):
    """徐汇区格式：序号,学校编号,学校名称,..."""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row.get('学校编号', '').strip()
            name = row.get('学校名称', '').strip()
            if code and name:
                schools[code] = name
    return schools

def parse_jingan(file_path):
    """静安区格式：前3行是标题，第1列是学校代码，第2列是学校名称"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        lines = list(reader)
        # 跳过前3行标题
        for row in lines[3:]:
            if len(row) >= 2:
                code = row[0].strip()
                name = row[1].strip()
                if code and name and code != 'None':
                    schools[code] = name
    return schools

def parse_yangpu(file_path):
    """杨浦区格式：有两行重复标题，初中学校代码,初中学校名称,..."""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        # 跳过前两行重复标题
        reader = csv.DictReader(lines[2:])
        for row in reader:
            code = str(row.get('初中学校代码', '')).strip()
            name = row.get('初中学校名称', '').strip()
            if code and name and code != 'None':
                schools[code] = name
    return schools

def parse_pudong(file_path):
    """浦东区格式：序号,初中学校名称,..."""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        idx = 1
        for row in reader:
            name = row.get('初中学校名称', '').strip()
            if name:
                # 生成代码：区代码+序号
                code = f'PD{idx:04d}'
                schools[code] = name
                idx += 1
    return schools

def parse_minhang(file_path):
    """闵行区格式：第1行是"初中学校信息"，第2行是标题，从第3行开始是数据"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        lines = list(reader)
        # 跳过前2行（第1行是"初中学校信息"，第2行是列标题）
        for row in lines[2:]:
            if len(row) >= 2:
                code = row[0].strip()
                name = row[1].strip()
                if code and name and code != 'None':
                    schools[code] = name
    return schools

def parse_baoshan(file_path):
    """宝山区格式：序号,学校代码,学校名称,..."""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row.get('学校代码', '').strip()
            name = row.get('学校名称', '').strip()
            if code and name:
                schools[code] = name
    return schools

def parse_putuo(file_path):
    """普陀区格式：学校代码,学校名称,...（第一行有重复标题）"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        # 跳过第一行重复标题
        reader = csv.DictReader(lines[1:])
        for row in reader:
            code = str(row.get('学校代码', '')).strip()
            name = row.get('学校名称', '').strip()
            if code and name and code != 'None':
                schools[code] = name
    return schools

def parse_songjiang(file_path):
    """松江区格式：学校代码,毕业学校,..."""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row.get('学校代码', '').strip()
            name = row.get('毕业学校', '').strip()
            if code and name:
                schools[code] = name
    return schools

def parse_qingpu(file_path):
    """青浦区格式：招生学校代码,招生学校名称,初中学校代码,初中学校名称,计划数"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row.get('初中学校代码', '').strip()
            name = row.get('初中学校名称', '').strip()
            if code and name:
                schools[code] = name
    return schools

def parse_jiading(file_path):
    """嘉定区格式：初中学校,...（第一列直接是学校名称）"""
    schools = {}
    idx = 1
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('初中学校', '').strip()
            if name and name not in ['', '初中学校']:
                if not name.replace(',', '').replace('.', '').isdigit():
                    code = f'JD{idx:04d}'
                    schools[code] = name
                    idx += 1
    return schools

def parse_fengxian(file_path):
    """奉贤区格式：初中学校代码,初中学校名称,...（列名可能有换行符）"""
    schools = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # 尝试多种可能的列名
            code = (row.get('初中学校代码', '') or row.get('初中学\n校代码', '') or
                    row.get('初中代码', '') or '').strip()
            name = (row.get('初中学校名称', '') or row.get('初中学校', '')).strip()
            if code and name:
                schools[code] = name
    return schools

def parse_cutoff_format(file_path, district_code):
    """解析cutoff_scores目录下的文件格式（长宁、虹口、金山、崇明）"""
    schools = {}
    idx = 1
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        lines = list(reader)
        # 跳过前两行标题
        for row in lines[2:]:
            if len(row) >= 1:
                name = row[0].strip()
                if name and name not in ['', '初中学校']:
                    # 避免重复
                    if name not in schools.values():
                        code = f'{district_code}{idx:04d}'
                        schools[code] = name
                        idx += 1
    return schools

# 区名到解析函数的映射
DISTRICT_PARSERS = {
    '黄浦区': parse_huangpu,
    '徐汇区': parse_xuhui,
    '静安区': parse_jingan,
    '杨浦区': parse_yangpu,
    '浦东区': parse_pudong,
    '闵行区': parse_minhang,
    '宝山区': parse_baoshan,
    '普陀区': parse_putuo,
    '松江区': parse_songjiang,
    '青浦区': parse_qingpu,
    '嘉定区': parse_jiading,
    '奉贤区': parse_fengxian,
}

# 需要从cutoff_scores目录提取的区
CUTOFF_DISTRICTS = {
    '长宁区': 'CN',
    '虹口区': 'HK',
    '金山区': 'JS',
    '崇明区': 'CM',
}

def main():
    """主处理函数"""
    base_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/raw/2024/quota_school')
    cutoff_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/raw/2024/cutoff_scores')
    output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/quota_school')
    output_path.mkdir(parents=True, exist_ok=True)

    all_schools = []

    # 处理quota_school目录的文件
    csv_files = sorted(base_path.glob('*.csv'))

    for csv_file in csv_files:
        filename = csv_file.name
        print(f"处理: {filename}")

        district_name, district_code = get_district_from_filename(filename)

        if not district_name or district_name not in DISTRICT_PARSERS:
            print(f"  跳过: 无法识别区名")
            continue

        parser = DISTRICT_PARSERS[district_name]
        schools = parser(csv_file)

        print(f"  提取到 {len(schools)} 所学校")

        for code, name in schools.items():
            nature = 'PRIVATE' if '民办' in name else 'PUBLIC'
            all_schools.append({
                'code': code,
                'name': name,
                'nature': nature,
                'district_code': district_code,
                'district_name': district_name,
            })

    # 处理cutoff_scores目录的文件（长宁、虹口、金山、崇明）
    cutoff_files = sorted(cutoff_path.glob('*名额分配到校*.csv'))

    for csv_file in cutoff_files:
        filename = csv_file.name
        print(f"处理: {filename}")

        district_name, district_code = get_district_from_filename(filename)

        if not district_name or district_name not in CUTOFF_DISTRICTS:
            print(f"  跳过: 无法识别区名")
            continue

        schools = parse_cutoff_format(csv_file, district_code)

        print(f"  提取到 {len(schools)} 所学校")

        for code, name in schools.items():
            nature = 'PRIVATE' if '民办' in name else 'PUBLIC'
            all_schools.append({
                'code': code,
                'name': name,
                'nature': nature,
                'district_code': district_code,
                'district_name': district_name,
            })

    # 排序：按区代码顺序
    district_order = ['HP', 'XH', 'CN', 'JA', 'PT', 'HK', 'YP', 'MH', 'BS', 'JD', 'PD', 'JS', 'SJ', 'QP', 'FX', 'CM']
    all_schools.sort(key=lambda x: (district_order.index(x['district_code']) if x['district_code'] in district_order else 999, x['code']))

    # 输出CSV
    output_file = output_path / 'middle_schools_2024_unified.csv'
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['序号', '学校代码', '学校名称', '办别', '所属区', '区代码'])

        for idx, school in enumerate(all_schools, 1):
            writer.writerow([
                idx,
                school['code'],
                school['name'],
                school['nature'],
                school['district_name'],
                school['district_code'],
            ])

    print(f"\n总计: {len(all_schools)} 所学校")
    print(f"已生成: {output_file}")

    # 生成SQL
    generate_sql(all_schools)

def generate_sql(schools):
    """生成SQL seed文件"""
    sql_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/db/seeds')
    output_file = sql_path / '040_seed_middle_schools_2024.sql'

    sql_lines = []
    sql_lines.append("-- " + "=" * 76)
    sql_lines.append("-- 2024年初中学校名单 - 种子数据（从名额分配到校数据提取）")
    sql_lines.append("-- 数据来源: raw/2024/quota_school/*.csv（12个区）+ cutoff_scores/*.csv（4个区）")
    sql_lines.append("-- 注：不选择生源初中默认为TRUE，适用于名额分配到校填报资格判断")
    sql_lines.append("-- 注：此数据仅包含有名额分配到校的初中学校")
    sql_lines.append("-- " + "=" * 76)
    sql_lines.append("")

    for school in schools:
        code = school['code']
        name = school['name'].replace("'", "''")
        short_name = name[:6] if len(name) > 6 else name
        district_code = school['district_code']

        sql_lines.append(f"-- {school['name']}")
        sql_lines.append("INSERT INTO ref_middle_school (code, name, short_name, district_id, school_nature_id, is_non_selective, data_year, is_active) VALUES")
        sql_lines.append(f"    '{code}', '{name}', '{short_name}',")
        sql_lines.append(f"    (SELECT id FROM ref_district WHERE code = '{district_code}'), '{school['nature']}', TRUE, 2024, TRUE)")
        sql_lines.append("ON CONFLICT (code, data_year) DO UPDATE SET")
        sql_lines.append("    name = EXCLUDED.name,")
        sql_lines.append("    short_name = EXCLUDED.short_name,")
        sql_lines.append("    district_id = EXCLUDED.district_id,")
        sql_lines.append("    updated_at = CURRENT_TIMESTAMP;")
        sql_lines.append("")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_lines))

    print(f"已生成SQL: {output_file}")

if __name__ == '__main__':
    main()
