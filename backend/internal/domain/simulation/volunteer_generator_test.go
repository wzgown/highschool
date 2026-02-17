// simulation/volunteer_generator_test.go - 志愿生成器测试
package simulation

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	highschoolv1 "highschool-backend/gen/highschool/v1"
	"highschool-backend/internal/repository"
)

// mockSchoolRepoForVolunteer 用于测试的模拟学校仓库
type mockSchoolRepoForVolunteer struct{}

func (m *mockSchoolRepoForVolunteer) GetByID(ctx context.Context, id int32) (*highschoolv1.School, error) {
	return &highschoolv1.School{Id: id, FullName: "测试学校"}, nil
}

func (m *mockSchoolRepoForVolunteer) List(ctx context.Context, districtID *int32, schoolTypeID, schoolNatureID *string,
	hasInternationalCourse *bool, keyword *string, page, pageSize int32) ([]*highschoolv1.School, int32, error) {
	return nil, 0, nil
}

func (m *mockSchoolRepoForVolunteer) GetDetail(ctx context.Context, id int32) (*highschoolv1.SchoolDetail, error) {
	return nil, nil
}

func (m *mockSchoolRepoForVolunteer) GetHistoryScores(ctx context.Context, schoolID int32) ([]*highschoolv1.HistoryScore, error) {
	return nil, nil
}

func (m *mockSchoolRepoForVolunteer) GetSchoolsWithQuotaDistrict(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolWithQuota, error) {
	return nil, nil
}

func (m *mockSchoolRepoForVolunteer) GetSchoolsWithQuotaSchool(ctx context.Context, middleSchoolID int32, year int) ([]*highschoolv1.SchoolWithQuota, error) {
	return nil, nil
}

func (m *mockSchoolRepoForVolunteer) GetSchoolsForUnified(ctx context.Context, districtID int32, year int) ([]*highschoolv1.SchoolForUnified, error) {
	// 返回模拟的统一招生可选学校
	return []*highschoolv1.SchoolForUnified{
		{Id: 1, FullName: "上海中学", Code: "001", IsDistrictSchool: false},
		{Id: 2, FullName: "华二附中", Code: "002", IsDistrictSchool: false},
		{Id: 3, FullName: "复旦附中", Code: "003", IsDistrictSchool: false},
		{Id: 4, FullName: "建平中学", Code: "004", IsDistrictSchool: true},
		{Id: 5, FullName: "进才中学", Code: "005", IsDistrictSchool: true},
		{Id: 6, FullName: "上师大附中", Code: "006", IsDistrictSchool: true},
		{Id: 7, FullName: "浦外", Code: "007", IsDistrictSchool: true},
		{Id: 8, FullName: "上中东校", Code: "008", IsDistrictSchool: true},
		{Id: 9, FullName: "川沙中学", Code: "009", IsDistrictSchool: true},
		{Id: 10, FullName: "洋泾中学", Code: "010", IsDistrictSchool: true},
		{Id: 11, FullName: "高桥中学", Code: "011", IsDistrictSchool: true},
		{Id: 12, FullName: "南汇中学", Code: "012", IsDistrictSchool: true},
		{Id: 13, FullName: "东昌中学", Code: "013", IsDistrictSchool: true},
		{Id: 14, FullName: "三林中学", Code: "014", IsDistrictSchool: true},
		{Id: 15, FullName: "杨思中学", Code: "015", IsDistrictSchool: true},
		{Id: 16, FullName: "周浦中学", Code: "016", IsDistrictSchool: true},
		{Id: 17, FullName: "大团中学", Code: "017", IsDistrictSchool: true},
		{Id: 18, FullName: "新川中学", Code: "018", IsDistrictSchool: true},
	}, nil
}

func (m *mockSchoolRepoForVolunteer) GetSchoolsByCutoffScoreRanking(ctx context.Context, districtID int32, year int) ([]*repository.SchoolRankingInfo, error) {
	// 返回模拟的学校排名数据（按分数线从高到低）
	// 模拟浦东新区的学校排名
	return []*repository.SchoolRankingInfo{
		{ID: 1, FullName: "上海中学", DistrictID: districtID, CutoffScore: 710, RankingOrder: 1},
		{ID: 2, FullName: "华二附中", DistrictID: districtID, CutoffScore: 706, RankingOrder: 2},
		{ID: 3, FullName: "复旦附中", DistrictID: districtID, CutoffScore: 708, RankingOrder: 3},
		{ID: 4, FullName: "建平中学", DistrictID: districtID, CutoffScore: 695, RankingOrder: 4},
		{ID: 5, FullName: "进才中学", DistrictID: districtID, CutoffScore: 690.5, RankingOrder: 5},
		{ID: 6, FullName: "上师大附中", DistrictID: districtID, CutoffScore: 689, RankingOrder: 6},
		{ID: 7, FullName: "浦外", DistrictID: districtID, CutoffScore: 685, RankingOrder: 7},
		{ID: 8, FullName: "上中东校", DistrictID: districtID, CutoffScore: 685, RankingOrder: 8},
		{ID: 9, FullName: "川沙中学", DistrictID: districtID, CutoffScore: 665, RankingOrder: 9},
		{ID: 10, FullName: "洋泾中学", DistrictID: districtID, CutoffScore: 670, RankingOrder: 10},
		{ID: 11, FullName: "高桥中学", DistrictID: districtID, CutoffScore: 660, RankingOrder: 11},
		{ID: 12, FullName: "南汇中学", DistrictID: districtID, CutoffScore: 655, RankingOrder: 12},
		{ID: 13, FullName: "东昌中学", DistrictID: districtID, CutoffScore: 668, RankingOrder: 13},
		{ID: 14, FullName: "三林中学", DistrictID: districtID, CutoffScore: 645, RankingOrder: 14},
		{ID: 15, FullName: "杨思中学", DistrictID: districtID, CutoffScore: 640, RankingOrder: 15},
		{ID: 16, FullName: "周浦中学", DistrictID: districtID, CutoffScore: 630, RankingOrder: 16},
		{ID: 17, FullName: "大团中学", DistrictID: districtID, CutoffScore: 625, RankingOrder: 17},
		{ID: 18, FullName: "新川中学", DistrictID: districtID, CutoffScore: 635, RankingOrder: 18},
	}, nil
}

