#!/usr/bin/env python3
"""
导入2025年统一招生(1-15志愿)分数线数据
"""

import csv
import os
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
    "浦东区": 12,
    "金山区": 13,
    "松江区": 14,
    "青浦区": 15,
    "奉贤区": 16,
    "崇明区": 17,
}


def parse_score(value):
    """解析分数值"""
    if not value or value in ["/", "否", "是", "查", ""]:
        return None
    try:
        return float(value)
    except (ValueError, TypeError):
        return None


def find_school_id(cursor, school_name, school_code=None):
    """根据学校名称或代码查找学校ID"""
    # 1. 用学校代码匹配（优先）
    if school_code:
        # 去掉前导零
        normalized_code = school_code.lstrip('0') or '0'
        cursor.execute(
            "SELECT id FROM ref_school WHERE code = %s OR code = %s",
            (school_code, normalized_code)
        )
        result = cursor.fetchone()
        if result:
            return result[0]
    
    # 2. 精确匹配学校名称
    cursor.execute(
        "SELECT id FROM ref_school WHERE full_name = %s OR short_name = %s",
        (school_name, school_name)
    )
    result = cursor.fetchone()
    if result:
        return result[0]
    
    # 3. 模糊匹配（去掉括号内容）
    clean_name = school_name.split('（')[0].split('(')[0].strip()
    cursor.execute(
        "SELECT id FROM ref_school WHERE full_name LIKE %s",
        (f"%{clean_name}%",)
    )
    result = cursor.fetchone()
    if result:
        return result[0]
    
    return None


def import_unified_scores_2025(conn):
    """导入2025年统一招生分数线"""
    cursor = conn.cursor()
    
    filepath = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'original_data/raw/2025/Kimi_Agent_上海中考分数 /2025年上海市中考1-15志愿统一招生录取分数线.csv'
    )
    
    stats = {'total': 0, 'inserted': 0, 'updated': 0, 'skipped': 0, 'not_found': []}
    
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        for row in reader:
            stats['total'] += 1
            
            district_name = row.get('区名', '')
            school_code = row.get('学校代码', '')
            school_name = row.get('学校名称', '')
            min_score = parse_score(row.get('录取最低分', ''))
            
            if not min_score or not school_name:
                stats['skipped'] += 1
                continue
            
            district_id = DISTRICT_NAME_TO_ID.get(district_name)
            if not district_id:
                stats['not_found'].append(f"未知区: {district_name}")
                stats['skipped'] += 1
                continue
            
            school_id = find_school_id(cursor, school_name, school_code)
            
            if not school_id:
                stats['not_found'].append(f"{district_name}: {school_name} ({school_code})")
                stats['skipped'] += 1
                continue
            
            # 检查是否已存在
            cursor.execute(
                """SELECT id FROM ref_admission_score_unified 
                   WHERE school_id = %s AND district_id = %s AND year = 2025""",
                (school_id, district_id)
            )
            existing = cursor.fetchone()
            
            if existing:
                # 更新
                cursor.execute(
                    """UPDATE ref_admission_score_unified 
                       SET min_score = %s 
                       WHERE id = %s""",
                    (min_score, existing[0])
                )
                stats['updated'] += 1
            else:
                # 插入
                cursor.execute(
                    """INSERT INTO ref_admission_score_unified 
                       (school_id, school_name, district_id, year, min_score)
                       VALUES (%s, %s, %s, 2025, %s)""",
                    (school_id, school_name, district_id, min_score)
                )
                stats['inserted'] += 1
    
    conn.commit()
    
    print("\n" + "="*50)
    print("2025年统一招生分数线导入完成!")
    print(f"  总记录数: {stats['total']}")
    print(f"  新增: {stats['inserted']}")
    print(f"  更新: {stats['updated']}")
    print(f"  跳过: {stats['skipped']}")
    
    if stats['not_found']:
        print(f"\n未匹配的学校 ({len(stats['not_found'])}个):")
        for name in stats['not_found'][:30]:
            print(f"  - {name}")
        if len(stats['not_found']) > 30:
            print(f"  ... 还有 {len(stats['not_found'])-30} 个")
    
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
        import_unified_scores_2025(conn)
    finally:
        conn.close()
