# Лабораторная работа №02 - Kubernetes базовый деплой
# Студент: Козловская Анна Геннадьевна
# Группа: АС-63, StudentID: 220012, Вариант: 8

# === Stage 1: Build ===
FROM golang:1.21-alpine AS builder

# Метаданные
LABEL org.bstu.student.fullname="Козловская Анна Геннадьевна" \
      org.bstu.student.id="220012" \
      org.bstu.group="АС-63" \
      org.bstu.variant="8" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="annkrq" \
      org.bstu.student.slug="as63-220012-v8" \
      org.bstu.app.name="web08" \
      org.bstu.app.namespace="app08"

WORKDIR /build

# Копируем файлы для сборки
COPY go.mod go.sum* ./
RUN go mod download || true

COPY main.go ./

# Собираем статический бинарник
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -a -installsuffix cgo \
    -ldflags="-w -s" \
    -o app .

# === Stage 2: Runtime ===
FROM alpine:3.19

# Метаданные для финального образа
LABEL org.bstu.student.fullname="Козловская Анна Геннадьевна" \
      org.bstu.student.id="220012" \
      org.bstu.group="АС-63" \
      org.bstu.variant="8" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="annkrq" \
      org.bstu.student.slug="as63-220012-v8" \
      org.bstu.app.name="web08" \
      org.bstu.app.namespace="app08" \
      maintainer="AS006309@g.bstu.by"

# Устанавливаем CA сертификаты
RUN apk --no-cache add ca-certificates=20240705-r0 tzdata=2024a-r0 && \
    rm -rf /var/cache/apk/*

# Создаем непривилегированного пользователя
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

WORKDIR /app

# Копируем бинарник из builder stage
COPY --from=builder --chown=appuser:appuser /build/app .

# Переключаемся на непривилегированного пользователя
USER appuser

# Открываем порт
EXPOSE 8094

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8094/health || exit 1

# Запуск приложения
ENTRYPOINT ["./app"]
