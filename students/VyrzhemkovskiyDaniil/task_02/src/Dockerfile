# Build stage
FROM python:3.11-alpine as builder

WORKDIR /app

# Установка curl для healthcheck (только в builder)
RUN apk add --no-cache curl

# Копирование зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Runtime stage
FROM python:3.11-alpine

WORKDIR /app

# Создание non-root пользователя
RUN addgroup -S appuser && adduser -S appuser -G appuser \
    && chown -R appuser:appuser /app

# Копирование зависимостей из builder
COPY --from=builder /root/.local /home/appuser/.local
# Копирование curl из builder
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --chown=appuser:appuser src/ /app/

# Установка переменных окружения
ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Переключаемся на non-root пользователя
USER appuser

# Экспорт порта
EXPOSE 8082

# Health check (теперь curl доступен)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8082/health || exit 1

# Команда запуска
CMD ["python", "app.py"]