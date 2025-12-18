FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ .

ENV STU_ID=your_student_id
ENV STU_GROUP=your_group
ENV STU_VARIANT=17
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus
ENV METRICS_PREFIX=app17_

RUN mkdir -p /tmp/prometheus

EXPOSE 8000
EXPOSE 9090

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--worker-class", "gthread", "--threads", "2", "--access-logfile", "-", "app:app"]