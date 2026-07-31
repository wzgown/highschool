package graph

import (
	"testing"

	"highschool-backend/internal/service/agent"
)

func tr(forLLM string) agent.ToolResult {
	return agent.ToolResult{ForLLM: forLLM, Summary: "test"}
}

func TestVerifyReply_PassWhenNumbersFromTools(t *testing.T) {
	results := []agent.ToolResult{
		tr(`{"school":"上海市第二中学","scores":[{"year":2024,"min_score":683.5},{"year":2025,"min_score":682.5},{"year":2026,"min_score":689.5}]}`),
	}
	reply := "市二中学在徐汇区平行志愿录取线：2024年683.5分、2025年682.5分、2026年689.5分（750分制）。2026年比2025年上涨7分。数据仅供参考，以上海市教育考试院官方公布为准。"
	pass, reason := verifyReply(reply, results)
	if !pass {
		t.Fatalf("expected pass, got fail: %s", reason)
	}
}

func TestVerifyReply_FailOnHallucinatedNumber(t *testing.T) {
	results := []agent.ToolResult{
		tr(`{"school":"上海市第二中学","scores":[{"year":2026,"min_score":689.5}]}`),
	}
	reply := "市二中学2026年平行志愿线689.5分，2025年是690.5分。"
	pass, reason := verifyReply(reply, results)
	if pass {
		t.Fatal("expected fail for hallucinated 690.5, got pass")
	}
	t.Logf("blocked: %s", reason)
}

func TestVerifyReply_DifferenceAllowed(t *testing.T) {
	results := []agent.ToolResult{
		tr(`{"scores":[{"year":2025,"min_score":682.5},{"year":2026,"min_score":689.5}]}`),
	}
	// 7 = 689.5 - 682.5，派生差值应被允许
	reply := "2026年689.5分，比2025年的682.5分上涨了7分。"
	pass, reason := verifyReply(reply, results)
	if !pass {
		t.Fatalf("expected pass for derived difference, got fail: %s", reason)
	}
}

func TestVerifyReply_NoToolResultsSkipsNumberCheck(t *testing.T) {
	pass, _ := verifyReply("名额分配占市重点计划约65%，其中委属约80%到区。", nil)
	if !pass {
		t.Fatal("expected pass when no tool results")
	}
}

func TestVerifyReply_EmptyReplyFails(t *testing.T) {
	pass, _ := verifyReply("", []agent.ToolResult{tr(`{"a":1}`)})
	if pass {
		t.Fatal("expected fail for empty reply")
	}
}

func TestVerifyReply_WhitelistAndYears(t *testing.T) {
	results := []agent.ToolResult{
		tr(`{"school":"上海市格致中学","min_score":691.0}`),
	}
	reply := "格致中学2026年平行志愿线691分（750分制）。2026年普高最低控制线为501分，名额分配批次为800分制。数据仅供参考。"
	pass, reason := verifyReply(reply, results)
	if !pass {
		t.Fatalf("expected pass (whitelist/year numbers), got fail: %s", reason)
	}
}

func TestExtractJSON(t *testing.T) {
	cases := []string{
		`{"intent":"data_query"}`,
		"```json\n{\"intent\":\"policy_qa\"}\n```",
		`前言 {"intent":"recommendation"} 后记`,
	}
	for _, c := range cases {
		got := extractJSON(c)
		if got == "" || got[0] != '{' {
			t.Fatalf("extractJSON failed for %q -> %q", c, got)
		}
	}
}
