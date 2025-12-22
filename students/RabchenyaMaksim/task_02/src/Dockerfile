# syntax=docker/dockerfile:1

FROM golang:1.25-alpine AS build
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app

FROM gcr.io/distroless/base-debian12
WORKDIR /app

# Required UID for variant #39
USER 65532:65532

COPY --from=build /app/app /app/app

EXPOSE 8003

# Исправленный HEALTHCHECK — убрали || exit 1, т.к. в distroless нет shell,
# а Docker сам считает контейнер unhealthy при non-zero exit code
HEALTHCHECK --interval=30s --timeout=3s \
  CMD ["/app/app", "-healthcheck"]

ENTRYPOINT ["/app/app"]