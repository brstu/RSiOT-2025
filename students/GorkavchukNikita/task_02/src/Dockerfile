# syntax=docker/dockerfile:1
#########################
# Stage 1: build
#########################
FROM golang:1.25-alpine AS build
WORKDIR /app

# Кэш зависимостей
COPY go.mod go.sum ./
RUN go mod download

# Копируем исходники и собираем
COPY . .
RUN go build -o server ./src

#########################
# Stage 2: runtime
#########################
FROM alpine:3.20

# Добавляем curl для healthcheck
RUN apk add --no-cache curl=8.2.1-r0

WORKDIR /app
USER 10001:10001

COPY --from=build /app/server .

EXPOSE 8044

LABEL org.bstu.student.fullname="Gorkavchuk Nikita Mikhailovich" \
      org.bstu.student.id="220038" \
      org.bstu.group="feis" \
      org.bstu.variant="v6" \
      org.bstu.course="RSIOT"

ENV STU_ID=220038 \
    STU_GROUP=feis \
    STU_VARIANT=v6 \
    PORT=8044

# Рабочий healthcheck
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8044/healthz || exit 1

ENTRYPOINT ["/app/server"]
