FROM python:3.12-slim AS builder

WORKDIR /build
COPY app/requirements.txt .
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

FROM python:3.12-slim

LABEL org.bstu.student.fullname="Брызгалов Юрий Николаевич" \
      org.bstu.student.id="220032" \
      org.bstu.group="AS-64" \
      org.bstu.variant="02" \
      org.bstu.course="RSIOT"

RUN useradd -u 10001 appuser
WORKDIR /app

COPY --from=builder /install /usr/local
COPY app /app

USER 10001

EXPOSE 8082

ENV PYTHONUNBUFFERED=1

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8082/healthz || exit 1

CMD ["python", "app.py"]
