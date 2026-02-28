// repository/district_repository.go - 区县数据访问层
package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/database"
)

// DistrictRepository 区县仓库接口
type DistrictRepository interface {
	// ListAll 获取所有区县
	ListAll(ctx context.Context) ([]*highschoolv1.District, error)

	// GetExamCount 获取区县中考人数
	GetExamCount(ctx context.Context, districtID int32, year int32) (*highschoolv1.DistrictExamCountItem, error)
}

// districtRepo 实现
type districtRepo struct {
	db *pgxpool.Pool
}

// NewDistrictRepository 创建区县仓库
func NewDistrictRepository() DistrictRepository {
	return &districtRepo{
		db: database.GetDB(),
	}
}

// ListAll 获取所有区县
func (r *districtRepo) ListAll(ctx context.Context) ([]*highschoolv1.District, error) {
	rows, err := r.db.Query(ctx, `
		SELECT id, code, name, name_en, display_order
		FROM ref_district
		ORDER BY display_order
	`)
	if err != nil {
		return nil, fmt.Errorf("list districts failed: %w", err)
	}
	defer rows.Close()

	var districts []*highschoolv1.District
	for rows.Next() {
		var d highschoolv1.District
		var code, nameEn string
		var displayOrder int32

		err := rows.Scan(&d.Id, &code, &d.Name, &nameEn, &displayOrder)
		if err != nil {
			continue
		}
		districts = append(districts, &d)
	}

	return districts, nil
}

// GetExamCount 获取区县中考人数
func (r *districtRepo) GetExamCount(ctx context.Context, districtID int32, year int32) (*highschoolv1.DistrictExamCountItem, error) {
	row := r.db.QueryRow(ctx, `
		SELECT d.id, d.name, total_students
		FROM ref_district d
		LEFT JOIN ref_district_exam_count c ON d.id = c.district_id AND c.year = $1
		WHERE d.id = $2
	`, year, districtID)

	var count highschoolv1.DistrictExamCountItem

	err := row.Scan(&count.DistrictId, &count.DistrictName, &count.ExamCount)
	if err != nil {
		return nil, fmt.Errorf("get exam count failed: %w", err)
	}

	return &count, nil
}
