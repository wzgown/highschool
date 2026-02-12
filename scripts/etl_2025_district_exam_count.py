#!/usr/bin/env python3
"""
ETL流程 Step 1: Extract - 从CSV提取2025年各区中考人数数据
遵循 ETL_PIPELINE_SOP.md 规范
"""

import csv
from pathlib import Path

# 区代码映射
DISTRICT_MAP = {
    '黄浦': 'HP',
    '徐汇': 'XH',
    '长宁': 'CN',
    '静安': 'JA',
    '普陀': 'PT',
    '虹口': 'HK',
    '杨浦': 'YP',
    '闵行': 'MH',
    '宝山': 'BS',
    '嘉定': 'JD',
    '浦东': 'PD',
    '金山': 'JS',
    '松江': 'SJ',
    '青浦': 'QP',
    '奉贤': 'FX',
    '崇明': 'CM',
}

def extract_csv_to_processed(csv_path, output_path):
    """从CSV提取数据到processed目录（Extract步骤）"""
    print(f"正在提取: {csv_path}")

    districts = []

    with open(csv_path, 'r', encoding='utf-8') as f:
        # 读取全部内容
        content = f.read()

        # 修复表头1：25年 → 2025年
        content = content.replace('25年中考人数', '2025年中考人数')

        # 修复表头2：去掉列名中的前导空格
        # DictReader会保留列名中的空格，所以我们需要用原始列名访问
        lines = content.split('\n')
        reader = csv.DictReader(lines)

        for row in reader:
            district_name = row.get('区域', '').strip()

            # 尝试多种可能的列名格式（处理原始文件的空格问题）
            exam_count_str = None
            for key in row:
                if '中考人数' in key or '人数' in key:
                    exam_count_str = row[key].strip()
                    break

            if not district_name or not exam_count_str:
                continue

            # 转换人数为整数（去除可能的逗号和空格）
            exam_count_str = exam_count_str.replace(',', '').replace(' ', '')
            try:
                exam_count = int(exam_count_str)
            except ValueError:
                print(f"警告：无法解析人数 '{exam_count_str}' ({district_name})")
                continue

            district_code = DISTRICT_MAP.get(district_name, 'SH')

            districts.append({
                'district': district_name,
                'district_code': district_code,
                'exam_count': exam_count,
            })

    print(f"解析到 {len(districts)} 个区的数据")

    # 计算全市总计
    total_count = sum(d['exam_count'] for d in districts)

    # 写入processed目录
    output_path.mkdir(parents=True, exist_ok=True)
    output_file = output_path / '2025年各区中考人数.csv'

    with open(output_file, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f)
        # 写入表头
        writer.writerow(['区域', '区代码', '中考人数'])
        # 写入数据
        for d in districts:
            writer.writerow([
                d['district'],
                d['district_code'],
                d['exam_count'],
            ])

    print(f"✅ 已生成: {output_file}")
    print(f"   总计: {total_count} 人")

    return districts, total_count

def main():
    # 输入：raw目录的CSV文件
    csv_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/raw/2025/2025年上海各区中考人数.csv')

    # 输出：processed目录
    output_path = Path('/Users/wangzhigang/workspace/wzgown/highschool/original_data/processed/2025/district_exam_count')

    print("=" * 60)
    print("ETL流程: Step 1 - Extract")
    print("=" * 60)
    print(f"输入: {csv_path}")
    print(f"输出: {output_path}")
    print()

    districts, total = extract_csv_to_processed(csv_path, output_path)

    print()
    print("=" * 60)
    print("Step 1完成: 各区人数数据已提取到processed目录")
    print("=" * 60)
    print(f"共处理: {len(districts)} 个区的数据")
    print(f"全市总计: {total} 人")
    print(f"数据文件: {output_path / '2025年各区中考人数.csv'}")
    print()
    print("下一步: 运行 generate_2025_district_exam_count_sql.py 生成SQL文件")

if __name__ == '__main__':
    main()
