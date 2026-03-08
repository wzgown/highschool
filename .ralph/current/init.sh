#!/bin/bash
# 前端多端适配重构 - 环境初始化脚本
# 用途：备份现有前端代码，准备 uni-app 开发环境

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKUP_DIR="$PROJECT_ROOT/frontend-legacy"

echo "================================================"
echo "  前端多端适配重构 - 环境初始化"
echo "================================================"

# Step 1: 备份现有前端代码
echo ""
echo "[1/4] 备份现有前端代码到 frontend-legacy..."
if [ -d "$BACKUP_DIR" ]; then
    echo "  ⚠️  frontend-legacy 已存在，跳过备份"
else
    cp -r "$FRONTEND_DIR" "$BACKUP_DIR"
    echo "  ✅ 备份完成"
fi

# Step 2: 检查 Node.js 版本
echo ""
echo "[2/4] 检查 Node.js 版本..."
NODE_VERSION=$(node -v 2>/dev/null || echo "none")
if [ "$NODE_VERSION" = "none" ]; then
    echo "  ❌ 未安装 Node.js，请先安装 Node.js 18+"
    exit 1
fi
echo "  ✅ Node.js 版本: $NODE_VERSION"

# Step 3: 检查 HBuilderX（可选，用于小程序开发）
echo ""
echo "[3/4] 检查开发工具..."
echo "  ℹ️  小程序开发需要安装 HBuilderX 或微信开发者工具"
echo "     - HBuilderX: https://www.dcloud.io/hbuilderx.html"
echo "     - 微信开发者工具: https://developers.weixin.qq.com/miniprogram/dev/devtools/download.html"

# Step 4: 显示下一步
echo ""
echo "[4/4] 下一步操作..."
echo ""
echo "  1. 创建 uni-app 项目："
echo "     cd $FRONTEND_DIR"
echo "     npx degit dcloudio/uni-preset-vue#vite-ts ."
echo ""
echo "  2. 安装依赖："
echo "     npm install"
echo ""
echo "  3. 运行开发服务器："
echo "     npm run dev:h5        # H5 开发"
echo "     npm run dev:mp-weixin # 微信小程序开发"
echo ""
echo "================================================"
echo "  ✅ 初始化准备完成"
echo "================================================"
