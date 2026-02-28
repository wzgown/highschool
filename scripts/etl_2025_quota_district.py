#!/usr/bin/env python3
"""
ETL流程：从PDF提取2025年名额分配到区数据
遵循 Extract -> Transform -> Load 流程
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

def extract_pdf_to_csv(pdf_path, csv_output_path):
    """从PDF提取数据到CSV（Extract + Transform第一步）"""
    print(f"正在提取: {pdf_path}")

    with pdfplumber.open(pdf_path) as pdf:
        all_schools = []

        # 解析每一页的表格
        for page_num, page in enumerate(pdf.pages):
            tables = page.extract_tables()

            for table_num, table in enumerate(tables):
                schools = parse_table(table)

                if schools:
                    print(f"第{page_num + 1}页表格{table_num + 1}: 解析到 {len(schools)} 所学校")
                    all_schools.extend(schools)

    print(f"总共提取到 {len(all_schools)} 条记录")

    # 去重（按代码+名称）
    unique_schools = {}
    for school in all_schools:
        key = f"{school['code']}_{school['name']}"
        if key not in unique_schools:
            unique_schools[key] = school

    print(f"去重后: {len(unique_schools)} 所学校")

    # 写入processed目录的CSV文件
    csv_output_path.mkdir(parents=True, exist_ok=True)
    output_file = csv_output_path / '2025年名额分配到区招生计划.csv'

    with open(output_file, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['序号', '招生代码', '学校名称', '所属区', '区代码', '计划数'])

        for school in unique_schools.values():
            writer.writerow([
                school['seq_no'],
                school['code'],
                school['name'],
                school['district'],
                school['district_code'],
                school['plan_count'],
            ])

    print(f"✅ 已生成: {output_file}")
    return len(unique_schools)

def parse_table(table):
    """解析表格数据"""
    schools = []

    # 跳过标题行
    for row_idx, row in enumerate(table[1:], start=1):
        if len(row) < 9:
            continue

        # 清理每列的数据
        cells = [clean_text(str(cell)) if cell else '' for cell in row]

        seq_no = cells[0]
        code = cells[1]
        name = cells[2]
        district = cells[3]

        # 提取计划数
        plan_count = 0
        for i in range(8, len(cells)):
            cell_text = cells[i]
            if cell_text and cell_text.isdigit():
                plan_count = int(cell_text)
                break

        # 验证必要字段
        if not code or not name or not district:
            continue

        if code and code.isdigit():
            schools.append({
                'seq_no': seq_no,
                'code': code,
                'name': name,
                'district': district,
                'district_code': DISTRICT_MAP.get(district, 'SH'),
                'plan_count': plan_count,
            })

    return schools

def main():
    pdf_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/policies/2025年名额分配到区招生计划.pdf')

    print("=" * 60)
    print("ETL流程: Extract -> Transform -> Load")
    print("=" * 60)
    print("Step 1 (Extract): 从PDF提取数据到CSV")
    print(f"  输入: {pdf_path}")

    school_count = extract_pdf_to_csv(pdf_path,
        Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/quota_district'))

    print()
    print("=" * 60)
    print("Step 2完成: 数据已提取并保存到processed目录")
    print()
    print(f"  共处理: {school_count} 所学校的数据")
    print(f"  数据文件: /Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/quota_district/2025年名额分配到区招生计划.csv")
    print()
    print("下一步: 使用generate_2025_quota_district_sql.py从processed数据生成SQL种子文件")

if __name__ == '__main__':
    main()
