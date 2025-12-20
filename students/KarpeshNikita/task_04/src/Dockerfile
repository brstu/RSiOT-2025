FROM python:3.11-slim

LABEL org.bstu.student.fullname="Немирович Дмитрий Александрович"
LABEL org.bstu.student.id="220050"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="37"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="goryachiy-ugolek"
LABEL org.bstu.student.slug="as64-220050-v37"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV STU_ID=220050
ENV STU_GROUP=АС-64
ENV STU_VARIANT=37

EXPOSE 8080

CMD ["python", "app.py"]
