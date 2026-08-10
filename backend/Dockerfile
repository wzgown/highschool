# ---- admin 前端构建 ----
FROM node:20-alpine AS admin-build
WORKDIR /admin
COPY admin/package.json admin/package-lock.json ./
RUN npm ci
COPY admin/ ./
# 覆盖 vite.config 的 outDir，构建到独立目录供 go 阶段拷贝
RUN npm run type-check && npx vite build --outDir /admin/dist --emptyOutDir

# ---- Go 构建 ----
FROM golang:1.24-alpine AS builder
WORKDIR /app
RUN apk add --no-cache git ca-certificates tzdata
ENV GOPROXY=https://goproxy.cn,direct
ENV GOSUMDB=sum.golang.org
ENV GOTOOLCHAIN=auto
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/cmd ./cmd/
COPY backend/internal ./internal/
COPY backend/pkg ./pkg/
COPY backend/gen ./gen/
# 放入前端构建产物（admin_dist_embed.go 用 -tags admindist 内嵌）
COPY --from=admin-build /admin/dist ./internal/api/v1/admin_dist
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -tags admindist -ldflags="-w -s" -o /api ./cmd/api

# ---- 运行时 ----
FROM alpine:3.19
WORKDIR /app
RUN apk --no-cache add ca-certificates tzdata wget
COPY --from=builder /api /app/api
ENV TZ=Asia/Shanghai
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
CMD ["./api"]
