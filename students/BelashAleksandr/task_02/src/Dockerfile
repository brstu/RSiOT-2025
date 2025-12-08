# Простой Dockerfile без multi-stage
FROM python:3.11-slim

# Labels для метаданных
LABEL org.bstu.student.fullname="Белаш Александр Олегович"
LABEL org.bstu.student.id="220031"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="25"
LABEL org.bstu.course="RSiOT"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8031

# Запуск от root
CMD ["python", "app.py"]
