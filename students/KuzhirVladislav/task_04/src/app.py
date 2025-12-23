import os
import signal
import sys
import time
from threading import Event, Thread
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY

app = Flask(__name__)
shutdown_event = Event()

# Переменные окружения
STU_ID = os.getenv('STU_ID', 'unknown')
STU_GROUP = os.getenv('STU_GROUP', 'unknown')
STU_VARIANT = os.getenv('STU_VARIANT', 'unknown')

# Prometheus метрики с префиксом app36_
REQUESTS_TOTAL = Counter(
    'app36_http_requests_total',
    'Total number of HTTP requests',
    ['method', 'status']
)

REQUEST_DURATION = Histogram(
    'app36_http_request_duration_seconds',
    'HTTP request latency',
    ['method'],
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0]  # кастомные buckets, можно оставить DefBuckets
)

ACTIVE_CONNECTIONS = Gauge(
    'app36_active_connections',
    'Number of currently active connections'
)

# Middleware для измерения метрик
def prometheus_middleware(wsgi_app):
    def wrapped_app(environ, start_response):
        method = environ.get('REQUEST_METHOD', 'UNKNOWN')
        start_time = time.time()

        # Увеличиваем active_connections
        ACTIVE_CONNECTIONS.inc()

        def custom_start_response(status, headers):
            duration = time.time() - start_time
            status_code = status.split()[0]

            # Записываем метрики
            REQUESTS_TOTAL.labels(method=method, status=status_code).inc()
            REQUEST_DURATION.labels(method=method).observe(duration)

            # Уменьшаем active_connections
            ACTIVE_CONNECTIONS.dec()

            return start_response(status, headers)

        return wsgi_app(environ, custom_start_response)
    return wrapped_app

# Применяем middleware
app.wsgi_app = prometheus_middleware(app.wsgi_app)

# Endpoint для Prometheus-метрик
@app.route('/metrics')
def metrics():
    return generate_latest(REGISTRY), 200, {'Content-Type': 'text/plain; version=0.0.4'}

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from Flask!',
        'student_id': STU_ID,
        'group': STU_GROUP,
        'variant': STU_VARIANT
    })

@app.route('/health')
def healthz():
    return jsonify({'status': 'ok'}), 200

def handle_sigterm(signum, frame):
    print('Received SIGTERM, shutting down gracefully...')
    shutdown_event.set()

signal.signal(signal.SIGTERM, handle_sigterm)

if __name__ == '__main__':
    print(f"Starting Flask app | STU_ID={STU_ID} | GROUP={STU_GROUP} | VARIANT={STU_VARIANT}")
    
    def run_app():
        app.run(host='0.0.0.0', port=8032)
    
    t = Thread(target=run_app)
    t.start()
    
    try:
        while not shutdown_event.is_set():
            shutdown_event.wait(1)
    except KeyboardInterrupt:
        print('Received KeyboardInterrupt, shutting down...')
    
    sys.exit(0)