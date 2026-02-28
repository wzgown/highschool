.PHONY: build run dev clean test

# 构建
build:
	go build -o bin/api cmd/api/main.go

# 运行
run:
	go run cmd/api/main.go

# 开发模式（热重载，需要安装 air）
dev:
	air -c .air.toml

# 测试
test:
	go test -v ./...

# 清理
clean:
	rm -rf bin/

# 安装依赖
deps:
	go mod download

# 格式化代码
fmt:
	go fmt ./...

# 代码检查
lint:
	golangci-lint run

# 数据库迁移（需要安装 goose）
migrate-up:
	goose -dir migrations postgres "host=localhost port=5432 user=highschool password=HS2025!db#SecurePass88 dbname=highschool sslmode=disable" up

migrate-down:
	goose -dir migrations postgres "host=localhost port=5432 user=highschool password=HS2025!db#SecurePass88 dbname=highschool sslmode=disable" down

.DEFAULT_GOAL := run
