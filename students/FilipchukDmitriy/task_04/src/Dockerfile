FROM python:3.11-slim

# Метаданные студента
LABEL org.bstu.student.fullname="Филипчук Дмитрий Васильевич"
LABEL org.bstu.student.id="220027"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="22"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="kuddel11"
LABEL org.bstu.student.slug="as63-220027-v22"

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/main.py .

# Переменные окружения
ENV STU_ID=220027
ENV STU_GROUP=АС-63
ENV STU_VARIANT=22

EXPOSE 8080

CMD ["python", "main.py"]
