#!/bin/bash
# 验证脚本 - 蘑菇云背景动效设计

set -e

echo "=== 验证开始 ==="
echo ""

# 检查 features.json 是否存在
if [ ! -f ".ralph/current/features.json" ]; then
    echo "❌ features.json 不存在"
    exit 1
fi

# 检查是否有 passes: true 的功能
PASSED=$(grep -c '"passes": true' .ralph/current/features.json 2>/dev/null || echo "0")
TOTAL=$(grep -c '"id"' .ralph/current/features.json 2>/dev/null || echo "0")

echo "📊 功能进度: $PASSED/$TOTAL 通过"
echo ""

if [ "$PASSED" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
    echo "✅ 所有功能已完成"
    exit 0
else
    echo "⏳ 还有功能未完成"
    exit 0
fi
