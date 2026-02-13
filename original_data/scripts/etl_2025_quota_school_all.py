#!/usr/bin/env python3
"""
ETL脚本：从所有markdown文件中提取2025年名额分配到校数据

Step 1: Extract (markdown → CSV)

处理所有已转换的markdown文件，支持多种格式：
1. 松江区格式：高中代码行 + 名称行 + 数据行
2. 浦东新区格式：表格格式，行=初中，列=高中
3. 静安区格式：原始解析格式
4. 黄浦区格式：代码+名称混合格式
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

def extract_district_from_filename(filename):
    """从文件名提取区名"""
    patterns = [
        r'(黄浦|徐汇|长宁|静安|普陀|虹口|杨浦|闵行|宝山|嘉定|浦东|金山|松江|青浦|奉贤|崇明)区',
        r'(黄浦|徐汇|长宁|静安|普陀|虹口|杨浦|闵行|宝山|嘉定|浦东|金山|松江|青浦|奉贤|崇明)'
    ]
    for pattern in patterns:
        match = re.search(pattern, filename)
        if match:
            return match.group(1)
    return "未知"


def clean_school_name(name):
    """清理学校名"""
    name = name.strip()
    # 去除多余空格
    name = re.sub(r'\s+', ' ', name)
    return name


def parse_format_1(lines, filename):
    """
    解析格式1：松江区格式
    - 第1部分：高中代码行（6位代码）
    - 第2部分：高中名称行
    - 后续部分：初中代码+名称 + 各高中名额数字
    """
    district = extract_district_from_filename(filename)
    records = []

    print(f"  使用格式1解析: {filename}")

    # 查找高中代码行
    code_line_idx = None
    for i, line in enumerate(lines):
        if re.search(r'\d{6}', line) and len(re.findall(r'\d{6}', line)) >= 3:
            code_line_idx = i
            break

    if code_line_idx is None:
        print(f"    警告: 未找到高中代码行")
        return []

    # 提取高中代码
    codes_line = lines[code_line_idx]
    high_codes = re.findall(r'\d{6}', codes_line)

    # 查找高中名称行（通常在代码行附近）
    name_line_idx = None
    for i in range(max(0, code_line_idx - 5), min(len(lines), code_line_idx + 5)):
        if '学校' in lines[i] and '委属' in lines[i]:
            name_line_idx = i
            break

    if name_line_idx is None:
        # 使用代码行后一行作为名称行
        if code_line_idx + 1 < len(lines):
            name_line_idx = code_line_idx + 1

    # 从名称行下一行开始解析数据
    i = name_line_idx + 1 if name_line_idx else code_line_idx + 1

    while i < len(lines):
        line = lines[i]

        # 跳过空行
        if not line.strip():
            i += 1
            continue

        # 检查是否结束（遇到"合计"或重复的标题）
        if '合计' in line or '未经允许' in line:
            break

        # 检查是否是新的数据块（有代码行）
        if re.match(r'^\d{6}', line.strip()):
            # 可能是新的高中代码行，跳出
            break

        # 分割行
        parts = line.split()
        parts = [p for p in parts if p.strip()]

        # 第一部分应该是初中代码
        if len(parts) < 4:
            i += 1
            continue

        middle_code = parts[0] if re.match(r'^\d{6}$', parts[0]) else None

        # 查找初中名称
        middle_name = None
        for part in parts[1:]:
            if '中学' in part or '学校' in part:
                middle_name = clean_school_name(part)
                break

        if not middle_name:
            middle_name = parts[1] if len(parts) > 1 else ''

        # 解析名额（从第3部分开始）
        for h_idx in range(len(high_codes)):
            if h_idx + 2 < len(parts):
                quota_str = parts[h_idx + 2]
                # 提取数字
                numbers = re.findall(r'\d+', quota_str)
                if numbers:
                    try:
                        quota = int(numbers[0])
                        if quota > 0:
                            records.append({
                                '年份': 2025,
                                '批次': '名额分配到校',
                                '区名称': district,
                                '初中学校代码': middle_code,
                                '初中学校': middle_name,
                                '高中学校代码': high_codes[h_idx],
                                '名额': quota,
                                '文件来源': filename,
                            })
                    except ValueError:
                        pass

        i += 1

    print(f"    提取 {len(records)} 条记录")
    return records


def parse_format_2(lines, filename):
    """
    解析格式2：浦东新区表格格式
    - 标题行定义列（初中名称 + 各高中名称）
    - 数据行：初中名称 + 各高中名额
    """
    district = extract_district_from_filename(filename)
    records = []

    print(f"  使用格式2解析: {filename}")

    # 查找标题行（包含多个高中名称）
    header_idx = None
    high_codes = []
    high_names = []

    for i, line in enumerate(lines):
        # 查找包含多个高中的行
        high_count = len(re.findall(r'上海市.*中学|华东师范.*中学|复旦.*中学|上海师范.*中学|上海交通.*中学', line))
        if high_count >= 5:
            header_idx = i
            # 提取高中代码和名称
            # 向前查找代码行
            if i > 0:
                prev_line = lines[i-1]
                codes = re.findall(r'\d{6}', prev_line)
                if codes:
                    high_codes = codes
            break

    if header_idx is None:
        return []

    # 从数据行开始解析
    i = header_idx + 1

    while i < len(lines):
        line = lines[i]

        # 跳过空行
        if not line.strip():
            i += 1
            continue

        # 检查是否结束
        if '合计' in line or '序号' in line:
            break

        # 分割行
        parts = line.split()
        parts = [p for p in parts if p.strip()]

        if len(parts) < len(high_codes) + 1:
            i += 1
            continue

        # 第一部分是序号
        # 第二部分开始是数据
        # 格式可能不同，需要灵活处理

        # 查找初中名称
        middle_name = None
        for part in parts:
            if '中学' in part or '学校' in part:
                middle_name = clean_school_name(part)
                break

        if not middle_name:
            # 可能序号后就是数据
            idx = 0
            for h_idx, code in enumerate(high_codes):
                if idx + 1 < len(parts):
                    quota_str = parts[idx + 1]
                    numbers = re.findall(r'\d+', quota_str)
                    if numbers and int(numbers[0]) > 0:
                        records.append({
                            '年份': 2025,
                            '批次': '名额分配到校',
                            '区名称': district,
                            '初中学校代码': '',
                            '初中学校': middle_name or f"初中{len(records)+1}",
                            '高中学校代码': code,
                            '名额': int(numbers[0]),
                            '文件来源': filename,
                        })
                    idx += 1
        else:
            # 解析各高中的名额
            data_start_idx = parts.index(middle_name) + 1
            for h_idx, code in enumerate(high_codes):
                if data_start_idx + h_idx < len(parts):
                    quota_str = parts[data_start_idx + h_idx]
                    numbers = re.findall(r'\d+', quota_str)
                    if numbers:
                        try:
                            quota = int(numbers[0])
                            if quota > 0:
                                records.append({
                                    '年份': 2025,
                                    '批次': '名额分配到校',
                                    '区名称': district,
                                    '初中学校代码': '',
                                    '初中学校': middle_name,
                                    '高中学校代码': code,
                                    '名额': quota,
                                    '文件来源': filename,
                                })
                        except ValueError:
                            pass

        i += 1

    print(f"    提取 {len(records)} 条记录")
    return records


def parse_format_3(lines, filename):
    """
    解析格式3：静安区格式（代码行+名称行）
    - 高中代码行
    - 学校名称行
    - 数据行（初中代码 + 名称 + 各高中名额）
    """
    district = extract_district_from_filename(filename)
    records = []

    print(f"  使用格式3解析: {filename}")

    # 查找高中代码行
    code_line_idx = None
    for i, line in enumerate(lines):
        stripped = line.strip()
        if re.search(r'\d{6}', stripped) and len(re.findall(r'\d{6}', stripped)) >= 3:
            code_line_idx = i
            break

    if code_line_idx is None:
        # 查找学校名称行
        for i, line in enumerate(lines):
            if '学校名称' in line:
                code_line_idx = i
                break

    if code_line_idx is None:
        print(f"    警告: 未找到表头")
        return []

    print(f"    代码行: {code_line_idx}")

    # 高中代码从代码行提取
    codes_line = lines[code_line_idx]
    high_codes = re.findall(r'\d{6}', codes_line)
    print(f"    找到 {len(high_codes)} 个高中代码")

    # 从名称行下一行开始解析数据
    # 查找名称行
    name_line_idx = None
    for i in range(code_line_idx, min(len(lines), code_line_idx + 10)):
        if '学校名称' in lines[i]:
            name_line_idx = i
            break

    if name_line_idx is None:
        name_line_idx = code_line_idx + 1

    records = []
    i = name_line_idx + 1

    while i < len(lines):
        line = lines[i]

        # 跳过空行
        if not line.strip():
            i += 1
            continue

        # 分割行
        parts = line.split()
        parts = [p for p in parts if p.strip()]

        # 检查是否是有效数据行
        if len(parts) < 4:
            i += 1
            continue

        # 第一部分是初中代码
        if not re.match(r'^\d{6}$', parts[0]):
            i += 1
            continue

        middle_code = parts[0]

        # 查找初中名称
        middle_name = None
        for part in parts[1:]:
            if '中学' in part or '学校' in part:
                middle_name = clean_school_name(part)
                break

        if not middle_name:
            middle_name = parts[1] if len(parts) > 1 else ''

        # 解析名额
        quotas = []
        for h_idx in range(len(high_codes)):
            if h_idx + 2 < len(parts):
                quota_str = parts[h_idx + 2]
                numbers = re.findall(r'\d+', quota_str)
                if numbers:
                    try:
                        quotas.append(int(numbers[0]))
                    except ValueError:
                        quotas.append(0)
                else:
                    quotas.append(0)
            else:
                quotas.append(0)

        # 创建记录
        for h_idx, quota in enumerate(quotas):
            if quota > 0:
                records.append({
                    '年份': 2025,
                    '批次': '名额分配到校',
                    '区名称': district,
                    '初中学校代码': middle_code,
                    '初中学校': middle_name,
                    '高中学校代码': high_codes[h_idx],
                    '名额': quota,
                    '文件来源': filename,
                })

        i += 1

    print(f"    提取 {len(records)} 条记录")
    return records


def parse_format_4(lines, filename):
    """
    解析格式4：黄浦区格式（代码和名称在同一行或相邻行）
    """
    district = extract_district_from_filename(filename)
    records = []

    print(f"  使用格式4解析: {filename}")

    # 查找学校代码列表开始
    school_start_idx = None
    for i, line in enumerate(lines):
        if re.search(r'\d{6}', line):
            school_start_idx = i
            break

    if school_start_idx is None:
        print(f"    警告: 未找到学校代码")
        return []

    # 查找高中学校列表
    high_schools = []
    i = school_start_idx
    while i < len(lines):
        line = lines[i]
        # 查找6位代码
        code_match = re.search(r'(\d{6})', line)
        if code_match:
            # 查找对应的学校名
            name = None
            # 检查当前行是否有学校名
            name_match = re.search(r'(上海市.*中学|华东.*中学|复旦.*中学|上海师范.*中学|上海交通.*中学)', line)
            if name_match:
                name = name_match.group(1)
            else:
                # 检查下一行
                if i + 1 < len(lines):
                    name_match = re.search(r'(上海市.*中学|华东.*中学|复旦.*中学|上海师范.*中学|上海交通.*中学)', lines[i+1])
                    if name_match:
                        name = name_match.group(1)

            if name:
                high_schools.append((code_match.group(1), name))
        i += 1

    print(f"    找到 {len(high_schools)} 个高中")

    # 查找初中学校数据（配额数据）
    middle_start_idx = i
    while i < len(lines):
        line = lines[i]
        # 查找初中代码和学校名
        code_match = re.search(r'(\d{6})', line)
        if code_match:
            middle_code = code_match.group(1)
            # 查找初中名称
            name_match = re.search(r'(上海市.*初级中学|上海市.*中学|.*初级中学|.*实验学校)', line)
            middle_name = name_match.group(1) if name_match else ''

            # 查找后面的配额数字
            # 简化：假设行中所有数字都是配额
            numbers = re.findall(r'\d+', line)
            if numbers and len(numbers) > 1:
                # 第一个数字是代码，其余可能是配额
                for h_code, h_name in high_schools:
                    # 简化：为每个高中创建记录，需要根据实际格式调整
                    pass

        i += 1

    print(f"    格式4解析未完全实现")
    return records


def detect_and_parse(md_file):
    """检测文件格式并解析"""
    filename = os.path.basename(md_file)

    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.split('\n')

    # 检测格式
    # 格式1：有"委属名额"标题
    if any('委属名额' in line for line in lines):
        return parse_format_1(lines, filename)

    # 格式2：有"初中学校名称"标题
    if any('初中学校名称' in line for line in lines):
        return parse_format_2(lines, filename)

    # 格式3：静安区特定格式
    if '静安' in filename:
        return parse_format_3(lines, filename)

    # 格式4：黄浦区特定格式
    if '黄浦' in filename and '公示' in filename:
        return parse_format_4(lines, filename)

    # 默认尝试格式1
    return parse_format_1(lines, filename)


# ============================================================================
# 主函数
# ============================================================================

def main():
    print("=" * 60)
    print("2025年名额分配到校数据提取（所有markdown文件）")
    print("=" * 60)

    # 查找所有 markdown 文件
    md_files = sorted(glob(os.path.join(MD_DIR, '*.md')))

    # 过滤掉到区相关的文件
    quota_school_files = [
        f for f in md_files
        if ('到校' in os.path.basename(f) or '公示' in os.path.basename(f))
        and '到区' not in os.path.basename(f)
    ]

    if not quota_school_files:
        print("错误：未找到名额分配到校相关的 markdown 文件")
        return

    print(f"\n找到 {len(quota_school_files)} 个名额分配到校 markdown 文件")

    all_records = []
    districts_processed = []

    for md_file in quota_school_files:
        try:
            print(f"\n解析: {os.path.basename(md_file)}")
            records = detect_and_parse(md_file)
            all_records.extend(records)
            districts_processed.append(extract_district_from_filename(os.path.basename(md_file)))
        except Exception as e:
            print(f"  错误: {e}")
            import traceback
            traceback.print_exc()

    # 保存到 CSV
    if all_records:
        output_file = os.path.join(PROCESSED_DIR, "2025年名额分配到校.csv")
        with open(output_file, 'w', encoding='utf-8', newline='') as f:
            fieldnames = ['年份', '批次', '区名称', '初中学校代码', '初中学校',
                        '高中学校代码', '名额', '文件来源']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(all_records)

        print(f"\n{'=' * 60}")
        print(f"输出: {output_file}")
        print(f"总记录数: {len(all_records)}")
        print(f"处理区县: {', '.join(set(districts_processed))}")

        # 统计每个区的记录数
        from collections import Counter
        district_counts = Counter(r['区名称'] for r in all_records)
        print(f"\n各区记录数:")
        for district, count in sorted(district_counts.items()):
            print(f"  {district}: {count}")

        # 列出新发现的初中学校
        middle_schools = set(r['初中学校'] for r in all_records if r['初中学校'])
        print(f"\n发现的初中学校数量: {len(middle_schools)}")
    else:
        print("\n没有提取到任何数据")


if __name__ == '__main__':
    main()
