FROM python:3.11-slim

WORKDIR /app

# Метаданные студента
LABEL org.bstu.student.fullname="Соколова Маргарита Александровна"
LABEL org.bstu.student.id="220024"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="19"
LABEL org.bstu.course="RSIOT"
LABEL org.bstu.owner="soko1ova"

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY app.py .

# ENV переменные
ENV STUDENT_ID=220024 \
    STUDENT_GROUP=АС-63 \
    VARIANT=19 \
    PORT=8080

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

CMD ["python", "app.py"]
