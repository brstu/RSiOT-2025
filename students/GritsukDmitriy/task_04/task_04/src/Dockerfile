FROM python:3.11-slim

WORKDIR /app

# Копируем зависимости и устанавливаем их
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем исходный код
COPY app/ .

# Создаем пользователя
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser:appuser /app

USER appuser

# Открываем порты
EXPOSE 8083 9090

# Команда запуска (важно: python без цифры 3)
CMD ["python", "app.py"]