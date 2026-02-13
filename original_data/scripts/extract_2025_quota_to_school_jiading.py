#!/usr/bin/env python3
"""
ETL脚本：提取2025年嘉定区名额分配到校数据

Step 1: Extract (markdown → CSV)

专门处理嘉定区的格式：
- 初中学校列表部分
- 分配到初中学校的招生学校及计划数

Author: Claude
Date: 2025-02-13
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

Path(PROCESSED_DIR).mkdir(parents=True, exist_ok=True)

# ============================================================================
# 工具函数
# ============================================================================

def clean_school_name(name):
    """清理学校名"""
    name = name.strip()
    # 去除多余空格
    name = re.sub(r'\s+', ' ', name)
    return name.strip()


def parse_jiading_format(lines, filename):
    """
    解析嘉定区格式：

    第一部分：初中学校列表
    第二部分：分配到初中学校的招生学校及计划数
    """
    print(f"  解析嘉定区格式: {filename}")

    middle_schools = []
    quota_records = []

    # 已知高中代码到名称映射
    high_school_map = {
        '142001': '上海市嘉定区第一中学',
        '142002': '上海市嘉定区第二中学',
        '142004': '上海师范大学附属中学嘉定新城分校',
        '042032': '上海市上海中学',
        '102056': '上海交通大学附属中学',
        '102057': '复旦大学附属中学',
        '152003': '华东师范大学第二附属中学',
        '152006': '上海师范大学附属中学',
    }

    # 第一阶段：提取初中学校列表
    in_middle_section = False
    i = 0

    while i < len(lines):
        line = lines[i].strip()

        # 查找初中学校部分开始
        if '初中学校' in line and i < 20:
            in_middle_section = True
            i += 1
            continue

        # 查找分配到初中学校部分（第二部分开始）
        if '分配到初中学校的招生学校' in line or '招生学校代码' in line:
            in_middle_section = False
            break

        # 提取初中学校名称
        if in_middle_section and line:
            # 检查是否是学校名称
            if '上海市' in line and '中学' in line:
                name = clean_school_name(line)
                # 过滤掉高中学校
                if '附属' not in name or '嘉定' in name:
                    # 生成代码
                    code = f"JD{len(middle_schools)+1:04d}"
                    middle_schools.append((code, name, '嘉定'))
                    print(f"    初中: {code} - {name}")

        i += 1

    print(f"    初中学校数: {len(middle_schools)}")

    # 第二阶段：解析配额数据
    # 查找"分配到初中学校"部分
    allocation_section = False
    high_school_codes = []
    current_high_code = None

    while i < len(lines):
        line = lines[i].strip()

        # 查找分配部分开始
        if '分配到初中学校的招生学校' in line or '招生学校代码' in line:
            allocation_section = True
            i += 1
            continue

        if allocation_section:
            # 提取高中代码
            code_match = re.match(r'^(\d{6})$', line)
            if code_match:
                current_high_code = code_match.group(1)
                if current_high_code not in high_school_codes:
                    high_school_codes.append(current_high_code)
                print(f"    高中代码: {current_high_code}")
                i += 1
                continue

            # 查找初中学校名称和计划数
            if '中学' in line:
                # 检查下一行是否有计划数
                quota = 0
                if i + 1 < len(lines):
                    next_line = lines[i + 1].strip()
                    # 尝试提取数字
                    num_match = re.match(r'^(\d+)$', next_line)
                    if num_match:
                        quota = int(num_match.group(1))

                # 确定高中代码（最近的高中代码）
                if high_school_codes:
                    high_code = current_high_code or high_school_codes[-1]
                    high_name = high_school_map.get(high_code, f"高中{high_code}")

                    # 查找匹配的初中学校
                    middle_code = None
                    middle_name = clean_school_name(line)

                    for code, name, dist in middle_schools:
                        if name in middle_name or middle_name in name:
                            middle_code = code
                            break

                    if not middle_code:
                        # 可能是新学校，生成临时代码
                        middle_code = f"JDNEW{len(quota_records)}"

                    if quota > 0:
                        quota_records.append({
                            '年份': 2025,
                            '批次': '名额分配到校',
                            '区名称': '嘉定',
                            '初中学校代码': middle_code,
                            '初中学校': middle_name,
                            '高中学校代码': high_code,
                            '高中学校': high_name,
                            '名额': quota,
                            '文件来源': filename,
                        })

        i += 1

    print(f"    配额记录: {len(quota_records)} 条")

    # 查找特别关注的学校
    special_schools = []
    for code, name, dist in middle_schools:
        if '交大附中' in name and ('洪德' in name or '德富' in name):
            special_schools.append(('交大附中附属嘉定', code, name))
        if '上海师范大学附属中学' in name and '嘉定新城' in name:
            special_schools.append(('上海师范大学附属中学嘉定新城分校', code, name))

    if special_schools:
        print(f"\n  发现特别关注的学校:")
        for key, code, name in special_schools:
            print(f"    {key}: {name} (代码: {code})")

    return middle_schools, quota_records


def save_to_csv(middle_schools, records, district):
    """保存数据到CSV"""
    # 保存初中学校列表
    if middle_schools:
        middle_csv = os.path.join(PROCESSED_DIR, f"{district}_2025_初中学校.csv")
        with open(middle_csv, 'w', encoding='utf-8', newline='') as f:
            fieldnames = ['代码', '名称', '区县']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for code, name, dist in middle_schools:
                writer.writerow({'代码': code, '名称': name, '区县': dist})
        print(f"    初中学校: {middle_csv}")

    # 保存配额数据
    if records:
        quota_csv = os.path.join(PROCESSED_DIR, f"{district}_2025_名额分配到校.csv")
        with open(quota_csv, 'w', encoding='utf-8', newline='') as f:
            fieldnames = ['年份', '批次', '区名称', '初中学校代码', '初中学校',
                        '高中学校代码', '高中学校', '名额', '文件来源']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(records)
        print(f"    配额数据: {quota_csv}")

    return len(records)


def main():
    print("=" * 60)
    print("2025年嘉定区名额分配到校数据提取")
    print("=" * 60)

    # 查找嘉定区的markdown文件
    md_files = sorted(glob(os.path.join(MD_DIR, '*嘉定*名额分配到校*.md')))

    if not md_files:
        print("错误：未找到嘉定区的markdown文件")
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

        middle_schools, records = parse_jiading_format(lines, filename)
        all_middle_schools.extend(middle_schools)
        all_records.extend(records)

    # 保存数据
    total_records = save_to_csv(all_middle_schools, all_records, '嘉定')

    print("\n" + "=" * 60)
    print("ETL处理完成")
    print("=" * 60)
    print(f"初中学校: {len(all_middle_schools)}")
    print(f"配额记录: {total_records}")
    print("\n输出文件:")
    print(f"  - 初中学校: {PROCESSED_DIR}/嘉定_2025_初中学校.csv")
    print(f"  - 配额数据: {PROCESSED_DIR}/嘉定_2025_名额分配到校.csv")


if __name__ == '__main__':
    main()
