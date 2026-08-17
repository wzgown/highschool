// repository/agent_data_repository.go - AI 顾问 Agent 只读数据访问层
// 覆盖 docs/agent-mode-plan.md §3.2.3 工具全集所需的全部查询。
// 全部只读：不写任何 INSERT/UPDATE。
// 口径提醒：QUOTA_DISTRICT/QUOTA_SCHOOL 为 800 分制，UNIFIED_1_15 为 750 分制。
package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/internal/service/agent"
)

// ErrNotFound 记录未找到（学校/初中/区县/画像）
var ErrNotFound = errors.New("agent data: record not found")

// ---------- 行结构 ----------

// DistrictRef 区县引用
type DistrictRef struct {
	ID   int32
	Name string
}

// SchoolRef 高中引用（名称解析/搜索结果）
type SchoolRef struct {
	ID           int32
	Code         string
	FullName     string
	ShortName    string
	DistrictID   int32
	DistrictName string
}

// MiddleSchoolRef 初中引用
type MiddleSchoolRef struct {
	ID           int32
	Name         string
	ShortName    string
	DistrictID   int32
	DistrictName string
}

// ScoreTrendRow v_school_score_trend 行
type ScoreTrendRow struct {
	Batch                     string
	Year                      int32
	DistrictID                int32
	SchoolID                  *int32
	SchoolName                string
	MiddleSchoolName          *string
	MinScore                  float64
	YoyChange                 *float64
	ChineseMathForeignSum     *float64
	MathScore                 *float64
	ChineseScore              *float64
	IntegratedTestScore       *float64
	ComprehensiveQualityScore *float64
	IsTiePreferred            *bool
}

// SchoolProfileRow v_school_profile 行
type SchoolProfileRow struct {
	SchoolID                 int32
	Code                     string
	FullName                 string
	ShortName                *string
	DistrictName             string
	SchoolTypeID             *string
	SchoolNatureID           *string
	BoardingTypeID           *string
	HasInternationalCourse   *bool
	UnifiedYear              *int32
	UnifiedMinScore          *float64
	QuotaDistrictYear        *int32
	QuotaDistrictMinScore    *float64
	QuotaSchoolYear          *int32
	QuotaSchoolMin           *float64
	QuotaSchoolAvg           *float64
	QuotaDistrictTotalLatest *int32
	QuotaSchoolTotalLatest   *int32
}

// QuotaTrendRow v_quota_trend 行
type QuotaTrendRow struct {
	Batch      string
	Year       int32
	DistrictID int32
	SchoolID   *int32
	SchoolCode string
	QuotaCount int32
	YoyChange  *int32
}

// QuotaDistrictRow 名额到区计划行
type QuotaDistrictRow struct {
	Year         int32
	SchoolID     int32
	SchoolCode   string
	SchoolName   string
	DistrictID   int32
	DistrictName string
	QuotaCount   int32
}

// QuotaSchoolRow 名额到校计划行
type QuotaSchoolRow struct {
	Year             int32
	DistrictID       int32
	DistrictName     string
	HighSchoolID     int32
	HighSchoolCode   string
	HighSchoolName   string
	MiddleSchoolName string
	QuotaCount       int32
}

// ControlScoreRow 控线行
type ControlScoreRow struct {
	Year        int32
	Batch       string
	Category    string
	MinScore    float64
	Description string
}

// MiddleSchoolProfileRow v_middle_school_profile 行
type MiddleSchoolProfileRow struct {
	MiddleSchoolID          int32
	Name                    string
	ShortName               *string
	DistrictName            string
	SchoolNatureID          *string
	IsNonSelective          *bool
	Tier                    *string
	DistrictRank            *int32
	ReputationScore         *float64
	ExactStudentCount       *int32
	EstimatedStudentCount   *int32
	Score700PlusCount       *int32
	Score700PlusReliability *string
	QuotaTotalLatest        *int32
	QuotaHighSchoolCount    *int32
	QuotaSchoolLineCount    *int32
	QuotaSchoolMin          *float64
	QuotaSchoolAvg          *float64
}

