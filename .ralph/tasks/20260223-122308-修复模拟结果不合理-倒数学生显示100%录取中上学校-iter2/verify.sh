#!/bin/bash
# 验证脚本：检查倒数学生的模拟录取概率是否合理

set -e

echo "=== 验证开始 ==="
echo ""

# 调用 API (使用端口 3000 后端直连)
RESPONSE=$(curl -s 'http://localhost:3000/highschool.v1.CandidateService/SubmitAnalysis' \
  -H 'content-type: application/json' \
  -H 'connect-protocol-version: 1' \
  --data-raw '{"candidate":{"districtId":11,"middleSchoolId":48,"hasQuotaSchoolEligibility":true},"scores":{"total":669.5},"ranking":{"rank":129,"totalStudents":130},"comprehensiveQuality":50,"volunteers":{"quotaDistrict":184,"quotaSchool":[184,183],"unified":[1,4,3,2,184,185,183,187,186,188,189,345,178,342,295]},"deviceId":"verify-test"}')

echo "API 响应:"
echo "$RESPONSE" | head -c 500
echo "..."
echo ""

# 提取学校 187 (嘉一实验高级中学) 的概率和风险等级
SCHOOL_187_PROB=$(echo "$RESPONSE" | jq -r '.result.results.probabilities[] | select(.schoolId == 187 and .batch == "UNIFIED_1_15") | .probability // 0')
SCHOOL_187_RISK=$(echo "$RESPONSE" | jq -r '.result.results.probabilities[] | select(.schoolId == 187 and .batch == "UNIFIED_1_15") | .riskLevel')

echo "学校 187 (嘉一实验高级中学) 统一招生结果:"
echo "  概率: ${SCHOOL_187_PROB}%"
echo "  风险等级: ${SCHOOL_187_RISK}"
echo ""

# 验证条件
FAILED=0

# 条件1: 概率应该 < 90%（倒数学生不应该有高录取概率）
if [ "$SCHOOL_187_PROB" -ge 10 ] 2>/dev/null; then
    echo "❌ 失败: 学校 187 录取概率 ${SCHOOL_187_PROB}% >= 10%，不符合预期"
    FAILED=1
else
    echo "✅ 通过: 学校 187 录取概率 ${SCHOOL_187_PROB}% < 90%"
fi

# 条件2: 风险等级应该是 high_risk（不是 safe）
if [ "$SCHOOL_187_RISK" = "safe" ]; then
    echo "❌ 失败: 学校 187 风险等级为 safe，不符合预期"
    FAILED=1
else
    echo "✅ 通过: 学校 187 风险等级为 ${SCHOOL_187_RISK}"
fi

echo ""
echo "=== 验证结果 ==="

if [ $FAILED -eq 0 ]; then
    echo "✅ 验证通过"
    exit 0
else
    echo "❌ 验证失败"
    exit 1
fi
