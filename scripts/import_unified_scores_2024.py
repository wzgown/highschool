#!/usr/bin/env python3
"""
导入2024年统一招生(1-15志愿)分数线数据
解决虹口区、崇明区等数据缺失问题
"""

import csv
import os
import re
import sys

# 添加项目路径
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# 区名称到ID的映射
DISTRICT_NAME_TO_ID = {
    "黄浦区": 2,
    "徐汇区": 3,
    "长宁区": 4,
    "静安区": 5,
    "普陀区": 6,
    "虹口区": 7,
    "杨浦区": 8,
    "闵行区": 9,
    "宝山区": 10,
    "嘉定区": 11,
    "浦东新区": 12,
    "浦东区": 12,  # 文件名中的别名
    "金山区": 13,
    "松江区": 14,
    "青浦区": 15,
    "奉贤区": 16,
    "崇明区": 17,
}

# 学校名称别名映射（处理不同数据源中的名称差异）
SCHOOL_NAME_ALIASES = {
    "复兴高级": "复旦大学附属复兴中学",
    "师大一附": "华东师范大学第一附属中学",
    "上财北郊": "上海财经大学附属北郊高级中学",
    "虹口高级": "上海市虹口高级中学",
    "上音北虹": "上海音乐学院虹口区北虹高级中学",
    "继光高级": "上海市继光高级中学",
    "澄衷高级": "上海市澄衷高级中学",
    "鲁迅中学": "上海市鲁迅中学",
    "五十二中": "上海市第五十二中学",
    "上戏附中": "上海戏剧学院附属高级中学",
    "上音安师": "上海音乐学院附属安师实验中学",
    "同济创意": "上海市同济黄浦设计创意中学",
    "五爱高级": "上海市五爱高级中学",
    "田家炳": "上海田家炳中学",
    "风范中学": "上海市民办风范中学",
    "安生学校": "上海安生学校",
    "师大二附": "华东师范大学第二附属中学",
    "上海中学": "上海市上海中学",
    "交大附中": "上海交通大学附属中学",
    "复旦附中": "复旦大学附属中学",
    "燎原双语": "上海市民办燎原双语高级中学",
    "存志高级": "上海存志高级中学",
    "维尚高级": "上海宝山区民办维尚高级中学",
    "创艺高级": "上海创艺高级中学",
    "华曜高级": "上海市宝山华曜高级中学",
    "宝山世外": "上海宝山区世外学校",
    "远东学校": "上海市民办远东学校",
    "华盛怀少": "上海嘉定区民办华盛怀少学校",
    "丰华高级": "上海市民办丰华高级中学",
    "金苹果": "上海市民办金苹果学校",
    "东鼎外语": "上海浦东新区民办东鼎外国语学校",
    "尚德实验": "上海市民办尚德实验学校",
    "交大南洋": "上海市民办交大南洋中学",
    "永昌中学": "上海市民办永昌中学",
    "金山世外": "上海金山区世外学校",
    "西外外语": "上海市西外外国语学校",
    "赫贤学校": "上海赫贤学校",
    "青浦世外": "上海青浦区世外高级中学",
    "美达菲": "上海美达菲双语高级中学",
    "博华双语": "上海奉贤区博华双语学校",
    "民一中学": "上海民办民一中学",
}


def parse_score(value):
    """解析分数值，处理空值和非数字"""
    if not value or value in ["/", "否", "是", "查", ""]:
        return None
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


def find_school_id(cursor, school_name, school_code=None):
    """根据学校名称或代码查找学校ID"""
    # 先尝试别名映射
    normalized_name = SCHOOL_NAME_ALIASES.get(school_name, school_name)
    
    # 1. 精确匹配
    cursor.execute(
        "SELECT id FROM ref_school WHERE full_name = %s OR short_name = %s",
        (normalized_name, school_name)
    )
    result = cursor.fetchone()
    if result:
        return result[0]
    
    # 2. 模糊匹配
    cursor.execute(
        "SELECT id FROM ref_school WHERE full_name LIKE %s",
        (f"%{school_name}%",)
    )
    result = cursor.fetchone()
    if result:
        return result[0]
    
    # 3. 用学校代码匹配
    if school_code:
        cursor.execute(
            "SELECT id FROM ref_school WHERE code = %s",
            (school_code,)
        )
        result = cursor.fetchone()
        if result:
            return result[0]
    
    return None


def parse_file_format1(filepath):
    """解析格式1：学校名称,分数,... (如虹口区文件)"""
    records = []
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            school_name = list(row.values())[0]  # 第一列是学校名称
            min_score = list(row.values())[1]    # 第二列是分数线
            score = parse_score(min_score)
            if score:
                records.append({
                    'school_name': school_name,
                    'min_score': score
                })
    return records


