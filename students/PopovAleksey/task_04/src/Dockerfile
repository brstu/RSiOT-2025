FROM python:3.11-slim

# Метаданные студента
LABEL org.bstu.student.fullname="Попов Алексей Сергеевич"
LABEL org.bstu.student.id="220051"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="38"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="LexusxdsD"
LABEL org.bstu.student.slug="as64-220051-v38"

WORKDIR /app

# Копирование зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY app.py .

# Переменные окружения для метаданных
ENV STU_ID=220051
ENV STU_GROUP=АС-64
ENV STU_VARIANT=38

EXPOSE 8080

# Запуск приложения
CMD ["python", "app.py"]
