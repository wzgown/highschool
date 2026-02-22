#!/bin/bash

# Ralph Loop 循环脚本
# 支持多任务复用，每个任务一个 task.md 文件
# 核心原理：结束-重启模式，状态外化到文件

set -e

RALPH_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_ROOT="$(dirname "$RALPH_DIR")"
SCRIPTS_DIR="$RALPH_DIR/scripts"
TEMPLATES_DIR="$RALPH_DIR/templates"
CURRENT_DIR="$RALPH_DIR/current"
TASKS_DIR="$RALPH_DIR/tasks"
CURRENT_TASK="$CURRENT_DIR/task.md"
STOP_HOOK="$SCRIPTS_DIR/stop-hook.sh"
TASK_TEMPLATE="$TEMPLATES_DIR/task-template.md"
VERIFY_TEMPLATE="$TEMPLATES_DIR/verify.sh"

# 参数
MAX_ITERATIONS=${MAX_ITERATIONS:-20}
DELAY_SECONDS=${DELAY_SECONDS:-1}

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

mkdir -p "$CURRENT_DIR" "$TASKS_DIR"

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()      { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_err()     { echo -e "${RED}[ERR]${NC} $1"; }
log_ralph()   { echo -e "${MAGENTA}[RALPH]${NC} $1"; }

# 显示帮助
show_help() {
    cat << EOF
Ralph Loop - 多任务复用的循环框架

用法:
  $0                          运行当前任务
  $0 --new                    创建新任务（从模板）
  $0 --task <file>            指定任务文件
  $0 --status                 显示状态
  $0 --archive [name]         归档当前任务
  $0 --reset                  重置当前任务（清空失败日志）
  $0 --help                   显示帮助

目录结构:
  .ralph/
  ├── scripts/        # 脚本
  ├── templates/      # 任务模板
  ├── current/        # 当前任务
  └── tasks/          # 历史任务归档

参数:
  MAX_ITERATIONS=$MAX_ITERATIONS  最大循环次数

EOF
}

# 创建新任务
new_task() {
    local task_name="${1:-task-$(date +%Y%m%d-%H%M%S)}"
    local task_file="$CURRENT_DIR/task.md"
    local verify_file="$CURRENT_DIR/verify.sh"
    local verify_template="$TEMPLATES_DIR/verify.sh"

    # 创建任务文件
    cp "$TASK_TEMPLATE" "$task_file"

    # 创建验证脚本
    cp "$VERIFY_TEMPLATE" "$verify_file"
    chmod +x "$verify_file"

    log_ok "已创建新任务:"
    echo ""
    echo "  任务描述: $task_file"
    echo "  验证脚本: $verify_file  ⬅️ 必须编辑！"
    echo ""
    echo "编辑命令:"
    echo "  vim $task_file"
    echo "  vim $verify_file"
}

# 指定任务文件
set_task() {
    local task_file="$1"
    if [ ! -f "$task_file" ]; then
        log_err "任务文件不存在: $task_file"
        exit 1
    fi
    cp "$task_file" "$CURRENT_TASK"
    log_ok "已设置任务: $task_file"
}

# 显示状态
show_status() {
    echo "=== Ralph Loop 状态 ==="
    echo ""
    echo "当前任务: $CURRENT_TASK"
    if [ -f "$CURRENT_TASK" ]; then
        echo ""
        echo "--- 成功标准 ---"
        grep -A 10 "## 成功标准" "$CURRENT_TASK" | head -15
        echo ""
        echo "--- 失败日志行数 ---"
        wc -l "$CURRENT_TASK" | awk '{print $1 " 行"}'
    else
        echo "无当前任务"
        echo ""
        echo "创建新任务: $0 --new"
    fi
    echo ""
    echo "--- 历史任务 ---"
    ls -la "$TASKS_DIR" 2>/dev/null || echo "无"
}

# 归档当前任务
archive_task() {
    local name="${1:-task-$(date +%Y%m%d-%H%M%S)}"
    local archive_dir="$TASKS_DIR/$name"

    if [ ! -f "$CURRENT_TASK" ]; then
        log_err "无当前任务可归档"
        exit 1
    fi

    mkdir -p "$archive_dir"
    cp "$CURRENT_TASK" "$archive_dir/task.md"
    rm "$CURRENT_TASK"

    log_ok "已归档: $archive_dir/task.md"
}

# 自动归档（任务完成后调用）
auto_archive() {
    local total_iterations="$1"
    local current_dir="$RALPH_DIR/current"
    local verify_script="$current_dir/verify.sh"
    local log_dir="$RALPH_DIR/logs"

    # 从 task.md 提取任务名称
    local task_name=$(grep "^# 任务：" "$CURRENT_TASK" | head -1 | sed 's/^# 任务：//' | tr -d '[:space:]')
    task_name="${task_name:-completed-$(date +%Y%m%d-%H%M%S)}"

    # 创建归档目录名：日期-任务名-循环次数
    local archive_name="$(date +%Y%m%d-%H%M%S)-${task_name}-iter${total_iterations}"
    local archive_dir="$TASKS_DIR/$archive_name"

    mkdir -p "$archive_dir"

    # 复制任务文件
    cp "$CURRENT_TASK" "$archive_dir/task.md"

    # 复制验证脚本
    if [ -f "$verify_script" ]; then
        cp "$verify_script" "$archive_dir/verify.sh"
    fi

    # 复制相关日志（包括 .log 和 .hook 文件）
    if [ -d "$log_dir" ]; then
        mkdir -p "$archive_dir/logs"
        cp "$log_dir"/*.log "$archive_dir/logs/" 2>/dev/null || true
        cp "$log_dir"/*.hook "$archive_dir/logs/" 2>/dev/null || true
    fi

    # 创建归档摘要
    cat > "$archive_dir/SUMMARY.md" << EOF
# 归档摘要

- 任务: $task_name
- 完成时间: $(date -Iseconds)
- 总循环次数: $total_iterations
- 状态: ✅ 完成

## 文件清单

- task.md - 任务描述
- verify.sh - 验证脚本
- logs/ - 循环日志

EOF

    # 清理当前任务
    rm -f "$CURRENT_TASK" "$verify_script"

    log_ok "📁 已自动归档: $archive_dir"

    # 询问是否继续
    echo ""
    read -p "是否创建新任务？[y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "创建新任务..."
        new_task
    fi
}

# 重置当前任务
reset_task() {
    if [ ! -f "$CURRENT_TASK" ]; then
        log_err "无当前任务"
        exit 1
    fi

    # 只保留失败日志之前的内容
    sed -i '' '/^## 失败日志/,$d' "$CURRENT_TASK" 2>/dev/null || \
        sed -i '/^## 失败日志/,$d' "$CURRENT_TASK"

    # 重新添加空的失败日志部分
    cat >> "$CURRENT_TASK" << 'EOF'

## 失败日志

<!-- 每轮失败后，Ralph Loop 会在此追加日志 -->
EOF

    log_ok "已重置失败日志"
}

# 主循环
main() {
    if [ ! -f "$CURRENT_TASK" ]; then
        log_err "无当前任务"
        log_info "创建新任务: $0 --new"
        exit 1
    fi

    log_ralph "════════════════════════════════════════════════════════"
    log_ralph "  Ralph Loop - 结束-重启模式"
    log_ralph "════════════════════════════════════════════════════════"
    log_info "项目: $PROJECT_ROOT"
    log_info "任务: $CURRENT_TASK"
    log_info "熔断: 最大 $MAX_ITERATIONS 次循环"
    echo ""

    local iter=0
    local log_dir="$RALPH_DIR/logs"
    mkdir -p "$log_dir"

    while [ $iter -lt $MAX_ITERATIONS ]; do
        iter=$((iter + 1))
        local log_file="$log_dir/iteration_$(printf '%03d' $iter).log"

        log_ralph "────────────────────────────────────────────────────"
        log_ralph "循环 #$iter"
        log_ralph "────────────────────────────────────────────────────"

        # 核心：启动全新 AI 实例
        claude -p "$(cat "$CURRENT_TASK")" 2>&1 | tee "$log_file" || true

        # Stop Hook：客观检查
        log_info "Stop Hook: 客观检查..."

        bash "$STOP_HOOK" 2>&1 | tee "${log_file}.hook"
        HOOK_EXIT_CODE=${PIPESTATUS[0]}

        if [ $HOOK_EXIT_CODE -eq 0 ]; then
            log_ok "════════════════════════════════════════════════════════"
            log_ok "🎉 客观标准达成！循环结束"
            log_ok "总循环: $iter"
            log_ok "════════════════════════════════════════════════════════"

            # 自动归档
            auto_archive "$iter"

            exit 0
        fi

        # 未通过：更新外部状态文件
        log_warn "标准未达成，更新任务文件..."

        cat >> "$CURRENT_TASK" << EOF

---

## 第 $iter 轮失败

\`\`\`
$(cat "${log_file}.hook" | head -30)
\`\`\`

**要求**: 修复上述错误后重新运行。

EOF

        log_info "已追加失败日志到 task.md"
        sleep $DELAY_SECONDS
    done

    # 熔断
    log_err "════════════════════════════════════════════════════════"
    log_err "⚠️ 达到最大循环 ($MAX_ITERATIONS)，转人工审查"
    log_err "日志: $log_dir"
    log_err "════════════════════════════════════════════════════════"
    exit 1
}

# 参数处理
case "${1:-}" in
    --new|-n)
        new_task "$2"
        ;;
    --task|-t)
        set_task "$2"
        ;;
    --status|-s)
        show_status
        ;;
    --archive|-a)
        archive_task "$2"
        ;;
    --reset|-r)
        reset_task
        ;;
    --help|-h)
        show_help
        ;;
    "")
        main
        ;;
    *)
        log_err "未知参数: $1"
        show_help
        exit 1
        ;;
esac
