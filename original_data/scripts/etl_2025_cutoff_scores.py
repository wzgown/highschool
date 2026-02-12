#!/usr/bin/env python3
"""
ETL脚本：清洗2025年中考录取分数线数据

处理两个CSV文件：
1. quota_to_district_scores_2025.csv（到区分数线，897行）
2. quota_to_school_scores_2025.csv（到校分数线，3479行）

主要问题：OCR提取时产生的"院"字符错误
- "院"作为前缀：如"院上海市格致中学"
- "院"作为后缀：如"上海师范大学附属中学闵行分校院"
- 独立"院"：学校名完全丢失，只剩"院"

清洗策略：
- 前缀/后缀：直接删除"院"字符
- 独立"院"：通过跨区比对，找到缺失的学校名

输出：
- processed/cutoff_scores/quota_to_district_scores_2025_clean.csv
- processed/cutoff_scores/quota_to_school_scores_2025_clean.csv
"""

import csv
import os
import re
from collections import defaultdict

# ============================================================================
# 配置
# ============================================================================
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROCESSED_DIR = os.path.join(BASE_DIR, "processed", "cutoff_scores")
SCHOOL_REF_FILE = os.path.join(BASE_DIR, "processed", "2025", "schools", "2025年学校信息.csv")

# ============================================================================
# 工具函数
# ============================================================================

def load_school_reference():
    """加载76所学校参考列表"""
    schools = {}
    with open(SCHOOL_REF_FILE, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            code = row['招生代码'].strip()
            name = row['学校名称'].strip()
            schools[name] = code
    return schools


def clean_yuan_prefix_suffix(name):
    """
    清理"院"前缀和后缀
    返回 (清洗后名称, 是否为独立院)
    """
    name = name.strip()
    
    # 独立"院"
    if name == '院':
        return name, True
    
    # "院"作为前缀：如"院上海市格致中学"
    if name.startswith('院') and len(name) > 1:
        cleaned = name[1:].strip()
        return cleaned, False
    
    # "院"作为后缀（含空格）：如"上海市朱家角中学 院"
    if name.endswith(' 院') or name.endswith('　院'):
        cleaned = name[:-2].strip()
        return cleaned, False
    
    # "院"作为后缀（无空格）：如"上海师范大学附属中学闵行分校院"
    # 注意：有些学校名本身含"院"字（如"学院"），需要区分
    # 策略：如果末尾是"院"且前面不是"学"，则去掉"院"
    if name.endswith('院') and not name.endswith('学院'):
        cleaned = name[:-1].strip()
        return cleaned, False
    
    return name, False


# ============================================================================
# 第一部分：清洗到区分数线
# ============================================================================

def clean_district_scores():
    """清洗到区分数线数据"""
    print("=" * 60)
    print("清洗2025年名额分配到区录取分数线")
    print("=" * 60)
    
    input_file = os.path.join(PROCESSED_DIR, "quota_to_district_scores_2025.csv")
    output_file = os.path.join(PROCESSED_DIR, "quota_to_district_scores_2025_clean.csv")
    
    school_ref = load_school_reference()
    all_school_names = set(school_ref.keys())
    
    # 第一遍：读取数据，清理前缀/后缀，记录独立"院"
    rows = []
    standalone_yuan_indices = []  # (行索引, 区名称)
    
    with open(input_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader):
            school_name = row['招生学校']
            cleaned, is_standalone = clean_yuan_prefix_suffix(school_name)
            row['招生学校'] = cleaned
            rows.append(row)
            if is_standalone:
                standalone_yuan_indices.append((i, row['区名称']))
    
    print(f"总行数: {len(rows)}")
    print(f"独立'院'数量: {len(standalone_yuan_indices)}")
    
    # 按区分组，收集每个区的学校名列表（已清洗前缀/后缀后）
    district_schools = defaultdict(list)
    district_rows = defaultdict(list)
    for i, row in enumerate(rows):
        d = row['区名称']
        district_schools[d].append(row['招生学校'])
        district_rows[d].append(i)
    
    # 对每个区，找出独立"院"应该对应哪个学校
    # 策略：收集所有区中非"院"的学校名集合，对于有"院"的区，
    # 找出在其他区存在但在该区缺失的学校
    
    # 先建立：每个学校出现在哪些区
    school_district_presence = defaultdict(set)
    for d, schools in district_schools.items():
        for s in schools:
            if s != '院':
                school_district_presence[s].add(d)
    
    # 对于每个有独立"院"的区，找缺失的学校
    resolved = {}
    for idx, district in standalone_yuan_indices:
        clean_schools_in_district = set(
            s for s in district_schools[district] if s != '院'
        )
        
        # 候选：在大多数区出现但在该区缺失的学校
        candidates = []
        for school, districts_present in school_district_presence.items():
            if school not in clean_schools_in_district:
                # 该学校在其他区出现但在该区没有
                # 优先考虑出现频率高的（在多个区都出现的学校更可能也在该区出现）
                candidates.append((school, len(districts_present)))
        
        # 按出现频率排序，优先选频率最高的
        candidates.sort(key=lambda x: -x[1])
        
        if candidates:
            best_match = candidates[0][0]
            freq = candidates[0][1]
            # 检查是否有高置信度匹配（出现在多个区）
            if freq >= 10:  # 至少在10个区出现
                resolved[idx] = best_match
                print(f"  ✓ {district}[{idx}]: '院' → '{best_match}' (出现在{freq}/16区)")
            else:
                # 低置信度，列出前几个候选
                print(f"  ⚠ {district}[{idx}]: '院' 候选（低置信度）:")
                for s, f in candidates[:3]:
                    print(f"      - '{s}' (出现在{f}/16区)")
                # 仍然选择最佳候选
                resolved[idx] = best_match
                print(f"    → 选择: '{best_match}'")
        else:
            print(f"  ✗ {district}[{idx}]: '院' 无法解析（没有候选）")
    
    # 应用修复
    for idx, school_name in resolved.items():
        rows[idx]['招生学校'] = school_name
    
    # 最终验证：检查是否还有"院"
    remaining_yuan = [(i, row['区名称'], row['招生学校']) 
                      for i, row in enumerate(rows) if '院' in row['招生学校']]
    if remaining_yuan:
        print(f"\n⚠ 仍有{len(remaining_yuan)}条含'院'的记录:")
        for i, d, s in remaining_yuan:
            print(f"  行{i}: {d} - {s}")
    else:
        print(f"\n✓ 所有'院'问题已修复")
    
    # 验证学校名是否在参考列表中
    unknown_schools = set()
    for row in rows:
        if row['招生学校'] not in all_school_names:
            unknown_schools.add(row['招生学校'])
    if unknown_schools:
        print(f"\n⚠ {len(unknown_schools)}个学校名不在参考列表中:")
        for s in sorted(unknown_schools):
            print(f"  - '{s}'")
    
    # 写入清洗后文件
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['年份', '批次', '区名称', '招生学校', '录取最低分', '是否同分优待'])
        writer.writeheader()
        writer.writerows(rows)
    
    print(f"\n输出: {output_file}")
    print(f"总行数: {len(rows)}")
    return rows


