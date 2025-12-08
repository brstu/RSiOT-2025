# Простой односложный образ
FROM python:3.11-slim

LABEL org.bstu.student.fullname="Кульбеда Кирилл Александрович"
LABEL org.bstu.student.id="220016"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="12"
LABEL org.bstu.course="RSiOT"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8074

ENV STU_ID=220016
ENV STU_GROUP=АС-63
ENV STU_VARIANT=12

# Запуск от root
CMD ["python", "app.py"]