// LocatedSchoolRow 分数定位行（min_score <= score，gap 已计算）
type LocatedSchoolRow struct {
	SchoolID   *int32
	SchoolName string
	DistrictID int32
	Year       int32
	MinScore   float64
	Gap        float64
}

// ---------- 接口 ----------

// AgentDataRepository AI 顾问 Agent 只读数据仓库
type AgentDataRepository interface {
	// FindDistrictByName 区名 → 区县（exact → LIKE，如「浦东」→「浦东新区」）
	FindDistrictByName(ctx context.Context, name string) (*DistrictRef, error)
	// TopSchoolNamesByDistrict 区内热门高中展示名（Clarify 追问动态选项；agent.ClarifyOptionsProvider）
	// districtID 优先，为 0 时用 districtName 解析；无分数线数据退回区内学校列表
	TopSchoolNamesByDistrict(ctx context.Context, districtID int32, districtName string, limit int) ([]string, error)
	// FindSchoolByName 高中名 → 学校（full_name exact → short_name exact → LIKE）
	// districtID 传 0 表示不限区；未找到返回 ErrNotFound
	FindSchoolByName(ctx context.Context, name string, districtID int32) (*SchoolRef, error)
	// SearchSchools 高中模糊搜索（full_name/short_name LIKE）
	SearchSchools(ctx context.Context, keyword string, districtID int32, limit int) ([]SchoolRef, error)
	// FindMiddleSchoolByName 初中名 → 学校（name exact → short_name exact → LIKE）
	FindMiddleSchoolByName(ctx context.Context, name string, districtID int32) (*MiddleSchoolRef, error)

	// GetScoreTrend 分数线趋势（v_school_score_trend）
	// batch 传 "" 表示全部批次；districtID 传 0 不限；minYear 传 0 不限年份
	GetScoreTrend(ctx context.Context, schoolID int32, batch string, districtID int32, minYear int) ([]ScoreTrendRow, error)
	// GetQuotaSchoolScoresByMiddle 某初中的历年到校录取线（v_school_score_trend, QUOTA_SCHOOL）
	// highSchoolID 传 0 表示全部高中
	GetQuotaSchoolScoresByMiddle(ctx context.Context, middleSchoolName string, districtID int32, highSchoolID int32, minYear int) ([]ScoreTrendRow, error)
	// GetSchoolProfile 高中画像（v_school_profile）
	GetSchoolProfile(ctx context.Context, schoolID int32) (*SchoolProfileRow, error)
	// GetMiddleSchoolProfile 初中画像（v_middle_school_profile）
	GetMiddleSchoolProfile(ctx context.Context, middleSchoolID int32) (*MiddleSchoolProfileRow, error)

	// GetQuotaTrend 名额同比（v_quota_trend）；batch 传 "" 全部
	GetQuotaTrend(ctx context.Context, schoolID int32, batch string, districtID int32, minYear int) ([]QuotaTrendRow, error)
	// GetDistrictQuotaPlan 名额到区计划；schoolID/districtID 传 0 不限；year 传 0 取最新年
	GetDistrictQuotaPlan(ctx context.Context, schoolID int32, districtID int32, year int) ([]QuotaDistrictRow, error)
	// GetSchoolQuotaPlan 名额到校计划；highSchoolID/districtID 传 0 不限；middleSchoolName 传 "" 不限；year 传 0 取最新年
	GetSchoolQuotaPlan(ctx context.Context, highSchoolID int32, districtID int32, middleSchoolName string, year int) ([]QuotaSchoolRow, error)

	// GetControlScores 控线；year 传 0 取最新年
	GetControlScores(ctx context.Context, year int) ([]ControlScoreRow, error)
	// LocateByScore 分数定位：该区该批次最新年 min_score <= score 的学校，按 min_score 降序
	// batch 必填：UNIFIED_1_15 用 750 制表，QUOTA_DISTRICT/QUOTA_SCHOOL 用各自 800 制表（不混用）
	LocateByScore(ctx context.Context, districtID int32, batch string, score float64) ([]LocatedSchoolRow, error)
}

