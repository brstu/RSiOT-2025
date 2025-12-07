import os
import time
import signal
import sys
from flask import Flask, jsonify, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import redis
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Метаданные студента
STU_ID = os.getenv('STU_ID', '220008')
STU_GROUP = os.getenv('STU_GROUP', 'as-63')
STU_VARIANT = os.getenv('STU_VARIANT', '05')

# Prometheus метрики с префиксом app05_
REQUEST_COUNT = Counter(
  'app05_http_requests_total',
  'Total HTTP requests',
  ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
  'app05_http_request_duration_seconds',
  'HTTP request latency in seconds',
  ['method', 'endpoint'],
  buckets=[0.1, 0.2, 0.3, 0.5, 1.0, 2.0, 5.0]
)

ERROR_COUNT = Counter(
  'app05_http_errors_total',
  'Total HTTP errors (4xx, 5xx)',
  ['method', 'endpoint', 'status']
)

# Redis клиент
redis_client = redis.Redis(
  host=os.getenv('REDIS_HOST', 'redis'),
  port=int(os.getenv('REDIS_PORT', 6379)),
  decode_responses=True
)


@app.before_request
def before_request():
  request.start_time = time.time()


@app.after_request
def after_request(response):
  # Рассчитываем latency
  latency = time.time() - request.start_time

  # Метрики
  endpoint = request.endpoint or 'unknown'
  REQUEST_COUNT.labels(
    method=request.method,
    endpoint=endpoint,
    status=response.status_code
  ).inc()

  REQUEST_LATENCY.labels(
    method=request.method,
    endpoint=endpoint
  ).observe(latency)

  # Счетчик ошибок
  if 400 <= response.status_code < 600:
    ERROR_COUNT.labels(
      method=request.method,
      endpoint=endpoint,
      status=response.status_code
    ).inc()

  return response


@app.route('/')
def hello():
  return jsonify({
    'message': 'Hello from Flask with Metrics!',
    'student': STU_ID,
    'variant': STU_VARIANT
  })


@app.route('/health')
def health():
  try:
    redis_client.ping()
    return jsonify({
      'status': 'healthy',
      'redis': 'connected'
    }), 200
  except Exception as e:
    return jsonify({
      'status': 'unhealthy',
      'error': str(e)
    }), 503


@app.route('/metrics')
def metrics():
  return Response(
    generate_latest(),
    mimetype=CONTENT_TYPE_LATEST
  )


@app.route('/slow')
def slow_endpoint():
  """Эндпоинт для тестирования latency"""
  time.sleep(float(request.args.get('delay', 0.5)))
  return jsonify({'message': 'Slow response', 'delay': request.args.get('delay', '0.5')})


@app.route('/error')
def error_endpoint():
  """Эндпоинт для тестирования ошибок"""
  status = int(request.args.get('code', 500))
  return jsonify({'error': 'Test error'}), status


if __name__ == '__main__':
  logger.info(f"Starting Flask app with metrics (Student: {STU_ID}, Variant: {STU_VARIANT})")
  app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)), debug=False)
