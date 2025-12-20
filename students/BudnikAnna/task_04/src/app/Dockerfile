# -------- builder --------
FROM golang:1.22-alpine AS builder
WORKDIR /src

RUN apk add --no-cache ca-certificates tzdata

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o /out/web03 ./main.go

# -------- runtime --------
FROM alpine:3.20
WORKDIR /app

RUN apk add --no-cache ca-certificates busybox-extras \
  && addgroup -S app && adduser -S -G app -u 65532 app

ENV PORT=8083
EXPOSE 8083

COPY --from=builder /out/web03 /app/web03

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8083/live >/dev/null 2>&1 || exit 1

USER 65532:65532
ENTRYPOINT ["/app/web03"]
