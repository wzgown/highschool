// repository/quota_repository.go - 名额分配数据访问层
package repository

import (
	"context"
	"fmt"
	"sync"

	"github.com/jackc/pgx/v5/pgxpool"

	"highschool-backend/internal/infrastructure/database"
	"highschool-backend/pkg/logger"
)

// QuotaRepository 名额分配数据仓库接口
type QuotaRepository interface {
	// GetQuotaDistrictPlan 获取名额分配到区计划数
	GetQuotaDistrictPlan(ctx context.Context, schoolID int32, districtID int32, year int) (int, error)
	// GetQuotaSchoolPlan 获取名额分配到校计划数
	GetQuotaSchoolPlan(ctx context.Context, schoolID int32, middleSchoolID int32, year int) (int, error)
	// GetUnifiedPlan 获取统一招生计划数
	GetUnifiedPlan(ctx context.Context, schoolID int32, year int) (int, error)
	// GetDistrictExamCount 获取区县中考人数
	GetDistrictExamCount(ctx context.Context, districtID int32, year int) (int, error)
	// GetMiddleSchoolStudentCount 获取初中学校学生人数
	GetMiddleSchoolStudentCount(ctx context.Context, middleSchoolID int32, year int) (int, error)
	// PreloadCache 预加载缓存
	PreloadCache(ctx context.Context, districtID int32, middleSchoolID int32, year int)
}

// quotaCache 名额数据缓存
type quotaCache struct {
	mu                  sync.RWMutex
	districtQuotas      map[string]int // key: "schoolID_districtID" -> quota
	schoolQuotas        map[string]int // key: "schoolID_middleSchoolID" -> quota
	unifiedQuotas       map[int32]int  // key: schoolID -> quota
	districtExamCounts  map[int32]int  // key: districtID -> count
	middleSchoolCounts  map[int32]int  // key: middleSchoolID -> count
	year                int
}

// quotaRepo 实现
type quotaRepo struct {
	db    *pgxpool.Pool
	cache *quotaCache
}

// NewQuotaRepository 创建名额分配仓库
func NewQuotaRepository() QuotaRepository {
	return &quotaRepo{
		db: database.GetDB(),
		cache: &quotaCache{
			districtQuotas:     make(map[string]int),
			schoolQuotas:       make(map[string]int),
			unifiedQuotas:      make(map[int32]int),
			districtExamCounts: make(map[int32]int),
			middleSchoolCounts: make(map[int32]int),
		},
	}
}

// PreloadCache 预加载缓存
func (r *quotaRepo) PreloadCache(ctx context.Context, districtID int32, middleSchoolID int32, year int) {
	r.cache.mu.Lock()
	defer r.cache.mu.Unlock()

	// 如果年份变了，清空缓存
	if r.cache.year != year {
		r.cache.districtQuotas = make(map[string]int)
		r.cache.schoolQuotas = make(map[string]int)
		r.cache.unifiedQuotas = make(map[int32]int)
		r.cache.districtExamCounts = make(map[int32]int)
		r.cache.middleSchoolCounts = make(map[int32]int)
		r.cache.year = year
	}

	// 加载该区的所有名额分配到区数据
	rows, err := r.db.Query(ctx, `
		SELECT school_id, district_id, quota_count
		FROM ref_quota_allocation_district
		WHERE district_id = $1 AND year = $2
	`, districtID, year)
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var schoolID, distID int32
			var quota int
			if err := rows.Scan(&schoolID, &distID, &quota); err == nil {
				key := fmt.Sprintf("%d_%d", schoolID, distID)
				r.cache.districtQuotas[key] = quota
			}
		}
	}

	// 加载该初中的所有名额分配到校数据
	rows2, err := r.db.Query(ctx, `
		SELECT high_school_id, middle_school_id, quota_count
		FROM ref_quota_allocation_school
		WHERE middle_school_id = $1 AND year = $2
	`, middleSchoolID, year)
	if err == nil {
		defer rows2.Close()
		for rows2.Next() {
			var schoolID, midID int32
			var quota int
			if err := rows2.Scan(&schoolID, &midID, &quota); err == nil {
				key := fmt.Sprintf("%d_%d", schoolID, midID)
				r.cache.schoolQuotas[key] = quota
			}
		}
	}

	// 加载区县中考人数
	var count int
	err = r.db.QueryRow(ctx, `
		SELECT COALESCE(exam_count, 5000)
		FROM ref_district_exam_count
		WHERE district_id = $1 AND year = $2
	`, districtID, year).Scan(&count)
	if err == nil {
		r.cache.districtExamCounts[districtID] = count
	}

	// 加载初中学校学生人数（从 ref_middle_school 表获取）
	err = r.db.QueryRow(ctx, `
		SELECT COALESCE(exact_student_count, estimated_student_count, 300)
		FROM ref_middle_school
		WHERE id = $1
	`, middleSchoolID).Scan(&count)
	if err == nil {
		r.cache.middleSchoolCounts[middleSchoolID] = count
	}
}

