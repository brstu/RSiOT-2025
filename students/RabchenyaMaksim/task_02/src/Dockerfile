# syntax=docker/dockerfile:1

FROM golang:1.25-alpine AS build
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app

# Используем фиксированный тег :nonroot вместо :latest
# Это решает DL3007 и DL3006, а также автоматически устанавливает non-root user
FROM gcr.io/distroless/base-debian12:nonroot

WORKDIR /app

# UID 65532 уже установлен по умолчанию в :nonroot,
# но оставляем для совместимости с требованиями задания (variant #39)
USER 65532:65532

COPY --from=build /app/app /app/app

EXPOSE 8003

HEALTHCHECK --interval=30s --timeout=3s \
  CMD ["/app/app", "-healthcheck"]

ENTRYPOINT ["/app/app"]
