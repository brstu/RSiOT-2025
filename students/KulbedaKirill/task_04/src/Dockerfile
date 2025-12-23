# Простой Dockerfile для приложения с метриками
FROM python:3.11-slim

# Метаданные студента согласно заданию
LABEL org.bstu.student.fullname="Кульбеда Кирилл Александрович"
LABEL org.bstu.student.id="220016"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="12"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="fr0ogi"
LABEL org.bstu.student.slug="as63-220016-v12"

WORKDIR /app

# Копирование зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY app.py .

# Переменные окружения
ENV STU_ID=220016
ENV STU_GROUP=АС-63
ENV STU_VARIANT=12
ENV PORT=8080

EXPOSE 8080

# Запуск приложения
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