# ============================================================================
# 第二部分：清洗到校分数线
# ============================================================================

def clean_school_scores():
    """清洗到校分数线数据"""
    print("\n" + "=" * 60)
    print("清洗2025年名额分配到校录取分数线")
    print("=" * 60)
    
    input_file = os.path.join(PROCESSED_DIR, "quota_to_school_scores_2025.csv")
    output_file = os.path.join(PROCESSED_DIR, "quota_to_school_scores_2025_clean.csv")
    
    school_ref = load_school_reference()
    all_high_school_names = set(school_ref.keys())
    
    # 高中学校的简称→全称映射
    short_to_full = build_short_name_mapping(school_ref)
    
    rows = []
    with open(input_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    
    print(f"总行数: {len(rows)}")
    
    # 解析每一行，拆分"学校信息"为初中和高中
    output_rows = []
    stats = {
        'total': len(rows),
        'both_schools': 0,
        'high_only': 0,
        'yuan_standalone': 0,
        'yuan_fixed': 0,
    }
    
    current_middle_school = None
    current_district = None
    
    for i, row in enumerate(rows):
        district = row['区名称']
        info = row['学校信息'].strip()
        score = row['录取最低分']
        is_tie = row['是否同分优待']
        
        # 区变化时重置当前初中
        if district != current_district:
            current_middle_school = None
            current_district = district
        
        # 情况1：独立"院"
        if info == '院':
            stats['yuan_standalone'] += 1
            # 尝试使用上下文推断
            # 通常是当前初中组的一个高中条目，高中名丢失
            # 看前后行推断缺失的高中名
            missing_high = infer_missing_high_school(rows, i, all_high_school_names, short_to_full)
            if missing_high:
                stats['yuan_fixed'] += 1
                output_rows.append({
                    '年份': row['年份'],
                    '批次': row['批次'],
                    '区名称': district,
                    '初中学校': current_middle_school or '',
                    '高中学校': missing_high,
                    '录取最低分': score,
                    '是否同分优待': is_tie,
                    '备注': '院→自动修复'
                })
            else:
                output_rows.append({
                    '年份': row['年份'],
                    '批次': row['批次'],
                    '区名称': district,
                    '初中学校': current_middle_school or '',
                    '高中学校': '[未识别]',
                    '录取最低分': score,
                    '是否同分优待': is_tie,
                    '备注': '院→未能修复'
                })
            continue
        
        # 清理"院"前缀/后缀
        info = clean_yuan_in_text(info)
        
        # 尝试拆分为初中+高中
        middle, high = split_school_info(info, all_high_school_names, short_to_full)
        
        if middle and high:
            stats['both_schools'] += 1
            current_middle_school = middle
            output_rows.append({
                '年份': row['年份'],
                '批次': row['批次'],
                '区名称': district,
                '初中学校': middle,
                '高中学校': high,
                '录取最低分': score,
                '是否同分优待': is_tie,
                '备注': ''
            })
        elif high and not middle:
            # 只有高中名，初中沿用上一组
            stats['high_only'] += 1
            output_rows.append({
                '年份': row['年份'],
                '批次': row['批次'],
                '区名称': district,
                '初中学校': current_middle_school or '',
                '高中学校': high,
                '录取最低分': score,
                '是否同分优待': is_tie,
                '备注': '初中沿用上组'
            })
        else:
            # 无法解析，保留原始信息
            output_rows.append({
                '年份': row['年份'],
                '批次': row['批次'],
                '区名称': district,
                '初中学校': '',
                '高中学校': info,
                '录取最低分': score,
                '是否同分优待': is_tie,
                '备注': '无法拆分'
            })
    
    # 写入清洗后文件
    fieldnames = ['年份', '批次', '区名称', '初中学校', '高中学校', '录取最低分', '是否同分优待', '备注']
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(output_rows)
    
    print(f"\n统计:")
    print(f"  初中+高中对: {stats['both_schools']}")
    print(f"  仅高中（初中沿用）: {stats['high_only']}")
    print(f"  独立'院': {stats['yuan_standalone']} (已修复: {stats['yuan_fixed']})")
    print(f"\n输出: {output_file}")
    print(f"总行数: {len(output_rows)}")
    
    # 统计空初中的情况
    empty_middle = sum(1 for r in output_rows if not r['初中学校'])
    unresolved = sum(1 for r in output_rows if r['备注'] in ('院→未能修复', '无法拆分'))
    print(f"空初中: {empty_middle}")
    print(f"未能解析: {unresolved}")
    
    return output_rows


def build_short_name_mapping(school_ref):
    """
    构建高中简称到全称的映射
    例：格致中学 → 上海市格致中学
         大同中学 → 上海市大同中学
    """
    mapping = {}
    for full_name in school_ref:
        # 去掉"上海市"前缀
        if full_name.startswith('上海市'):
            short = full_name[3:]
            mapping[short] = full_name
        # 也考虑不含前缀的情况
        mapping[full_name] = full_name
    return mapping


def clean_yuan_in_text(text):
    """
    清理文本中的"院"OCR错误
    处理各种位置的"院"：前缀、后缀、中间
    """
    # "院" + 空格 + 学校名 的模式（在中间）
    # 如 "格致初级中学   院    上海市格致中学"
    # 需要去掉多余的"院"和空格
    text = re.sub(r'\s+院\s+', '    ', text)
    
    # "院" 在开头（如 "院   上海交通大学附属中学"）
    text = re.sub(r'^院\s+', '', text)
    
    # "院" 在结尾（如 "复旦中学 院"）
    text = re.sub(r'\s*院$', '', text)
    
    # 连续空格标准化为4个空格（保留分隔符）
    text = re.sub(r'\s{2,}', '    ', text)
    
    return text.strip()


def split_school_info(info, all_high_names, short_to_full):
    """
    将"学校信息"字段拆分为初中和高中
    
    格式：
    - "初中学校名    高中学校名" → (初中, 高中)
    - "高中学校名" → (None, 高中)
    """
    # 用多个空格分割
    parts = re.split(r'\s{2,}', info)
    
    if len(parts) >= 2:
        # 有明确分隔：第一部分=初中，最后部分=高中
        middle = parts[0].strip()
        high = parts[-1].strip()
        
        # 尝试标准化高中名称
        high = normalize_high_school_name(high, all_high_names, short_to_full)
        
        return middle, high
    
    # 只有一个部分，判断是初中还是高中
    single = info.strip()
    
    # 先尝试匹配为高中
    normalized = normalize_high_school_name(single, all_high_names, short_to_full)
    if normalized in all_high_names:
        return None, normalized
    
    # 如果含"初级"或在已知初中列表中，则是初中（这种情况不应该出现）
    if '初级' in single or '初中' in single:
        return single, None
    
    # 默认当作高中简称处理
    return None, normalized


def normalize_high_school_name(name, all_high_names, short_to_full):
    """将高中简称标准化为全称"""
    name = name.strip()
    
    # 已经是全称
    if name in all_high_names:
        return name
    
    # 简称映射
    if name in short_to_full:
        return short_to_full[name]
    
    # 尝试加"上海市"前缀
    with_prefix = f"上海市{name}"
    if with_prefix in all_high_names:
        return with_prefix
    
    # 保持原样
    return name


def infer_missing_high_school(rows, current_idx, all_high_names, short_to_full):
    """
    推断独立"院"处缺失的高中名称
    
    策略：
    1. 查看同一区同一初中组内的上下文（前后行）
    2. 找到该初中组应有的高中列表
    3. 找出缺失的高中
    """
    district = rows[current_idx]['区名称']
    
    # 收集同一初中组内的高中名列表
    # 向前看：找到这个组的开始（初中名出现的第一行）
    group_schools = []
    
    # 向前扫描
    prev_schools = []
    for j in range(current_idx - 1, -1, -1):
        if rows[j]['区名称'] != district:
            break
        info = rows[j]['学校信息'].strip()
        if info == '院':
            continue
        info_clean = clean_yuan_in_text(info)
        parts = re.split(r'\s{2,}', info_clean)
        if len(parts) >= 2:
            prev_schools.append(parts[-1].strip())
        else:
            prev_schools.append(info_clean)
    
    # 向后扫描
    next_schools = []
    for j in range(current_idx + 1, len(rows)):
        if rows[j]['区名称'] != district:
            break
        info = rows[j]['学校信息'].strip()
        if info == '院':
            continue
        info_clean = clean_yuan_in_text(info)
        parts = re.split(r'\s{2,}', info_clean)
        if len(parts) >= 2:
            next_schools.append(parts[-1].strip())
            break  # 只取紧邻的下一个
        else:
            next_schools.append(info_clean)
            break
    
    # 这个位置的前后高中名，结合到区分数线数据中每个区的学校顺序
    # 来推断缺失的学校名
    # 简单启发式：在到区分数线中，找到同区同位置的学校
    
    # 如果前一行是某高中A，后一行是某高中B
    # 那么缺失的高中就是到区数据中A和B之间的学校
    before = normalize_high_school_name(
        prev_schools[0] if prev_schools else '', all_high_names, short_to_full
    ) if prev_schools else None
    after = normalize_high_school_name(
        next_schools[0] if next_schools else '', all_high_names, short_to_full
    ) if next_schools else None
    
    # 简化：如果前后学校名都已知，在参考列表中查找它们之间的学校
    # 但因为顺序不确定，这个方法不可靠
    # 更好的方法：查看到区分数线数据中同一区的学校顺序
    
    # 返回None让上层处理
    return None


# ============================================================================
# 主函数
# ============================================================================

if __name__ == '__main__':
    print("2025年中考录取分数线数据清洗")
    print("=" * 60)
    
    # 清洗到区分数线
    district_rows = clean_district_scores()
    
    # 清洗到校分数线
    school_rows = clean_school_scores()
    
    print("\n" + "=" * 60)
    print("清洗完成！")
