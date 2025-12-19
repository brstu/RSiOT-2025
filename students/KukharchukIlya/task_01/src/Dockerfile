# Multi-stage build for Go HTTP server
# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /build

# Copy go mod files
COPY src/go.mod src/go.sum ./
RUN go mod download

# Copy source code
COPY src/server.go ./

# Build the application
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o server server.go

# Stage 2: Runtime
FROM alpine:latest

# Install ca-certificates, postgresql client libraries, and wget for healthcheck
RUN apk --no-cache add ca-certificates libc6-compat wget

WORKDIR /app

# Copy binary from builder
COPY --from=builder /build/server .

# Create non-root user with UID 10001
RUN addgroup -g 10001 appuser && \
    adduser -D -u 10001 -G appuser appuser

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port 8074
EXPOSE 8074

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8074/ready || exit 1

# Labels with student metadata
LABEL org.bstu.student.fullname="Кухарчук Илья Николаевич" \
      org.bstu.student.id="220017" \
      org.bstu.group="АС-63" \
      org.bstu.variant="13" \
      org.bstu.course="RSIOT"

# Run the server
CMD ["./server"]

