# Stage 1: build
FROM golang:1.21-alpine AS builder
WORKDIR /src
COPY go.mod ./
COPY main.go ./
RUN go build -o app main.go

# Stage 2: minimal runtime
FROM alpine:3.18
WORKDIR /app
COPY --from=builder /src/app /app/app

# Create non-root user
RUN adduser -D -u 10001 appuser
USER appuser

ENV APP_PORT=7992
EXPOSE 7992

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:7992/ready || exit 1

CMD ["./app"]
