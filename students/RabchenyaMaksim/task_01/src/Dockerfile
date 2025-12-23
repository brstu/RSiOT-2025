# syntax=docker/dockerfile:1

FROM golang:1.25.5-alpine3.23 AS build
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app

FROM gcr.io/distroless/base-debian12:nonroot
WORKDIR /app

COPY --from=build /app/app /app/app

EXPOSE 8003

HEALTHCHECK --interval=30s --timeout=3s --retries=3 --start-period=5s \
  CMD ["/app/app", "-healthcheck"]

ENTRYPOINT ["/app/app"]
