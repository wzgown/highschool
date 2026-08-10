#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Agent 成本/用量日报：输出 Markdown 到 stdout。

用法:
    python3 agent_daily_report.py [YYYY-MM-DD]   # 默认统计"昨天"
    python3 agent_daily_report.py > reports/daily/$(date -v-1d +%F)-agent.md

依赖: 仅 Python 标准库 + 本机 psql。
连接参数: 优先取环境变量 PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD，
否则解析 backend/config.yaml 的 database 段（简单 key: value，不用 yaml 库）。

注意: 脚本只执行 SELECT，直连基表（不依赖 012 视图是否已创建）。
"""
import datetime
import os
import re
import subprocess
import sys

# ---------------------------------------------------------------
# DeepSeek deepseek-chat 公开定价（元/百万 tokens）
# ⚠️ 按官网公开价 (https://api-docs.deepseek.com/quick_start/pricing)，
#    使用前请校对官网最新价格；缓存命中价未细分，统一按 miss 价估算，偏保守。
# ---------------------------------------------------------------
DEEPSEEK_INPUT_PRICE_PER_M = 2.0    # 输入（cache miss），元/百万 tokens
DEEPSEEK_OUTPUT_PRICE_PER_M = 8.0   # 输出，元/百万 tokens

# 与近 7 天均值对比的异常阈值：超过均值 N 倍标 ⚠️
ANOMALY_RATIO = 3.0

CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "config.yaml")


def load_conn_from_config():
    """从 backend/config.yaml 的 database 段抠出连接参数（避免引入 yaml 依赖）。"""
    cfg = {}
    try:
        with open(CONFIG_PATH, encoding="utf-8") as f:
            in_db = False
            for line in f:
                if re.match(r"^database:\s*$", line):
                    in_db = True
                    continue
                if in_db:
                    if re.match(r"^\S", line):  # 下一个顶层段开始
                        break
                    m = re.match(r"^\s+(\w+):\s*(.+?)\s*$", line)
                    if m:
                        cfg[m.group(1)] = m.group(2).strip("'\"")
    except OSError:
        pass
    return cfg


def psql(sql):
    """执行只读 SQL，返回 (列名列表, 行列表[均为 str])。"""
    env = dict(os.environ)
    cfg = load_conn_from_config()
    host = env.get("PGHOST") or cfg.get("host", "localhost")
    port = env.get("PGPORT") or cfg.get("port", "5432")
    db = env.get("PGDATABASE") or cfg.get("name", "highschool")
    user = env.get("PGUSER") or cfg.get("user", "highschool")
    password = env.get("PGPASSWORD") or cfg.get("password", "")
    env["PGPASSWORD"] = password
    out = subprocess.run(
        ["psql", "-h", host, "-p", str(port), "-U", user, "-d", db,
         "-X", "-A", "-F", "\t", "--pset=footer=off", "-c", sql],
        env=env, capture_output=True, text=True, timeout=60)
    if out.returncode != 0:
        sys.stderr.write("psql 执行失败:\n" + out.stderr)
        sys.exit(2)
    lines = [ln for ln in out.stdout.splitlines() if ln != ""]
    if not lines:
        return [], []
    return lines[0].split("\t"), [ln.split("\t") for ln in lines[1:]]


def q1(sql):
    """取单行单列的辅助函数，空结果返回 None。"""
    _, rows = psql(sql)
    if not rows or not rows[0] or rows[0][0] == "":
        return None
    return rows[0][0]


def fmt_cost(pt, ct):
    cost = pt / 1_000_000 * DEEPSEEK_INPUT_PRICE_PER_M \
        + ct / 1_000_000 * DEEPSEEK_OUTPUT_PRICE_PER_M
    return cost


def warn(value, avg7):
    """value 超过 7 日均值 ANOMALY_RATIO 倍时标 ⚠️。"""
    if avg7 is not None and avg7 > 0 and value > avg7 * ANOMALY_RATIO:
        return f" ⚠️（超近 7 日均值 {value / avg7:.1f} 倍）"
    return ""


def main():
    if len(sys.argv) > 1:
        day = datetime.date.fromisoformat(sys.argv[1])
    else:
        day = datetime.date.today() - datetime.timedelta(days=1)
    d = day.isoformat()

    # ---- 昨日 LLM 概览 ----------------------------------------------------
    row = psql(f"""
        SELECT COUNT(*),
               COALESCE(SUM(prompt_tokens),0),
               COALESCE(SUM(completion_tokens),0),
               COALESCE(SUM(prompt_tokens),0)+COALESCE(SUM(completion_tokens),0),
               COALESCE(ROUND(AVG(latency_ms)),0),
               COALESCE(ROUND(percentile_cont(0.95) WITHIN GROUP (ORDER BY latency_ms)),0),
               COUNT(*) FILTER (WHERE output ? 'error')
        FROM agent_trace
        WHERE kind='llm' AND created_at >= DATE '{d}' AND created_at < DATE '{d}' + 1
    """)[1][0]
    calls, pt, ct, total, avg_lat, p95_lat, errs = (int(x) for x in row)

    # 近 7 天日均（不含当日），用于异常对比
    avg7_calls = q1(f"""
        SELECT ROUND(AVG(cnt)::numeric, 1) FROM (
            SELECT COUNT(*) AS cnt FROM agent_trace
            WHERE kind='llm' AND created_at >= DATE '{d}' - 7 AND created_at < DATE '{d}'
            GROUP BY created_at::date) t
    """)
    avg7_tokens = q1(f"""
        SELECT ROUND(AVG(tok)::numeric, 0) FROM (
            SELECT COALESCE(SUM(prompt_tokens),0)+COALESCE(SUM(completion_tokens),0) AS tok
            FROM agent_trace
            WHERE kind='llm' AND created_at >= DATE '{d}' - 7 AND created_at < DATE '{d}'
            GROUP BY created_at::date) t
    """)
    avg7_calls = float(avg7_calls) if avg7_calls else None
    avg7_tokens = float(avg7_tokens) if avg7_tokens else None

    # ---- 昨日 tool 调用 ---------------------------------------------------
    tool_rows = psql(f"""
        SELECT COALESCE(name,'(unknown)'), COUNT(*),
               COUNT(*) FILTER (WHERE output ? 'error'),
               COALESCE(ROUND(AVG(latency_ms)),0)
        FROM agent_trace
        WHERE kind='tool' AND created_at >= DATE '{d}' AND created_at < DATE '{d}' + 1
        GROUP BY 1 ORDER BY 2 DESC, 1
    """)[1]

    # ---- 昨日会话/消息 ----------------------------------------------------
    sess = psql(f"""
        SELECT COUNT(DISTINCT session_id), COUNT(*),
               COUNT(*) FILTER (WHERE role='user'),
               COUNT(*) FILTER (WHERE role='assistant')
        FROM agent_message
        WHERE created_at >= DATE '{d}' AND created_at < DATE '{d}' + 1
    """)[1][0]
    active_sessions, msgs, user_msgs, asst_msgs = (int(x) for x in sess)

    # ---- 输出 Markdown ----------------------------------------------------
    cost = fmt_cost(pt, ct)
    print(f"# Agent 日报 {d}\n")
    print("> 数据源: agent_trace / agent_message / agent_session（只读统计）\n")

    print("## LLM 调用与成本\n")
    print("| 指标 | 数值 | 备注 |")
    print("|---|---|---|")
    print(f"| LLM 调用次数 | {calls} |{warn(calls, avg7_calls)} |")
    print(f"| Prompt tokens | {pt:,} | |")
    print(f"| Completion tokens | {ct:,} | |")
    print(f"| 总 tokens | {total:,} |{warn(total, avg7_tokens)} |")
    print(f"| 估算成本 | ¥{cost:.4f} | deepseek-chat 公开价估算，见脚本头常量 |")
    print(f"| 平均延迟 | {avg_lat} ms | p95: {p95_lat} ms |")
    err_note = " ⚠️ 有失败调用" if errs > 0 else ""
    print(f"| 错误次数 | {errs} |{err_note} |\n")

    print("## 工具调用 TOP\n")
    if tool_rows:
        print("| 工具 | 次数 | 失败 | 平均耗时(ms) |")
        print("|---|---|---|---|")
        for name, c, f_, lat in tool_rows:
            flag = " ⚠️" if int(f_) > 0 else ""
            print(f"| {name} | {c} | {f_}{flag} | {lat} |")
        print()
    else:
        print("（昨日无工具调用）\n")

    print("## 活跃会话\n")
    print(f"- 活跃会话数: **{active_sessions}**")
    print(f"- 消息总数: {msgs}（用户 {user_msgs} / 助手 {asst_msgs}）\n")

    print("## 与近 7 天均值对比\n")
    print(f"- LLM 调用 7 天日均: {avg7_calls if avg7_calls is not None else '无数据'}"
          f"，昨日 {calls}{warn(calls, avg7_calls)}")
    avg7_tokens_str = f"{int(avg7_tokens):,}" if avg7_tokens is not None else "无数据"
    print(f"- 总 tokens 7 天日均: {avg7_tokens_str}，昨日 {total:,}{warn(total, avg7_tokens)}")
    print()
    print("---")
    print(f"_生成时间: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}_")


if __name__ == "__main__":
    main()
