// reflection.go Reflection 程序化校验器
// 核心规则：回答中的数字必须能溯源到工具结果（允许直接命中、两者之差、白名单常量）
package graph

import (
	"math"
	"regexp"
	"strconv"
	"strings"

	"highschool-backend/internal/service/agent"
)

var numberRe = regexp.MustCompile(`\d+(?:\.\d+)?`)

// numberWhitelist 政策/常识常量白名单（出现在 system prompt 中的规则数字）
var numberWhitelist = map[float64]bool{
	1: true, 2: true, 3: true, 4: true, 5: true, 6: true, 7: true, 8: true,
	10: true, 12: true, 15: true, 16: true, 20: true, 30: true, 50: true,
	65: true, 70: true, 80: true, 100: true, 300: true, 400: true, 500: true,
	501: true, 513: true, 605: true, 615: true, 750: true, 800: true,
}

// verifyReply 校验回答中的数字是否全部可溯源
// 返回 (pass, reason)；无工具结果时直接通过（政策问答类）
func verifyReply(reply string, toolResults []agent.ToolResult) (bool, string) {
	if strings.TrimSpace(reply) == "" {
		return false, "回答为空"
	}
	if len(toolResults) == 0 {
		return true, ""
	}
	// 工具结果中的全部数字（容差集合）
	sourceSet := make(map[float64]bool)
	var sourceNums []float64
	for _, tr := range toolResults {
		for _, n := range extractNumbers(tr.ForLLM) {
			sourceSet[round2(n)] = true
			sourceNums = append(sourceNums, n)
		}
	}
	// 允许的派生值：两数之差（涨跌/gap）
	derivedSet := make(map[float64]bool)
	for i := 0; i < len(sourceNums); i++ {
		for j := 0; j < len(sourceNums); j++ {
			derivedSet[round2(sourceNums[i]-sourceNums[j])] = true
			derivedSet[round2(sourceNums[j]-sourceNums[i])] = true
		}
	}
	for _, n := range extractNumbers(reply) {
		if isYear(n) || numberWhitelist[n] {
			continue
		}
		r := round2(n)
		if sourceSet[r] || derivedSet[r] {
			continue
		}
		// 容差匹配（0.05）
		if approxIn(sourceSet, r, 0.05) || approxIn(derivedSet, r, 0.05) {
			continue
		}
		return false, "回答中的数字无法在工具结果中溯源: " + strconv.FormatFloat(n, 'f', -1, 64)
	}
	return true, ""
}

// extractNumbers 提取文本中的全部数字
func extractNumbers(text string) []float64 {
	matches := numberRe.FindAllString(text, -1)
	nums := make([]float64, 0, len(matches))
	for _, m := range matches {
		if f, err := strconv.ParseFloat(m, 64); err == nil {
			nums = append(nums, f)
		}
	}
	return nums
}

func round2(f float64) float64 { return math.Round(f*100) / 100 }

func isYear(n float64) bool { return n >= 1900 && n <= 2100 }

func approxIn(set map[float64]bool, target, tol float64) bool {
	for k := range set {
		if math.Abs(k-target) <= tol {
			return true
		}
	}
	return false
}
