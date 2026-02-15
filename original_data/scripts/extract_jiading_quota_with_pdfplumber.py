#!/usr/bin/env python3
"""
使用 pdfplumber 提取嘉定区 2025 年名额分配到校数据

Author: Claude
Date: 2025-02-15
"""

import pdfplumber
import csv
import os
import re
from pathlib import Path

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PDF_PATH = os.path.join(BASE_DIR, "raw", "2025", "quota_district", "2025_quota_to_school_jiading.pdf")
OUTPUT_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")
Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

# 高中代码映射
HIGH_SCHOOL_MAP = {
    '142001': '上海市嘉定区第一中学',
    '142002': '上海交通大学附属中学嘉定分校',
    '142004': '上海师范大学附属中学嘉定新城分校',
    '102056': '上海交通大学附属中学',
    '102057': '复旦大学附属中学',
    '042032': '上海市上海中学',
    '152003': '华东师范大学第二附属中学',
    '152006': '上海师范大学附属中学',
}

def extract_tables_from_pdf():
    """从 PDF 提取所有表格"""
    all_tables = []

    with pdfplumber.open(PDF_PATH) as pdf:
        print(f"PDF 页数: {len(pdf.pages)}")

        for page_num, page in enumerate(pdf.pages):
            print(f"\n处理第 {page_num + 1} 页...")

            # 提取表格
            tables = page.extract_tables()
            print(f"  发现 {len(tables)} 个表格")

            for table_num, table in enumerate(tables):
                print(f"  表格 {table_num + 1}: {len(table)} 行")
                all_tables.append({
                    'page': page_num + 1,
                    'table_num': table_num + 1,
                    'data': table
                })

            # 也提取文本
            text = page.extract_text()
            if text:
                print(f"  文本长度: {len(text)} 字符")

    return all_tables

def parse_quota_data(tables):
    """解析名额分配数据"""
    quota_records = []
    current_high_code = None
    current_high_name = None

    for table_info in tables:
        table = table_info['data']
        page = table_info['page']

        for row in table:
            if not row:
                continue

            # 清理单元格
            cells = [str(cell).strip() if cell else '' for cell in row]

            # 检查是否是高中代码行
            for cell in cells:
                code_match = re.match(r'^(\d{6})$', cell)
                if code_match and code_match.group(1) in HIGH_SCHOOL_MAP:
                    current_high_code = code_match.group(1)
                    current_high_name = HIGH_SCHOOL_MAP[current_high_code]
                    print(f"  发现高中代码: {current_high_code} - {current_high_name}")

            # 检查是否有初中学校和名额
            # 格式通常是: [初中学校名] [名额]
            if current_high_code:
                # 尝试从行中提取初中学校和名额
                middle_name = None
                quota = None

                for i, cell in enumerate(cells):
                    # 检查是否是初中学校名称
                    if '中学' in cell or '学校' in cell:
                        if '上海市' in cell or '上海' in cell or '交大' in cell or '中科院' in cell:
                            # 可能是初中学校
                            if cell not in HIGH_SCHOOL_MAP.values():
                                middle_name = cell

                    # 检查是否是数字（名额）
                    if cell.isdigit() and len(cell) <= 3:
                        num = int(cell)
                        if 1 <= num <= 100:  # 合理的名额范围
                            quota = num

                if middle_name and quota:
                    record = {
                        'year': 2025,
                        'district': '嘉定区',
                        'district_code': 'JD',
                        'high_school_code': current_high_code,
                        'high_school_name': current_high_name,
                        'middle_school_name': middle_name,
                        'quota_count': quota,
                        'source': f'page_{page}'
                    }
                    quota_records.append(record)
                    print(f"    提取: {middle_name} -> {current_high_name}: {quota}")

    return quota_records

def parse_text_content():
    """直接解析 PDF 文本内容"""
    quota_records = []
    current_high_code = None
    current_high_name = None

    with pdfplumber.open(PDF_PATH) as pdf:
        for page_num, page in enumerate(pdf.pages):
            text = page.extract_text()
            if not text:
                continue

            lines = text.split('\n')

            for i, line in enumerate(lines):
                line = line.strip()

                # 检查高中代码
                code_match = re.search(r'(\d{6})', line)
                if code_match:
                    code = code_match.group(1)
                    if code in HIGH_SCHOOL_MAP:
                        current_high_code = code
                        current_high_name = HIGH_SCHOOL_MAP[code]
                        print(f"第{page_num+1}页 - 高中: {current_high_code} - {current_high_name}")

                # 尝试提取 "初中学校名 数字" 模式
                # 例如: "上海市嘉定区启良中学 7"
                pattern = r'([^\d]+?[中学校院])(?:\s+)?(\d{1,3})(?:\s|$)'
                matches = re.findall(pattern, line)
                for name, num in matches:
                    name = name.strip()
                    if name and num.isdigit():
                        quota = int(num)
                        if 1 <= quota <= 100 and current_high_code:
                            # 检查不是高中名称
                            if name not in HIGH_SCHOOL_MAP.values():
                                record = {
                                    'year': 2025,
                                    'district': '嘉定区',
                                    'district_code': 'JD',
                                    'high_school_code': current_high_code,
                                    'high_school_name': current_high_name,
                                    'middle_school_name': name,
                                    'quota_count': quota,
                                    'source': f'page_{page_num+1}'
                                }
                                quota_records.append(record)

    return quota_records

def main():
    print("=" * 60)
    print("嘉定区 2025 年名额分配到校数据提取")
    print("=" * 60)

    print(f"\n读取 PDF: {PDF_PATH}")

    # 方法1: 提取表格
    print("\n--- 方法1: 表格提取 ---")
    tables = extract_tables_from_pdf()
    records_from_tables = parse_quota_data(tables)

    # 方法2: 直接解析文本
    print("\n--- 方法2: 文本解析 ---")
    records_from_text = parse_text_content()

    # 合并结果
    all_records = records_from_tables + records_from_text

    # 去重
    seen = set()
    unique_records = []
    for r in all_records:
        key = (r['high_school_code'], r['middle_school_name'], r['quota_count'])
        if key not in seen:
            seen.add(key)
            unique_records.append(r)

    print(f"\n提取结果: {len(unique_records)} 条唯一记录")

    # 保存到 CSV
    if unique_records:
        output_csv = os.path.join(OUTPUT_DIR, "嘉定_2025_名额分配到校.csv")
        fieldnames = ['year', 'district', 'district_code', 'high_school_code',
                     'high_school_name', 'middle_school_name', 'quota_count', 'source']

        with open(output_csv, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(unique_records)

        print(f"保存到: {output_csv}")

        # 显示统计
        print("\n按高中统计:")
        high_stats = {}
        for r in unique_records:
            code = r['high_school_code']
            if code not in high_stats:
                high_stats[code] = {'name': r['high_school_name'], 'count': 0, 'total': 0}
            high_stats[code]['count'] += 1
            high_stats[code]['total'] += r['quota_count']

        for code, stats in sorted(high_stats.items()):
            print(f"  {code} - {stats['name']}: {stats['count']} 所初中, 共 {stats['total']} 个名额")

    return unique_records

if __name__ == '__main__':
    main()
