FROM python:3.11-slim

LABEL org.bstu.student.fullname="Игнаткевич Кирилл Сергеевич"
LABEL org.bstu.student.id="220042"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="9"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="pyrokekw"
LABEL org.bstu.student.slug="as64-220042-v9"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV STU_ID=220042
ENV STU_GROUP=АС-64
ENV STU_VARIANT=9

EXPOSE 8080

CMD ["python", "app.py"]
