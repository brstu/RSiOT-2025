from flask import Flask, jsonify, request
import random
import time
import os
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY

app = Flask(__name__)

# Метаданные из переменных окружения
STU_ID = os.getenv('STU_ID', 'unknown')
STU_GROUP = os.getenv('STU_GROUP', 'unknown')
STU_VARIANT = os.getenv('STU_VARIANT', '16')

# Метрики с префиксом по варианту (memes_gallery_*)
REQUEST_COUNT = Counter(
    'memes_gallery_http_requests_total',
    'Total HTTP requests to memes gallery',
    ['method', 'endpoint', 'status']
)
REQUEST_LATENCY = Histogram(
    'memes_gallery_http_request_duration_seconds',
    'HTTP request latency in seconds',
    ['method', 'endpoint'],
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0]
)
ACTIVE_USERS = Gauge(
    'memes_gallery_active_users',
    'Number of active users in memes gallery'
)

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    latency = time.time() - request.start_time
    REQUEST_LATENCY.labels(request.method, request.path).observe(latency)
    REQUEST_COUNT.labels(request.method, request.path, response.status_code).inc()
    return response

@app.route('/')
def home():
    ACTIVE_USERS.inc()
    return jsonify({
        'app': 'Memes Gallery API',
        'version': '1.0',
        'student': {
            'id': STU_ID,
            'group': STU_GROUP,
            'variant': STU_VARIANT
        }
    })

@app.route('/memes')
def get_memes():
    memes = [
        'https://example.com/meme1.jpg',
        'https://example.com/meme2.png',
        'https://example.com/meme3.gif'
    ]
    return jsonify({
        'memes': memes,
        'count': len(memes)
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/error')
def trigger_error():
    """Эндпоинт для тестирования ошибок 5xx"""
    return jsonify({'error': 'Internal Server Error'}), 500

@app.route('/metrics')
def metrics():
    return generate_latest(REGISTRY), 200, {'Content-Type': 'text/plain'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)