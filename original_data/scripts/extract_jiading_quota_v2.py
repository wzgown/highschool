#!/usr/bin/env python3
"""
使用 pdfplumber 精确提取嘉定区 2025 年名额分配到校数据

表格结构：
- 列1: 初中学校名称
- 列2-4: 高中代码1, 高中名称1, 计划数1 (可能为空)
- 列5-7: 高中代码2, 高中名称2, 计划数2
- 列8-10: 高中代码3, 高中名称3, 计划数3
- 列11-13: 高中代码4, 高中名称4, 计划数4

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

def clean_name(name):
    """清理学校名称"""
    if not name:
        return ""
    name = name.replace('\n', '').strip()
    return name

def extract_quota_data():
    """从 PDF 表格提取名额分配数据"""
    quota_records = []

    with pdfplumber.open(PDF_PATH) as pdf:
        for page_num, page in enumerate(pdf.pages):
            tables = page.extract_tables()

            for table in tables:
                # 跳过表头行
                for row_idx, row in enumerate(table):
                    if row_idx < 2:  # 跳过前两行表头
                        continue

                    if not row or len(row) < 5:
                        continue

                    # 第一列是初中学校名称
                    middle_name = clean_name(row[0])
                    if not middle_name or middle_name == '初中学校':
                        continue

                    # 解析 4 组高中数据
                    # 每组 3 个字段: 代码(可选), 名称, 计划数
                    groups = [
                        (row[1], row[2], row[3]),   # 第1组
                        (row[4], row[5], row[6]),   # 第2组
                        (row[7], row[8], row[9]),   # 第3组
                        (row[10], row[11], row[12]) if len(row) > 12 else (None, None, None),  # 第4组
                    ]

                    for code, name, quota in groups:
                        # 清理数据
                        code = clean_name(str(code)) if code else None
                        name = clean_name(str(name)) if name else None
                        quota_str = clean_name(str(quota)) if quota else None

                        # 检查是否有有效的名额数字
                        if quota_str and quota_str.isdigit():
                            quota_num = int(quota_str)
                            if 1 <= quota_num <= 100:
                                # 提取高中代码 (6位数字)
                                high_code = None
                                if code and re.match(r'^\d{6}$', code):
                                    high_code = code

                                # 清理高中名称
                                high_name = name if name else None

                                if high_code and high_name:
                                    record = {
                                        'year': 2025,
                                        'district': '嘉定区',
                                        'district_code': 'JD',
                                        'middle_school_name': middle_name,
                                        'high_school_code': high_code,
                                        'high_school_name': high_name,
                                        'quota_count': quota_num,
                                        'source': f'page_{page_num+1}'
                                    }
                                    quota_records.append(record)
                                    print(f"  {middle_name} -> {high_code} {high_name}: {quota_num}")

    return quota_records

def main():
    print("=" * 60)
    print("嘉定区 2025 年名额分配到校数据提取")
    print("=" * 60)

    records = extract_quota_data()

    # 去重
    seen = set()
    unique_records = []
    for r in records:
        key = (r['high_school_code'], r['middle_school_name'])
        if key not in seen:
            seen.add(key)
            unique_records.append(r)

    print(f"\n提取结果: {len(unique_records)} 条记录")

    # 保存到 CSV
    if unique_records:
        output_csv = os.path.join(OUTPUT_DIR, "嘉定_2025_名额分配到校.csv")
        fieldnames = ['year', 'district', 'district_code', 'middle_school_name',
                     'high_school_code', 'high_school_name', 'quota_count', 'source']

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

        # 检查洪德中学
        print("\n检查洪德中学数据:")
        hongde_records = [r for r in unique_records if '洪德' in r['middle_school_name']]
        if hongde_records:
            for r in hongde_records:
                print(f"  {r['high_school_code']} - {r['high_school_name']}: {r['quota_count']}")
        else:
            print("  未找到洪德中学数据")

    return unique_records

if __name__ == '__main__':
    main()
