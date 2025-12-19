"""
Flask приложение для демонстрации метрик Prometheus
Вариант 12: prefix=app12_, slo=99.9%, p95=350ms
"""

import logging
import os
import time

from flask import Flask, Response
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    generate_latest,
    REGISTRY
)

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Метаданные студента из переменных окружения
STU_ID = os.getenv('STU_ID', '220016')
STU_GROUP = os.getenv('STU_GROUP', 'АС-63')
STU_VARIANT = os.getenv('STU_VARIANT', '12')

# Логирование метаданных при старте
logger.info("Starting application with metadata:")
logger.info("  STU_ID: %s", STU_ID)
logger.info("  STU_GROUP: %s", STU_GROUP)
logger.info("  STU_VARIANT: %s", STU_VARIANT)

# Метрики с префиксом app12_ согласно варианту
# Счетчик запросов
request_counter = Counter(
    'app12_requests_total',
    'Total number of requests',
    ['method', 'endpoint']
)

# Гистограмма задержек (для p95/p99)
request_duration = Histogram(
    'app12_request_duration_seconds',
    'Request duration in seconds',
    ['endpoint']
)

# Gauge для статусов
active_requests = Gauge(
    'app12_active_requests',
    'Number of active requests'
)


@app.route('/')
def index():
    """Главная страница"""
    request_counter.labels(method='GET', endpoint='/').inc()
    with request_duration.labels(endpoint='/').time():
        active_requests.inc()
        time.sleep(0.01)  # Имитация работы
        active_requests.dec()
        return {
            "message": "Application is running",
            "variant": STU_VARIANT,
            "student_id": STU_ID,
            "group": STU_GROUP
        }


@app.route('/health')
def health():
    """Health check endpoint"""
    request_counter.labels(method='GET', endpoint='/health').inc()
    return {"status": "healthy"}


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(REGISTRY), mimetype='text/plain')


if __name__ == '__main__':
    port = int(os.getenv('PORT', '8080'))
    logger.info("Starting Flask app on port %s", port)
    app.run(host='0.0.0.0', port=port)
