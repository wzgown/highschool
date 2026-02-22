#!/bin/bash
# 验证脚本：检查 ref_school 关联表的数据一致性和完整性

set -e

echo "════════════════════════════════════════════════════════"
echo "  关联表数据验证"
echo "════════════════════════════════════════════════════════"

# 1. 检查数据库连接
if ! docker exec highschool_postgres pg_isready -U highschool -d highschool > /dev/null 2>&1; then
    echo "❌ 数据库连接失败"
    exit 1
fi
echo "✅ 数据库连接正常"

TOTAL_ISSUES=0

# 检查通过 school_name 关联的表
check_table_by_name() {
    local TABLE=$1
    local SCHOOL_ID_FIELD=$2
    local SCHOOL_NAME_FIELD=$3

    echo ""
    echo "--- 检查 $TABLE ---"

    # school_name 不匹配
    local NAME_MISMATCH=$(docker exec highschool_postgres psql -U highschool -d highschool -t -c "
    SELECT COUNT(*) FROM $TABLE t
    JOIN ref_school s ON t.$SCHOOL_ID_FIELD = s.id
    WHERE t.$SCHOOL_NAME_FIELD != s.full_name AND t.data_year = 2025;
    " | tr -d ' ')

    if [ "$NAME_MISMATCH" -gt 0 ]; then
        echo "❌ 一致性: $NAME_MISMATCH 条不匹配"
        TOTAL_ISSUES=$((TOTAL_ISSUES + NAME_MISMATCH))
    else
        echo "✅ 一致性: 匹配"
    fi

    # 引用不活跃学校
    local INACTIVE_REFS=$(docker exec highschool_postgres psql -U highschool -d highschool -t -c "
    SELECT COUNT(*) FROM $TABLE t
    JOIN ref_school s ON t.$SCHOOL_ID_FIELD = s.id
    WHERE s.is_active = false AND t.data_year = 2025;
    " | tr -d ' ')

    if [ "$INACTIVE_REFS" -gt 0 ]; then
        echo "⚠️  完整性: $INACTIVE_REFS 条引用不活跃学校"
        TOTAL_ISSUES=$((TOTAL_ISSUES + INACTIVE_REFS))
    else
        echo "✅ 完整性: 无引用不活跃学校"
    fi

    # 孤立记录
    local ORPHAN_REFS=$(docker exec highschool_postgres psql -U highschool -d highschool -t -c "
    SELECT COUNT(*) FROM $TABLE t
    LEFT JOIN ref_school s ON t.$SCHOOL_ID_FIELD = s.id
    WHERE s.id IS NULL AND t.data_year = 2025;
    " | tr -d ' ')

    if [ "$ORPHAN_REFS" -gt 0 ]; then
        echo "❌ 完整性: $ORPHAN_REFS 条孤立记录"
        TOTAL_ISSUES=$((TOTAL_ISSUES + ORPHAN_REFS))
    else
        echo "✅ 完整性: 无孤立记录"
    fi
}

# 检查通过 school_code 关联的表
check_table_by_code() {
    local TABLE=$1
    local SCHOOL_ID_FIELD=$2
    local SCHOOL_CODE_FIELD=$3

    echo ""
    echo "--- 检查 $TABLE ---"

    # school_code 不匹配
    local CODE_MISMATCH=$(docker exec highschool_postgres psql -U highschool -d highschool -t -c "
    SELECT COUNT(*) FROM $TABLE t
    JOIN ref_school s ON t.$SCHOOL_ID_FIELD = s.id
    WHERE t.$SCHOOL_CODE_FIELD != s.code AND t.data_year = 2025;
    " | tr -d ' ')

    if [ "$CODE_MISMATCH" -gt 0 ]; then
        echo "❌ 一致性: $CODE_MISMATCH 条不匹配"
        TOTAL_ISSUES=$((TOTAL_ISSUES + CODE_MISMATCH))
    else
        echo "✅ 一致性: 匹配"
    fi

    # 引用不活跃学校
    local INACTIVE_REFS=$(docker exec highschool_postgres psql -U highschool -d highschool -t -c "
    SELECT COUNT(*) FROM $TABLE t
    JOIN ref_school s ON t.$SCHOOL_ID_FIELD = s.id
    WHERE s.is_active = false AND t.data_year = 2025;
    " | tr -d ' ')

    if [ "$INACTIVE_REFS" -gt 0 ]; then
        echo "⚠️  完整性: $INACTIVE_REFS 条引用不活跃学校"
        TOTAL_ISSUES=$((TOTAL_ISSUES + INACTIVE_REFS))
    else
        echo "✅ 完整性: 无引用不活跃学校"
    fi

    # 孤立记录
    local ORPHAN_REFS=$(docker exec highschool_postgres psql -U highschool -d highschool -t -c "
    SELECT COUNT(*) FROM $TABLE t
    LEFT JOIN ref_school s ON t.$SCHOOL_ID_FIELD = s.id
    WHERE s.id IS NULL AND t.data_year = 2025;
    " | tr -d ' ')

    if [ "$ORPHAN_REFS" -gt 0 ]; then
        echo "❌ 完整性: $ORPHAN_REFS 条孤立记录"
        TOTAL_ISSUES=$((TOTAL_ISSUES + ORPHAN_REFS))
    else
        echo "✅ 完整性: 无孤立记录"
    fi
}

echo ""
echo "════════════════════════════════════════════════════════"
echo "  一致性检查"
echo "════════════════════════════════════════════════════════"

check_table_by_name "ref_admission_plan_summary" "school_id" "school_name"
check_table_by_name "ref_admission_score_unified" "school_id" "school_name"
check_table_by_name "ref_admission_score_quota_district" "school_id" "school_name"
check_table_by_name "ref_admission_score_quota_school" "school_id" "school_name"
check_table_by_code "ref_quota_allocation_district" "school_id" "school_code"
check_table_by_code "ref_quota_allocation_school" "high_school_id" "high_school_code"

echo ""
echo "════════════════════════════════════════════════════════"
echo "  验证结果"
echo "════════════════════════════════════════════════════════"

if [ "$TOTAL_ISSUES" -eq 0 ]; then
    echo "✅ 所有关联表数据一致且完整"
    echo "════════════════════════════════════════════════════════"
    exit 0
else
    echo "❌ 发现 $TOTAL_ISSUES 个问题需要修正"
    echo "════════════════════════════════════════════════════════"
    exit 1
fi
