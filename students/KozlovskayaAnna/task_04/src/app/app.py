"""
Мониторинговое приложение с метриками Prometheus
Вариант 8: prefix=app08_, slo=99.5%, p95=350ms
Студент: Козловская Анна Геннадьевна, АС-63, 220012
"""

import os
import time
import random
import logging
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Создание Flask приложения
app = Flask(__name__)

# Получение метаданных из переменных окружения
STU_ID = os.getenv('STU_ID', '220012')
STU_GROUP = os.getenv('STU_GROUP', 'АС-63')
STU_VARIANT = os.getenv('STU_VARIANT', '8')
STU_FULLNAME = os.getenv('STU_FULLNAME', 'Козловская Анна Геннадьевна')

# Логирование метаданных при старте
logger.info("=== Application Starting ===")
logger.info("Student ID: %s", STU_ID)
logger.info("Group: %s", STU_GROUP)
logger.info("Variant: %s", STU_VARIANT)
logger.info("Full Name: %s", STU_FULLNAME)
logger.info("Metrics Prefix: app08_")
logger.info("============================")

# Определение метрик с префиксом app08_
# Счётчик HTTP запросов
http_requests_total = Counter(
    'app08_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

# Гистограмма задержек HTTP запросов
http_request_duration_seconds = Histogram(
    'app08_http_request_duration_seconds',
    'HTTP request latency in seconds',
    ['method', 'endpoint'],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.35, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0)
)

# Gauge для текущих активных запросов
http_requests_in_progress = Gauge(
    'app08_http_requests_in_progress',
    'HTTP requests in progress',
    ['method', 'endpoint']
)

# Счётчик ошибок 5xx
http_errors_5xx_total = Counter(
    'app08_http_errors_5xx_total',
    'Total 5xx errors',
    ['method', 'endpoint']
)

# Счётчик ошибок 4xx
http_errors_4xx_total = Counter(
    'app08_http_errors_4xx_total',
    'Total 4xx errors',
    ['method', 'endpoint']
)

# Gauge для health status (0 = unhealthy, 1 = healthy)
app_health_status = Gauge(
    'app08_health_status',
    'Application health status (1=healthy, 0=unhealthy)'
)

# Gauge для версии приложения
app_info = Gauge(
    'app08_app_info',
    'Application info',
    ['version', 'student_id', 'group', 'variant']
)

# Устанавливаем информацию о приложении
app_info.labels(version='1.0.0', student_id=STU_ID, group=STU_GROUP, variant=STU_VARIANT).set(1)

# Изначально приложение здорово
app_health_status.set(1)


# Middleware для автоматического сбора метрик
@app.before_request
def before_request():
    """Отмечаем начало обработки запроса"""
    request.start_time = time.time()

    endpoint = request.endpoint or 'unknown'
    http_requests_in_progress.labels(
        method=request.method,
        endpoint=endpoint
    ).inc()


@app.after_request
def after_request(response):
    """Собираем метрики после обработки запроса"""
    if hasattr(request, 'start_time'):
        request_latency = time.time() - request.start_time
        endpoint = request.endpoint or 'unknown'

        # Записываем задержку
        http_request_duration_seconds.labels(
            method=request.method,
            endpoint=endpoint
        ).observe(request_latency)

        # Увеличиваем счётчик запросов
        http_requests_total.labels(
            method=request.method,
            endpoint=endpoint,
            status=response.status_code
        ).inc()

        # Считаем ошибки
        if 500 <= response.status_code < 600:
            http_errors_5xx_total.labels(
                method=request.method,
                endpoint=endpoint
            ).inc()
        elif 400 <= response.status_code < 500:
            http_errors_4xx_total.labels(
                method=request.method,
                endpoint=endpoint
            ).inc()

        # Уменьшаем счётчик активных запросов
        http_requests_in_progress.labels(
            method=request.method,
            endpoint=endpoint
        ).dec()

    return response


@app.route('/')
def index():
    """Главная страница"""
    return jsonify({
        'service': 'monitoring-app',
        'variant': STU_VARIANT,
        'student': STU_FULLNAME,
        'group': STU_GROUP,
        'student_id': STU_ID,
        'endpoints': {
            '/': 'Main page',
            '/health': 'Health check',
            '/ready': 'Readiness check',
            '/metrics': 'Prometheus metrics',
            '/api/data': 'Sample data endpoint',
            '/api/slow': 'Slow endpoint (for testing latency)',
            '/api/error': 'Error endpoint (for testing 5xx alerts)'
        }
    })


@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'}), 200


@app.route('/ready')
def ready():
    """Readiness check endpoint"""
    return jsonify({'status': 'ready'}), 200


@app.route('/api/data')
def api_data():
    """Пример API endpoint с данными"""
    # Имитация небольшой задержки
    time.sleep(random.uniform(0.01, 0.05))

    return jsonify({
        'message': 'Sample data',
        'timestamp': time.time(),
        'student_id': STU_ID
    }), 200


@app.route('/api/slow')
def api_slow():
    """Медленный endpoint для тестирования latency алертов"""
    # Имитация медленного запроса (иногда превышаем p95=350ms)
    delay = random.uniform(0.1, 0.6)
    time.sleep(delay)

    return jsonify({
        'message': 'Slow response',
        'delay': delay
    }), 200


@app.route('/api/error')
def api_error():
    """Endpoint, возвращающий ошибку 5xx для тестирования алертов"""
    # 30% вероятность ошибки
    if random.random() < 0.3:
        return jsonify({'error': 'Internal server error'}), 500
    return jsonify({'message': 'Success'}), 200


@app.route('/api/toggle-health', methods=['POST'])
def toggle_health():
    """Переключение health status для тестирования"""
    # pylint: disable=protected-access
    current = app_health_status._value._value
    new_status = 0 if current == 1 else 1
    app_health_status.set(new_status)

    return jsonify({
        'health_status': 'healthy' if new_status == 1 else 'unhealthy'
    }), 200


# Подключаем Prometheus metrics endpoint
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})


if __name__ == '__main__':
    port = int(os.getenv('PORT', '8080'))
    logger.info("Starting application on port %s", port)
    app.run(host='0.0.0.0', port=port)
