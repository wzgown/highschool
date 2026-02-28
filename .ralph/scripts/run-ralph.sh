#!/bin/bash

# Ralph Loop 循环脚本 (tmux 版)
# 支持多任务复用，每个任务一个 task.md 文件
# 核心原理：结束-重启模式，状态外化到文件
# tmux 版本：在 tmux 会话中运行 claude，可随时 attach 观察

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
MAX_ITERATIONS=${MAX_ITERATIONS:-5}
DELAY_SECONDS=${DELAY_SECONDS:-1}
TMUX_SESSION="ralph-loop"
CLAUDE_TIMEOUT=${CLAUDE_TIMEOUT:-1200}  # 单次 claude 执行超时（秒）
POLL_INTERVAL=${POLL_INTERVAL:-3}      # 轮询间隔（秒）

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
Ralph Loop - 多任务复用的循环框架 (tmux 版)

用法:
  $0                          运行当前任务
  $0 --new                    创建新任务（从模板）
  $0 --task <file>            指定任务文件
  $0 --status                 显示状态
  $0 --archive [name]         归档当前任务
  $0 --reset                  重置当前任务（清空失败日志）
  $0 --attach                 附加到 tmux 会话观察
  $0 --help                   显示帮助

tmux 操作:
  tmux attach -t $TMUX_SESSION    附加到会话
  Ctrl+B D                         分离会话（保持后台运行）

目录结构:
  .ralph/
  ├── scripts/        # 脚本
  ├── templates/      # 任务模板
  ├── current/        # 当前任务
  ├── tasks/          # 历史任务归档
  └── logs/           # 循环日志

参数:
  MAX_ITERATIONS=$MAX_ITERATIONS    最大循环次数
  CLAUDE_TIMEOUT=$CLAUDE_TIMEOUT    单次执行超时(秒)
  POLL_INTERVAL=$POLL_INTERVAL      轮询间隔(秒)

EOF
}

