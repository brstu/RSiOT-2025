# НЕ multi-stage, образ будет большой
FROM python:3.11

# Запуск от root (не безопасно, но проще)
WORKDIR /app

COPY app/server.py .

ENV PORT=8001

# Нет EXPOSE - забыли добавить

CMD ["python", "server.py"]
