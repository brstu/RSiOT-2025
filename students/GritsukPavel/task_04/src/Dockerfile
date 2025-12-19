FROM python:3.11-slim

# Метаданные студента
LABEL org.bstu.student.fullname="Грицук Павел Эдуардович"
LABEL org.bstu.student.id="220007"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="4"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="momo-kitsune"
LABEL org.bstu.student.slug="as63-220007-v04"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Переменные окружения для метаданных
ENV STU_ID=220007
ENV STU_GROUP=АС-63
ENV STU_VARIANT=4

EXPOSE 8080

CMD ["python", "app.py"]
