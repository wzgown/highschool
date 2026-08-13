-- P4: 取消 agent_checkpoint 的 (session_id, step_seq) 唯一约束
-- 原因：Run 每轮 stepSeq 从 0 重置（每轮重建 State 的设计），该约束会丢弃第 2 轮起的 checkpoint。
-- checkpoint 语义为「轮内逐节点快照」，step_seq 轮内递增即可，无需全 session 唯一。
-- 详见 docs/agent-state-model-review.md §2 P4 / §4 C1
ALTER TABLE agent_checkpoint DROP CONSTRAINT IF EXISTS agent_checkpoint_session_id_step_seq_key;
