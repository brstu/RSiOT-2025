# Простой Dockerfile БЕЗ multi-stage (нарушение требований)
FROM python:3.11

LABEL org.bstu.student.fullname="Филипчук Дмитрий Васильевич"
LABEL org.bstu.student.id="220027"
LABEL org.bstu.group="АС-63"
LABEL org.bstu.variant="22"
LABEL org.bstu.course="RSiOT"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Запуск от root (нарушение best practices)
CMD ["python", "app.py"]