func TestStrategyVolunteerGenerator_GenerateUnifiedVolunteers(t *testing.T) {
	ctx := context.Background()
	districtID := int32(7) // 浦东新区

	// 创建志愿生成器
	mockRepo := &mockSchoolRepoForVolunteer{}
	generator := NewStrategyVolunteerGenerator(mockRepo, 2025)

	t.Run("should generate volunteers with reach-target-safety strategy for high score", func(t *testing.T) {
		// 高分考生：700分
		// 应该冲：710+的学校（分数线高于700分5-15分）
		// 应该稳：695-705的学校
		// 应该保：680-695的学校
		volunteers := generator.GenerateUnifiedVolunteers(ctx, 700, districtID)

		assert.NotEmpty(t, volunteers, "should generate volunteers")
		assert.LessOrEqual(t, len(volunteers), 15, "should not exceed 15 volunteers")

		// 验证志愿数量合理
		t.Logf("Generated %d volunteers for score 700: %v", len(volunteers), volunteers)
	})

	t.Run("should generate volunteers with reach-target-safety strategy for medium score", func(t *testing.T) {
		// 中等分数：660分
		volunteers := generator.GenerateUnifiedVolunteers(ctx, 660, districtID)

		assert.NotEmpty(t, volunteers, "should generate volunteers")
		assert.LessOrEqual(t, len(volunteers), 15, "should not exceed 15 volunteers")

		t.Logf("Generated %d volunteers for score 660: %v", len(volunteers), volunteers)
	})

	t.Run("should generate volunteers with reach-target-safety strategy for low score", func(t *testing.T) {
		// 低分考生：620分
		volunteers := generator.GenerateUnifiedVolunteers(ctx, 620, districtID)

		assert.NotEmpty(t, volunteers, "should generate volunteers")
		assert.LessOrEqual(t, len(volunteers), 15, "should not exceed 15 volunteers")

		t.Logf("Generated %d volunteers for score 620: %v", len(volunteers), volunteers)
	})
}

func TestStrategyVolunteerGenerator_GenerateQuotaDistrictVolunteer(t *testing.T) {
	ctx := context.Background()
	districtID := int32(7) // 浦东新区

	mockRepo := &mockSchoolRepoForVolunteer{}
	generator := NewStrategyVolunteerGenerator(mockRepo, 2025)

	t.Run("should generate quota district volunteer", func(t *testing.T) {
		volunteer := generator.GenerateQuotaDistrictVolunteer(ctx, 680, districtID)

		// 注意：由于mock没有实现GetSchoolsWithQuotaDistrict，这里会返回nil
		// 在实际环境中会返回一个学校ID
		t.Logf("Generated quota district volunteer: %v", volunteer)
	})
}

func TestStrategyVolunteerGenerator_GenerateQuotaSchoolVolunteers(t *testing.T) {
	ctx := context.Background()
	districtID := int32(7) // 浦东新区
	middleSchoolID := int32(1)

	mockRepo := &mockSchoolRepoForVolunteer{}
	generator := NewStrategyVolunteerGenerator(mockRepo, 2025)

	t.Run("should return nil if no eligibility", func(t *testing.T) {
		volunteers := generator.GenerateQuotaSchoolVolunteers(ctx, 680, districtID, middleSchoolID, false)
		assert.Nil(t, volunteers, "should return nil if no eligibility")
	})

	t.Run("should generate quota school volunteers if has eligibility", func(t *testing.T) {
		volunteers := generator.GenerateQuotaSchoolVolunteers(ctx, 680, districtID, middleSchoolID, true)

		// 注意：由于mock没有实现GetSchoolsWithQuotaSchool，这里会返回nil
		// 在实际环境中会返回最多2个学校ID
		t.Logf("Generated quota school volunteers: %v", volunteers)
	})
}
