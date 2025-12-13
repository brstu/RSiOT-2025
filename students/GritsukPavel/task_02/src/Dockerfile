FROM python:3.11

WORKDIR /app

# Копируем файлы
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Добавляем метаданные (частично)
LABEL org.bstu.student.fullname="Грицук Павел Эдуардович"
LABEL org.bstu.student.id="220007"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="4"
LABEL org.bstu.course="RSiOT"

EXPOSE 8084
ENV STU_ID=220007
ENV STU_GROUP=АС-63
ENV STU_VARIANT=4

CMD ["python", "app.py"]
