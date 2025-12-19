#!/usr/bin/env python3
"""
Простое Flask приложение с Prometheus метриками
Вариант 22: prefix=app22_, slo=99.0%, p95=250ms
"""

import os
import time
import random
from flask import Flask, Response
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY

app = Flask(__name__)

# Метрики с префиксом app22_
requests_counter = Counter(
    'app22_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'app22_http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint']
)

service_status = Gauge(
    'app22_service_status',
    'Service health status (1=healthy, 0=unhealthy)'
)

# Изначально сервис здоров
service_status.set(1)

# Логирование переменных окружения при старте
STU_ID = os.getenv('STU_ID', '220027')
STU_GROUP = os.getenv('STU_GROUP', 'АС-63')
STU_VARIANT = os.getenv('STU_VARIANT', '22')

print(f"[STARTUP] Student ID: {STU_ID}, Group: {STU_GROUP}, Variant: {STU_VARIANT}")


@app.route('/')
def index():
    """Main endpoint handler"""
    start = time.time()

    # Симуляция реальной обработки запроса
    delay = random.uniform(0.05, 0.3)
    time.sleep(delay)

    # Обработка редких ошибок
    if random.random() < 0.02:
        requests_counter.labels(method='GET', endpoint='/', status='500').inc()
        duration = time.time() - start
        request_duration.labels(method='GET', endpoint='/').observe(duration)
        return 'Internal Server Error', 500

    requests_counter.labels(method='GET', endpoint='/', status='200').inc()
    duration = time.time() - start
    request_duration.labels(method='GET', endpoint='/').observe(duration)

    return f'Hello from variant {STU_VARIANT}! Student: {STU_ID}'


@app.route('/health')
def health():
    """Health check endpoint"""
    requests_counter.labels(method='GET', endpoint='/health', status='200').inc()
    return {'status': 'healthy', 'variant': STU_VARIANT}


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(REGISTRY), mimetype='text/plain')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
