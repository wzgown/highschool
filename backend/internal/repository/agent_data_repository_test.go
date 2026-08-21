// agent_data_repository_test.go 校名解析（变体展开/候选提示）的单元与集成测试。
// 集成部分需要可达 Postgres：HS_DATABASE_HOST=... go test ./internal/repository/ -run SchoolName -v -count=1
package repository

import (
	"context"
	"errors"
	"strings"
	"testing"

	"highschool-backend/internal/infrastructure/database"
)

// TestExpandSchoolNameVariants 口语缩写展开的确定性与零回归保证（原样第一）。
func TestExpandSchoolNameVariants(t *testing.T) {
	// 「交大附中嘉定分校」→ 复合展开命中官方全名片段
	vs := expandSchoolNameVariants("交大附中嘉定分校")
	found := false
	for _, v := range vs {
		if v == "交通大学附属中学嘉定分校" {
			found = true
		}
	}
	if !found {
		t.Fatalf("应展开出「交通大学附属中学嘉定分校」：%v", vs)
	}
	if vs[0] != "交大附中嘉定分校" {
		t.Fatalf("原样必须第一（零回归保证）：%v", vs)
	}
	if len(vs) > 16 {
		t.Fatalf("变体数超上限：%d", len(vs))
	}

	// 不含缩写的名称只有原样一个变体
	if got := expandSchoolNameVariants("上海市格致中学"); len(got) != 1 {
		t.Fatalf("无缩写时不应产生变体：%v", got)
	}
}

// TestFindSchoolByName_VariantsAndCandidates 集成（真库）：
// ① 口语缩写命中官方全名；② 短语 exact 与全名 exact 零回归；③ 彻底 miss 带候选。
func TestFindSchoolByName_VariantsAndCandidates(t *testing.T) {
	if !dbReady() {
		t.Skip("database not initialized; set HS_DATABASE_HOST to run school name integration test")
	}
	r := NewAgentDataRepository()
	ctx := context.Background()

	// ① 口语缩写（线上实证 case）
	s, err := r.FindSchoolByName(ctx, "交大附中嘉定分校", 0)
	if err != nil {
		t.Fatalf("口语缩写应命中：%v", err)
	}
	if s.FullName != "上海交通大学附属中学嘉定分校" {
		t.Fatalf("命中校错误：%s", s.FullName)
	}

	// ② 零回归：short_name exact 与 full_name exact 仍直接命中
	s2, err := r.FindSchoolByName(ctx, "交大嘉分", 0)
	if err != nil || s2.FullName != "上海交通大学附属中学嘉定分校" {
		t.Fatalf("简称 exact 应零回归：%v %+v", err, s2)
	}
	s3, err := r.FindSchoolByName(ctx, "上海市上海中学", 0)
	if err != nil || s3.FullName != "上海市上海中学" {
		t.Fatalf("全名 exact 应零回归：%v %+v", err, s3)
	}

	// ③ 彻底 miss：带候选的 SchoolNotFoundError，且 errors.Is(ErrNotFound) 成立
	_, err = r.FindSchoolByName(ctx, "不存在的某某学校嘉定", 0)
	if err == nil {
		t.Fatal("应返回未找到")
	}
	var sne *SchoolNotFoundError
	if !errors.As(err, &sne) {
		t.Fatalf("应为 SchoolNotFoundError：%T", err)
	}
	if len(sne.Candidates) == 0 {
		t.Log("warning: 未产生候选（核心词太短可接受）")
	} else if !strings.Contains(sne.Error(), "candidates") {
		t.Fatalf("错误信息应含候选：%s", sne.Error())
	}
}

// dbReady 复用 agent_store_repository_test 的 TestMain 初始化结果
func dbReady() bool { return database.GetDB() != nil }

// TestGetScoreTrend_CrossDistrictBatchSemantics 集成（真库）：
// 区过滤只作用于到区批次——考生区≠学校所在区时（如奉贤考生问嘉定的交大嘉分），
// 到校/平行志愿线不得被滤空（「死活找不到趋势数据」的根因）。
func TestGetScoreTrend_CrossDistrictBatchSemantics(t *testing.T) {
	if !dbReady() {
		t.Skip("database not initialized; set HS_DATABASE_HOST to run score trend integration test")
	}
	r := NewAgentDataRepository()
	ctx := context.Background()

	school, err := r.FindSchoolByName(ctx, "上海交通大学附属中学嘉定分校", 0)
	if err != nil {
		t.Fatalf("find school: %v", err)
	}
	fengxian, err := r.FindDistrictByName(ctx, "奉贤区")
	if err != nil {
		t.Fatalf("find district: %v", err)
	}

	// 奉贤考生视角：到校/平行志愿（学校区语义行）必须能取到
	rows, err := r.GetScoreTrend(ctx, school.ID, "", fengxian.ID, 0)
	if err != nil {
		t.Fatalf("get score trend: %v", err)
	}
	batches := map[string]int{}
	years := map[int32]bool{}
	for _, row := range rows {
		batches[row.Batch]++
		years[row.Year] = true
	}
	if batches["UNIFIED_1_15"] == 0 {
		t.Fatalf("跨区查询的平行志愿线被滤空：%v", batches)
	}
	if batches["QUOTA_SCHOOL"] == 0 {
		t.Fatalf("跨区查询的到校线被滤空：%v", batches)
	}
	if len(years) < 3 {
		t.Fatalf("应覆盖三年：%v", years)
	}
	// 到区线（考生视角批次）仍按考生区过滤
	for _, row := range rows {
		if row.Batch == "QUOTA_DISTRICT" && row.DistrictID != fengxian.ID {
			t.Fatalf("到区线应按考生区过滤，出现他区行：district=%d", row.DistrictID)
		}
	}
}
