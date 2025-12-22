"""
Простое Flask приложение с метриками Prometheus
Вариант 1: prefix=app01_, SLO=99.0%, p95≤300ms, Alert: 5xx>2% за 10м
"""

from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random
import os

app = Flask(__name__)

# Префикс метрик согласно варианту 1
METRICS_PREFIX = "app01_"

# Метрики Prometheus
http_requests_total = Counter(
    f'{METRICS_PREFIX}http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    f'{METRICS_PREFIX}http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint'],
    buckets=(
        0.05, 0.1, 0.15, 0.2, 0.25,
        0.3, 0.35, 0.4, 0.5, 0.75, 1.0, 2.5
    )
)

# Метаданные студента
STUDENT_ID = os.getenv('STUDENT_ID', '220028')
STUDENT_GROUP = os.getenv('STUDENT_GROUP', 'АС-63')
VARIANT = os.getenv('VARIANT', '1')


@app.before_request
def before_request():
    request.start_time = time.time()


@app.after_request
def after_request(response):
    if hasattr(request, 'start_time'):
        latency = time.time() - request.start_time

        http_request_duration_seconds.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown'
        ).observe(latency)

        http_requests_total.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown',
            status=response.status_code
        ).inc()

    return response


@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'student_id': STUDENT_ID,
        'group': STUDENT_GROUP,
        'variant': VARIANT
    })


@app.route('/api/data')
def get_data():
    """Нормальный endpoint (latency < 300ms)"""
    delay = random.uniform(0.05, 0.25)
    time.sleep(delay)

    return jsonify({
        'message': 'Success',
        'delay_ms': round(delay * 1000, 2),
        'variant': VARIANT
    })


@app.route('/api/slow')
def slow_endpoint():
    """Медленный endpoint для демонстрации превышения p95 > 300ms"""
    delay = random.uniform(0.35, 0.6)
    time.sleep(delay)

    return jsonify({
        'message': 'Slow response',
        'delay_ms': round(delay * 1000, 2)
    })


@app.route('/api/error')
def error_endpoint():
    """Endpoint для генерации ошибок 5xx"""
    if random.random() < 0.5:
        return jsonify({'error': 'Internal Server Error'}), 500
    return jsonify({'message': 'Success'})


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


@app.route('/')
def index():
    """Root endpoint"""
    return jsonify({
        'app': 'Monitoring Demo',
        'student_id': STUDENT_ID,
        'group': STUDENT_GROUP,
        'variant': VARIANT,
        'metrics_prefix': METRICS_PREFIX,
        'slo': {
            'availability': '99.0%',
            'p95_latency': '≤300ms',
            'error_rate': '5xx > 2% (10m)'
        },
        'endpoints': {
            'health': '/health',
            'data': '/api/data',
            'slow': '/api/slow',
            'error': '/api/error',
            'metrics': '/metrics'
        }
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