// agentDataRepo pgx 实现
type agentDataRepo struct {
	db *pgxpool.Pool
}

// NewAgentDataRepository 创建 Agent 数据仓库
func NewAgentDataRepository() AgentDataRepository {
	return &agentDataRepo{
		db: database.GetDB(),
	}
}

// ---------- 名称解析 ----------

func (r *agentDataRepo) FindDistrictByName(ctx context.Context, name string) (*DistrictRef, error) {
	row := r.db.QueryRow(ctx, `
		SELECT id, name
		FROM ref_district
		WHERE name = $1 OR name LIKE '%' || $1 || '%'
		ORDER BY (name = $1) DESC, id
		LIMIT 1
	`, name)

	var d DistrictRef
	if err := row.Scan(&d.ID, &d.Name); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("district %q: %w", name, ErrNotFound)
		}
		return nil, fmt.Errorf("find district failed: %w", err)
	}
	return &d, nil
}

var _ agent.ClarifyOptionsProvider = (*agentDataRepo)(nil)

// TopSchoolNamesByDistrict 区内热门高中展示名（agent.ClarifyOptionsProvider 实现）。
// 「热门」以最新年份平行志愿录取线降序为准；该区无分数线数据时退回区内学校列表。
// 展示名优先简称（可被 FindSchoolByName short_name 精确命中）。
func (r *agentDataRepo) TopSchoolNamesByDistrict(ctx context.Context, districtID int32, districtName string, limit int) ([]string, error) {
	if districtID == 0 && districtName != "" {
		d, err := r.FindDistrictByName(ctx, districtName)
		if err != nil {
			return nil, err
		}
		districtID = d.ID
	}
	if districtID == 0 {
		return nil, fmt.Errorf("top schools: no district")
	}
	if limit <= 0 {
		limit = 7
	}

	// 主路径：区内最新年份平行志愿线降序（即该区考生实际可填、最热的头部校）
	rows, err := r.db.Query(ctx, `
		SELECT COALESCE(NULLIF(s.short_name, ''), s.full_name)
		FROM (
			SELECT DISTINCT ON (school_id) school_id, min_score
			FROM ref_admission_score_unified
			WHERE district_id = $1 AND school_id IS NOT NULL
			ORDER BY school_id, year DESC
		) t
		JOIN ref_school s ON s.id = t.school_id
		WHERE s.is_active
		ORDER BY t.min_score DESC, t.school_id
		LIMIT $2`, districtID, limit)
	if err != nil {
		return nil, fmt.Errorf("top schools by score: %w", err)
	}
	defer rows.Close()
	names, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (string, error) {
		var n string
		return n, row.Scan(&n)
	})
	if err != nil {
		return nil, fmt.Errorf("top schools scan: %w", err)
	}
	if len(names) > 0 {
		return names, nil
	}

	// 兜底：区内无分数线（数据缺口），退回区内全部在招高中
	fallback, err := r.db.Query(ctx, `
		SELECT COALESCE(NULLIF(s.short_name, ''), s.full_name)
		FROM ref_school s
		WHERE s.district_id = $1 AND s.is_active
		ORDER BY s.full_name
		LIMIT $2`, districtID, limit)
	if err != nil {
		return nil, fmt.Errorf("top schools fallback: %w", err)
	}
	defer fallback.Close()
	return pgx.CollectRows(fallback, func(row pgx.CollectableRow) (string, error) {
		var n string
		return n, row.Scan(&n)
	})
}

func (r *agentDataRepo) FindSchoolByName(ctx context.Context, name string, districtID int32) (*SchoolRef, error) {
	row := r.db.QueryRow(ctx, `
		SELECT s.id, s.code, s.full_name, COALESCE(s.short_name, ''), s.district_id, d.name
		FROM ref_school s
		JOIN ref_district d ON d.id = s.district_id
		WHERE s.is_active
		  AND ($2 = 0 OR s.district_id = $2)
		  AND (s.full_name = $1 OR s.short_name = $1 OR s.full_name LIKE '%' || $1 || '%' OR s.short_name LIKE '%' || $1 || '%')
		ORDER BY (s.full_name = $1) DESC, (s.short_name = $1) DESC, s.id
		LIMIT 1
	`, name, districtID)

	s, err := scanSchoolRef(row)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("school %q: %w", name, ErrNotFound)
		}
		return nil, fmt.Errorf("find school failed: %w", err)
	}
	return s, nil
}

