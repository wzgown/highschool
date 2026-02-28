// repository/recommendation_repository.go - 志愿推荐数据访问层
package repository

import (
	"context"
	"sync"

	"github.com/jackc/pgx/v5/pgxpool"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/pkg/logger"
)

// AdmissionScoreQuotaDistrict 名额分配到区分数线
type AdmissionScoreQuotaDistrict struct {
	SchoolID                int32
	SchoolName              string
	DistrictID              int32
	Year                    int32
	MinScore                float64
	IsTiePreferred          bool
	ChineseMathForeignSum   float64
	MathScore               float64
	ChineseScore            float64
	IntegratedTestScore     float64
	ComprehensiveQualityScore float64
}

// AdmissionScoreQuotaSchool 名额分配到校分数线
type AdmissionScoreQuotaSchool struct {
	SchoolID                int32
	SchoolName              string
	MiddleSchoolName        string
	DistrictID              int32
	Year                    int32
	MinScore                float64
	IsTiePreferred          bool
	ChineseMathForeignSum   float64
	MathScore               float64
	ChineseScore            float64
	IntegratedTestScore     float64
	ComprehensiveQualityScore float64
}

// AdmissionScoreUnified 统一招生分数线
type AdmissionScoreUnified struct {
	SchoolID              int32
	SchoolName            string
	DistrictID            int32
	Year                  int32
	MinScore              float64
	ChineseMathForeignSum float64
	MathScore             float64
	ChineseScore          float64
}

// ControlScore 控制分数线
type ControlScore struct {
	Year             int32
	AdmissionBatchID string
	Category         string
	MinScore         float64
	Description      string
}

// DistrictTotalScore 区一模/二模总分映射
type DistrictTotalScore struct {
	DistrictID       int32
	DistrictName     string
	FirstMockTotal   float64 // 一模总分
	SecondMockTotal  float64 // 二模总分
}

// RecommendationRepository 志愿推荐数据仓库接口
type RecommendationRepository interface {
	// GetAdmissionScoresQuotaDistrict 获取名额分配到区历史分数线
	GetAdmissionScoresQuotaDistrict(ctx context.Context, districtID int32, year int32) ([]*AdmissionScoreQuotaDistrict, error)

	// GetAdmissionScoresQuotaSchool 获取名额分配到校历史分数线
	GetAdmissionScoresQuotaSchool(ctx context.Context, districtID int32, middleSchoolName string, year int32) ([]*AdmissionScoreQuotaSchool, error)

	// GetAdmissionScoresUnified 获取统一招生历史分数线
	GetAdmissionScoresUnified(ctx context.Context, districtID int32, year int32) ([]*AdmissionScoreUnified, error)

	// GetControlScores 获取最低投档控制分数线
	GetControlScores(ctx context.Context, year int32) ([]*ControlScore, error)

	// GetDistrictExamCount 获取区中考人数
	GetDistrictExamCount(ctx context.Context, districtID int32, year int32) (int, error)

	// GetDistrictTotalScores 获取区一模/二模总分映射
	GetDistrictTotalScores(ctx context.Context) (map[int32]*DistrictTotalScore, error)

	// GetDistrictByID 获取区信息
	GetDistrictByID(ctx context.Context, districtID int32) (*highschoolv1.District, error)

	// GetSchoolsWithQuotaDistrict 获取有名额分配到区的高中列表
	GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32, year int32) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表
	GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32, year int32) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsForUnified 获取统一招生可选学校列表
	GetSchoolsForUnified(ctx context.Context, districtID int32, year int32) ([]*highschoolv1.SchoolForUnified, error)

	// GetMiddleSchoolByID 获取初中信息
	GetMiddleSchoolByID(ctx context.Context, middleSchoolID int32) (*highschoolv1.MiddleSchool, error)

	// GetLatestScoreYear 获取最新分数线年份
	GetLatestScoreYear(ctx context.Context) (int32, error)
}

