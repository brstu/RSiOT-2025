# syntax=docker/dockerfile:1
FROM python:3.12-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential=12.9 \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip \
 && pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/install/lib/python3.12/site-packages \
    PATH=/install/bin:$PATH

RUN apt-get update \
 && apt-get install -y --no-install-recommends curl=7.88.1-10+deb12u10 \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 10001 appuser \
 && useradd -r -u 10001 -g appuser appuser

COPY --from=builder /install /install

COPY app ./app

LABEL org.bstu.student.fullname="Выржемковский Даниил Иванович" \
      org.bstu.student.id="220005" \
      org.bstu.group="АС-63" \
      org.bstu.variant="2" \
      org.bstu.course="RSIOT"

EXPOSE 8082
ENV APP_PORT=8082

USER 10001:10001

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost:8082/healthz || exit 1

CMD ["python", "-m", "app.main"]