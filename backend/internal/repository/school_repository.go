// repository/school_repository.go - 学校数据访问层
package repository

import (
	"context"
	"fmt"
	"sync"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/pkg/logger"
)

// SchoolRankingInfo 学校排名信息（用于竞争对手志愿生成）
type SchoolRankingInfo struct {
	ID           int32   // 学校ID
	FullName     string  // 学校全称
	DistrictID   int32   // 所属区ID
	CutoffScore  float64 // 历史分数线（统一招生）
	RankingOrder int     // 排名序号（从1开始）
}

// SchoolRepository 学校仓库接口
type SchoolRepository interface {
	// GetByID 根据ID获取学校
	GetByID(ctx context.Context, id int32) (*highschoolv1.School, error)

	// List 获取学校列表
	List(ctx context.Context, districtID *int32, schoolTypeID, schoolNatureID *string,
		hasInternationalCourse *bool, keyword *string, page, pageSize int32) ([]*highschoolv1.School, int32, error)

	// GetDetail 获取学校详情
	GetDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error)

	// GetHistoryScores 获取学校历年分数线
	GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error)

	// GetSchoolsWithQuotaDistrict 获取有名额分配到区的高中列表（自动使用最新数据）
	GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表（自动使用最新数据）
	GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsForUnified 获取统一招生（1-15志愿）可选学校列表（自动使用最新数据）
	GetSchoolsForUnified(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolForUnified, error)

	// GetSchoolsByCutoffScoreRanking 获取按分数线排名的学校列表（自动使用最新数据）
	// 返回指定区可填报的学校，按分数线从高到低排序
	GetSchoolsByCutoffScoreRanking(ctx context.Context, districtID int32) ([]*SchoolRankingInfo, error)

	// PreloadCache 预加载缓存（在生成大量竞争对手前调用）
	PreloadCache(ctx context.Context, districtID int32, middleSchoolID int32)

	// GetLatestScoreYear 获取数据库中最新的分数线数据年份
	GetLatestScoreYear(ctx context.Context) (int, error)
}

// schoolCache 学校数据缓存
type schoolCache struct {
	mu                   sync.RWMutex
	quotaDistrictSchools map[int32][]*highschoolv1.SchoolWithQuota  // districtID -> schools
	quotaSchoolSchools   map[int32][]*highschoolv1.SchoolWithQuota  // middleSchoolID -> schools
	unifiedSchools       map[int32][]*highschoolv1.SchoolForUnified // districtID -> schools
	cutoffScoreRankings  map[int32][]*SchoolRankingInfo             // districtID -> rankings
	cachedYear           int                                       // 缓存使用的年份
}

// schoolRepo 实现
type schoolRepo struct {
	db    *pgxpool.Pool
	cache *schoolCache
}

// NewSchoolRepository 创建学校仓库
func NewSchoolRepository() SchoolRepository {
	return &schoolRepo{
		db: database.GetDB(),
		cache: &schoolCache{
			quotaDistrictSchools: make(map[int32][]*highschoolv1.SchoolWithQuota),
			quotaSchoolSchools:   make(map[int32][]*highschoolv1.SchoolWithQuota),
			unifiedSchools:       make(map[int32][]*highschoolv1.SchoolForUnified),
			cutoffScoreRankings:  make(map[int32][]*SchoolRankingInfo),
			cachedYear:           0,
		},
	}
}

// getLatestYear 获取最新年份（内部方法）
func (r *schoolRepo) getLatestYear(ctx context.Context) int {
	year, err := r.GetLatestScoreYear(ctx)
	if err != nil {
		logger.Warn(ctx, "failed to get latest score year from database, using fallback value",
			logger.Int("fallback_year", 2024),
			logger.ErrorField(err),
		)
		return 2024 // fallback
	}
	return year
}

