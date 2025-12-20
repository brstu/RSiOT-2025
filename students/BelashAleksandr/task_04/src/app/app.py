"""Flask application with Prometheus metrics."""
import logging
import os
import time

from flask import Flask, jsonify
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    generate_latest,
    REGISTRY
)

# Метаданные студента
STU_ID = os.getenv('STU_ID', '220031')
STU_GROUP = os.getenv('STU_GROUP', 'АС-64')
STU_VARIANT = os.getenv('STU_VARIANT', '25')

app = Flask(__name__)

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Логирование метаданных при старте
logger.info(
    "Starting application - Student ID: %s, Group: %s, Variant: %s",
    STU_ID,
    STU_GROUP,
    STU_VARIANT
)

# Метрики с префиксом app25_
request_counter = Counter(
    'app25_requests_total',
    'Total number of requests',
    ['method', 'endpoint']
)
request_duration = Histogram(
    'app25_request_duration_seconds',
    'Request duration in seconds'
)
app_status = Gauge('app25_status', 'Application status (1=up, 0=down)')

# Установка начального статуса
app_status.set(1)


@app.route('/')
def index():
    """Main endpoint."""
    start_time = time.time()
    request_counter.labels(method='GET', endpoint='/').inc()

    response = {
        'message': 'Hello from Lab 04!',
        'student_id': STU_ID,
        'group': STU_GROUP,
        'variant': STU_VARIANT
    }

    request_duration.observe(time.time() - start_time)
    return jsonify(response)


@app.route('/health')
def health():
    """Health check endpoint."""
    return jsonify({'status': 'healthy'})


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint."""
    return generate_latest(REGISTRY)


if __name__ == '__main__':
    logger.info("Application started successfully")
    app.run(host='0.0.0.0', port=8080)
