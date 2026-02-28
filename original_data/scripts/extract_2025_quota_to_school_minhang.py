#!/usr/bin/env python3
"""
ETL脚本：提取2025年闵行区名额分配到校数据

Step 1: Extract (markdown → CSV)

专门处理闵行区的列式格式：
- 初中学校信息
- 各高中招生代码（作为列）

Author: Claude
Date: 2025-02-12
"""

import csv
import os
import re
from pathlib import Path
from glob import glob

# ============================================================================
# 配置
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MD_DIR = os.path.join(BASE_DIR, "raw", "2025", "quota_district", "markdown")
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school")
PROCESSED_CLEAN_DIR = os.path.join(BASE_DIR, "processed", "2025", "quota_school_clean")

Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)
Path(PROCESSED_CLEAN_DIR).mkdir(parents=True, exist_ok=True)

# ============================================================================
# 工具函数
# ============================================================================

def extract_district_from_filename(filename):
    """从文件名提取区名"""
    district_map = {
        '闵行': 'MH', '闵行区': 'MH', '静安': 'JA', '嘉定': 'JD', '青浦': 'QP',
        '松江': 'SJ', '黄浦': 'HP', '徐汇': 'XH', '长宁': 'CN',
        '普陀': 'PT', '虹口': 'HK', '杨浦': 'YP', '宝山': 'BS',
        '浦东': 'PD', '金山': 'JS', '奉贤': 'FX', '崇明': 'CM',
    }
    for zh, code in district_map.items():
        if zh in filename:
            return zh, code
    return "未知", "UNK"


def parse_minhang_format(lines, filename):
    """
    解析闵行区格式：
    - 初中学校信息部分：列出所有初中学校
    - 数据部分：每个初中学校对应各高中的招生代码和名额
    """
    district = extract_district_from_filename(filename)[0]

    print(f"  解析闵行区格式: {filename}")

    # 第一阶段：提取初中学校列表
    middle_schools = []
    high_schools = []
    data_section_start = None

    # 查找"初中学校信息"标记
    for i, line in enumerate(lines):
        if '初中学校信息' in line:
            data_section_start = i + 1
            break

    if data_section_start is None:
        print(f"    错误：未找到数据部分")
        return [], []

    # 提取初中学校列表
    i = data_section_start + 1

    while i < len(lines):
        line = lines[i].strip()

        # 跳过标题和空行
        if not line or line in ['序号', '年份', '批次', '区名称']:
            i += 1
            continue

        # 检查是否是学校代码行（6位数字）
        if re.match(r'^\d{6}$', line):
            # 这是高中代码行
            codes = re.findall(r'\d{6}', line)
            if len(codes) >= 3:  # 至少3个代码
                high_schools = codes
                print(f"    找到高中代码: {codes}")
                break
        elif '初中' in line or '学校' in line:
            # 这是初中学校行
            # 提取代码和名称
            parts = line.split()
            if len(parts) >= 2:
                code = parts[0]
                name = ' '.join(parts[1:])
                if re.match(r'^\d{6}$', code) and '中学' in name:
                    middle_schools.append((code, name, district))
                    print(f"    初中: {code} - {name}")
            i += 1

        # 如果开始找到高中代码，则后面的都是数据行
        if high_schools:
            print(f"    初中学校数: {len(middle_schools)}")
            break

    if not high_schools:
        print(f"    警告：未找到高中代码")
        return []

    # 第二阶段：解析配额数据
    # 格式：初中代码 | 各高中代码（用多个空格或tab分隔）
    records = []

    # 跳过到数据部分
    while i < len(lines):
        line = lines[i].strip()

        if not line or '初中学校信息' in line:
            i += 1
            continue

        # 分割行
        parts = re.split(r'\s{2,}', line)
        parts = [p for p in parts if p.strip()]

        if len(parts) < len(high_schools) + 2:
            i += 1
            continue

        # 第一部分应该是初中代码
        middle_code = parts[0]

        # 检查是否是有效初中代码
        if not re.match(r'^\d{6}$', middle_code):
            i += 1
            continue

        # 找到对应的初中名称
        middle_name = None
        for code, name, dist in middle_schools:
            if code == middle_code and dist == district:
                middle_name = name
                break

        if not middle_name:
            middle_name = f"未知学校_{middle_code}"

        # 解析各高中的名额
        for h_idx, high_code in enumerate(high_schools):
            if h_idx + 1 < len(parts):
                quota_str = parts[h_idx + 1]
                # 提取数字
                numbers = re.findall(r'\d+', quota_str)
                if numbers:
                    quota = int(numbers[0])
                    if quota > 0:
                        records.append({
                            '年份': 2025,
                            '批次': '名额分配到校',
                            '区名称': district,
                            '初中学校代码': middle_code,
                            '初中学校': middle_name,
                            '高中学校代码': high_code,
                            '名额': quota,
                            '文件来源': filename,
                        })

        i += 1

    print(f"    提取配额记录: {len(records)} 条")
    return middle_schools, records


def save_to_csv(middle_schools, records, district):
    """保存数据到CSV"""
    # 保存初中学校列表
    if middle_schools:
        middle_csv = os.path.join(PROCESSED_DIR, f"{district}_初中学校.csv")
        with open(middle_csv, 'w', encoding='utf-8', newline='') as f:
            fieldnames = ['代码', '名称', '区县']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for code, name, dist in middle_schools:
                writer.writerow({'代码': code, '名称': name, '区县': dist})
        print(f"    初中学校: {middle_csv}")

    # 保存配额数据
    if records:
        quota_csv = os.path.join(PROCESSED_DIR, f"{district}_名额分配到校.csv")
        with open(quota_csv, 'w', encoding='utf-8', newline='') as f:
            fieldnames = ['年份', '批次', '区名称', '初中学校代码', '初中学校',
                        '高中学校代码', '名额', '文件来源']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(records)
        print(f"    配额数据: {quota_csv}")

    return len(records)


def main():
    print("=" * 60)
    print("2025年闵行区名额分配到校数据提取")
    print("=" * 60)

    # 查找闵行区的markdown文件
    md_files = sorted(glob(os.path.join(MD_DIR, '*闵行*.md')))

    if not md_files:
        print("错误：未找到闵行区的markdown文件")
        print("\n请确保已转换PDF文件到markdown:")
        print("docker run --rm -v \"$(pwd)/data:/data\" adeuxy/markitdown:latest \"/data/input.pdf\" > \"/data/output.md\"")
        return

    print(f"\n找到 {len(md_files)} 个文件")

    all_middle_schools = []
    all_records = []

    for md_file in md_files:
        filename = os.path.basename(md_file)

        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
            lines = content.split('\n')

        middle_schools, records = parse_minhang_format(lines, filename)
        all_middle_schools.extend(middle_schools)
        all_records.extend(records)

    # 保存数据
    total_records = save_to_csv(all_middle_schools, all_records, '闵行')

    print("\n" + "=" * 60)
    print("ETL处理完成")
    print("=" * 60)
    print(f"初中学校: {len(all_middle_schools)}")
    print(f"配额记录: {total_records}")
    print("\n输出文件:")
    print(f"  - 初中学校: {PROCESSED_DIR}/闵行_初中学校.csv")
    print(f"  - 配额数据: {PROCESSED_DIR}/闵行_名额分配到校.csv")


if __name__ == '__main__':
    main()
