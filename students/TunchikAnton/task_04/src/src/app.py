from flask import Flask, Response, request, jsonify
import random
import time
import logging
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware
import os

app = Flask(__name__)

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Метрики с префиксом app21_
REQUEST_COUNT = Counter(
    'app21_requests_total',
    'Total number of HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_LATENCY = Histogram(
    'app21_request_duration_seconds',
    'HTTP request latency in seconds',
    ['method', 'endpoint'],
    buckets=[0.1, 0.2, 0.3, 0.5, 1.0, 2.0, 5.0]
)

ERROR_COUNT = Counter(
    'app21_errors_total',
    'Total number of HTTP 5xx errors',
    ['method', 'endpoint']
)

HEALTH_GAUGE = Gauge(
    'app21_health',
    'Application health status',
    ['version']
)

APP_INFO = Gauge(
    'app21_info',
    'Application information',
    ['version', 'environment']
)

# Инициализация метрик
HEALTH_GAUGE.labels(version='1.0.0').set(1)
APP_INFO.labels(version='1.0.0', environment='production').set(1)

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    # Измеряем латенси
    if hasattr(request, 'start_time'):
        latency = time.time() - request.start_time
    else:
        latency = 0
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status_code=response.status_code
    ).inc()
    
    REQUEST_LATENCY.labels(
        method=request.method,
        endpoint=request.path
    ).observe(latency)

    if 500 <= response.status_code < 600:
        ERROR_COUNT.labels(
            method=request.method,
            endpoint=request.path
        ).inc()
    
    # Логируем запрос
    logger.info(f"{request.method} {request.path} - {response.status_code} - {latency:.3f}s")
    
    return response

@app.route('/')
def index():
    if random.random() < 0.05:
        return "Internal Server Error", 500
    
    # Симулируем обработку
    time.sleep(random.uniform(0.1, 0.5))
    return """
    <h1>Monitoring App (Variant 21)</h1>
    <p>Metrics prefix: app21_</p>
    <p>SLO: 99.9% availability</p>
    <p>P95 latency: 300ms</p>
    <p>Alert: 5xx > 2% за 5 минут</p>
    <p><a href="/metrics">Metrics endpoint</a></p>
    <p><a href="/health">Health check</a></p>
    <p><a href="/api/data">API Data</a></p>
    """

# Метод для экспорта метрик через Prometheus client
@app.route('/metrics')
def metrics():
    return Response(generate_latest(REGISTRY), mimetype='text/plain')

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": time.time(),
        "version": "1.0.0",
        "metrics_prefix": "app21_"
    })

@app.route('/api/data')
def api_data():
    latency = random.uniform(0.05, 1.0)
    time.sleep(latency)
    
    if random.random() < 0.02:
        return jsonify({"error": "Internal server error"}), 500
    
    return jsonify({
        "data": [1, 2, 3, 4, 5],
        "timestamp": time.time(),
        "latency": round(latency, 3),
        "endpoint": "/api/data"
    })

@app.route('/api/slow')
def slow_endpoint():
    time.sleep(random.uniform(0.4, 0.8))
    return jsonify({"message": "Slow response", "delay": "400-800ms"})

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    logger.info(f"Starting application on port {port}")
    app.run(host='0.0.0.0', port=port, debug=False)