// PreloadCache 预加载缓存
func (r *schoolRepo) PreloadCache(ctx context.Context, districtID int32, middleSchoolID int32) {
	// 获取不同数据源的年份
	quotaYear := r.getLatestQuotaYear(ctx)  // 名额分配数据年份
	scoreYear := r.getLatestYear(ctx)       // 分数线数据年份

	logger.Debug(ctx, "PreloadCache: starting preload",
		logger.Int("district_id", int(districtID)),
		logger.Int("middle_school_id", int(middleSchoolID)),
		logger.Int("quota_year", quotaYear),
		logger.Int("score_year", scoreYear),
	)

	// 并发预加载
	var wg sync.WaitGroup
	wg.Add(4)

	go func() {
		defer wg.Done()
		r.getSchoolsWithQuotaDistrictWithCache(ctx, districtID, quotaYear)
	}()

	go func() {
		defer wg.Done()
		r.getSchoolsWithQuotaSchoolWithCache(ctx, middleSchoolID, quotaYear)
	}()

	go func() {
		defer wg.Done()
		r.getSchoolsForUnifiedWithCache(ctx, districtID, scoreYear)
	}()

	go func() {
		defer wg.Done()
		r.getSchoolsByCutoffScoreRankingWithCache(ctx, districtID, scoreYear)
	}()

	wg.Wait()

	// 记录缓存年份
	r.cache.mu.Lock()
	r.cache.cachedYear = quotaYear
	r.cache.mu.Unlock()
}

// GetByID 根据ID获取学校
func (r *schoolRepo) GetByID(ctx context.Context, id int32) (*highschoolv1.School, error) {
	row := r.db.QueryRow(ctx, `
		SELECT s.id, s.full_name, s.code, d.id, d.name, s.school_type_id, s.school_nature_id,
		       s.has_international_course
		FROM ref_school s
		JOIN ref_district d ON s.district_id = d.id
		WHERE s.id = $1
	`, id)

	var school highschoolv1.School
	var districtID int32
	var districtName string

	err := row.Scan(
		&school.Id, &school.FullName, &school.Code,
		&districtID, &districtName,
		&school.SchoolTypeId, &school.SchoolNatureId,
		&school.HasInternationalCourse,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("school not found")
		}
		return nil, fmt.Errorf("get school failed: %w", err)
	}

	school.DistrictId = districtID
	school.DistrictName = &districtName

	return &school, nil
}

// List 获取学校列表
func (r *schoolRepo) List(ctx context.Context, districtID *int32, schoolTypeID, schoolNatureID *string,
	hasInternationalCourse *bool, keyword *string, page, pageSize int32) ([]*highschoolv1.School, int32, error) {

	// 构建查询条件
	whereClause := "WHERE 1=1"
	args := []interface{}{}
	argIdx := 1

	if districtID != nil {
		whereClause += fmt.Sprintf(" AND s.district_id = $%d", argIdx)
		args = append(args, *districtID)
		argIdx++
	}
	if schoolTypeID != nil {
		whereClause += fmt.Sprintf(" AND s.school_type_id = $%d", argIdx)
		args = append(args, *schoolTypeID)
		argIdx++
	}
	if schoolNatureID != nil {
		whereClause += fmt.Sprintf(" AND s.school_nature_id = $%d", argIdx)
		args = append(args, *schoolNatureID)
		argIdx++
	}
	if hasInternationalCourse != nil {
		whereClause += fmt.Sprintf(" AND s.has_international_course = $%d", argIdx)
		args = append(args, *hasInternationalCourse)
		argIdx++
	}
	if keyword != nil && *keyword != "" {
		whereClause += fmt.Sprintf(" AND (s.name ILIKE $%d OR s.code ILIKE $%d)", argIdx, argIdx)
		args = append(args, "%"+*keyword+"%")
		argIdx++
	}

	// 获取总数
	var total int32
	countQuery := "SELECT COUNT(*) FROM ref_school s " + whereClause
	err := r.db.QueryRow(ctx, countQuery, args...).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("count schools failed: %w", err)
	}

	// 获取分页数据
	query := fmt.Sprintf(`
		SELECT s.id, s.full_name, s.code, d.id, d.name, s.school_type_id, s.school_nature_id,
		       s.has_international_course
		FROM ref_school s
		JOIN ref_district d ON s.district_id = d.id
		%s
		ORDER BY s.id
		LIMIT $%d OFFSET $%d
	`, whereClause, argIdx, argIdx+1)

	offset := (page - 1) * pageSize
	args = append(args, pageSize, offset)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, 0, fmt.Errorf("list schools failed: %w", err)
	}
	defer rows.Close()

	var schools []*highschoolv1.School
	for rows.Next() {
		var school highschoolv1.School
		var districtID int32
		var districtName string

		err := rows.Scan(
			&school.Id, &school.FullName, &school.Code,
			&districtID, &districtName,
			&school.SchoolTypeId, &school.SchoolNatureId,
			&school.HasInternationalCourse,
		)
		if err != nil {
			continue
		}

		school.DistrictId = districtID
		school.DistrictName = &districtName
		schools = append(schools, &school)
	}

	return schools, total, nil
}

