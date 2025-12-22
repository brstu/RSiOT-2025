# syntax=docker/dockerfile:1

FROM golang:1.25-alpine AS build
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app

# Явно указываем версию (рекомендуемый стабильный тег на декабрь 2025)
FROM gcr.io/distroless/base-debian12:latest

WORKDIR /app

# Required UID for variant #39
USER 65532:65532

COPY --from=build /app/app /app/app

EXPOSE 8003

HEALTHCHECK --interval=30s --timeout=3s \
  CMD ["/app/app", "-healthcheck"]

ENTRYPOINT ["/app/app"]