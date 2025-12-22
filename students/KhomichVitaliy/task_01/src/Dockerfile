FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/app


FROM alpine:3.20

RUN adduser -D -u 10001 appuser

WORKDIR /app
COPY --from=builder /app/server .

USER 10001

EXPOSE 7992

HEALTHCHECK --interval=5s --timeout=2s --retries=3 \
  CMD wget -qO- http://localhost:7992/ready || exit 1

CMD ["./server"]
