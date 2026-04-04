.PHONY: build run dev clean test deps fmt lint docker-build docker-up docker-down docker-logs

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

# 构建
build:
	$(GOBUILD) -o $(BINARY) ./$(CMD_DIR)

# 运行
run:
	$(GOCMD) run ./$(CMD_DIR)

# 开发模式（热重载，需要安装 air）
dev:
	air -c .air.toml

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

# Docker 构建
docker-build:
	docker compose build

# Docker 启动
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

# 数据库迁移（需要安装 goose）
migrate-up:
	goose -dir migrations postgres "host=localhost port=5432 user=highschool password=HS2025!db#SecurePass88 dbname=highschool sslmode=disable" up

migrate-down:
	goose -dir migrations postgres "host=localhost port=5432 user=highschool password=HS2025!db#SecurePass88 dbname=highschool sslmode=disable" down

# 创建迁移文件
migrate-create:
	@read -p "Enter migration name: " name; \
	goose -dir migrations create $$name sql

# 生成代码（如果有 protoc/gRPC）
generate:
	$(GOCMD) generate ./...

# 默认目标
.DEFAULT_GOAL := run
