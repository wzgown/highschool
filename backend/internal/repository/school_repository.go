// repository/school_repository.go - 学校数据访问层
package repository

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/database"
)

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

	// GetSchoolsWithQuotaDistrict 获取有名额分配到区的高中列表
	GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表
	GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32, year int) ([]*highschoolv1.SchoolWithQuota, error)

	// GetSchoolsForUnified 获取统一招生（1-15志愿）可选学校列表
	GetSchoolsForUnified(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolForUnified, error)
}

// schoolRepo 实现
type schoolRepo struct {
	db *pgxpool.Pool
}

// NewSchoolRepository 创建学校仓库
func NewSchoolRepository() SchoolRepository {
	return &schoolRepo{
		db: database.GetDB(),
	}
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
func (r *schoolRepo) GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolWithQuota, error) {
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.code, q.quota_count
		FROM ref_school s
		INNER JOIN ref_quota_allocation_district q ON q.school_id = s.id
		WHERE q.district_id = $1 AND q.year = $2 AND q.quota_count > 0 AND s.is_active = true
		ORDER BY s.full_name
	`, districtID, year)
	if err != nil {
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

	return schools, nil
}

// GetSchoolsWithQuotaSchool 获取有名额分配到校的高中列表
func (r *schoolRepo) GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32, year int) ([]*highschoolv1.SchoolWithQuota, error) {
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

	return schools, nil
}

// GetSchoolsForUnified 获取统一招生（1-15志愿）可选学校列表
// 包括：1. 本区所有高中 2. 面向全市招生的高中（根据历史分数线数据判断）
func (r *schoolRepo) GetSchoolsForUnified(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolForUnified, error) {
	// 查询该区在统一招生批次可填报的学校
	// 基于 ref_admission_score_unified 表，该表记录了各区统一招生的学校及其分数线
	rows, err := r.db.Query(ctx, `
		SELECT DISTINCT s.id, s.full_name, s.code,
		       CASE WHEN s.district_id = $1 THEN true ELSE false END as is_district_school
		FROM ref_school s
		INNER JOIN ref_admission_score_unified u ON u.school_id = s.id OR u.school_name = s.full_name
		WHERE u.district_id = $1 AND u.year = $2 AND s.is_active = true
		ORDER BY is_district_school DESC, s.full_name
	`, districtID, year-1) // 使用前一年的分数线数据（当年的分数线在录取后才有）
	if err != nil {
		return nil, fmt.Errorf("get schools for unified failed: %w", err)
	}
	defer rows.Close()

	var schools []*highschoolv1.SchoolForUnified
	for rows.Next() {
		var school highschoolv1.SchoolForUnified
		err := rows.Scan(&school.Id, &school.FullName, &school.Code, &school.IsDistrictSchool)
		if err != nil {
			continue
		}
		schools = append(schools, &school)
	}

	return schools, nil
}
