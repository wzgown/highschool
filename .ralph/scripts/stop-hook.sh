#!/bin/bash

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Ralph Loop v2.0 - Stop Hook                                                 ║
# ║                                                                              ║
# ║  验证流程：                                                                   ║
# ║  1. 检查 AI 是否输出了 MISSION_COMPLETE                                       ║
# ║  2. 检查 Git 工作区状态（可选）                                                ║
# ║  3. 执行 verify.sh（客观验证）                                                ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

RALPH_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(dirname "$RALPH_DIR")"
CURRENT_DIR="$RALPH_DIR/current"
LOGS_DIR="$RALPH_DIR/logs"

VERIFY_SCRIPT="$CURRENT_DIR/verify.sh"
FEATURES_FILE="$CURRENT_DIR/features.json"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "════════════════════════════════════════════════════════"
echo "  Stop Hook: 验证"
echo "════════════════════════════════════════════════════════"

# ============================================================
# 步骤 1：检查 AI 是否声称完成
# ============================================================
echo ""
echo -e "${BLUE}[1/3]${NC} 检查完成信号..."

LATEST_LOG=$(ls -t "$LOGS_DIR"/iteration_*.log 2>/dev/null | head -1)
if [ -z "$LATEST_LOG" ]; then
    echo -e "${RED}❌ 无日志文件${NC}"
    exit 1
fi

if ! grep -q "MISSION_COMPLETE" "$LATEST_LOG"; then
    echo -e "${RED}❌ AI 未输出 MISSION_COMPLETE 信号${NC}"
    echo "   AI 需要在完成任务后输出 MISSION_COMPLETE"
    exit 1
fi
echo -e "${GREEN}✅ AI 已声称完成 (MISSION_COMPLETE)${NC}"

# ============================================================
# 步骤 2：检查 Git 状态（可选但推荐）
# ============================================================
echo ""
echo -e "${BLUE}[2/3]${NC} 检查工作区状态..."

if git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    CHANGES=$(git -C "$PROJECT_ROOT" status --short 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CHANGES" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  工作区有 $CHANGES 个未提交的更改${NC}"
        echo ""
        git -C "$PROJECT_ROOT" status --short | head -10
        echo ""
        echo -e "${YELLOW}建议: AI 应该提交这些更改以保持干净状态${NC}"
        # 不阻止验证，只是警告
    else
        echo -e "${GREEN}✅ 工作区状态干净${NC}"
    fi
else
    echo "   (非 Git 仓库，跳过)"
fi

# ============================================================
# 步骤 3：执行客观验证
# ============================================================
echo ""
echo -e "${BLUE}[3/3]${NC} 执行客观验证..."

if [ ! -f "$VERIFY_SCRIPT" ]; then
    echo -e "${RED}❌ 验证脚本不存在: $VERIFY_SCRIPT${NC}"
    echo ""
    echo "请在 .ralph/current/ 目录中创建 verify.sh"
    exit 1
fi

# 检查是否可执行
if [ ! -x "$VERIFY_SCRIPT" ]; then
    chmod +x "$VERIFY_SCRIPT"
fi

echo ""
if bash "$VERIFY_SCRIPT" 2>&1; then
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo -e "${GREEN}✅ 验证通过！${NC}"

    # 显示功能进度
    if [ -f "$FEATURES_FILE" ]; then
        TOTAL=$(grep -c '"id"' "$FEATURES_FILE" 2>/dev/null || echo "0")
        PASSED=$(grep -c '"passes": true' "$FEATURES_FILE" 2>/dev/null || echo "0")
        echo ""
        echo "📊 功能进度: $PASSED/$TOTAL 通过"
    fi

    echo "════════════════════════════════════════════════════════"
    exit 0
else
    EXIT_CODE=$?
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo -e "${RED}❌ 验证失败 (exit code: $EXIT_CODE)${NC}"
    echo "════════════════════════════════════════════════════════"
    exit 1
fi
