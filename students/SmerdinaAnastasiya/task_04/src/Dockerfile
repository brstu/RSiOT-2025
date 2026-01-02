FROM python:3.11-slim

LABEL org.bstu.student.fullname="Смердина Анастасия Валентиновна"
LABEL org.bstu.student.id="220053"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="41"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="KotyaLapka"
LABEL org.bstu.student.slug="as64-220053-v41"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV STU_ID=220053
ENV STU_GROUP=АС-64
ENV STU_VARIANT=41

EXPOSE 8080

CMD ["python", "app.py"]