#!/usr/bin/env python3
"""
ETL流程：从PDF提取2025年名额分配到区数据
"""

import csv
import pdfplumber
from pathlib import Path

DISTRICT_MAP = {
    '上海市': 'SH', '黄浦区': 'HP', '徐汇区': 'XH', '长宁区': 'CN',
    '静安区': 'JA', '普陀区': 'PT', '虹口区': 'HK', '杨浦区': 'YP',
    '闵行区': 'MH', '宝山区': 'BS', '嘉定区': 'JD', '浦东新区': 'PD',
    '金山区': 'JS', '松江区': 'SJ', '青浦区': 'QP', '奉贤区': 'FX', '崇明区': 'CM',
}

def clean_text(text):
    if not text:
        return ''
    text = text.replace('\n', '')
    unwanted_prefixes = ['不', '许', '可', '转', '载', '经', '得', '未']
    for prefix in unwanted_prefixes:
        if text.startswith(prefix):
            text = text[len(prefix):]
            break
    text = text.replace('，', '').replace('。', '')
    return text.strip()

def extract_pdf_to_csv(pdf_path, csv_output_path):
    with pdfplumber.open(pdf_path) as pdf:
        all_schools = []
        for page_num, page in enumerate(pdf.pages):
            tables = page.extract_tables()
            for table_num, table in enumerate(tables):
                schools = parse_table(table)
                if schools:
                    print(f"Page {page_num+1} Table {table_num+1}: {len(schools)} schools")
                    all_schools.extend(schools)

    unique_schools = {}
    for school in all_schools:
        key = f"{school['code']}_{school['name']}"
        if key not in unique_schools:
            unique_schools[key] = school

    csv_output_path.mkdir(parents=True, exist_ok=True)
    output_file = csv_output_path / '2025年名额分配到区招生计划.csv'

    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['序号', '招生代码', '学校名称', '所属区', '区代码', '计划数'])
        for school in unique_schools.values():
            writer.writerow([school['seq_no'], school['code'], school['name'],
                          school['district'], school['district_code'], school['plan_count']])

    print(f"Extracted {len(unique_schools)} schools to {output_file}")
    return len(unique_schools)

def parse_table(table):
    schools = []
    for row_idx, row in enumerate(table[1:], start=1):
        if len(row) < 9:
            continue
        cells = [clean_text(str(cell)) if cell else '' for cell in row]
        seq_no = cells[0]
        code = cells[1]
        name = cells[2]
        district = cells[3]
        plan_count = 0
        for i in range(8, len(cells)):
            cell_text = cells[i]
            if cell_text and cell_text.isdigit():
                plan_count = int(cell_text)
                break
        if not code or not name or not district:
            continue
        if code and code.isdigit():
            schools.append({'seq_no': seq_no, 'code': code, 'name': name,
                          'district': district, 'district_code': DISTRICT_MAP.get(district, 'SH'),
                          'plan_count': plan_count})
    return schools

def main():
    base_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/raw/2025')
    pdf_path = base_path / 'policies/2025年名额分配到区招生计划.pdf'
    csv_output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/quota_district')

    print("ETL Pipeline: 2025 Quota Allocation District")
    school_count = extract_pdf_to_csv(pdf_path, csv_output_path)
    print(f"Total: {school_count} schools extracted")
