# === Stage 1: Build ===
FROM golang:1.25-alpine AS builder

WORKDIR /src

# Кешируем зависимости отдельно — ускоряет пересборку
COPY go.mod go.sum ./
RUN go mod download

# Копируем только исходник
COPY src/server.go ./

# Убираем отладочную инфу и сжимаем бинарник максимально
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w -s" -trimpath -o /app/server .

# === Stage 2: Runtime (суперлёгкий) ===
FROM alpine:3.20

# Только нужные системные пакеты (ca-certificates для HTTPS, если будет)
RUN apk add --no-cache ca-certificates tzdata && \
    adduser -D -u 10001 appuser

WORKDIR /app
COPY --from=builder --chown=appuser:appuser /app/server .

USER appuser

# Переменные окружения (можно переопределить в Deployment)
ENV PORT=8071 \
    STU_ID=220013 \
    STU_GROUP=as-63 \
    STU_VARIANT=09

EXPOSE 8071

# Healthcheck по твоему /healthz (или /ready — как удобнее)
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/healthz || exit 1

LABEL org.bstu.student.fullname="Kolodich Maksim Pavlovich" \
      org.bstu.student.id="220013" \
      org.bstu.group="as-63" \
      org.bstu.variant="09" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="proxladno" \
      org.bstu.student.slug="as-63-220013-v09"

CMD ["./server"]