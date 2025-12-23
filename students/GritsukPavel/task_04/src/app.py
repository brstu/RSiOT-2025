"""Flask application with Prometheus metrics endpoint."""
import os
import logging
from typing import Dict

from flask import Flask, Response

app = Flask(__name__)

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Логирование метаданных студента при старте
STU_ID = os.getenv('STU_ID', '220007')
STU_GROUP = os.getenv('STU_GROUP', 'АС-63')
STU_VARIANT = os.getenv('STU_VARIANT', '4')

logger.info(
    "Starting application - Student ID: %s, Group: %s, Variant: %s",
    STU_ID, STU_GROUP, STU_VARIANT
)

# Счетчики для метрик
metrics_storage: Dict[str, int] = {
    'requests': 0,
    'errors': 0
}


@app.route('/')
def home():
    """Home endpoint."""
    metrics_storage['requests'] += 1
    return f"Hello from variant {STU_VARIANT}! Student: {STU_GROUP}-{STU_ID}"


@app.route('/health')
def health():
    """Health check endpoint."""
    return {'status': 'ok'}


@app.route('/metrics')
def metrics():
    """Endpoint метрик в формате Prometheus."""
    # Базовые метрики в формате Prometheus
    metrics_data = f"""# HELP app04_requests_total Total number of requests
# TYPE app04_requests_total counter
app04_requests_total {metrics_storage['requests']}

# HELP app04_errors_total Total number of errors
# TYPE app04_errors_total counter
app04_errors_total {metrics_storage['errors']}

# HELP app04_up Service availability
# TYPE app04_up gauge
app04_up 1
"""
    return Response(metrics_data, mimetype='text/plain')


if __name__ == '__main__':
    logger.info("Application started successfully")
    app.run(host='0.0.0.0', port=8080)
