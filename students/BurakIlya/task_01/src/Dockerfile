# НЕ multi-stage сборка (намеренно для уменьшения баллов)
# Образ будет большим (>150MB)
FROM python:3.11

LABEL org.bstu.student.fullname="Бурак Илья Эдуардович"
LABEL org.bstu.student.id="220035"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="29"
LABEL org.bstu.course="RSiOT"

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

ENV STU_ID=220035
ENV STU_GROUP=AS-64
ENV STU_VARIANT=29
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379

EXPOSE 8021

# Запуск от root (намеренно НЕ меняем USER - антипаттерн)
CMD ["python", "app.py"]