// recommendationCache 推荐数据缓存
type recommendationCache struct {
	mu                       sync.RWMutex
	quotaDistrictScores      map[string][]*AdmissionScoreQuotaDistrict  // key: "districtID_year"
	quotaSchoolScores        map[string][]*AdmissionScoreQuotaSchool    // key: "districtID_middleSchoolName_year"
	unifiedScores            map[string][]*AdmissionScoreUnified        // key: "districtID_year"
	controlScores            map[int32][]*ControlScore                  // key: year
	districtTotalScores      map[int32]*DistrictTotalScore              // key: districtID
}

// recommendationRepo 实现
type recommendationRepo struct {
	db    *pgxpool.Pool
	cache *recommendationCache
}

// NewRecommendationRepository 创建志愿推荐仓库
func NewRecommendationRepository() RecommendationRepository {
	return &recommendationRepo{
		db: database.GetDB(),
		cache: &recommendationCache{
			quotaDistrictScores: make(map[string][]*AdmissionScoreQuotaDistrict),
			quotaSchoolScores:   make(map[string][]*AdmissionScoreQuotaSchool),
			unifiedScores:       make(map[string][]*AdmissionScoreUnified),
			controlScores:       make(map[int32][]*ControlScore),
			districtTotalScores: make(map[int32]*DistrictTotalScore),
		},
	}
}

