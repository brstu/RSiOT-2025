# Лабораторная работа №02 - Kubernetes базовый деплой
# Студент: Смердина Анастасия Валентиновна
# Группа: АС-64, StudentID: 220053, Вариант: 41

# === Stage 1: Build ===
FROM golang:1.21-alpine AS builder

# Метаданные
LABEL org.bstu.student.fullname="Смердина Анастасия Валентиновна" \
      org.bstu.student.id="220053" \
      org.bstu.group="АС-64" \
      org.bstu.variant="41" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="KotyaLapka" \
      org.bstu.student.slug="as64-220053-v41" \
      org.bstu.app.name="web41" \
      org.bstu.app.namespace="app41"

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
LABEL org.bstu.student.fullname="Смердина Анастасия Валентиновна" \
      org.bstu.student.id="220053" \
      org.bstu.group="АС-64" \
      org.bstu.variant="41" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="KotyaLapka" \
      org.bstu.student.slug="as64-220053-v41" \
      org.bstu.app.name="web41" \
      org.bstu.app.namespace="app41" \
      maintainer="AS006424@g.bstu.by"

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
EXPOSE 7991

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:7991/health || exit 1

# Запуск приложения
ENTRYPOINT ["./app"]