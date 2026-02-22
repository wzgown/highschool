#!/bin/bash

# Ralph Loop Stop Hook
# 用途：执行任务文件中的验证脚本
# 验证脚本定义在每个 task.md 中，随任务不同而不同

RALPH_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CURRENT_TASK="$RALPH_DIR/current/task.md"
LOG_DIR="$RALPH_DIR/logs"

echo "════════════════════════════════════════════════════════"
echo "  Stop Hook: 执行验证脚本"
echo "════════════════════════════════════════════════════════"

if [ ! -f "$CURRENT_TASK" ]; then
    echo "❌ 无当前任务文件"
    exit 1
fi

# 从 task.md 提取验证脚本（```bash ... ``` 之间的内容）
# 查找 "## 验证脚本" 后的第一个 bash 代码块
VERIFY_SCRIPT=$(awk '
/^## 验证脚本/,/^## / {
    if (/^```bash/) { in_block=1; next }
    if (/^```/ && in_block) { in_block=0; exit }
    if (in_block) { print }
}
' "$CURRENT_TASK")

if [ -z "$VERIFY_SCRIPT" ]; then
    echo "⚠️ 未找到验证脚本，使用默认检查..."
    VERIFY_SCRIPT='
cd /Users/lance.wang/workspace/wzgown/highschool_new/backend
go test ./... -v
'
fi

# 写入临时脚本并执行
TEMP_SCRIPT=$(mktemp)
echo "$VERIFY_SCRIPT" > "$TEMP_SCRIPT"

echo ""
echo "--- 执行验证脚本 ---"
echo ""

if bash "$TEMP_SCRIPT" 2>&1; then
    rm -f "$TEMP_SCRIPT"

    # 额外检查：完成信号
    echo ""
    echo "--- 检查完成信号 ---"
    LATEST_LOG=$(ls -t "$LOG_DIR"/iteration_*.log 2>/dev/null | head -1)
    if [ -n "$LATEST_LOG" ] && grep -q "MISSION_COMPLETE" "$LATEST_LOG"; then
        echo "✅ 检测到 MISSION_COMPLETE"
        echo ""
        echo "════════════════════════════════════════════════════════"
        echo "✅ 所有检查通过"
        echo "════════════════════════════════════════════════════════"
        exit 0
    else
        echo "❌ 未检测到 MISSION_COMPLETE 信号"
        echo "════════════════════════════════════════════════════════"
        exit 1
    fi
else
    EXIT_CODE=$?
    rm -f "$TEMP_SCRIPT"
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo "❌ 验证脚本执行失败 (exit code: $EXIT_CODE)"
    echo "════════════════════════════════════════════════════════"
    exit 1
fi
