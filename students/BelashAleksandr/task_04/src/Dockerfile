FROM python:3.11-slim

# Метаданные студента
LABEL org.bstu.student.fullname="Белаш Александр Олегович"
LABEL org.bstu.student.id="220031"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="25"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="went2smoke"
LABEL org.bstu.student.slug="as64-220031-v25"

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/app.py .

ENV STU_ID=220031
ENV STU_GROUP=АС-64
ENV STU_VARIANT=25

EXPOSE 8080

CMD ["python", "app.py"]