func (r *agentDataRepo) SearchSchools(ctx context.Context, keyword string, districtID int32, limit int) ([]SchoolRef, error) {
	if limit <= 0 {
		limit = 10
	}
	rows, err := r.db.Query(ctx, `
		SELECT s.id, s.code, s.full_name, COALESCE(s.short_name, ''), s.district_id, d.name
		FROM ref_school s
		JOIN ref_district d ON d.id = s.district_id
		WHERE s.is_active
		  AND ($2 = 0 OR s.district_id = $2)
		  AND (s.full_name LIKE '%' || $1 || '%' OR s.short_name LIKE '%' || $1 || '%')
		ORDER BY (s.full_name = $1) DESC, (s.short_name = $1) DESC, s.id
		LIMIT $3
	`, keyword, districtID, limit)
	if err != nil {
		return nil, fmt.Errorf("search schools failed: %w", err)
	}
	defer rows.Close()

	var out []SchoolRef
	for rows.Next() {
		s, err := scanSchoolRef(rows)
		if err != nil {
			return nil, fmt.Errorf("scan school failed: %w", err)
		}
		out = append(out, *s)
	}
	return out, rows.Err()
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanSchoolRef(row rowScanner) (*SchoolRef, error) {
	var s SchoolRef
	if err := row.Scan(&s.ID, &s.Code, &s.FullName, &s.ShortName, &s.DistrictID, &s.DistrictName); err != nil {
		return nil, err
	}
	return &s, nil
}

func (r *agentDataRepo) FindMiddleSchoolByName(ctx context.Context, name string, districtID int32) (*MiddleSchoolRef, error) {
	row := r.db.QueryRow(ctx, `
		SELECT m.id, m.name, COALESCE(m.short_name, ''), m.district_id, d.name
		FROM ref_middle_school m
		JOIN ref_district d ON d.id = m.district_id
		WHERE m.is_active
		  AND ($2 = 0 OR m.district_id = $2)
		  AND (m.name = $1 OR m.short_name = $1 OR m.name LIKE '%' || $1 || '%' OR m.short_name LIKE '%' || $1 || '%')
		ORDER BY (m.name = $1) DESC, (m.short_name = $1) DESC, m.id
		LIMIT 1
	`, name, districtID)

	var m MiddleSchoolRef
	if err := row.Scan(&m.ID, &m.Name, &m.ShortName, &m.DistrictID, &m.DistrictName); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("middle school %q: %w", name, ErrNotFound)
		}
		return nil, fmt.Errorf("find middle school failed: %w", err)
	}
	return &m, nil
}

// ---------- 分数线 ----------

func (r *agentDataRepo) GetScoreTrend(ctx context.Context, schoolID int32, batch string, districtID int32, minYear int) ([]ScoreTrendRow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT batch, year, district_id, school_id, school_name, middle_school_name,
		       min_score, yoy_change, chinese_math_foreign_sum, math_score, chinese_score,
		       integrated_test_score, comprehensive_quality_score, is_tie_preferred
		FROM v_school_score_trend
		WHERE school_id = $1
		  AND ($2 = '' OR batch = $2)
		  AND ($3 = 0 OR district_id = $3)
		  AND ($4 = 0 OR year >= $4)
		ORDER BY batch, year
	`, schoolID, batch, districtID, minYear)
	if err != nil {
		return nil, fmt.Errorf("get score trend failed: %w", err)
	}
	defer rows.Close()
	return scanScoreTrendRows(rows)
}

func (r *agentDataRepo) GetQuotaSchoolScoresByMiddle(ctx context.Context, middleSchoolName string, districtID int32, highSchoolID int32, minYear int) ([]ScoreTrendRow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT batch, year, district_id, school_id, school_name, middle_school_name,
		       min_score, yoy_change, chinese_math_foreign_sum, math_score, chinese_score,
		       integrated_test_score, comprehensive_quality_score, is_tie_preferred
		FROM v_school_score_trend
		WHERE batch = 'QUOTA_SCHOOL'
		  AND middle_school_name = $1
		  AND district_id = $2
		  AND ($3 = 0 OR school_id = $3)
		  AND ($4 = 0 OR year >= $4)
		ORDER BY school_name, year
	`, middleSchoolName, districtID, highSchoolID, minYear)
	if err != nil {
		return nil, fmt.Errorf("get quota school scores by middle failed: %w", err)
	}
	defer rows.Close()
	return scanScoreTrendRows(rows)
}

