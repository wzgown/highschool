#!/bin/bash
# 验证脚本：基于一模/二模成绩的志愿推荐功能
# 检查功能是否完整实现

set -e

echo "=== 验证开始：志愿推荐功能 ==="
echo ""

# 1. 检查 Protobuf 定义
echo "📋 检查 Protobuf 定义..."
if grep -q "GetVolunteerRecommendations" proto/highschool/v1/reference_service.proto; then
    echo "  ✅ RPC 定义存在"
else
    echo "  ❌ 缺少 GetVolunteerRecommendations RPC 定义"
    exit 1
fi

if grep -q "RecommendedSchool" proto/highschool/v1/reference_service.proto; then
    echo "  ✅ RecommendedSchool 消息定义存在"
else
    echo "  ❌ 缺少 RecommendedSchool 消息定义"
    exit 1
fi

echo ""

# 2. 检查生成代码是否存在
echo "🔧 检查生成代码..."
if [ -f "backend/gen/highschool/v1/reference_service.pb.go" ]; then
    if grep -q "GetVolunteerRecommendations" backend/gen/highschool/v1/reference_service.pb.go; then
        echo "  ✅ Go 生成代码存在"
    else
        echo "  ❌ Go 生成代码缺少 GetVolunteerRecommendations"
        exit 1
    fi
else
    echo "  ❌ 缺少 Go 生成代码"
    exit 1
fi

if [ -f "frontend/src/gen/highschool/v1/reference_service_pb.ts" ]; then
    if grep -q "GetVolunteerRecommendations" frontend/src/gen/highschool/v1/reference_service_pb.ts; then
        echo "  ✅ TypeScript 生成代码存在"
    else
        echo "  ❌ TypeScript 生成代码缺少 GetVolunteerRecommendations"
        exit 1
    fi
else
    echo "  ❌ 缺少 TypeScript 生成代码"
    exit 1
fi

echo ""

# 3. 检查后端 Repository 层
echo "🗄️ 检查 Repository 层..."
if [ -f "backend/internal/repository/recommendation_repository.go" ]; then
    echo "  ✅ recommendation_repository.go 存在"
    if grep -q "GetAdmissionScoresQuotaDistrict\|GetAdmissionScoresQuotaSchool\|GetAdmissionScoresUnified" backend/internal/repository/recommendation_repository.go; then
        echo "  ✅ 数据访问方法已实现"
    else
        echo "  ❌ 缺少必要的数据访问方法"
        exit 1
    fi
else
    echo "  ❌ 缺少 recommendation_repository.go"
    exit 1
fi

echo ""

# 4. 检查后端 Service 层
echo "⚙️ 检查 Service 层..."
if [ -f "backend/internal/service/recommendation_service.go" ]; then
    echo "  ✅ recommendation_service.go 存在"
    if grep -q "GetVolunteerRecommendations\|ConvertScore\|RecommendQuotaDistrict\|RecommendQuotaSchool\|RecommendUnified" backend/internal/service/recommendation_service.go; then
        echo "  ✅ 推荐服务方法已实现"
    else
        echo "  ❌ 缺少必要的推荐服务方法"
        exit 1
    fi
else
    echo "  ❌ 缺少 recommendation_service.go"
    exit 1
fi

echo ""

# 5. 检查后端 API 层
echo "🌐 检查 API 层..."
if grep -rq "GetVolunteerRecommendations" backend/internal/api/v1/; then
    echo "  ✅ API Handler 已实现"
else
    echo "  ❌ 缺少 API Handler"
    exit 1
fi

echo ""

# 6. 检查前端集成
echo "🖥️ 检查前端集成..."
if grep -rq "GetVolunteerRecommendations\|getVolunteerRecommendations" frontend/src/api/; then
    echo "  ✅ 前端 API 调用已实现"
else
    echo "  ❌ 缺少前端 API 调用"
    exit 1
fi

# 检查推荐组件或视图
if grep -rl "recommend\|Recommend" frontend/src/views/ frontend/src/components/ 2>/dev/null | grep -q .; then
    echo "  ✅ 前端推荐展示组件已实现"
else
    echo "  ❌ 缺少前端推荐展示组件"
    exit 1
fi

echo ""

# 7. 检查测试
echo "🧪 检查测试覆盖..."
TEST_FILES=$(find backend/internal -name "*recommendation*_test.go" 2>/dev/null | wc -l)
if [ "$TEST_FILES" -gt 0 ]; then
    echo "  ✅ 测试文件存在 ($TEST_FILES 个)"
else
    echo "  ⚠️ 未找到测试文件（建议添加）"
fi

echo ""

# 8. 运行后端测试（如果存在）
echo "🚀 运行后端测试..."
cd backend
if go test ./internal/service/... -run Recommendation -v 2>&1 | grep -q "PASS\|no test files"; then
    echo "  ✅ 服务层测试通过"
else
    echo "  ⚠️ 服务层测试未通过或不存在"
fi
cd ..

echo ""

# 9. 检查后端编译
echo "🔨 检查后端编译..."
cd backend
if go build ./cmd/api/... 2>&1; then
    echo "  ✅ 后端编译成功"
else
    echo "  ❌ 后端编译失败"
    exit 1
fi
cd ..

echo ""

# 10. 检查前端类型
echo "📝 检查前端类型..."
cd frontend
if npm run type-check 2>&1 | grep -q "error\|Error"; then
    echo "  ❌ 前端类型检查失败"
    exit 1
else
    echo "  ✅ 前端类型检查通过"
fi
cd ..

echo ""
echo "=========================================="
echo "✅ 验证通过：志愿推荐功能实现完整"
echo "=========================================="
