# Multi-stage build for app14-monitoring
# Student: Логинов Глеб Олегович (AS-63-220018-v14)

# Stage 1: Base image with dependencies
FROM python:3.11-slim AS base

# Install security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Builder
FROM base AS builder

WORKDIR /build

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 3: Final runtime image
FROM base AS runtime

# Add metadata labels (as per variant 14 requirements)
LABEL org.bstu.student.fullname="Логинов Глеб Олегович"
LABEL org.bstu.student.id="220018"
LABEL org.bstu.group="AS-63"
LABEL org.bstu.variant="14"
LABEL org.bstu.course="RSIOT"
LABEL org.bstu.owner="gleb7499"
LABEL org.bstu.student.slug="AS-63-220018-v14"
LABEL version="1.0.0"
LABEL description="Monitoring application with Prometheus metrics for Lab 04"

# Create non-root user for security
RUN useradd -m -u 1000 appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# Copy application code
COPY --chown=appuser:appuser main.py .

# Switch to non-root user
USER appuser

# Update PATH for user-installed packages
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

# Environment variables for student metadata
ENV STU_ID="220018"
ENV STU_GROUP="AS-63"
ENV STU_VARIANT="14"

# Expose application port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Run with gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "4", "--timeout", "30", "--access-logfile", "-", "--error-logfile", "-", "main:app"]