func scanScoreTrendRows(rows pgx.Rows) ([]ScoreTrendRow, error) {
	var out []ScoreTrendRow
	for rows.Next() {
		var t ScoreTrendRow
		if err := rows.Scan(
			&t.Batch, &t.Year, &t.DistrictID, &t.SchoolID, &t.SchoolName, &t.MiddleSchoolName,
			&t.MinScore, &t.YoyChange, &t.ChineseMathForeignSum, &t.MathScore, &t.ChineseScore,
			&t.IntegratedTestScore, &t.ComprehensiveQualityScore, &t.IsTiePreferred,
		); err != nil {
			return nil, fmt.Errorf("scan score trend failed: %w", err)
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

// ---------- 画像 ----------

func (r *agentDataRepo) GetSchoolProfile(ctx context.Context, schoolID int32) (*SchoolProfileRow, error) {
	row := r.db.QueryRow(ctx, `
		SELECT school_id, code, full_name, short_name, district_name,
		       school_type_id, school_nature_id, boarding_type_id, has_international_course,
		       unified_year, unified_min_score,
		       quota_district_year, quota_district_min_score,
		       quota_school_year, quota_school_min, quota_school_avg,
		       quota_district_total_latest, quota_school_total_latest
		FROM v_school_profile
		WHERE school_id = $1
	`, schoolID)

	var p SchoolProfileRow
	if err := row.Scan(
		&p.SchoolID, &p.Code, &p.FullName, &p.ShortName, &p.DistrictName,
		&p.SchoolTypeID, &p.SchoolNatureID, &p.BoardingTypeID, &p.HasInternationalCourse,
		&p.UnifiedYear, &p.UnifiedMinScore,
		&p.QuotaDistrictYear, &p.QuotaDistrictMinScore,
		&p.QuotaSchoolYear, &p.QuotaSchoolMin, &p.QuotaSchoolAvg,
		&p.QuotaDistrictTotalLatest, &p.QuotaSchoolTotalLatest,
	); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("school profile id=%d: %w", schoolID, ErrNotFound)
		}
		return nil, fmt.Errorf("get school profile failed: %w", err)
	}
	return &p, nil
}

func (r *agentDataRepo) GetMiddleSchoolProfile(ctx context.Context, middleSchoolID int32) (*MiddleSchoolProfileRow, error) {
	row := r.db.QueryRow(ctx, `
		SELECT middle_school_id, name, short_name, district_name, school_nature_id,
		       is_non_selective, tier, district_rank, reputation_score,
		       exact_student_count, estimated_student_count,
		       score_700plus_count, score_700plus_reliability,
		       quota_total_latest, quota_high_school_count,
		       quota_school_line_count, quota_school_min, quota_school_avg
		FROM v_middle_school_profile
		WHERE middle_school_id = $1
	`, middleSchoolID)

	var p MiddleSchoolProfileRow
	if err := row.Scan(
		&p.MiddleSchoolID, &p.Name, &p.ShortName, &p.DistrictName, &p.SchoolNatureID,
		&p.IsNonSelective, &p.Tier, &p.DistrictRank, &p.ReputationScore,
		&p.ExactStudentCount, &p.EstimatedStudentCount,
		&p.Score700PlusCount, &p.Score700PlusReliability,
		&p.QuotaTotalLatest, &p.QuotaHighSchoolCount,
		&p.QuotaSchoolLineCount, &p.QuotaSchoolMin, &p.QuotaSchoolAvg,
	); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, fmt.Errorf("middle school profile id=%d: %w", middleSchoolID, ErrNotFound)
		}
		return nil, fmt.Errorf("get middle school profile failed: %w", err)
	}
	return &p, nil
}