// GetQuotaDistrictPlan 获取名额分配到区计划数
func (r *quotaRepo) GetQuotaDistrictPlan(ctx context.Context, schoolID int32, districtID int32, year int) (int, error) {
	// 检查缓存
	key := fmt.Sprintf("%d_%d", schoolID, districtID)
	r.cache.mu.RLock()
	if r.cache.year == year {
		if quota, ok := r.cache.districtQuotas[key]; ok {
			r.cache.mu.RUnlock()
			return quota, nil
		}
	}
	r.cache.mu.RUnlock()

	// 缓存未命中，查询数据库
	var quota int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(SUM(quota_count), 0)
		FROM ref_quota_allocation_district
		WHERE school_id = $1 AND district_id = $2 AND year = $3
	`, schoolID, districtID, year).Scan(&quota)
	if err != nil {
		return 0, fmt.Errorf("get quota district plan failed: %w", err)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.districtQuotas[key] = quota
	r.cache.mu.Unlock()

	return quota, nil
}

// GetQuotaSchoolPlan 获取名额分配到校计划数
func (r *quotaRepo) GetQuotaSchoolPlan(ctx context.Context, schoolID int32, middleSchoolID int32, year int) (int, error) {
	// 检查缓存
	key := fmt.Sprintf("%d_%d", schoolID, middleSchoolID)
	r.cache.mu.RLock()
	if r.cache.year == year {
		if quota, ok := r.cache.schoolQuotas[key]; ok {
			r.cache.mu.RUnlock()
			return quota, nil
		}
	}
	r.cache.mu.RUnlock()

	// 缓存未命中，查询数据库
	var quota int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(quota_count, 0)
		FROM ref_quota_allocation_school
		WHERE high_school_id = $1 AND middle_school_id = $2 AND year = $3
	`, schoolID, middleSchoolID, year).Scan(&quota)
	if err != nil {
		return 0, fmt.Errorf("get quota school plan failed: %w", err)
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.schoolQuotas[key] = quota
	r.cache.mu.Unlock()

	return quota, nil
}

// GetUnifiedPlan 获取统一招生计划数
func (r *quotaRepo) GetUnifiedPlan(ctx context.Context, schoolID int32, year int) (int, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if r.cache.year == year {
		if quota, ok := r.cache.unifiedQuotas[schoolID]; ok {
			r.cache.mu.RUnlock()
			return quota, nil
		}
	}
	r.cache.mu.RUnlock()

	// 查询数据库获取统一招生计划数
	var quota int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(unified_count, 0)
		FROM ref_admission_plan_summary
		WHERE school_id = $1 AND year = $2
	`, schoolID, year).Scan(&quota)
	if err != nil {
		// 如果没有找到，使用默认值并打印警告
		quota = 100
		logger.Warn(ctx, "unified plan not found in database, using default value",
			logger.Int("school_id", int(schoolID)),
			logger.Int("year", year),
			logger.Int("default_quota", quota),
			logger.ErrorField(err),
		)
	}

	// 存入缓存
	r.cache.mu.Lock()
	if r.cache.year != year {
		// 年份变了，重置缓存
		r.cache.unifiedQuotas = make(map[int32]int)
		r.cache.year = year
	}
	r.cache.unifiedQuotas[schoolID] = quota
	r.cache.mu.Unlock()

	return quota, nil
}

// GetDistrictExamCount 获取区县中考人数
func (r *quotaRepo) GetDistrictExamCount(ctx context.Context, districtID int32, year int) (int, error) {
	// 检查缓存
	r.cache.mu.RLock()
	if r.cache.year == year {
		if count, ok := r.cache.districtExamCounts[districtID]; ok {
			r.cache.mu.RUnlock()
			return count, nil
		}
	}
	r.cache.mu.RUnlock()

	// 缓存未命中，查询数据库
	var count int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(exam_count, 0)
		FROM ref_district_exam_count
		WHERE district_id = $1 AND year = $2
	`, districtID, year).Scan(&count)
	if err != nil {
		// 如果没有数据，返回默认值并打印警告
		count = 5000
		logger.Warn(ctx, "district exam count not found in database, using default value",
			logger.Int("district_id", int(districtID)),
			logger.Int("year", year),
			logger.Int("default_count", count),
			logger.ErrorField(err),
		)
		return count, nil
	}

	// 存入缓存
	r.cache.mu.Lock()
	r.cache.districtExamCounts[districtID] = count
	r.cache.mu.Unlock()

	return count, nil
}

// GetMiddleSchoolStudentCount 获取初中学校学生人数
func (r *quotaRepo) GetMiddleSchoolStudentCount(ctx context.Context, middleSchoolID int32, year int) (int, error) {
	var count int
	// 先尝试获取精确人数
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(exact_student_count, estimated_student_count, 200)
		FROM ref_middle_school
		WHERE id = $1
	`, middleSchoolID).Scan(&count)
	if err != nil {
		// 如果没有数据，返回默认值并打印警告
		count = 200
		logger.Warn(ctx, "middle school student count not found in database, using default value",
			logger.Int("middle_school_id", int(middleSchoolID)),
			logger.Int("year", year),
			logger.Int("default_count", count),
			logger.ErrorField(err),
		)
		return count, nil
	}
	return count, nil
}
