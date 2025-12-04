# НЕ multi-stage build (теряем баллы)
# Запуск от root (теряем баллы)
FROM python:3.11

LABEL org.bstu.student.fullname="Бурак Илья Эдуардович"
LABEL org.bstu.student.id="220035"
LABEL org.bstu.group="АС-64"
LABEL org.bstu.variant="29"
LABEL org.bstu.course="RSiOT"

WORKDIR /app

COPY app.py .

EXPOSE 8021

CMD ["python", "app.py"]