// ---------- 名额计划 ----------

func (r *agentDataRepo) GetQuotaTrend(ctx context.Context, schoolID int32, batch string, districtID int32, minYear int) ([]QuotaTrendRow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT batch, year, district_id, school_id, school_code, quota_count, yoy_change
		FROM v_quota_trend
		WHERE school_id = $1
		  AND ($2 = '' OR batch = $2)
		  AND ($3 = 0 OR district_id = $3)
		  AND ($4 = 0 OR year >= $4)
		ORDER BY batch, district_id, year
	`, schoolID, batch, districtID, minYear)
	if err != nil {
		return nil, fmt.Errorf("get quota trend failed: %w", err)
	}
	defer rows.Close()

	var out []QuotaTrendRow
	for rows.Next() {
		var q QuotaTrendRow
		if err := rows.Scan(&q.Batch, &q.Year, &q.DistrictID, &q.SchoolID, &q.SchoolCode, &q.QuotaCount, &q.YoyChange); err != nil {
			return nil, fmt.Errorf("scan quota trend failed: %w", err)
		}
		out = append(out, q)
	}
	return out, rows.Err()
}

func (r *agentDataRepo) GetDistrictQuotaPlan(ctx context.Context, schoolID int32, districtID int32, year int) ([]QuotaDistrictRow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT q.year, q.school_id, q.school_code, s.full_name, q.district_id, d.name, q.quota_count
		FROM ref_quota_allocation_district q
		JOIN ref_school s ON s.id = q.school_id
		JOIN ref_district d ON d.id = q.district_id
		WHERE ($1 = 0 OR q.school_id = $1)
		  AND ($2 = 0 OR q.district_id = $2)
		  AND ($3 = 0 OR q.year = $3)
		  AND ($3 <> 0 OR q.year = (SELECT MAX(year) FROM ref_quota_allocation_district))
		ORDER BY q.year, d.display_order, q.quota_count DESC
	`, schoolID, districtID, year)
	if err != nil {
		return nil, fmt.Errorf("get district quota plan failed: %w", err)
	}
	defer rows.Close()

	var out []QuotaDistrictRow
	for rows.Next() {
		var q QuotaDistrictRow
		if err := rows.Scan(&q.Year, &q.SchoolID, &q.SchoolCode, &q.SchoolName, &q.DistrictID, &q.DistrictName, &q.QuotaCount); err != nil {
			return nil, fmt.Errorf("scan district quota plan failed: %w", err)
		}
		out = append(out, q)
	}
	return out, rows.Err()
}

