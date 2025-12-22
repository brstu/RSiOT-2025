FROM python:3.11-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-alpine
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY app.py .

ENV STU_ID="220020" \
    STU_GROUP="AS-63" \
    STU_VARIANT="16" \
    FLASK_APP="app.py"

EXPOSE 5000

# Используем gunicorn для продакшн-сервера
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]