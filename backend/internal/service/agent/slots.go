// Package agent 槽位（slots）分级：持久槽位跨意图保留，易变槽位意图切换时清除。
// 详见 docs/agent-state-model-review.md §1.6 / §4 A1
package agent

// 持久槽位：用户/考生的长期属性，说一次即整场会话保留
var persistentSlots = map[string]bool{
	"district_name": true, // 所在区
	"total_score":   true, // 总分
	"exam_type":     true, // 考试类型（MOCK1/MOCK2/ZHONGKAO）
}

// IsPersistentSlot 是否持久槽位（跨意图保留）。
func IsPersistentSlot(k string) bool { return persistentSlots[k] }