func (r *agentDataRepo) GetSchoolQuotaPlan(ctx context.Context, highSchoolID int32, districtID int32, middleSchoolName string, year int) ([]QuotaSchoolRow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT q.year, q.district_id, d.name, q.high_school_id, q.high_school_code,
		       s.full_name, q.middle_school_name, q.quota_count
		FROM ref_quota_allocation_school q
		JOIN ref_school s ON s.id = q.high_school_id
		JOIN ref_district d ON d.id = q.district_id
		WHERE ($1 = 0 OR q.high_school_id = $1)
		  AND ($2 = 0 OR q.district_id = $2)
		  AND ($3 = '' OR q.middle_school_name = $3)
		  AND ($4 = 0 OR q.year = $4)
		  AND ($4 <> 0 OR q.year = (SELECT MAX(year) FROM ref_quota_allocation_school))
		ORDER BY q.year, s.full_name, q.middle_school_name
	`, highSchoolID, districtID, middleSchoolName, year)
	if err != nil {
		return nil, fmt.Errorf("get school quota plan failed: %w", err)
	}
	defer rows.Close()

	var out []QuotaSchoolRow
	for rows.Next() {
		var q QuotaSchoolRow
		if err := rows.Scan(&q.Year, &q.DistrictID, &q.DistrictName, &q.HighSchoolID, &q.HighSchoolCode,
			&q.HighSchoolName, &q.MiddleSchoolName, &q.QuotaCount); err != nil {
			return nil, fmt.Errorf("scan school quota plan failed: %w", err)
		}
		out = append(out, q)
	}
	return out, rows.Err()
}

// ---------- 控线 ----------

func (r *agentDataRepo) GetControlScores(ctx context.Context, year int) ([]ControlScoreRow, error) {
	rows, err := r.db.Query(ctx, `
		SELECT year, admission_batch_id, category, min_score, COALESCE(description, '')
		FROM ref_control_score
		WHERE ($1 = 0 OR year = $1)
		  AND ($1 <> 0 OR year = (SELECT MAX(year) FROM ref_control_score))
		ORDER BY year, admission_batch_id, min_score DESC
	`, year)
	if err != nil {
		return nil, fmt.Errorf("get control scores failed: %w", err)
	}
	defer rows.Close()

	var out []ControlScoreRow
	for rows.Next() {
		var c ControlScoreRow
		if err := rows.Scan(&c.Year, &c.Batch, &c.Category, &c.MinScore, &c.Description); err != nil {
			return nil, fmt.Errorf("scan control score failed: %w", err)
		}
		out = append(out, c)
	}
	return out, rows.Err()
}

// ---------- 分数定位 ----------

func (r *agentDataRepo) LocateByScore(ctx context.Context, districtID int32, batch string, score float64) ([]LocatedSchoolRow, error) {
	var query string
	switch batch {
	case "UNIFIED_1_15":
		query = `
			SELECT school_id, school_name, district_id, year, min_score
			FROM ref_admission_score_unified
			WHERE district_id = $1 AND min_score <= $2
			  AND year = (SELECT MAX(year) FROM ref_admission_score_unified WHERE district_id = $1)
			ORDER BY min_score DESC
			LIMIT 50
		`
	case "QUOTA_DISTRICT":
		query = `
			SELECT school_id, school_name, district_id, year, min_score
			FROM ref_admission_score_quota_district
			WHERE district_id = $1 AND min_score <= $2
			  AND year = (SELECT MAX(year) FROM ref_admission_score_quota_district WHERE district_id = $1)
			ORDER BY min_score DESC
			LIMIT 50
		`
	case "QUOTA_SCHOOL":
		// 到校线按初中一行，取该高中在该区全部初中的最低到校线
		query = `
			SELECT MAX(school_id), school_name, district_id, MAX(year), MIN(min_score)
			FROM ref_admission_score_quota_school
			WHERE district_id = $1
			  AND year = (SELECT MAX(year) FROM ref_admission_score_quota_school WHERE district_id = $1)
			GROUP BY school_name, district_id
			HAVING MIN(min_score) <= $2
			ORDER BY MIN(min_score) DESC
			LIMIT 50
		`
	default:
		return nil, fmt.Errorf("unsupported batch %q (want UNIFIED_1_15 / QUOTA_DISTRICT / QUOTA_SCHOOL)", batch)
	}

	rows, err := r.db.Query(ctx, query, districtID, score)
	if err != nil {
		return nil, fmt.Errorf("locate by score failed: %w", err)
	}
	defer rows.Close()

	var out []LocatedSchoolRow
	for rows.Next() {
		var l LocatedSchoolRow
		if err := rows.Scan(&l.SchoolID, &l.SchoolName, &l.DistrictID, &l.Year, &l.MinScore); err != nil {
			return nil, fmt.Errorf("scan located school failed: %w", err)
		}
		l.Gap = score - l.MinScore
		out = append(out, l)
	}
	return out, rows.Err()
}
