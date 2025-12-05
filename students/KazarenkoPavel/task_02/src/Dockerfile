FROM python:3.11-alpine AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --user --no-cache-dir --no-warn-script-location -r requirements.txt

FROM python:3.11-alpine

RUN adduser -D -u 10001 webuser && \
    apk add --no-cache curl=8.8.0-r0

WORKDIR /app

COPY --from=builder --chown=webuser:webuser /root/.local /home/webuser/.local
COPY --chown=webuser:webuser . .

ENV PATH=/home/webuser/.local/bin:$PATH
ENV PORT=8091

USER webuser

EXPOSE 8091

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || exit 1

CMD ["python", "app.py"]

LABEL org.bstu.student.fullname="Kazarenko Pavel Vladimirovich" \
      org.bstu.student.id="220008" \
      org.bstu.group="as-63" \
      org.bstu.variant="05" \
      org.bstu.course="RSIOT"
