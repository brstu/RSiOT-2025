import os
import time
import random
import logging
from flask import Flask, request, jsonify
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST
import metrics

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Вывод метаданных при запуске
logger.info(f"Starting app with:")
logger.info(f"  STU_ID: {os.getenv('STU_ID', 'not_set')}")
logger.info(f"  STU_GROUP: {os.getenv('STU_GROUP', 'not_set')}")
logger.info(f"  STU_VARIANT: {os.getenv('STU_VARIANT', 'not_set')}")
logger.info(f"  METRICS_PREFIX: {os.getenv('METRICS_PREFIX', 'app17_')}")

@app.route('/')
def hello():
    metrics.REQUEST_COUNTER.labels(method='GET', endpoint='/', status='200').inc()
    
    # Имитация задержки
    delay = random.uniform(0.05, 0.5)
    time.sleep(delay)
    
    # Измерение времени выполнения
    start_time = time.time()
    response = {
        'message': 'Hello from app17!',
        'student_id': os.getenv('STU_ID'),
        'group': os.getenv('STU_GROUP'),
        'variant': os.getenv('STU_VARIANT')
    }
    duration = time.time() - start_time
    
    # Запись в гистограмму
    metrics.REQUEST_DURATION.labels(method='GET', endpoint='/').observe(duration + delay)
    
    return jsonify(response)

@app.route('/health')
def health():
    metrics.REQUEST_COUNTER.labels(method='GET', endpoint='/health', status='200').inc()
    return jsonify({'status': 'healthy'}), 200

@app.route('/api/data')
def get_data():
    # Случайно генерируем статус ответа
    status = '200'
    if random.random() < 0.03:  # 3% шанс на ошибку
        status = '500'
        metrics.REQUEST_COUNTER.labels(method='GET', endpoint='/api/data', status='500').inc()
        metrics.ERROR_GAUGE.inc()
        return jsonify({'error': 'Internal Server Error'}), 500
    
    metrics.REQUEST_COUNTER.labels(method='GET', endpoint='/api/data', status='200').inc()
    
    delay = random.uniform(0.1, 1.0)
    time.sleep(delay)
    
    start_time = time.time()
    data = [{'id': i, 'value': random.randint(1, 100)} for i in range(10)]
    duration = time.time() - start_time
    
    metrics.REQUEST_DURATION.labels(method='GET', endpoint='/api/data').observe(duration + delay)
    
    return jsonify({'data': data})

@app.route('/metrics')
def metrics_endpoint():
    metrics.REQUEST_COUNTER.labels(method='GET', endpoint='/metrics', status='200').inc()
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/slow')
def slow_endpoint():
    # Эндпоинт с большой задержкой для тестирования p95 алерта
    delay = random.uniform(0.3, 1.5)
    time.sleep(delay)
    
    metrics.REQUEST_COUNTER.labels(method='GET', endpoint='/slow', status='200').inc()
    metrics.REQUEST_DURATION.labels(method='GET', endpoint='/slow').observe(delay)
    
    return jsonify({'message': 'Slow response', 'delay': delay})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)