// GetDetail 获取学校详情
func (r *schoolRepo) GetDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error) {
	// 获取基本信息
	school, err := r.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	// 获取寄宿类型
	row := r.db.QueryRow(ctx, `
		SELECT boarding_type_id
		FROM ref_school
		WHERE id = $1
	`, id)

	var boardingTypeID *string
	row.Scan(&boardingTypeID)

	// 构建 SchoolDetail
	detail := &highschoolv1.SchoolDetail{
		School:       school,
		BoardingTypeId: boardingTypeID,
	}

	return detail, nil
}

// GetHistoryScores 获取学校历年分数线
func (r *schoolRepo) GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error) {
	rows, err := r.db.Query(ctx, `
		SELECT year, batch, batch_name, min_score, is_tie_preferred
		FROM ref_school_score_history
		WHERE school_id = $1
		ORDER BY year DESC, batch
	`, schoolID)
	if err != nil {
		return nil, fmt.Errorf("get history scores failed: %w", err)
	}
	defer rows.Close()

	var scores []*highschoolv1.HistoryScore
	for rows.Next() {
		var score highschoolv1.HistoryScore
		schoolIDPtr := schoolID // 创建指针
		score.SchoolId = &schoolIDPtr
		score.SchoolName = "" // 查询时填充

		err := rows.Scan(
			&score.Year, &score.Batch, &score.BatchName,
			&score.MinScore, &score.IsTiePreferred,
		)
		if err != nil {
			continue
		}
		scores = append(scores, &score)
	}

	return scores, nil
}

// GetSchoolsWithQuotaDistrict 获取有名额分配到区的高中列表
func (r *schoolRepo) GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolWithQuota, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if schools, ok := r.cache.quotaDistrictSchools[districtID]; ok && r.cache.cachedYear > 0 {
		r.cache.mu.RUnlock()
		return schools, nil
	}
	r.cache.mu.RUnlock()

	// 缓存未命中，查询数据库（使用名额分配数据的年份，而非分数线年份）
	year := r.getLatestQuotaYear(ctx)
	return r.getSchoolsWithQuotaDistrictWithCache(ctx, districtID, year)
}

