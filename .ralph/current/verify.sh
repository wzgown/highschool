#!/bin/bash
# 前端多端适配重构 - 验证脚本
# 用途：验证当前功能是否完成

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

echo "================================================"
echo "  前端多端适配重构 - 验证"
echo "================================================"

# 检查 uni-app 项目结构
echo ""
echo "[1/4] 检查 uni-app 项目结构..."
if [ -f "$FRONTEND_DIR/src/manifest.json" ] && [ -f "$FRONTEND_DIR/src/pages.json" ]; then
    echo "  ✅ uni-app 配置文件存在"
else
    echo "  ❌ uni-app 配置文件缺失"
    exit 1
fi

# 检查 TypeScript 编译
echo ""
echo "[2/4] 检查 TypeScript 编译..."
cd "$FRONTEND_DIR"
if npm run type-check > /dev/null 2>&1; then
    echo "  ✅ TypeScript 类型检查通过"
else
    echo "  ❌ TypeScript 类型检查失败"
    npm run type-check
    exit 1
fi

# 检查 H5 构建
echo ""
echo "[3/4] 检查 H5 构建..."
if npm run build:h5 > /dev/null 2>&1; then
    echo "  ✅ H5 构建成功"
else
    echo "  ❌ H5 构建失败"
    npm run build:h5
    exit 1
fi

# 检查小程序构建（可选）
echo ""
echo "[4/4] 检查微信小程序构建..."
if npm run build:mp-weixin > /dev/null 2>&1; then
    echo "  ✅ 微信小程序构建成功"
else
    echo "  ⚠️  微信小程序构建失败（可能需要配置 AppID）"
fi

echo ""
echo "================================================"
echo "  ✅ 验证完成"
echo "================================================"
