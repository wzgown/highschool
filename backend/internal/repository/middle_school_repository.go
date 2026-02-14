// repository/middle_school_repository.go - 初中学校数据访问层
package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/database"
)

// MiddleSchoolRepository 初中学校仓库接口
type MiddleSchoolRepository interface {
	// List 获取初中学校列表
	List(ctx context.Context, districtID *int32, keyword *string) ([]*highschoolv1.MiddleSchool, error)
}

// middleSchoolRepo 实现
type middleSchoolRepo struct {
	db *pgxpool.Pool
}

// NewMiddleSchoolRepository 创建初中学校仓库
func NewMiddleSchoolRepository() MiddleSchoolRepository {
	return &middleSchoolRepo{
		db: database.GetDB(),
	}
}

// List 获取初中学校列表
func (r *middleSchoolRepo) List(ctx context.Context, districtID *int32, keyword *string) ([]*highschoolv1.MiddleSchool, error) {
	whereClause := "WHERE is_active = true"
	args := []interface{}{}
	argIdx := 1

	if districtID != nil {
		whereClause += fmt.Sprintf(" AND district_id = $%d", argIdx)
		args = append(args, *districtID)
		argIdx++
	}

	if keyword != nil && *keyword != "" {
		whereClause += fmt.Sprintf(" AND (name ILIKE $%d OR code ILIKE $%d)", argIdx, argIdx)
		args = append(args, "%"+*keyword+"%")
		argIdx++
	}

	query := fmt.Sprintf(`
		SELECT id, code, name, short_name, district_id, school_nature_id, is_non_selective, exact_student_count, estimated_student_count
		FROM ref_middle_school
		%s
		ORDER BY id
	`, whereClause)

	rows, err := r.db.Query(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list middle schools failed: %w", err)
	}
	defer rows.Close()

	var schools []*highschoolv1.MiddleSchool
	for rows.Next() {
		var school highschoolv1.MiddleSchool
		var shortName *string
		var exactCount *int32
		var estimatedCount *int32

		var schoolNatureId *string // Changed to pointer to handle NULL
		err := rows.Scan(
			&school.Id,
			&school.Code,
			&school.Name,
			&shortName,
			&school.DistrictId,
			&schoolNatureId,
			&school.IsNonSelective,
			&exactCount,
			&estimatedCount,
		)
		if err != nil {
			continue
		}

		school.ShortName = shortName
		school.ExactStudentCount = exactCount
		school.EstimatedStudentCount = estimatedCount
		schools = append(schools, &school)
	}

	return schools, nil
}