def parse_file_format2(filepath):
    """解析格式2：学校代码,学校名称,分数线,... (如崇明区、闵行区文件)"""
    records = []
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            # 尝试多种可能的列名
            school_code = (row.get('学校代码', '') or 
                          row.get('招生代码', '') or 
                          row.get('代码', ''))
            school_name = (row.get('学校名称', '') or 
                          row.get('招生学校', ''))
            min_score = (row.get('投档分数线', '') or 
                        row.get('录取分数线', '') or 
                        row.get('录取最低分', ''))
            district_name = row.get('区名称', '')  # 有些文件包含区名称
            
            score = parse_score(min_score)
            if score and school_name:
                record = {
                    'school_name': school_name,
                    'school_code': school_code,
                    'min_score': score
                }
                if district_name:
                    record['district_name'] = district_name
                records.append(record)
    return records


def detect_file_format(filepath):
    """检测文件格式"""
    with open(filepath, 'r', encoding='utf-8') as f:
        first_line = f.readline()
        if ('学校代码' in first_line or 
            '招生代码' in first_line or 
            '区名称' in first_line or
            '代码' in first_line or
            '招生学校' in first_line):
            return 'format2'
        else:
            return 'format1'


def import_unified_scores(conn, year=2024):
    """导入统一招生分数线"""
    cursor = conn.cursor()
    
    raw_dir = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'original_data/raw/2024/cutoff_scores'
    )
    
    stats = {'total': 0, 'inserted': 0, 'updated': 0, 'skipped': 0, 'not_found': []}
    
    for filename in os.listdir(raw_dir):
        if '1-15志愿录取分数线' not in filename:
            continue
        
        filepath = os.path.join(raw_dir, filename)
        
        # 提取区名称
        match = re.search(r'1-15志愿录取分数线(.+)\.csv', filename)
        if not match:
            continue
        district_name = match.group(1)
        district_id = DISTRICT_NAME_TO_ID.get(district_name)
        if not district_id:
            print(f"未知区: {district_name}")
            continue
        
        print(f"\n处理 {district_name} (ID={district_id})...")
        
        # 检测文件格式并解析
        file_format = detect_file_format(filepath)
        if file_format == 'format1':
            records = parse_file_format1(filepath)
        else:
            records = parse_file_format2(filepath)
        
        print(f"  解析到 {len(records)} 条记录")
        
        for record in records:
            stats['total'] += 1
            
            # 使用记录中的区名称（如果有的话），否则使用文件名中的区
            record_district_name = record.get('district_name')
            if record_district_name:
                record_district_id = DISTRICT_NAME_TO_ID.get(record_district_name)
                if not record_district_id:
                    stats['skipped'] += 1
                    continue
            else:
                record_district_id = district_id
            
            school_id = find_school_id(
                cursor, 
                record['school_name'], 
                record.get('school_code')
            )
            
            if not school_id:
                stats['not_found'].append(f"{district_name}: {record['school_name']}")
                stats['skipped'] += 1
                continue
            
            # 检查是否已存在
            cursor.execute(
                """SELECT id FROM ref_admission_score_unified 
                   WHERE school_id = %s AND district_id = %s AND year = %s""",
                (school_id, record_district_id, year)
            )
            existing = cursor.fetchone()
            
            if existing:
                # 更新
                cursor.execute(
                    """UPDATE ref_admission_score_unified 
                       SET min_score = %s 
                       WHERE id = %s""",
                    (record['min_score'], existing[0])
                )
                stats['updated'] += 1
            else:
                # 插入
                cursor.execute(
                    """INSERT INTO ref_admission_score_unified 
                       (school_id, school_name, district_id, year, min_score)
                       VALUES (%s, (SELECT full_name FROM ref_school WHERE id = %s), %s, %s, %s)""",
                    (school_id, school_id, record_district_id, year, record['min_score'])
                )
                stats['inserted'] += 1
    
    conn.commit()
    
    print("\n" + "="*50)
    print("导入完成!")
    print(f"  总记录数: {stats['total']}")
    print(f"  新增: {stats['inserted']}")
    print(f"  更新: {stats['updated']}")
    print(f"  跳过: {stats['skipped']}")
    
    if stats['not_found']:
        print(f"\n未匹配的学校 ({len(stats['not_found'])}个):")
        for name in stats['not_found'][:20]:
            print(f"  - {name}")
        if len(stats['not_found']) > 20:
            print(f"  ... 还有 {len(stats['not_found'])-20} 个")
    
    return stats


if __name__ == '__main__':
    import psycopg2
    
    conn = psycopg2.connect(
        host='localhost',
        port=5432,
        database='highschool',
        user='highschool',
        password='HS2025!db#SecurePass88'
    )
    
    try:
        import_unified_scores(conn, year=2024)
    finally:
        conn.close()
