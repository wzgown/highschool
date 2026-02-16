// repository/quota_repository.go - 名额分配数据访问层
package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"highschool-backend/internal/infrastructure/database"
)

// QuotaRepository 名额分配数据仓库接口
type QuotaRepository interface {
	// GetQuotaDistrictPlan 获取名额分配到区计划数
	GetQuotaDistrictPlan(ctx context.Context, schoolID int32, districtID int32, year int) (int, error)
	// GetQuotaSchoolPlan 获取名额分配到校计划数
	GetQuotaSchoolPlan(ctx context.Context, schoolID int32, middleSchoolID int32, year int) (int, error)
	// GetDistrictExamCount 获取区县中考人数
	GetDistrictExamCount(ctx context.Context, districtID int32, year int) (int, error)
	// GetMiddleSchoolStudentCount 获取初中学校学生人数
	GetMiddleSchoolStudentCount(ctx context.Context, middleSchoolID int32, year int) (int, error)
}

// quotaRepo 实现
type quotaRepo struct {
	db *pgxpool.Pool
}

// NewQuotaRepository 创建名额分配仓库
func NewQuotaRepository() QuotaRepository {
	return &quotaRepo{
		db: database.GetDB(),
	}
}

// GetQuotaDistrictPlan 获取名额分配到区计划数
func (r *quotaRepo) GetQuotaDistrictPlan(ctx context.Context, schoolID int32, districtID int32, year int) (int, error) {
	var quota int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(SUM(quota_count), 0)
		FROM ref_quota_allocation_district
		WHERE school_id = $1 AND district_id = $2 AND year = $3
	`, schoolID, districtID, year).Scan(&quota)
	if err != nil {
		return 0, fmt.Errorf("get quota district plan failed: %w", err)
	}
	return quota, nil
}

// GetQuotaSchoolPlan 获取名额分配到校计划数
func (r *quotaRepo) GetQuotaSchoolPlan(ctx context.Context, schoolID int32, middleSchoolID int32, year int) (int, error) {
	var quota int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(quota_count, 0)
		FROM ref_quota_allocation_school
		WHERE high_school_id = $1 AND middle_school_id = $2 AND year = $3
	`, schoolID, middleSchoolID, year).Scan(&quota)
	if err != nil {
		return 0, fmt.Errorf("get quota school plan failed: %w", err)
	}
	return quota, nil
}

// GetDistrictExamCount 获取区县中考人数
func (r *quotaRepo) GetDistrictExamCount(ctx context.Context, districtID int32, year int) (int, error) {
	var count int
	err := r.db.QueryRow(ctx, `
		SELECT COALESCE(exam_count, 0)
		FROM ref_district_exam_count
		WHERE district_id = $1 AND year = $2
	`, districtID, year).Scan(&count)
	if err != nil {
		// 如果没有数据，返回默认值
		return 5000, nil
	}
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
		// 如果没有数据，返回默认值
		return 200, nil
	}
	return count, nil
}
