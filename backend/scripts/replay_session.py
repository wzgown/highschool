#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""会话回放查询工具：按时间线还原 AI 顾问会话的全部留痕。

用法：
    python3 replay_session.py <session_id> [--full]   回放单个会话
    python3 replay_session.py --list [--days N]       列出最近 N 天（默认 3）的会话

仅依赖 Python 标准库，通过 subprocess 调用本机 psql 查询生产库。
连接信息默认读取 backend/config.yaml 的 database 段，可用 PGHOST/PGPORT/
PGDATABASE/PGUSER/PGPASSWORD 环境变量覆盖。
"""

import argparse
import json
import os
import re
import subprocess
import sys

# 默认截断长度（--full 时不截断）
TRUNC = 200

CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "config.yaml")


def load_db_config():
    """从 config.yaml 用正则提取 database 段连接信息（避免引入 yaml 依赖），环境变量优先。"""
    cfg = {}
    try:
        with open(CONFIG_PATH, encoding="utf-8") as f:
            text = f.read()
        m = re.search(r"^database:\n((?:[ \t]+\S.*\n)+)", text, re.M)
        if m:
            for line in m.group(1).splitlines():
                kv = re.match(r"\s*(\w+):\s*(.+?)\s*$", line)
                if kv:
                    cfg[kv.group(1)] = kv.group(2).strip('"').strip("'")
    except OSError:
        pass
    return {
        "host": os.environ.get("PGHOST", cfg.get("host", "localhost")),
        "port": os.environ.get("PGPORT", cfg.get("port", "5432")),
        "dbname": os.environ.get("PGDATABASE", cfg.get("name", "highschool")),
        "user": os.environ.get("PGUSER", cfg.get("user", "postgres")),
        "password": os.environ.get("PGPASSWORD", cfg.get("password", "")),
    }


def query(sql, cfg):
    """执行 SQL 并返回行列表（每行已被服务端包成 JSON 对象）。"""
    env = dict(os.environ)
    if cfg["password"]:
        env["PGPASSWORD"] = cfg["password"]
    wrapped = "SELECT coalesce(json_agg(t), '[]'::json) FROM (%s) t" % sql
    proc = subprocess.run(
        ["psql", "-h", cfg["host"], "-p", str(cfg["port"]), "-U", cfg["user"],
         "-d", cfg["dbname"], "-X", "-A", "-t", "-c", wrapped],
        capture_output=True, text=True, env=env, timeout=120,
    )
    if proc.returncode != 0:
        sys.stderr.write("psql 执行失败：%s\nSQL: %s\n" % (proc.stderr.strip(), sql))
        sys.exit(1)
    out = proc.stdout.strip()
    return json.loads(out) if out else []


def trunc(text, full, limit=TRUNC):
    """长文本截断，--full 时原样返回。"""
    if text is None:
        return ""
    text = str(text)
    if full or len(text) <= limit:
        return text
    return text[:limit] + "…[截断 %d 字符]" % (len(text) - limit)


def has_error_column(cfg):
    """agent_trace 历史上没有 error 列，做兼容探测。"""
    rows = query(
        "SELECT 1 AS x FROM information_schema.columns "
        "WHERE table_name='agent_trace' AND column_name='error'", cfg)
    return bool(rows)


# ---------- 模式一：会话清单 ----------

def list_sessions(days, cfg):
    rows = query("""
        SELECT s.id AS session_id,
               s.status, s.intent,
               (SELECT count(*) FROM agent_message m WHERE m.session_id = s.id) AS msg_count,
               (SELECT count(*) FROM agent_trace t WHERE t.session_id = s.id AND t.kind = 'llm') AS llm_count,
               (SELECT coalesce(sum(t.prompt_tokens + t.completion_tokens), 0)
                  FROM agent_trace t WHERE t.session_id = s.id AND t.kind = 'llm') AS total_tokens,
               s.last_active_at
          FROM agent_session s
         WHERE s.last_active_at >= now() - interval '%d days'
         ORDER BY s.last_active_at DESC
    """ % int(days), cfg)
    if not rows:
        print("最近 %d 天没有会话。" % days)
        return
    print("最近 %d 天的会话（共 %d 个）：\n" % (days, len(rows)))
    print("%-6s %-10s %-18s %6s %6s %8s  %s" % (
        "ID", "状态", "意图", "消息数", "LLM数", "总tokens", "最后活动"))
    print("-" * 90)
    for r in rows:
        print("%-6s %-10s %-18s %6s %6s %8s  %s" % (
            r["session_id"], r["status"], r.get("intent") or "-",
            r["msg_count"], r["llm_count"], r["total_tokens"],
            str(r["last_active_at"])[:19]))


# ---------- 模式二：会话回放 ----------

def fmt_checkpoint_summary(state, full):
    """从 checkpoint 的 State 快照提取关键字段，不 dump 全量（messages 可能很长）。"""
    parts = []
    if state.get("intent"):
        parts.append("intent=%s" % state["intent"])
    if state.get("slots"):
        parts.append("slots=%s" % json.dumps(state["slots"], ensure_ascii=False))
    plan = state.get("plan") or []
    if plan:
        tools = [p.get("tool_name", "?") for p in plan if isinstance(p, dict)]
        parts.append("plan=%s" % tools)
    if state.get("pending_q"):
        parts.append("pending_q=%s" % trunc(json.dumps(state["pending_q"], ensure_ascii=False), full, 80))
    infos = state.get("tool_call_infos") or []
    if infos:
        desc = ["%s(%s)" % (i.get("name", "?"), "ok" if i.get("success") else "fail") for i in infos]
        parts.append("tools=%s" % desc)
    parts.append("step_budget=%s replan=%s" % (state.get("step_budget"), state.get("replan_count")))
    if state.get("reply"):
        parts.append("reply=%s" % trunc(state["reply"], full, 120))
    if state.get("cards"):
        parts.append("cards=%d张" % len(state["cards"]))
    msgs = state.get("messages") or []
    parts.append("messages=%d条" % len(msgs))
    return "; ".join(parts)


def replay(session_id, full, cfg):
    sessions = query(
        "SELECT id, device_id, status, current_node, intent, slots, pending_question,"
        "       created_at, last_active_at FROM agent_session WHERE id = %d" % session_id, cfg)
    if not sessions:
        sys.exit("会话 %d 不存在。" % session_id)
    sess = sessions[0]

    messages = query(
        "SELECT id, role, node, content, tool_calls, usage, created_at"
        " FROM agent_message WHERE session_id = %d ORDER BY id" % session_id, cfg)
    err_col = ", error" if has_error_column(cfg) else ", NULL::text AS error"
    traces = query(
        "SELECT id, kind, name, input, output, prompt_tokens, completion_tokens, latency_ms, created_at"
        + err_col +
        " FROM agent_trace WHERE session_id = %d ORDER BY id" % session_id, cfg)
    checkpoints = query(
        "SELECT id, step_seq, node, state, created_at"
        " FROM agent_checkpoint WHERE session_id = %d ORDER BY step_seq" % session_id, cfg)

    print("=" * 100)
    print("会话 #%s  设备=%s  状态=%s  意图=%s  当前节点=%s" % (
        sess["id"], sess["device_id"], sess["status"], sess.get("intent"), sess.get("current_node")))
    print("创建=%s  最后活动=%s" % (str(sess["created_at"])[:19], str(sess["last_active_at"])[:19]))
    print("slots=%s" % json.dumps(sess.get("slots") or {}, ensure_ascii=False))
    if sess.get("pending_question"):
        print("pending_question=%s" % trunc(
            json.dumps(sess["pending_question"], ensure_ascii=False), full))
    print("=" * 100)

    # 合并三类事件为统一时间线：同秒时按 消息 < trace < checkpoint 排序
    events = []
    for m in messages:
        events.append((m["created_at"], 0, m["id"], ("msg", m)))
    for t in traces:
        events.append((t["created_at"], 1, t["id"], ("trace", t)))
    for c in checkpoints:
        events.append((c["created_at"], 2, c["id"], ("ckpt", c)))
    events.sort(key=lambda e: (e[0], e[1], e[2]))

    for ts, _, _, (etype, e) in events:
        time = str(ts)[11:19]
        if etype == "msg":
            role_label = {"user": "用户", "assistant": "助手", "system": "系统"}.get(e["role"], e["role"])
            line = "[%s] 【%s】%s" % (time, role_label, trunc(e["content"], full))
            if e.get("node"):
                line += "  (node=%s)" % e["node"]
            print(line)
            if e.get("usage"):
                print("         usage=%s" % json.dumps(e["usage"], ensure_ascii=False))
            if e.get("tool_calls"):
                print("         tool_calls=%s" % trunc(json.dumps(e["tool_calls"], ensure_ascii=False), full))
        elif etype == "trace":
            kind, name = e["kind"], e.get("name") or "-"
            latency = "%sms" % e["latency_ms"] if e.get("latency_ms") is not None else "-"
            if kind == "llm":
                print("[%s] ── LLM 调用: %s  tokens=%s+%s  耗时=%s" % (
                    time, name, e.get("prompt_tokens"), e.get("completion_tokens"), latency))
                msgs = e.get("input") or []
                if isinstance(msgs, list):
                    for msg in msgs:
                        print("         入参[%s]: %s" % (
                            msg.get("role", "?"), trunc(msg.get("content"), full)))
                out = e.get("output") or {}
                if isinstance(out, dict):
                    if out.get("content"):
                        print("         响应: %s" % trunc(out["content"], full))
                    if out.get("tool_calls"):
                        print("         响应tool_calls: %s" % trunc(
                            json.dumps(out["tool_calls"], ensure_ascii=False), full))
                if e.get("error"):
                    print("         !! error: %s" % e["error"])
            elif kind == "tool":
                print("[%s] ── 工具调用: %s  耗时=%s" % (time, name, latency))
                print("         args: %s" % trunc(json.dumps(e.get("input"), ensure_ascii=False), full))
                out = e.get("output") or {}
                if isinstance(out, dict):
                    print("         结果: %s" % (out.get("summary") or trunc(
                        json.dumps(out, ensure_ascii=False), full)))
                    if full and out.get("for_llm"):
                        print("         for_llm: %s" % out["for_llm"])
                if e.get("error"):
                    print("         !! error: %s" % e["error"])
            else:  # node
                out = e.get("output") or {}
                nxt = out.get("next") if isinstance(out, dict) else None
                print("[%s] ── 节点: %s → %s  耗时=%s" % (time, name, nxt or "?", latency))
                if e.get("error"):
                    print("         !! error: %s" % e["error"])
        else:  # ckpt
            print("[%s] ◆ checkpoint #%s 节点=%s" % (time, e["step_seq"], e["node"]))
            print("         %s" % fmt_checkpoint_summary(e.get("state") or {}, full))

    print("=" * 100)
    total_pt = sum(t.get("prompt_tokens") or 0 for t in traces if t["kind"] == "llm")
    total_ct = sum(t.get("completion_tokens") or 0 for t in traces if t["kind"] == "llm")
    print("统计：消息 %d 条，LLM 调用 %d 次，工具调用 %d 次，checkpoint %d 个，tokens %d+%d=%d" % (
        len(messages), sum(1 for t in traces if t["kind"] == "llm"),
        sum(1 for t in traces if t["kind"] == "tool"), len(checkpoints),
        total_pt, total_ct, total_pt + total_ct))


def main():
    parser = argparse.ArgumentParser(description="AI 顾问会话回放查询工具")
    parser.add_argument("session_id", nargs="?", type=int, help="要回放的会话 ID")
    parser.add_argument("--list", action="store_true", help="列出最近会话清单")
    parser.add_argument("--days", type=int, default=3, help="--list 模式回看天数（默认 3）")
    parser.add_argument("--full", action="store_true", help="LLM 入参/响应显示全文（默认截断）")
    args = parser.parse_args()

    cfg = load_db_config()
    if args.list:
        list_sessions(args.days, cfg)
    elif args.session_id is not None:
        replay(args.session_id, args.full, cfg)
    else:
        parser.error("请指定 session_id，或使用 --list 查看会话清单")


if __name__ == "__main__":
    main()
