# syntax=docker/dockerfile:1.7

FROM golang:1.22-alpine AS builder

WORKDIR /src

COPY go.mod ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY cmd ./cmd

RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /out/server ./cmd/server

FROM alpine:3.20

# USER uid=65532
RUN addgroup -S app && adduser -S -D -H -u 65532 -G app app

WORKDIR /app
COPY --from=builder /out/server /app/server

ENV PORT=8083
EXPOSE 8083

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
  CMD wget -qO- "http://127.0.0.1:${PORT}/ready" >/dev/null 2>&1 || exit 1

USER 65532

ENTRYPOINT ["/app/server"]
