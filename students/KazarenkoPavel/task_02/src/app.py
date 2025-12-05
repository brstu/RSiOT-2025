import os
import signal
import sys
import time
from flask import Flask, jsonify
import redis
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Метаданные студента для логирования
STU_ID = os.getenv('STU_ID', '220008')
STU_GROUP = os.getenv('STU_GROUP', 'as-63')
STU_VARIANT = os.getenv('STU_VARIANT', '05')

logger.info(f"=== Student: {STU_ID}, Group: {STU_GROUP}, Variant: {STU_VARIANT} ===")

# Конфигурация из ConfigMap/Secret
REDIS_HOST = os.getenv('REDIS_HOST', 'redis-service')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))
REDIS_PASSWORD = os.getenv('REDIS_PASSWORD', '')
APP_PORT = int(os.getenv('PORT', 8091))

# Redis клиент
redis_client = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    password=REDIS_PASSWORD if REDIS_PASSWORD else None,
    decode_responses=True
)

# Graceful shutdown
def shutdown_handler(signum, frame):
    logger.info(f"Received signal {signum}, initiating graceful shutdown...")
    sys.exit(0)

signal.signal(signal.SIGTERM, shutdown_handler)
signal.signal(signal.SIGINT, shutdown_handler)

@app.route('/')
def hello():
    return jsonify({
        'message': 'Hello from Flask in Kubernetes!',
        'status': 'success',
        'student': STU_ID,
        'variant': STU_VARIANT,
        'pod': os.getenv('HOSTNAME', 'unknown')
    })

@app.route('/health')
def health():
    try:
        redis_client.ping()
        return jsonify({
            'status': 'healthy',
            'redis': 'connected',
            'student': STU_ID,
            'pod': os.getenv('HOSTNAME', 'unknown'),
            'timestamp': time.time()
        }), 200
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return jsonify({
            'status': 'unhealthy',
            'redis': 'disconnected',
            'error': str(e)
        }), 503

@app.route('/visit')
def visit_count():
    try:
        key = f"stu:{STU_ID}:v{STU_VARIANT}:visit_count"
        count = redis_client.incr(key)
        return jsonify({
            'visit_count': count,
            'message': f'This is visit number {count}',
            'student': STU_ID,
            'pod': os.getenv('HOSTNAME', 'unknown')
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info(f"Starting Flask application on port {APP_PORT}...")
    app.run(host='0.0.0.0', port=APP_PORT, debug=False)
