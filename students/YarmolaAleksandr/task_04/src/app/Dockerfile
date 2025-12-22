FROM python:3.11-slim

WORKDIR /app

# Метаданные студента
LABEL org.bstu.student.fullname="Ярмола Александр Олегович"
LABEL org.bstu.student.id="220028"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="23"
LABEL org.bstu.course="RSIOT"
LABEL org.bstu.owner="alexsandro007"

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY app.py .

# ENV переменные
ENV STUDENT_ID=220028 \
    STUDENT_GROUP=АС-63 \
    VARIANT=23 \
    PORT=8080

EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"

CMD ["python", "app.py"]
