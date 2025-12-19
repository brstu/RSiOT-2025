"""
Простое Flask приложение с Prometheus метриками
Вариант 35: prefix=app35_
"""
import time
import random

from flask import Flask, Response
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    generate_latest,
    REGISTRY
)

app = Flask(__name__)

# Метрики с префиксом app35_
request_counter = Counter(
    'app35_requests_total',
    'Total requests',
    ['method', 'endpoint', 'status']
)
request_duration = Histogram(
    'app35_request_duration_seconds',
    'Request duration'
)
active_connections = Gauge('app35_active_connections', 'Active connections')


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(REGISTRY), mimetype='text/plain')


@app.route('/')
def index():
    """Главная страница"""
    start = time.time()
    active_connections.inc()

    # Симуляция работы
    time.sleep(random.uniform(0.01, 0.1))

    active_connections.dec()
    duration = time.time() - start
    request_duration.observe(duration)
    request_counter.labels(method='GET', endpoint='/', status='200').inc()

    return 'Hello from app35!'


@app.route('/health')
def health():
    """Health check endpoint"""
    return {'status': 'ok'}


@app.route('/error')
def error():
    """Endpoint для тестирования ошибок"""
    request_counter.labels(
        method='GET',
        endpoint='/error',
        status='500'
    ).inc()
    return 'Internal Server Error', 500


if __name__ == '__main__':
    # Логирование метаданных при старте
    print("="*50)
    print("Application Starting...")
    print("STU_ID: 220044")
    print("STU_GROUP: АС-64")
    print("STU_VARIANT: 35")
    print("="*50)

    app.run(host='0.0.0.0', port=8080)
