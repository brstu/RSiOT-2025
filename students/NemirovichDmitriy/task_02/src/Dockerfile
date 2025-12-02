# Стадия 1: базовый образ
FROM python:3.11-slim as base

WORKDIR /app

# Стадия 2: финальный образ
FROM python:3.11-slim

# Метаданные студента
LABEL org.bstu.student.fullname="Немирович Дмитрий Александрович"
LABEL org.bstu.student.id="220050"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="37"
LABEL org.bstu.course="RSiOT"

# Создание непривилегированного пользователя
RUN useradd -m -u 1000 appuser

WORKDIR /app

# Копирование приложения
COPY src/app.py .
COPY src/requirements.txt .

# Установка зависимостей (если есть)
RUN pip install --no-cache-dir -r requirements.txt

# Переключение на непривилегированного пользователя
USER appuser

# Открытие порта
EXPOSE 8001

# Переменные окружения
ENV STU_ID=220050
ENV STU_GROUP=АС-64
ENV STU_VARIANT=37
ENV PORT=8001

# Запуск приложения
CMD ["python", "app.py"]
