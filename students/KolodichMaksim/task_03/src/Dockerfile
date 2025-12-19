# === Stage 1: Build ===
FROM golang:1.25-alpine AS builder

WORKDIR /src

# Кешируем зависимости
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходный код
COPY src/server.go ./

# Сборка максимально лёгкого и «чистого» бинарника
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build \
      -ldflags="-s -w -extldflags=-static" \
      -trimpath \
      -o /app/server \
      .

# === Stage 2: Runtime (минимальный и безопасный образ) ===
FROM alpine:3.20 AS runtime

# Устанавливаем точные версии пакетов (убираем DL3018)
# На момент декабря 2025 актуальные версии в alpine 3.20:
RUN apk add --no-cache \
      ca-certificates=20241121-r0 \
      tzdata=2024b-r0 \
    && adduser -D -u 10001 appuser

WORKDIR /app

# Копируем бинарник с правильным владельцем
COPY --from=builder --chown=appuser:appuser /app/server .

USER appuser

# Переменные окружения
ENV PORT=8071 \
    STU_ID=220013 \
    STU_GROUP=as-63 \
    STU_VARIANT=09

EXPOSE 8071

# Healthcheck
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/healthz || exit 1

# Метки (оставляем как есть — они нужны для задания)
LABEL org.bstu.student.fullname="Kolodich Maksim Pavlovich" \
      org.bstu.student.id="220013" \
      org.bstu.group="as-63" \
      org.bstu.variant="09" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="proxladno" \
      org.bstu.student.slug="as-63-220013-v09"

CMD ["./server"]