// GetAdmissionScoresQuotaDistrict 获取名额分配到区历史分数线
func (r *recommendationRepo) GetAdmissionScoresQuotaDistrict(ctx context.Context, districtID int32, year int32) ([]*AdmissionScoreQuotaDistrict, error) {
	// 检查缓存
	key := cacheKey(districtID, year)
	r.cache.mu.RLock()
	if scores, ok := r.cache.quotaDistrictScores[key]; ok {
		r.cache.mu.RUnlock()
		return scores, nil
	}
	r.cache.mu.RUnlock()

	// 查询数据库
	rows, err := r.db.Query(ctx, `
		SELECT school_id, school_name, district_id, year, min_score, is_tie_preferred,
		       COALESCE(chinese_math_foreign_sum, 0),
		       COALESCE(math_score, 0),
		       COALESCE(chinese_score, 0),
		       COALESCE(integrated_test_score, 0),
		       COALESCE(comprehensive_quality_score, 50)
		FROM ref_admission_score_quota_district
		WHERE district_id = $1 AND year = $2
		ORDER BY min_score DESC
	`, districtID, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var scores []*AdmissionScoreQuotaDistrict
	for rows.Next() {
		var s AdmissionScoreQuotaDistrict
		err := rows.Scan(
			&s.SchoolID, &s.SchoolName, &s.DistrictID, &s.Year, &s.MinScore, &s.IsTiePreferred,
			&s.ChineseMathForeignSum, &s.MathScore, &s.ChineseScore,
			&s.IntegratedTestScore, &s.ComprehensiveQualityScore,
		)
		if err != nil {
			logger.Warn(ctx, "scan quota district score failed", logger.ErrorField(err))
			continue
		}
		scores = append(scores, &s)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.quotaDistrictScores[key] = scores
	r.cache.mu.Unlock()

	return scores, nil
}

// GetAdmissionScoresQuotaSchool 获取名额分配到校历史分数线
func (r *recommendationRepo) GetAdmissionScoresQuotaSchool(ctx context.Context, districtID int32, middleSchoolName string, year int32) ([]*AdmissionScoreQuotaSchool, error) {
	// 检查缓存
	key := cacheKey3(districtID, middleSchoolName, year)
	r.cache.mu.RLock()
	if scores, ok := r.cache.quotaSchoolScores[key]; ok {
		r.cache.mu.RUnlock()
		return scores, nil
	}
	r.cache.mu.RUnlock()

	// 查询数据库
	rows, err := r.db.Query(ctx, `
		SELECT school_id, school_name, middle_school_name, district_id, year, min_score, is_tie_preferred,
		       COALESCE(chinese_math_foreign_sum, 0),
		       COALESCE(math_score, 0),
		       COALESCE(chinese_score, 0),
		       COALESCE(integrated_test_score, 0),
		       COALESCE(comprehensive_quality_score, 50)
		FROM ref_admission_score_quota_school
		WHERE district_id = $1 AND middle_school_name = $2 AND year = $3
		ORDER BY min_score DESC
	`, districtID, middleSchoolName, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var scores []*AdmissionScoreQuotaSchool
	for rows.Next() {
		var s AdmissionScoreQuotaSchool
		err := rows.Scan(
			&s.SchoolID, &s.SchoolName, &s.MiddleSchoolName, &s.DistrictID, &s.Year, &s.MinScore, &s.IsTiePreferred,
			&s.ChineseMathForeignSum, &s.MathScore, &s.ChineseScore,
			&s.IntegratedTestScore, &s.ComprehensiveQualityScore,
		)
		if err != nil {
			logger.Warn(ctx, "scan quota school score failed", logger.ErrorField(err))
			continue
		}
		scores = append(scores, &s)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.quotaSchoolScores[key] = scores
	r.cache.mu.Unlock()

	return scores, nil
}

// GetAdmissionScoresUnified 获取统一招生历史分数线
func (r *recommendationRepo) GetAdmissionScoresUnified(ctx context.Context, districtID int32, year int32) ([]*AdmissionScoreUnified, error) {
	// 检查缓存
	key := cacheKey(districtID, year)
	r.cache.mu.RLock()
	if scores, ok := r.cache.unifiedScores[key]; ok {
		r.cache.mu.RUnlock()
		return scores, nil
	}
	r.cache.mu.RUnlock()

	// 查询数据库
	rows, err := r.db.Query(ctx, `
		SELECT school_id, school_name, district_id, year, min_score,
		       COALESCE(chinese_math_foreign_sum, 0),
		       COALESCE(math_score, 0),
		       COALESCE(chinese_score, 0)
		FROM ref_admission_score_unified
		WHERE district_id = $1 AND year = $2
		ORDER BY min_score DESC
	`, districtID, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var scores []*AdmissionScoreUnified
	for rows.Next() {
		var s AdmissionScoreUnified
		err := rows.Scan(
			&s.SchoolID, &s.SchoolName, &s.DistrictID, &s.Year, &s.MinScore,
			&s.ChineseMathForeignSum, &s.MathScore, &s.ChineseScore,
		)
		if err != nil {
			logger.Warn(ctx, "scan unified score failed", logger.ErrorField(err))
			continue
		}
		scores = append(scores, &s)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.unifiedScores[key] = scores
	r.cache.mu.Unlock()

	return scores, nil
}

// GetControlScores 获取最低投档控制分数线
func (r *recommendationRepo) GetControlScores(ctx context.Context, year int32) ([]*ControlScore, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if scores, ok := r.cache.controlScores[year]; ok {
		r.cache.mu.RUnlock()
		return scores, nil
	}
	r.cache.mu.RUnlock()

	// 查询数据库
	rows, err := r.db.Query(ctx, `
		SELECT year, admission_batch_id, category, min_score, COALESCE(description, '')
		FROM ref_control_score
		WHERE year = $1
		ORDER BY min_score DESC
	`, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var scores []*ControlScore
	for rows.Next() {
		var s ControlScore
		err := rows.Scan(
			&s.Year, &s.AdmissionBatchID, &s.Category, &s.MinScore, &s.Description,
		)
		if err != nil {
			logger.Warn(ctx, "scan control score failed", logger.ErrorField(err))
			continue
		}
		scores = append(scores, &s)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.controlScores[year] = scores
	r.cache.mu.Unlock()

	return scores, nil
}

// GetDistrictExamCount 获取区中考人数
func (r *recommendationRepo) GetDistrictExamCount(ctx context.Context, districtID int32, year int32) (int, error) {
	var count int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(exam_count, 5000)
		FROM ref_district_exam_count
		WHERE district_id = $1 AND year = $2
	`, districtID, year).Scan(&count)
	if err != nil {
		logger.Warn(ctx, "get district exam count failed, using default",
			logger.Int("district_id", int(districtID)),
			logger.Int("year", int(year)),
			logger.ErrorField(err),
		)
		return 5000, nil // 默认值
	}
	return count, nil
}

// GetDistrictTotalScores 获取区一模/二模总分映射
func (r *recommendationRepo) GetDistrictTotalScores(ctx context.Context) (map[int32]*DistrictTotalScore, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if len(r.cache.districtTotalScores) > 0 {
		result := make(map[int32]*DistrictTotalScore)
		for k, v := range r.cache.districtTotalScores {
			result[k] = v
		}
		r.cache.mu.RUnlock()
		return result, nil
	}
	r.cache.mu.RUnlock()

	// 硬编码的区总分映射表（基于2026届一模/2025届二模）
	// 注意：区ID与ref_district表对应
	// ID 1 = 上海市（汇总）
	// ID 2-17 = 各区
	totalScores := map[int32]*DistrictTotalScore{
		2:  {DistrictID: 2, DistrictName: "黄浦区", FirstMockTotal: 615, SecondMockTotal: 615},
		3:  {DistrictID: 3, DistrictName: "徐汇区", FirstMockTotal: 700, SecondMockTotal: 605},
		4:  {DistrictID: 4, DistrictName: "长宁区", FirstMockTotal: 635, SecondMockTotal: 605},
		5:  {DistrictID: 5, DistrictName: "静安区", FirstMockTotal: 630, SecondMockTotal: 605},
		6:  {DistrictID: 6, DistrictName: "普陀区", FirstMockTotal: 635, SecondMockTotal: 605},
		7:  {DistrictID: 7, DistrictName: "虹口区", FirstMockTotal: 635, SecondMockTotal: 615},
		8:  {DistrictID: 8, DistrictName: "杨浦区", FirstMockTotal: 645, SecondMockTotal: 615},
		9:  {DistrictID: 9, DistrictName: "闵行区", FirstMockTotal: 645, SecondMockTotal: 615},
		10: {DistrictID: 10, DistrictName: "宝山区", FirstMockTotal: 615, SecondMockTotal: 615},
		11: {DistrictID: 11, DistrictName: "嘉定区", FirstMockTotal: 635, SecondMockTotal: 605},
		12: {DistrictID: 12, DistrictName: "浦东新区", FirstMockTotal: 605, SecondMockTotal: 605},
		13: {DistrictID: 13, DistrictName: "金山区", FirstMockTotal: 605, SecondMockTotal: 605},
		14: {DistrictID: 14, DistrictName: "松江区", FirstMockTotal: 645, SecondMockTotal: 615},
		15: {DistrictID: 15, DistrictName: "青浦区", FirstMockTotal: 605, SecondMockTotal: 605},
		16: {DistrictID: 16, DistrictName: "奉贤区", FirstMockTotal: 615, SecondMockTotal: 615},
		17: {DistrictID: 17, DistrictName: "崇明区", FirstMockTotal: 605, SecondMockTotal: 605},
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.districtTotalScores = totalScores
	r.cache.mu.Unlock()

	return totalScores, nil
}

// GetDistrictByID 获取区信息
func (r *recommendationRepo) GetDistrictByID(ctx context.Context, districtID int32) (*highschoolv1.District, error) {
	row := r.db.QueryRow(ctx, `
		SELECT id, code, name, name_en
		FROM ref_district
		WHERE id = $1
	`, districtID)

	var d highschoolv1.District
	err := row.Scan(&d.Id, &d.Code, &d.Name, &d.NameEn)
	if err != nil {
		return nil, err
	}
	return &d, nil
}

// GetSchoolsWithQuotaDistrict 获取有名额分配到区的高中列表
func (r *recommendationRepo) GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32, year int32) ([]*highschoolv1.SchoolWithQuota, error) {
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.code, q.quota_count
		FROM ref_school s
		INNER JOIN ref_quota_allocation_district q ON q.school_id = s.id
		WHERE q.district_id = $1 AND q.year = $2 AND q.quota_count > 0 AND s.is_active = true
		ORDER BY s.full_name
	`, districtID, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var schools []*highschoolv1.SchoolWithQuota
	for rows.Next() {
		var s highschoolv1.SchoolWithQuota
		err := rows.Scan(&s.Id, &s.FullName, &s.Code, &s.QuotaCount)
		if err != nil {
			continue
		}
		schools = append(schools, &s)
	}
	return schools, nil
}

// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表
func (r *recommendationRepo) GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32, year int32) ([]*highschoolv1.SchoolWithQuota, error) {
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.code, q.quota_count
		FROM ref_school s
		INNER JOIN ref_quota_allocation_school q ON q.high_school_id = s.id
		WHERE q.middle_school_id = $1 AND q.year = $2 AND q.quota_count > 0 AND s.is_active = true
		ORDER BY s.full_name
	`, middleSchoolID, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var schools []*highschoolv1.SchoolWithQuota
	for rows.Next() {
		var s highschoolv1.SchoolWithQuota
		err := rows.Scan(&s.Id, &s.FullName, &s.Code, &s.QuotaCount)
		if err != nil {
			continue
		}
		schools = append(schools, &s)
	}
	return schools, nil
}

// GetSchoolsForUnified 获取统一招生可选学校列表
func (r *recommendationRepo) GetSchoolsForUnified(ctx context.Context, districtID int32, year int32) ([]*highschoolv1.SchoolForUnified, error) {
	rows, err := r.db.Query(ctx, `
		SELECT s.id, s.full_name, s.code,
		       CASE WHEN s.district_id = $1 THEN true ELSE false END as is_district_school
		FROM ref_school s
		INNER JOIN ref_quota_unified_allocation_district q
			ON q.school_id = s.id AND q.district_id = $1 AND q.year = $2 AND q.quota_count > 0
		WHERE s.is_active = true
		ORDER BY
		  CASE WHEN s.district_id = $1 THEN 0 ELSE 1 END,
		  s.full_name
	`, districtID, year)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var schools []*highschoolv1.SchoolForUnified
	for rows.Next() {
		var s highschoolv1.SchoolForUnified
		err := rows.Scan(&s.Id, &s.FullName, &s.Code, &s.IsDistrictSchool)
		if err != nil {
			continue
		}
		schools = append(schools, &s)
	}
	return schools, nil
}

// GetMiddleSchoolByID 获取初中信息
func (r *recommendationRepo) GetMiddleSchoolByID(ctx context.Context, middleSchoolID int32) (*highschoolv1.MiddleSchool, error) {
	row := r.db.QueryRow(ctx, `
		SELECT m.id, m.name, m.short_name, m.district_id, m.is_non_selective
		FROM ref_middle_school m
		WHERE m.id = $1
	`, middleSchoolID)

	var m highschoolv1.MiddleSchool
	var shortName *string
	err := row.Scan(&m.Id, &m.Name, &shortName, &m.DistrictId, &m.IsNonSelective)
	if err != nil {
		return nil, err
	}
	if shortName != nil {
		m.ShortName = shortName
	}
	return &m, nil
}

// GetLatestScoreYear 获取最新分数线年份
func (r *recommendationRepo) GetLatestScoreYear(ctx context.Context) (int32, error) {
	var year int32
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(MAX(year), 2024) FROM ref_admission_score_unified
	`).Scan(&year)
	if err != nil {
		return 2024, err
	}
	return year, nil
}

// 辅助函数
func cacheKey(districtID int32, year int32) string {
	return string(rune(districtID)) + "_" + string(rune(year))
}

func cacheKey3(districtID int32, middleSchoolName string, year int32) string {
	return string(rune(districtID)) + "_" + middleSchoolName + "_" + string(rune(year))
}
