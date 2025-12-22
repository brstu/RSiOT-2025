"""Flask application with Prometheus metrics endpoint."""
import os

from flask import Flask, Response
import prometheus_client
from prometheus_client import Counter, Histogram

app = Flask(__name__)

# Метрики с префиксом app9_
REQUEST_COUNT = Counter(
    'app9_requests_total',
    'Total requests',
    ['method', 'endpoint']
)

REQUEST_LATENCY = Histogram(
    'app9_request_duration_seconds',
    'Request latency'
)


@app.route('/')
def hello():
    """Root endpoint."""
    REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
    return "Hello from app9!"


@app.route('/health')
def health():
    """Health check endpoint."""
    return {"status": "ok"}


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint."""
    return Response(
        prometheus_client.generate_latest(),
        mimetype='text/plain'
    )


if __name__ == '__main__':
    # Логирование метаданных
    print(f"STU_ID: {os.getenv('STU_ID', '220042')}")
    print(f"STU_GROUP: {os.getenv('STU_GROUP', 'АС-64')}")
    print(f"STU_VARIANT: {os.getenv('STU_VARIANT', '9')}")

    app.run(host='0.0.0.0', port=8080)