func (r *schoolRepo) getSchoolsWithQuotaDistrictWithCache(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolWithQuota, error) {
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.code, q.quota_count
		FROM ref_school s
		INNER JOIN ref_quota_allocation_district q ON q.school_id = s.id
		WHERE q.district_id = $1 AND q.year = $2 AND q.quota_count > 0 AND s.is_active = true
		ORDER BY s.full_name
	`, districtID, year)
	if err != nil {
		logger.Warn(ctx, "getSchoolsWithQuotaDistrictWithCache: query failed",
			logger.Int("district_id", int(districtID)),
			logger.Int("year", year),
			logger.ErrorField(err),
		)
		return nil, fmt.Errorf("get schools with quota district failed: %w", err)
	}
	defer rows.Close()

	var schools []*highschoolv1.SchoolWithQuota
	for rows.Next() {
		var school highschoolv1.SchoolWithQuota
		err := rows.Scan(&school.Id, &school.FullName, &school.Code, &school.QuotaCount)
		if err != nil {
			continue
		}
		schools = append(schools, &school)
	}

	logger.Debug(ctx, "getSchoolsWithQuotaDistrictWithCache: query result",
		logger.Int("district_id", int(districtID)),
		logger.Int("year", year),
		logger.Int("schools_count", len(schools)),
	)

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.quotaDistrictSchools[districtID] = schools
	r.cache.mu.Unlock()

	return schools, nil
}

// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表
func (r *schoolRepo) GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32) ([]*highschoolv1.SchoolWithQuota, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if schools, ok := r.cache.quotaSchoolSchools[middleSchoolID]; ok && r.cache.cachedYear > 0 {
		r.cache.mu.RUnlock()
		return schools, nil
	}
	r.cache.mu.RUnlock()

	// 缓存未命中，查询数据库（使用名额分配数据的年份，而非分数线年份）
	year := r.getLatestQuotaYear(ctx)
	return r.getSchoolsWithQuotaSchoolWithCache(ctx, middleSchoolID, year)
}

func (r *schoolRepo) getSchoolsWithQuotaSchoolWithCache(ctx context.Context, middleSchoolID int32, year int) ([]*highschoolv1.SchoolWithQuota, error) {
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.code, q.quota_count
		FROM ref_school s
		INNER JOIN ref_quota_allocation_school q ON q.high_school_id = s.id
		WHERE q.middle_school_id = $1 AND q.year = $2 AND q.quota_count > 0 AND s.is_active = true
		ORDER BY s.full_name
	`, middleSchoolID, year)
	if err != nil {
		return nil, fmt.Errorf("get schools with quota school failed: %w", err)
	}
	defer rows.Close()

	var schools []*highschoolv1.SchoolWithQuota
	for rows.Next() {
		var school highschoolv1.SchoolWithQuota
		err := rows.Scan(&school.Id, &school.FullName, &school.Code, &school.QuotaCount)
		if err != nil {
			continue
		}
		schools = append(schools, &school)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.quotaSchoolSchools[middleSchoolID] = schools
	r.cache.mu.Unlock()

	return schools, nil
}

// GetSchoolsForUnified 获取统一招生（1-15志愿）可选学校列表
// 包括：1. 本区所有高中 2. 面向全市招生的高中（根据历史分数线数据判断）
func (r *schoolRepo) GetSchoolsForUnified(ctx context.Context, districtID int32) ([]*highschoolv1.SchoolForUnified, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if schools, ok := r.cache.unifiedSchools[districtID]; ok && r.cache.cachedYear > 0 {
		r.cache.mu.RUnlock()
		return schools, nil
	}
	r.cache.mu.RUnlock()

	// 缓存未命中，查询数据库
	year := r.getLatestYear(ctx)
	return r.getSchoolsForUnifiedWithCache(ctx, districtID, year)
}

