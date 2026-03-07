#!/bin/bash
set -e
echo "=== 验证功能 ==="

# 检查组件文件
if [ -f "frontend/src/components/ScoreCloudBackground.vue" ]; then
    echo "✅ 组件文件存在"
else
    echo "❌ 组件文件不存在"
    exit 1
fi

# 检查集成
if grep -q "ScoreCloudBackground" "frontend/src/views/HomeView.vue"; then
    echo "✅ 已集成到 HomeView"
else
    echo "❌ 未集成到 HomeView"
    exit 1
fi

echo "✅ 验证通过"
