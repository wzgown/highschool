#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Agent 运行告警：无状态、幂等，可 cron 每 15 分钟执行一次。

检查项（命中任意一项即告警）:
  1. 最近 1 小时 LLM 错误率 > 20%（且调用数 > 5，避免小样本误报）
  2. 当日累计 tokens 超预算 DAILY_TOKEN_BUDGET
  3. agent_trace 最近 1 小时完全无写入，但 agent_message 有新用户消息
     —— 说明 agent 在跑但 trace 落库失败

告警输出: 若设置了环境变量 AGENT_ALERT_WEBHOOK（企业微信群机器人地址），
以 markdown 消息 POST 过去；否则打印到 stdout（cron 邮件/日志可收）。

依赖: 仅 Python 标准库 + 本机 psql。只执行 SELECT。
连接参数: 优先 PGHOST/PGPORT/PGDATABASE/PGUSER/PGPASSWORD 环境变量，
否则解析 backend/config.yaml 的 database 段。
"""
import json
import os
import re
import subprocess
import sys
import urllib.request

# 当日 LLM token 预算（prompt + completion 合计）。
# 默认 200 万：按 deepseek-chat 公开价约 ¥10~20/天的量级，可按实际业务调整。
DAILY_TOKEN_BUDGET = 2_000_000

# 最近 1 小时 LLM 错误率阈值与最小样本数
ERROR_RATE_THRESHOLD = 0.20
ERROR_RATE_MIN_CALLS = 5

CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "config.yaml")


def load_conn_from_config():
    cfg = {}
    try:
        with open(CONFIG_PATH, encoding="utf-8") as f:
            in_db = False
            for line in f:
                if re.match(r"^database:\s*$", line):
                    in_db = True
                    continue
                if in_db:
                    if re.match(r"^\S", line):
                        break
                    m = re.match(r"^\s+(\w+):\s*(.+?)\s*$", line)
                    if m:
                        cfg[m.group(1)] = m.group(2).strip("'\"")
    except OSError:
        pass
    return cfg


def psql_scalar(sql):
    env = dict(os.environ)
    cfg = load_conn_from_config()
    env["PGPASSWORD"] = env.get("PGPASSWORD") or cfg.get("password", "")
    out = subprocess.run(
        ["psql",
         "-h", env.get("PGHOST") or cfg.get("host", "localhost"),
         "-p", str(env.get("PGPORT") or cfg.get("port", "5432")),
         "-U", env.get("PGUSER") or cfg.get("user", "highschool"),
         "-d", env.get("PGDATABASE") or cfg.get("name", "highschool"),
         "-X", "-A", "-t", "-c", sql],
        env=env, capture_output=True, text=True, timeout=30)
    if out.returncode != 0:
        raise RuntimeError("psql 失败: " + out.stderr.strip())
    return out.stdout.strip()


def check_llm_error_rate():
    """返回 (告警文本 or None)。"""
    res = psql_scalar("""
        SELECT COUNT(*), COUNT(*) FILTER (WHERE output ? 'error')
        FROM agent_trace
        WHERE kind='llm' AND created_at >= now() - interval '1 hour'
    """)
    calls, errs = (int(x) for x in res.split("|")) if "|" in res else (int(res or 0), 0)
    if calls > ERROR_RATE_MIN_CALLS:
        rate = errs / calls
        if rate > ERROR_RATE_THRESHOLD:
            return (f"LLM 错误率异常: 最近 1 小时 {errs}/{calls} 次失败"
                    f"（{rate:.0%} > {ERROR_RATE_THRESHOLD:.0%}）")
    return None


def check_token_budget():
    res = psql_scalar("""
        SELECT COALESCE(SUM(prompt_tokens),0) + COALESCE(SUM(completion_tokens),0)
        FROM agent_trace
        WHERE kind='llm' AND created_at >= CURRENT_DATE
    """)
    tokens = int(res or 0)
    if tokens > DAILY_TOKEN_BUDGET:
        return f"当日 token 超预算: {tokens:,} > {DAILY_TOKEN_BUDGET:,}"
    return None


def check_trace_missing():
    res = psql_scalar("""
        SELECT
          (SELECT COUNT(*) FROM agent_trace
            WHERE created_at >= now() - interval '1 hour'),
          (SELECT COUNT(*) FROM agent_message
            WHERE role='user' AND created_at >= now() - interval '1 hour')
    """)
    trace_cnt, user_msg_cnt = (int(x) for x in res.split("|"))
    if trace_cnt == 0 and user_msg_cnt > 0:
        return (f"trace 落库疑似失败: 最近 1 小时有 {user_msg_cnt} 条新用户消息，"
                f"但 agent_trace 无任何写入")
    return None


def send_webhook(text):
    """企业微信群机器人 markdown 消息。"""
    url = os.environ["AGENT_ALERT_WEBHOOK"]
    body = json.dumps({"msgtype": "markdown", "markdown": {"content": text}}).encode()
    req = urllib.request.Request(url, data=body,
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        if resp.status != 200:
            raise RuntimeError(f"webhook 返回 {resp.status}")


def main():
    alerts = []
    for check in (check_llm_error_rate, check_token_budget, check_trace_missing):
        try:
            msg = check()
            if msg:
                alerts.append(msg)
        except Exception as e:  # 单项检查失败不应掩盖其他告警
            alerts.append(f"检查 {check.__name__} 执行失败: {e}")

    if not alerts:
        return 0

    text = "**⚠️ Agent 运行告警**\n" + "\n".join(f"> {a}" for a in alerts)
    if os.environ.get("AGENT_ALERT_WEBHOOK"):
        try:
            send_webhook(text)
        except Exception as e:
            print(f"[webhook 发送失败: {e}]", file=sys.stderr)
            print(text)
    else:
        print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