func (r *schoolRepo) getSchoolsForUnifiedWithCache(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolForUnified, error) {
	// 查询该区在统一招生批次可填报的学校
	// 基于 ref_admission_score_unified 表，该表记录了各区统一招生的学校及其分数线
	// 使用模糊匹配处理学校名称差异（如 "上海中学" vs "上海市上海中学"）
	// 按分数线降序排列（好学校在前）
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.code,
		       CASE WHEN s.district_id = $1 THEN true ELSE false END as is_district_school,
		       MAX(u.min_score) as cutoff_score
		FROM ref_school s
		INNER JOIN ref_admission_score_unified u
			ON u.school_id = s.id
			OR u.school_name = s.full_name
			OR s.full_name LIKE '%' || u.school_name || '%'
			OR u.school_name LIKE '%' || s.short_name || '%'
		WHERE u.district_id = $1 AND u.year = $2 AND s.is_active = true
		GROUP BY s.id, s.full_name, s.code, s.district_id
		ORDER BY cutoff_score DESC, is_district_school DESC, s.full_name
	`, districtID, year-1) // 使用前一年的分数线数据（当年的分数线在录取后才有）
	if err != nil {
		return nil, fmt.Errorf("get schools for unified failed: %w", err)
	}
	defer rows.Close()

	var schools []*highschoolv1.SchoolForUnified
	for rows.Next() {
		var school highschoolv1.SchoolForUnified
		var cutoffScore *float64 // 用于排序，不需要返回给前端
		err := rows.Scan(&school.Id, &school.FullName, &school.Code, &school.IsDistrictSchool, &cutoffScore)
		if err != nil {
			continue
		}
		schools = append(schools, &school)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.unifiedSchools[districtID] = schools
	r.cache.mu.Unlock()

	return schools, nil
}

// GetSchoolsByCutoffScoreRanking 获取按分数线排名的学校列表（用于竞争对手志愿生成）
// 返回指定区可填报的学校，按分数线从高到低排序
func (r *schoolRepo) GetSchoolsByCutoffScoreRanking(ctx context.Context, districtID int32) ([]*SchoolRankingInfo, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if schools, ok := r.cache.cutoffScoreRankings[districtID]; ok && r.cache.cachedYear > 0 {
		r.cache.mu.RUnlock()
		return schools, nil
	}
	r.cache.mu.RUnlock()

	// 缓存未命中，查询数据库
	year := r.getLatestYear(ctx)
	return r.getSchoolsByCutoffScoreRankingWithCache(ctx, districtID, year)
}

func (r *schoolRepo) getSchoolsByCutoffScoreRankingWithCache(ctx context.Context, districtID int32, year int) ([]*SchoolRankingInfo, error) {
	// 使用前一年的统一招生分数线数据作为排名依据
	// 按分数线从高到低排序，分数线越高说明学校越好
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.district_id, u.min_score
		FROM ref_school s
		INNER JOIN ref_admission_score_unified u ON u.school_id = s.id
		WHERE u.district_id = $1 AND u.year = $2 AND s.is_active = true
		ORDER BY u.min_score DESC
	`, districtID, year-1)
	if err != nil {
		return nil, fmt.Errorf("get schools by cutoff score ranking failed: %w", err)
	}
	defer rows.Close()

	var schools []*SchoolRankingInfo
	rank := 0
	for rows.Next() {
		rank++
		var school SchoolRankingInfo
		var cutoffScore float64
		err := rows.Scan(&school.ID, &school.FullName, &school.DistrictID, &cutoffScore)
		if err != nil {
			continue
		}
		school.CutoffScore = cutoffScore
		school.RankingOrder = rank
		schools = append(schools, &school)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.cutoffScoreRankings[districtID] = schools
	r.cache.mu.Unlock()

	return schools, nil
}

// GetLatestScoreYear 获取数据库中最新的分数线数据年份
func (r *schoolRepo) GetLatestScoreYear(ctx context.Context) (int, error) {
	// 从统一招生分数线表获取最新年份
	var year int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(MAX(year), 2024) FROM ref_admission_score_unified
	`).Scan(&year)
	if err != nil {
		return 2024, fmt.Errorf("get latest score year failed: %w", err)
	}
	return year, nil
}

// getLatestQuotaYear 获取最新的名额分配数据年份
func (r *schoolRepo) getLatestQuotaYear(ctx context.Context) int {
	var year int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(MAX(year), 2025) FROM ref_quota_allocation_district
	`).Scan(&year)
	if err != nil {
		logger.Warn(ctx, "failed to get latest quota year from database, using fallback value",
			logger.Int("fallback_year", 2025),
			logger.ErrorField(err),
		)
		return 2025
	}
	return year
}
