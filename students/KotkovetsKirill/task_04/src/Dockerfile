FROM python:3.11-slim

# Метаданные студента
LABEL org.bstu.student.fullname="Котковец Кирилл Викторович"
LABEL org.bstu.student.id="220044"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="35"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="Kirill-Kotkovets"
LABEL org.bstu.student.slug="as64-220044-v35"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Environment variables для метаданных
ENV STU_ID=220044
ENV STU_GROUP=АС-64
ENV STU_VARIANT=35

EXPOSE 8080

CMD ["python", "app.py"]
