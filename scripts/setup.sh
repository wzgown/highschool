#!/bin/bash

###############################################################################
# 上海中考招生模拟系统 - 环境初始化脚本
###############################################################################

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印信息函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_info "检查系统依赖..."

    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js 未安装，请先安装 Node.js >= 20.0.0"
        exit 1
    fi

    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 20 ]; then
        print_error "Node.js 版本过低，需要 >= 20.0.0，当前版本: $(node -v)"
        exit 1
    fi

    print_info "Node.js 版本: $(node -v)"

    # 检查 pnpm/npm
    if command -v pnpm &> /dev/null; then
        PACKAGE_MANAGER="pnpm"
    elif command -v npm &> /dev/null; then
        PACKAGE_MANAGER="npm"
    else
        print_error "未找到 pnpm 或 npm，请先安装"
        exit 1
    fi

    print_info "包管理器: $PACKAGE_MANAGER"

    # 检查 PostgreSQL
    if ! command -v psql &> /dev/null; then
        print_warn "PostgreSQL 客户端未安装，请确保 PostgreSQL 服务器已安装"
    else
        print_info "PostgreSQL 客户端版本: $(psql --version)"
    fi

    # 检查 Redis
    if ! command -v redis-cli &> /dev/null; then
        print_warn "Redis 客户端未安装，请确保 Redis 服务器已安装"
    else
        print_info "Redis 客户端版本: $(redis-cli --version)"
    fi
}

# 安装后端依赖
install_backend() {
    print_info "安装后端依赖..."

    cd backend

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm install
    else
        npm install
    fi

    cd ..
    print_info "后端依赖安装完成"
}

# 安装前端依赖
install_frontend() {
    print_info "安装前端依赖..."

    cd frontend

    if [ "$PACKAGE_MANAGER" = "pnpm" ]; then
        pnpm install
    else
        npm install
    fi

    cd ..
    print_info "前端依赖安装完成"
}

# 配置环境变量
setup_env() {
    print_info "配置环境变量..."

    # 复制后端环境变量模板
    if [ ! -f backend/.env ]; then
        cp backend/.env.example backend/.env
        print_info "已创建 backend/.env，请根据实际情况修改配置"
    else
        print_info "backend/.env 已存在，跳过"
    fi

    # 复制前端环境变量模板
    if [ ! -f frontend/.env.h5 ]; then
        cp frontend/.env.h5.example frontend/.env.h5
        print_info "已创建 frontend/.env.h5，请根据实际情况修改配置"
    else
        print_info "frontend/.env.h5 已存在，跳过"
    fi
}

# 初始化数据库
init_database() {
    print_info "初始化数据库..."

    # 询问数据库连接信息
    read -p "数据库主机 (默认: localhost): " DB_HOST
    DB_HOST=${DB_HOST:-localhost}

    read -p "数据库端口 (默认: 5432): " DB_PORT
    DB_PORT=${DB_PORT:-5432}

    read -p "数据库名称 (默认: highschool): " DB_NAME
    DB_NAME=${DB_NAME:-highschool}

    read -p "数据库用户 (默认: postgres): " DB_USER
    DB_USER=${DB_USER:-postgres}

    read -sp "数据库密码: " DB_PASSWORD
    echo

    # 执行数据库迁移
    print_info "执行数据库迁移..."

    # 创建数据库（如果不存在）
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1 || \
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME"

    # 执行迁移文件
    for migration in db/migrations/*.sql; do
        print_info "执行迁移: $migration"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$migration"
    done

    # 导入种子数据
    print_info "导入种子数据..."
    for seed in db/seeds/*.sql; do
        print_info "执行种子数据: $seed"
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$seed"
    done

    print_info "数据库初始化完成"
}

# 构建项目
build_project() {
    print_info "构建项目..."

    # 构建后端
    print_info "构建后端..."
    cd backend
    $PACKAGE_MANAGER run build
    cd ..

    # 构建前端（H5）
    print_info "构建前端 H5..."
    cd frontend
    $PACKAGE_MANAGER run build:h5
    cd ..

    print_info "项目构建完成"
}

# 启动服务
start_services() {
    print_info "启动服务..."

    # 检查是否后台运行
    if [ "$1" = "--background" ]; then
        print_info "后台启动服务..."

        # 启动后端
        cd backend
        nohup $PACKAGE_MANAGER run start > ../logs/backend.log 2>&1 &
        BACKEND_PID=$!
        echo $BACKEND_PID > ../backend.pid
        cd ..

        print_info "后端服务已启动 (PID: $BACKEND_PID)"
        print_info "日志文件: logs/backend.log"
    else
        print_info "前台启动服务（开发模式）..."
        print_info "请在两个终端分别运行："
        print_info "  终端1: cd backend && $PACKAGE_MANAGER run dev"
        print_info "  终端2: cd frontend && $PACKAGE_MANAGER run dev:h5"
    fi
}

# 主函数
main() {
    print_info "开始初始化上海中考招生模拟系统..."
    echo

    # 检查依赖
    check_dependencies
    echo

    # 安装依赖
    install_backend
    install_frontend
    echo

    # 配置环境变量
    setup_env
    echo

    # 初始化数据库
    read -p "是否初始化数据库? (y/n): " INIT_DB
    if [ "$INIT_DB" = "y" ]; then
        init_database
        echo
    fi

    # 构建项目
    read -p "是否构建项目? (y/n): " BUILD_PROJECT
    if [ "$BUILD_PROJECT" = "y" ]; then
        build_project
        echo
    fi

    # 启动服务
    read -p "是否启动服务? (y/n): " START_SERVICES
    if [ "$START_SERVICES" = "y" ]; then
        read -p "后台启动? (y/n): " BACKGROUND
        if [ "$BACKGROUND" = "y" ]; then
            start_services --background
        else
            start_services
        fi
    fi

    echo
    print_info "初始化完成！"
    print_info "后端地址: http://localhost:3000"
    print_info "前端地址: http://localhost:5173"
    print_info "API文档: http://localhost:3000/docs"
}

# 创建日志目录
mkdir -p logs

# 运行主函数
main "$@"
