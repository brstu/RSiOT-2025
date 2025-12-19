FROM python:3.11-slim

LABEL org.bstu.student.fullname="Бурак Илья Эдуардович"
LABEL org.bstu.student.id="220035"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="29"
LABEL org.bstu.course="RSiOT"
LABEL org.bstu.owner="burakillya"
LABEL org.bstu.student.slug="as64-220035-v29"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

ENV STU_ID=220035
ENV STU_GROUP=АС-64
ENV STU_VARIANT=29

EXPOSE 8080

CMD ["python", "app.py"]
