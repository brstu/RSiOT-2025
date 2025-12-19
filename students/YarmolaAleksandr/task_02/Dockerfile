# Multi-stage build для минимизации размера образа

# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /build

# Копируем go.mod и go.sum (если есть)
COPY src/go.mod ./
# COPY src/go.sum ./

# Загружаем зависимости
RUN go mod download

# Копируем исходный код
COPY src/ ./

# Собираем статический бинарник
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /build/server main.go

# Stage 2: Final minimal image
FROM alpine:3.19

# Создаем non-root пользователя
RUN addgroup -g 1001 appuser && \
    adduser -D -u 1001 -G appuser appuser

WORKDIR /app

# Копируем бинарник из builder stage
COPY --from=builder --chown=appuser:appuser /build/server /app/server

# Устанавливаем переменные окружения по умолчанию
ENV APP_PORT=8043 \
    STU_ID="" \
    STU_GROUP="" \
    STU_VARIANT=""

# Открываем порт приложения
EXPOSE 8043

# Переключаемся на non-root пользователя
USER appuser

# Healthcheck для Docker
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8043/live || exit 1

# Запускаем приложение
CMD ["/app/server"]
