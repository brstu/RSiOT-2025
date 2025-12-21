FROM golang:1.20-alpine AS build
WORKDIR /src

# Copy the application sources into the build context
COPY src/ .

# Build a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/main .

FROM alpine:3.18
RUN addgroup -S app && adduser -S -G app app
COPY --from=build /app/main /app/main
RUN chown app:app /app/main
USER app
EXPOSE 8080
ENTRYPOINT ["/app/main"]
