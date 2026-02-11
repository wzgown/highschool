// repository/simulation_history.go - 模拟历史记录数据访问层
package repository

import (
	"context"
	"fmt"
	"strconv"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"google.golang.org/protobuf/encoding/protojson"

	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/infrastructure/database"
)

// SimulationHistoryRepository 模拟历史记录仓库接口
type SimulationHistoryRepository interface {
	// Save 保存模拟历史记录
	Save(ctx context.Context, deviceID string, deviceInfo map[string]interface{},
		candidateData *highschoolv1.SubmitAnalysisRequest,
		result *highschoolv1.SimulationResults) (string, error)

	// GetByID 根据ID获取记录
	GetByID(ctx context.Context, id string) (*SimulationHistoryRecord, error)

	// ListByDevice 获取设备的历史记录列表
	ListByDevice(ctx context.Context, deviceID string, page, pageSize int32) ([]*SimulationHistoryRecord, int32, error)

	// DeleteByID 删除指定记录
	DeleteByID(ctx context.Context, id string) error

	// DeleteByDevice 删除设备的所有记录
	DeleteByDevice(ctx context.Context, deviceID string) error
}

// SimulationHistoryRecord 模拟历史记录
type SimulationHistoryRecord struct {
	ID               int64
	DeviceID         string
	DeviceInfo       map[string]interface{}
	CandidateData    *highschoolv1.SubmitAnalysisRequest
	SimulationResult *highschoolv1.SimulationResults
	CreatedAt        time.Time
}

// simulationHistoryRepo 实现
type simulationHistoryRepo struct {
	db *pgxpool.Pool
}

// NewSimulationHistoryRepository 创建仓库实例
func NewSimulationHistoryRepository() SimulationHistoryRepository {
	return &simulationHistoryRepo{
		db: database.GetDB(),
	}
}

// Save 保存模拟历史记录
func (r *simulationHistoryRepo) Save(ctx context.Context, deviceID string, deviceInfo map[string]interface{},
	candidateData *highschoolv1.SubmitAnalysisRequest,
	result *highschoolv1.SimulationResults) (string, error) {

	createdAt := time.Now()
	var analysisID int64

	// 使用自增ID，通过 RETURNING 获取插入的ID
	err := r.db.QueryRow(ctx, `
		INSERT INTO simulation_history (device_id, device_info, candidate_data, simulation_result, created_at)
		VALUES ($1, $2, $3, $4, $5)
		RETURNING id
	`, deviceID, deviceInfo, candidateData, result, createdAt).Scan(&analysisID)

	if err != nil {
		return "", fmt.Errorf("save simulation history failed: %w", err)
	}

	return strconv.FormatInt(analysisID, 10), nil
}

// GetByID 根据ID获取记录
func (r *simulationHistoryRepo) GetByID(ctx context.Context, id string) (*SimulationHistoryRecord, error) {
	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		return nil, fmt.Errorf("invalid id format")
	}

	row := r.db.QueryRow(ctx, `
		SELECT id, device_id, device_info, candidate_data, simulation_result, created_at
		FROM simulation_history
		WHERE id = $1
	`, idInt)

	var record SimulationHistoryRecord
	var createdAt pgtype.Timestamp
	var simResultJSON []byte

	err = row.Scan(&record.ID, &record.DeviceID, &record.DeviceInfo, &record.CandidateData, &simResultJSON, &createdAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("record not found")
		}
		return nil, fmt.Errorf("get simulation history failed: %w", err)
	}

	record.CreatedAt = createdAt.Time

	// 使用 protojson 正确反序列化 JSONB 数据
	if len(simResultJSON) > 0 {
		record.SimulationResult = &highschoolv1.SimulationResults{}
		if err := protojson.Unmarshal(simResultJSON, record.SimulationResult); err != nil {
			return nil, fmt.Errorf("unmarshal simulation result failed: %w", err)
		}
	}

	return &record, nil
}

// ListByDevice 获取设备的历史记录列表
func (r *simulationHistoryRepo) ListByDevice(ctx context.Context, deviceID string, page, pageSize int32) ([]*SimulationHistoryRecord, int32, error) {
	// 获取总数
	var total int32
	err := r.db.QueryRow(ctx, `
		SELECT COUNT(*) FROM simulation_history WHERE device_id = $1
	`, deviceID).Scan(&total)
	if err != nil {
		return nil, 0, fmt.Errorf("count history failed: %w", err)
	}

	// 获取分页数据
	offset := (page - 1) * pageSize
	rows, err := r.db.Query(ctx, `
		SELECT id, device_id, created_at
		FROM simulation_history
		WHERE device_id = $1
		ORDER BY created_at DESC
		LIMIT $2 OFFSET $3
	`, deviceID, pageSize, offset)
	if err != nil {
		return nil, 0, fmt.Errorf("list history failed: %w", err)
	}
	defer rows.Close()

	var records []*SimulationHistoryRecord
	for rows.Next() {
		var record SimulationHistoryRecord
		var createdAt pgtype.Timestamp

		err := rows.Scan(&record.ID, &record.DeviceID, &createdAt)
		if err != nil {
			continue
		}
		record.CreatedAt = createdAt.Time
		records = append(records, &record)
	}

	return records, total, nil
}

// DeleteByID 删除指定记录
func (r *simulationHistoryRepo) DeleteByID(ctx context.Context, id string) error {
	idInt, err := strconv.ParseInt(id, 10, 64)
	if err != nil {
		return fmt.Errorf("invalid id format")
	}

	_, err = r.db.Exec(ctx, `
		DELETE FROM simulation_history WHERE id = $1
	`, idInt)
	if err != nil {
		return fmt.Errorf("delete history failed: %w", err)
	}
	return nil
}

// DeleteByDevice 删除设备的所有记录
func (r *simulationHistoryRepo) DeleteByDevice(ctx context.Context, deviceID string) error {
	_, err := r.db.Exec(ctx, `
		DELETE FROM simulation_history WHERE device_id = $1
	`, deviceID)
	if err != nil {
		return fmt.Errorf("delete device history failed: %w", err)
	}
	return nil
}