# 创建新任务
new_task() {
    local task_name="${1:-task-$(date +%Y%m%d-%H%M%S)}"
    local task_file="$CURRENT_DIR/task.md"
    local verify_file="$CURRENT_DIR/verify.sh"
    local verify_template="$TEMPLATES_DIR/verify.sh"

    # 如果有当前任务，先归档
    if [ -f "$CURRENT_TASK" ]; then
        log_info "发现现有任务，先归档..."
        auto_archive "0"
    fi

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
    echo "tmux 会话: $TMUX_SESSION"
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo "  状态: 运行中"
        echo "  附加: tmux attach -t $TMUX_SESSION"
    else
        echo "  状态: 未运行"
    fi
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

    # 复制相关日志
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

# 构建带上下文的 prompt
build_context_prompt() {
    local iteration=$1
    local log_dir="$RALPH_DIR/logs"

    # 获取 git 状态
    local git_status=""
    if git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
        git_status=$(git -C "$PROJECT_ROOT" status --short 2>/dev/null || echo "无法获取 git 状态")
    else
        git_status="非 git 仓库"
    fi

    # 获取最近修改的文件
    local recent_changes=""
    if git -C "$PROJECT_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
        recent_changes=$(git -C "$PROJECT_ROOT" diff --name-only HEAD~3 2>/dev/null | head -10 || echo "")
    fi

    cat << EOF
# Ralph Loop 上下文

你是 Ralph Loop 的执行实例（循环 #$iteration/$MAX_ITERATIONS）。

Ralph Loop 是一个结束-重启模式的自动化循环框架。每次循环启动一个全新的 AI 实例来解决问题，完成后由外部脚本进行客观验证。若验证失败，失败日志会追加到任务文件供下一轮参考。

## 项目信息
- 项目目录: \`$PROJECT_ROOT\`
- 任务文件: \`$CURRENT_TASK\`
- 验证脚本: \`$CURRENT_DIR/verify.sh\`
- 日志目录: \`$log_dir/\`

## Git 状态
\`\`\`
$git_status
\`\`\`

$([ -n "$recent_changes" ] && echo "### 最近修改的文件" && echo "\`\`\`$recent_changes\`\`\`" || echo "")

## 工作流程
1. 阅读下方任务描述和失败日志（如有）
2. 解决问题，修改代码
3. 完成后会自动进行客观验证
4. 若验证失败，失败日志会追加到任务文件

---

$(cat "$CURRENT_TASK")
EOF
}

# 确保tmux会话存在
ensure_tmux_session() {
    if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux new-session -d -s "$TMUX_SESSION" -c "$PROJECT_ROOT"
        # 设置较大的历史缓冲区
        tmux set-option -t "$TMUX_SESSION" history-limit 50000
        log_info "创建 tmux 会话: $TMUX_SESSION"
    fi
}

# 终止tmux会话
kill_tmux_session() {
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux kill-session -t "$TMUX_SESSION"
        log_info "终止 tmux 会话: $TMUX_SESSION"
    fi
}

# 捕获 tmux pane 内容到文件
capture_pane() {
    local output_file="$1"
    tmux capture-pane -t "$TMUX_SESSION" -p -S -10000 > "$output_file" 2>/dev/null
}

# 在 tmux 中运行 claude 并等待完成
run_claude_in_tmux() {
    local context_prompt="$1"
    local log_file="$2"
    local timeout=$CLAUDE_TIMEOUT
    local elapsed=0

    # 确保会话存在
    ensure_tmux_session

    # 清空 pane，发送命令
    tmux send-keys -t "$TMUX_SESSION" "clear" Enter
    sleep 0.5

    # 将 prompt 写入临时文件，让 claude 读取
    local prompt_file="/tmp/ralph-prompt-$$.txt"
    echo "$context_prompt" > "$prompt_file"

    # 发送 claude 命令
    tmux send-keys -t "$TMUX_SESSION" "claude -p '$prompt_file'" Enter

    log_info "claude 已启动，等待完成 (超时: ${timeout}s)..."
    log_info "可随时附加观察: tmux attach -t $TMUX_SESSION"

    # 轮询检测完成状态
    # 检测方式：pane 中出现 shell 提示符，且没有 claude 进程在运行
    while [ $elapsed -lt $timeout ]; do
        sleep $POLL_INTERVAL
        elapsed=$((elapsed + POLL_INTERVAL))

        # 检查 claude 进程是否还在运行
        local claude_running=$(tmux send-keys -t "$TMUX_SESSION" "" 2>/dev/null && \
            pgrep -f "claude.*ralph-prompt" > /dev/null 2>&1 && echo "1" || echo "0")

        if [ "$claude_running" = "0" ]; then
            # 检查是否回到了 shell 提示符
            local pane_content=$(tmux capture-pane -t "$TMUX_SESSION" -p | tail -5)
            if echo "$pane_content" | grep -qE '\$|#\s*$|>\s*$'; then
                log_ok "claude 执行完成 (耗时: ${elapsed}s)"
                break
            fi
        fi

        # 显示进度
        printf "\r${BLUE}[INFO]${NC} 等待中... %ds/%ds " "$elapsed" "$timeout"
    done
    echo ""

    # 超时处理
    if [ $elapsed -ge $timeout ]; then
        log_warn "执行超时，发送 Ctrl-C..."
        tmux send-keys -t "$TMUX_SESSION" C-c
        sleep 2
    fi

    # 捕获完整输出
    capture_pane "$log_file"

    # 清理临时文件
    rm -f "$prompt_file"

    return 0
}

# 主循环
main() {
    if [ ! -f "$CURRENT_TASK" ]; then
        log_err "无当前任务"
        log_info "创建新任务: $0 --new"
        exit 1
    fi

    log_ralph "════════════════════════════════════════════════════════"
    log_ralph "  Ralph Loop - 结束-重启模式 (tmux 版)"
    log_ralph "════════════════════════════════════════════════════════"
    log_info "项目: $PROJECT_ROOT"
    log_info "任务: $CURRENT_TASK"
    log_info "熔断: 最大 $MAX_ITERATIONS 次循环"
    log_info "tmux: $TMUX_SESSION (附加: tmux attach -t $TMUX_SESSION)"
    echo ""

    local iter=0
    local log_dir="$RALPH_DIR/logs"
    mkdir -p "$log_dir"

    # 清理可能存在的旧会话
    kill_tmux_session

    while [ $iter -lt $MAX_ITERATIONS ]; do
        iter=$((iter + 1))
        local log_file="$log_dir/iteration_$(printf '%03d' $iter).log"

        log_ralph "────────────────────────────────────────────────────"
        log_ralph "循环 #$iter"
        log_ralph "────────────────────────────────────────────────────"

        # 构建上下文
        local context_prompt=$(build_context_prompt $iter)
        log_info "注入上下文:"
        echo "$context_prompt" | head -30
        echo ""
        log_info "... (完整内容见任务文件)"
        echo ""

        # 核心：在 tmux 中启动 claude
        run_claude_in_tmux "$context_prompt" "$log_file"

        log_info "日志已保存: $log_file"

        # Stop Hook：客观检查
        log_info "Stop Hook: 客观检查..."

        bash "$STOP_HOOK" 2>&1 | tee "${log_file}.hook"
        HOOK_EXIT_CODE=${PIPESTATUS[0]}

        if [ $HOOK_EXIT_CODE -eq 0 ]; then
            log_ok "════════════════════════════════════════════════════════"
            log_ok "🎉 客观标准达成！循环结束"
            log_ok "总循环: $iter"
            log_ok "════════════════════════════════════════════════════════"

            # 清理 tmux 会话
            kill_tmux_session

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
    log_err "tmux 会话保留，可附加查看: tmux attach -t $TMUX_SESSION"
    log_err "════════════════════════════════════════════════════════"
    exit 1
}

# 附加到 tmux 会话
attach_tmux() {
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux attach -t "$TMUX_SESSION"
    else
        log_err "tmux 会话 '$TMUX_SESSION' 不存在"
        exit 1
    fi
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
    --attach)
        attach_tmux
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
