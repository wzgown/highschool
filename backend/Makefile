.PHONY: build run run-prod dev clean test deps fmt lint infra-check docker-build docker-up docker-down docker-logs

# 应用名称
APP_NAME := highschool-backend
BINARY := bin/api

# Go 相关
GOCMD := go
GOBUILD := $(GOCMD) build
GOTEST := $(GOCMD) test
GOFORMAT := $(GOCMD) fmt
GOMOD := $(GOCMD) mod

# 构建目录
CMD_DIR := cmd/api

# ============================================================
# 基础设施（postgres/redis 已迁移到 192.168.71.160，本机不再启动 docker）
# 默认数据库/缓存指向 160；可用环境变量覆盖，如：
#   HS_DATABASE_HOST=36.150.236.225 make run   # 临时连线上库
# ============================================================
INFRA_HOST ?= 192.168.71.160
export HS_DATABASE_HOST ?= $(INFRA_HOST)
export HS_REDIS_HOST ?= $(INFRA_HOST)

# 构建
build:
	$(GOBUILD) -o $(BINARY) ./$(CMD_DIR)

# 运行（直接启动进程，基础设施使用 160）
run:
	$(GOCMD) run ./$(CMD_DIR)

# 运行（显式连线上生产库 36.150.236.225，谨慎：写操作会影响线上）
run-prod:
	HS_DATABASE_HOST=36.150.236.225 $(GOCMD) run ./$(CMD_DIR)

# 开发模式（热重载，需要安装 air）
dev:
	air -c .air.toml

# 基础设施连通性检查（160 上的 postgres/redis）
infra-check:
	@pg_isready -h $(INFRA_HOST) -p 5432 -U highschool && echo "postgres@$(INFRA_HOST) OK"
	@(echo > /dev/tcp/$(INFRA_HOST)/6379) 2>/dev/null && echo "redis@$(INFRA_HOST) OK" || echo "redis@$(INFRA_HOST) FAIL"

# 测试
test:
	$(GOTEST) -v -race ./...

# 测试覆盖率
test-coverage:
	$(GOTEST) -v -race -coverprofile=coverage.out ./...
	$(GOCMD) tool cover -html=coverage.out -o coverage.html

# 清理
clean:
	rm -rf bin/
	rm -f coverage.out coverage.html

# 安装依赖
deps:
	$(GOMOD) download
	$(GOMOD) tidy

# 格式化代码
fmt:
	$(GOFORMAT) ./...

# 代码检查
lint:
	golangci-lint run --timeout 5m

# ============================================================
# Docker（遗留目标：仅当需要在本机重建完整栈时使用。
# 基础设施已迁移至 160，日常开发不需要本机 docker）
# ============================================================

# Docker 构建
docker-build:
	docker compose build

# Docker 启动（注意：会在本机重建 postgres/redis 容器）
docker-up:
	docker compose up -d

# Docker 停止
docker-down:
	docker compose down

# Docker 日志
docker-logs:
	docker compose logs -f backend

# Docker 重建并启动
docker-rebuild: docker-down docker-build docker-up

# 数据库迁移（需要安装 goose；默认指向 160）
migrate-up:
	goose -dir migrations postgres "host=$(INFRA_HOST) port=5432 user=highschool password=HS2025!db#SecurePass88 dbname=highschool sslmode=disable" up

migrate-down:
	goose -dir migrations postgres "host=$(INFRA_HOST) port=5432 user=highschool password=HS2025!db#SecurePass88 dbname=highschool sslmode=disable" down

# 创建迁移文件
migrate-create:
	@read -p "Enter migration name: " name; \
	goose -dir migrations create $$name sql

# 生成代码（如果有 protoc/gRPC）
generate:
	$(GOCMD) generate ./...

# 默认目标
.DEFAULT_GOAL := run
