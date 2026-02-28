#!/bin/bash

###############################################################################
# 上海中考招生模拟系统 - 部署脚本
###############################################################################

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 配置
REMOTE_HOST=${DEPLOY_HOST:-""}
REMOTE_USER=${DEPLOY_USER:-"root"}
REMOTE_PATH=${DEPLOY_PATH:-"/var/www/highschool"}
BRANCH=${DEPLOY_BRANCH:-"main"}

# 检查配置
check_config() {
    if [ -z "$REMOTE_HOST" ]; then
        print_error "请设置 DEPLOY_HOST 环境变量"
        print_info "示例: export DEPLOY_HOST=your-server.com"
        exit 1
    fi

    print_info "部署配置:"
    print_info "  主机: $REMOTE_HOST"
    print_info "  用户: $REMOTE_USER"
    print_info "  路径: $REMOTE_PATH"
    print_info "  分支: $BRANCH"
}

# 构建项目
build_project() {
    print_info "构建项目..."

    # 安装依赖
    print_info "安装依赖..."
    npm ci

    # 构建后端
    print_info "构建后端..."
    cd backend
    npm ci
    npm run build
    cd ..

    # 构建前端
    print_info "构建前端 H5..."
    cd frontend
    npm ci
    npm run build:h5
    cd ..

    print_info "构建完成"
}

# 部署到服务器
deploy_to_server() {
    print_info "部署到服务器..."

    # 创建远程目录结构
    ssh "$REMOTE_USER@$REMOTE_HOST" "mkdir -p $REMOTE_PATH/{backend,frontend,logs}"

    # 上传后端文件
    print_info "上传后端文件..."
    rsync -avz --delete \
        backend/dist/ \
        backend/node_modules/ \
        backend/package.json \
        "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/backend/"

    # 上传前端文件
    print_info "上传前端文件..."
    rsync -avz --delete \
        frontend/dist/build/ \
        "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/frontend/"

    # 上传环境变量模板
    scp backend/.env.example "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH/backend/.env"

    # 重启服务
    print_info "重启服务..."
    ssh "$REMOTE_USER@$REMOTE_HOST" << 'ENDSSH'
cd /var/www/highschool

# 停止旧服务
if [ -f backend.pid ]; then
    kill $(cat backend.pid) 2>/dev/null || true
    rm backend.pid
fi

# 启动新服务
cd backend
nohup node dist/main.js > ../logs/backend.log 2>&1 &
echo $! > ../backend.pid

# 等待服务启动
sleep 5

# 检查服务状态
if curl -f http://localhost:3000/api/v1/health > /dev/null 2>&1; then
    echo "Backend service started successfully"
else
    echo "Backend service failed to start"
    exit 1
fi

# 重启 Nginx
systemctl reload nginx
ENDSSH

    print_info "部署完成"
}

# 回滚部署
rollback() {
    print_info "回滚部署..."

    ssh "$REMOTE_USER@$REMOTE_HOST" << 'ENDSSH'
cd /var/www/highschool

# 停止当前服务
if [ -f backend.pid ]; then
    kill $(cat backend.pid) 2>/dev/null || true
fi

# 恢复备份
if [ -d backup ]; then
    cp -r backup/backend/* backend/
    cp -r backup/frontend/* frontend/
fi

# 重启服务
cd backend
nohup node dist/main.js > ../logs/backend.log 2>&1 &
echo $! > ../backend.pid

systemctl reload nginx
ENDSSH

    print_info "回滚完成"
}

# 创建备份
create_backup() {
    print_info "创建备份..."

    ssh "$REMOTE_USER@$REMOTE_HOST" << 'ENDSSH'
cd /var/www/highschool

# 删除旧备份
rm -rf backup

# 创建新备份
mkdir -p backup
cp -r backend/* backup/backend/ 2>/dev/null || true
cp -r frontend/* backup/frontend/ 2>/dev/null || true
ENDSSH

    print_info "备份完成"
}

# 主函数
main() {
    print_info "开始部署..."
    echo

    check_config
    echo

    # 询问操作类型
    read -p "选择操作: (1)部署 (2)回滚 (3)备份: " CHOICE

    case $CHOICE in
        1)
            # 创建备份
            create_backup
            echo

            # 构建项目
            build_project
            echo

            # 部署到服务器
            deploy_to_server
            ;;
        2)
            rollback
            ;;
        3)
            create_backup
            ;;
        *)
            print_error "无效选择"
            exit 1
            ;;
    esac

    echo
    print_info "操作完成！"
    print_info "访问地址: http://$REMOTE_HOST"
}

# 运行主函数
main "$@"
