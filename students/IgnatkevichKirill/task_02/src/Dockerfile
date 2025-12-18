# === Stage 1: Build ===
FROM golang:1.25-alpine AS builder

WORKDIR /src

# Кешируем зависимости
COPY go.mod go.sum ./
RUN go mod download

COPY src/server.go ./

# Максимально сжатый и «чистый» бинарник
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \
    -trimpath \
    -o /app/server .

# === Stage 2: Runtime ===
FROM alpine:3.20

# Фиксируем версии пакетов — убирает DL3018
# На момент декабря 2025 актуальные версии в alpine 3.20:
RUN apk add --no-cache \
    ca-certificates=20240705-r0 \
    tzdata=2024b-r0 \
    && adduser -D -u 10001 appuser

WORKDIR /app

# Копируем бинарник с правильным владельцем
COPY --from=builder --chown=appuser:appuser /app/server .

USER appuser

ENV PORT=8071 \
    STU_ID=220042 \
    STU_GROUP=as-64 \
    STU_VARIANT=09

EXPOSE 8071

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/healthz || exit 1

LABEL org.bstu.student.fullname="Ignatkevich Kirill Sergeevich" \
      org.bstu.student.id="220042" \
      org.bstu.group="as-64" \
      org.bstu.variant="09" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="pyrokekw" \
      org.bstu.student.slug="as-64-220042-v09"

CMD ["./server"]
