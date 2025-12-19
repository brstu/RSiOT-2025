# Multi-stage Dockerfile для мониторингового приложения
# Студент: Козловская Анна Геннадьевна, АС-63, 220012
# Вариант 8

# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /app

# Копируем requirements и устанавливаем зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

# Метаданные студента (labels)
LABEL org.bstu.student.fullname="Козловская Анна Геннадьевна" \
      org.bstu.student.id="220012" \
      org.bstu.group="АС-63" \
      org.bstu.variant="8" \
      org.bstu.course="RSIOT" \
      org.bstu.owner="annkrq" \
      org.bstu.student.slug="as63-220012-v8" \
      org.opencontainers.image.title="Monitoring App Variant 8" \
      org.opencontainers.image.description="Flask application with Prometheus metrics for lab 04" \
      org.opencontainers.image.authors="Козловская Анна Геннадьевна <AS006309@g.bstu.by>" \
      org.opencontainers.image.version="1.0.0"

WORKDIR /app

# Копируем установленные пакеты из builder stage
COPY --from=builder /root/.local /root/.local

# Копируем код приложения
COPY app.py .

# Создаём non-root пользователя
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Переключаемся на non-root пользователя
USER appuser

# Добавляем .local/bin в PATH
ENV PATH=/root/.local/bin:$PATH

# Переменные окружения
ENV STU_ID=220012 \
    STU_GROUP=АС-63 \
    STU_VARIANT=8 \
    STU_FULLNAME="Козловская Анна Геннадьевна" \
    PORT=8080

# Expose порт
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Запуск приложения через gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
