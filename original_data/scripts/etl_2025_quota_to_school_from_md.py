#!/usr/bin/env python3
"""
ETL脚本：从markdown表格中提取2025年名额分配到校数据

Step 1: Extract (markdown → CSV)

使用 MarkItDown 转换后的 markdown 文件，解析表格数据
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
    patterns = [r'（(.*?)区', r'(黄浦|徐汇|长宁|静安|普陀|虹口|杨浦|闵行|宝山|嘉定|浦东|金山|松江|青浦|奉贤|崇明)']
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


def parse_markdown_text(md_file):
    """
    解析 markdown 纯文本格式

    格式：
    - 第1行：区名（标题行）
    - 第2-3行：说明文字
    - 第4行：空行或高中代码行
    - 第5行：高中名称
    - 第6行起：数据行
    """
    filename = os.path.basename(md_file)
    district = extract_district_from_filename(filename)

    print(f"  解析: {filename}")

    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.split('\n')

    # 查找关键标记行
    code_line_idx = None
    name_line_idx = None
    for i, line in enumerate(lines):
        stripped = line.strip()
        # 查找包含6位代码的行（高中代码行）
        if re.search(r'\d{6}', stripped) and len(re.findall(r'\d{6}', stripped)) >= 3:
            code_line_idx = i
            break
        # 查找"学校名称"行
        if '学校名称' in stripped:
            name_line_idx = i
            break

    if code_line_idx is None or name_line_idx is None:
        print(f"    警告: 未找到表头")
        return []

    print(f"    代码行: {code_line_idx}, 名称行: {name_line_idx}")

    # 高中代码从代码行提取
    codes_line = lines[code_line_idx]
    high_codes = re.findall(r'\d{6}', codes_line)
    print(f"    找到 {len(high_codes)} 个高中代码")

    # 从名称行下一行开始解析数据
    records = []
    i = name_line_idx + 1

    while i < len(lines):
        line = lines[i]

        # 跳过空行
        if not line.strip():
            i += 1
            continue

        # 分割行（按空格）
        parts = line.split()
        parts = [p for p in parts if p.strip()]

        # 检查是否是有效数据行
        # 格式：代码 | 名称 | 各区名额数字...
        if len(parts) < 4:
            i += 1
            continue

        # 第一部分是初中代码（6位数字）
        if not re.match(r'^\d{6}$', parts[0]):
            i += 1
            continue

        middle_code = parts[0]

        # 查找初中名称（第二个非数字部分）
        middle_name = None
        for part in parts[1:]:
            if '中学' in part:
                middle_name = clean_school_name(part)
                break

        if not middle_name:
            middle_name = parts[1] if len(parts) > 1 else ''

        # 解析名额（从第3部分开始）
        quotas = []
        for h_idx in range(len(high_codes)):
            if h_idx + 2 < len(parts):
                quota_str = parts[h_idx + 2]
                # 提取数字
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


# ============================================================================
# 主函数
# ============================================================================

def main():
    print("=" * 60)
    print("2025年名额分配到校数据提取（从markdown）")
    print("=" * 60)

    # 查找所有 markdown 文件
    md_files = sorted(glob(os.path.join(MD_DIR, '*.md')))

    if not md_files:
        print("错误：未找到 markdown 文件")
        print(f"请先运行 MarkItDown 转换 PDF 到 markdown")
        return

    print(f"\n找到 {len(md_files)} 个 markdown 文件")

    all_records = []
    districts_processed = []

    for md_file in md_files:
        try:
            records = parse_markdown_text(md_file)
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
        print(f"处理区县: {', '.join(districts_processed)}")

        # 统计每个区的记录数
        from collections import Counter
        district_counts = Counter(r['区名称'] for r in all_records)
        print(f"\n各区记录数:")
        for district, count in sorted(district_counts.items()):
            print(f"  {district}: {count}")

        # 列出新发现的初中学校
        middle_schools = set(r['初中学校'] for r in all_records)
        print(f"\n发现的初中学校数量: {len(middle_schools)}")
        print(f"初中学校列表:")
        for school in sorted(middle_schools):
            print(f"  - {school}")
    else:
        print("\n没有提取到任何数据")


if __name__ == '__main__':
    main()
