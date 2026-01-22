FROM python:3.12-slim AS builder
WORKDIR /build
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

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

CMD ["python", "app.py"]
