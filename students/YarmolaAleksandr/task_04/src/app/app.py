"""
Простое Flask приложение с метриками Prometheus
Вариант 23: prefix=app23_, SLO=99.5%, p95≤200ms, Alert: 5xx>1% за 5м
"""
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random
import os

app = Flask(__name__)

# Префикс метрик согласно варианту 23
METRICS_PREFIX = "app23_"

# Метрики с префиксом app23_
http_requests_total = Counter(
    f'{METRICS_PREFIX}http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    f'{METRICS_PREFIX}http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint'],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3, 0.5, 1.0, 2.5, 5.0)
)

# Метаданные студента
STUDENT_ID = os.getenv('STUDENT_ID', '220028')
STUDENT_GROUP = os.getenv('STUDENT_GROUP', 'АС-63')
VARIANT = os.getenv('VARIANT', '23')


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
    """Endpoint с искусственной задержкой для демонстрации latency"""
    # Случайная задержка 10-250ms
    delay = random.uniform(0.01, 0.25)
    time.sleep(delay)
    
    return jsonify({
        'message': 'Success',
        'delay_ms': round(delay * 1000, 2),
        'variant': VARIANT
    })


@app.route('/api/slow')
def slow_endpoint():
    """Медленный endpoint для демонстрации превышения p95 threshold"""
    # Задержка 200-400ms (превышает SLO 200ms)
    delay = random.uniform(0.2, 0.4)
    time.sleep(delay)
    
    return jsonify({
        'message': 'Slow response',
        'delay_ms': round(delay * 1000, 2)
    })


@app.route('/api/error')
def error_endpoint():
    """Endpoint для генерации ошибок 5xx"""
    # 50% вероятность ошибки 500
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
            'availability': '99.5%',
            'p95_latency': '≤200ms',
            'error_rate': '5xx>1% triggers alert'
        },
        'endpoints': {
            'health': '/health',
            'data': '/api/data',
            'slow': '/api/slow (для демо превышения latency)',
            'error': '/api/error (для демо 5xx ошибок)',
            'metrics': '/metrics'
        }
    })


if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
