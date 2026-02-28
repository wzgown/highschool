#!/usr/bin/env python3
"""
从PDF文件解析2025年名额分配到区招生计划
使用pdfplumber提取表格
"""

import csv
import pdfplumber
from pathlib import Path

# 区代码映射
DISTRICT_MAP = {
    '上海市': 'SH',
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

NATURE_MAP = {
    '公办': 'PUBLIC',
    '民办': 'PRIVATE',
}

SCHOOL_TYPE_MAP = {
    '市实验性示范性高中': 'CITY_MODEL',
    '市实验性示范性高中（招生政策）': 'CITY_POLICY',
    '市特色普通高中': 'CITY_FEATURED',
}

BOARDING_MAP = {
    '全部寄宿': 'FULL',
    '部分寄宿': 'PARTIAL',
    '无寄宿': 'NONE',
}

PLAN_AREA_MAP = {
    '全市': 'ALL',
    '本区': 'DISTRICT',
    '外区': 'OTHER',
}

def clean_text(text):
    """清理文本中的换行符和多余字符"""
    if not text:
        return ''

    # 移除换行符
    text = text.replace('\n', '')

    # 移除常见的错误前缀字符
    unwanted_prefixes = ['不', '许', '可', '转', '载', '经', '得', '未']
    for prefix in unwanted_prefixes:
        if text.startswith(prefix):
            text = text[len(prefix):]
            break

    # 移除多余的标点
    text = text.replace('，', '').replace('。', '')

    return text.strip()

def parse_table_data(table):
    """解析表格数据"""
    schools = []

    # 跳过标题行
    for row in table[1:]:  # 跳过第1行（表头）
        if len(row) < 9:
            continue

        # 清理每列的数据
        cells = [clean_text(str(cell)) if cell else '' for cell in row]

        seq_no = cells[0]
        code = cells[1]
        name = cells[2]
        district = cells[3]
        nature = cells[4]
        school_type = cells[5]
        boarding = cells[6]
        plan_area = cells[7]
        plan_count_str = cells[8]

        # 验证必要字段
        if not code or not name or not district:
            continue

        # 处理代码（移除非数字字符）
        code_clean = ''.join(c for c in code if c.isdigit())

        # 处理办别
        nature = 'PUBLIC'  # 默认
        if cells[4] in NATURE_MAP:
            nature = NATURE_MAP[cells[4]]

        # 处理学校类型
        school_type = 'CITY_MODEL'  # 默认
        if cells[5] in SCHOOL_TYPE_MAP:
            school_type = SCHOOL_TYPE_MAP[cells[5]]

        # 处理寄宿情况
        boarding = 'PARTIAL'  # 默认
        if cells[6] in BOARDING_MAP:
            boarding = BOARDING_MAP[cells[6]]

        # 处理计划区域
        plan_area = 'ALL'  # 默认
        if cells[7] in PLAN_AREA_MAP:
            plan_area = PLAN_AREA_MAP[cells[7]]

        # 处理计划数
        try:
            plan_count = int(plan_count_str) if plan_count_str and plan_count_str.isdigit() else 0
        except:
            plan_count = 0

        if code_clean and name:
            schools.append({
                'seq_no': seq_no,
                'code': code_clean,
                'name': name,
                'district': district,
                'district_code': DISTRICT_MAP.get(district, 'SH'),
                'nature': nature,
                'school_type': school_type,
                'boarding': boarding,
                'plan_area': plan_area,
                'plan_count': plan_count,
            })

    return schools

def main():
    pdf_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/policies/2025-名额分配到区招生计划.pdf')

    print(f"正在解析: {pdf_path}")

    with pdfplumber.open(pdf_path) as pdf:
        print(f"PDF总页数: {len(pdf.pages)}")

        all_schools = []

        # 解析每一页的表格
        for page_num, page in enumerate(pdf.pages):
            tables = page.extract_tables()
            print(f"第{page_num + 1}页: 提取到 {len(tables)} 个表格")

            for table_num, table in enumerate(tables):
                schools = parse_table_data(table)
                print(f"  表格{table_num + 1}: 解析到 {len(schools)} 所学校")

                all_schools.extend(schools)

    print(f"\n总计解析到 {len(all_schools)} 条记录")

    # 去重（按学校代码）
    unique_schools = {}
    for school in all_schools:
        code = school['code']
        name = school['name']
        # 用代码+名称作为唯一键
        key = f"{code}_{name}"
        if key not in unique_schools:
            unique_schools[key] = school

    print(f"去重后: {len(unique_schools)} 所学校")

    # 输出CSV
    output_dir = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/raw/2025/quota_district')
    output_dir.mkdir(parents=True, exist_ok=True)

    output_file = output_dir / '2025年名额分配到区招生计划.csv'

    with open(output_file, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([
            '序号', '招生代码', '学校名称', '所属区', '区代码', '办别',
            '学校类型代码', '学校类型', '寄宿情况代码', '寄宿情况',
            '计划区域代码', '计划区域', '计划数'
        ])

        for school in unique_schools.values():
            writer.writerow([
                school['seq_no'],
                school['code'],
                school['name'],
                school['district'],
                school['district_code'],
                school['nature'],
                school['school_type'],
                # 学校类型中文名称
                next((k for k, v in SCHOOL_TYPE_MAP.items() if v == school['school_type']), ''),
                # 寄宿情况中文名称
                next((k for k, v in BOARDING_MAP.items() if v == school['boarding']), ''),
                school['plan_area'],
                # 计划区域中文名称
                next((k for k, v in PLAN_AREA_MAP.items() if v == school['plan_area']), ''),
                school['plan_count'],
            ])

    print(f"\n已生成: {output_file}")

if __name__ == '__main__':
    main()
