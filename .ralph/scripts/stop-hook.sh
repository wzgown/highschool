#!/bin/bash

# Ralph Loop Stop Hook
# 验证流程：
# 1. 检查 AI 是否输出了 MISSION_COMPLETE（声称完成）
# 2. 执行 verify.sh（客观验证数据）

RALPH_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_DIR="$RALPH_DIR/current"
VERIFY_SCRIPT="$CURRENT_DIR/verify.sh"
LOG_DIR="$RALPH_DIR/logs"

echo "════════════════════════════════════════════════════════"
echo "  Stop Hook: 验证"
echo "════════════════════════════════════════════════════════"

# ============================================================
# 步骤 1：检查 AI 是否声称完成
# ============================================================
echo ""
echo "[1/2] 检查完成信号..."

LATEST_LOG=$(ls -t "$LOG_DIR"/iteration_*.log 2>/dev/null | head -1)
if [ -z "$LATEST_LOG" ]; then
    echo "❌ 无日志文件"
    exit 1
fi

if ! grep -q "MISSION_COMPLETE" "$LATEST_LOG"; then
    echo "❌ AI 未输出 MISSION_COMPLETE 信号"
    echo "   AI 需要在完成任务后输出 MISSION_COMPLETE"
    exit 1
fi
echo "✅ AI 已声称完成 (MISSION_COMPLETE)"

# ============================================================
# 步骤 2：执行客观验证
# ============================================================
echo ""
echo "[2/2] 执行客观验证..."

if [ ! -f "$VERIFY_SCRIPT" ]; then
    echo "❌ 验证脚本不存在: $VERIFY_SCRIPT"
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
    echo "✅ 验证通过！任务完成"
    echo "════════════════════════════════════════════════════════"
    exit 0
else
    EXIT_CODE=$?
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo "❌ 验证失败 (exit code: $EXIT_CODE)"
    echo "════════════════════════════════════════════════════════"
    exit 1
fi
