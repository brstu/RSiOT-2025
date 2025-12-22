#!/usr/bin/env python3
"""
Минимальное приложение с метриками для мониторинга
Вариант 38: prefix=app38_, slo=99.5%, p95=250ms
"""

import os
import random
import time

from flask import Flask, Response

app = Flask(__name__)

# Хранилище метрик в памяти
metrics_storage = {
    'requests_total': 0,
    'requests_success': 0,
    'requests_error': 0,
    'response_times': []
}


@app.route('/')
def home():
    """Главная страница"""
    start = time.time()

    # Симуляция работы
    time.sleep(random.uniform(0.05, 0.15))

    metrics_storage['requests_total'] += 1
    metrics_storage['requests_success'] += 1

    duration = time.time() - start
    metrics_storage['response_times'].append(duration)

    # Логирование метаданных студента
    student_id = os.getenv('STU_ID', '220051')
    student_group = os.getenv('STU_GROUP', 'АС-64')
    student_variant = os.getenv('STU_VARIANT', '38')

    return f"""
    <h1>Monitoring App v38</h1>
    <p>Student ID: {student_id}</p>
    <p>Group: {student_group}</p>
    <p>Variant: {student_variant}</p>
    <p>Total Requests: {metrics_storage['requests_total']}</p>
    """


@app.route('/error')
def error():
    """Эндпоинт для генерации ошибок"""
    metrics_storage['requests_total'] += 1
    metrics_storage['requests_error'] += 1
    return "Error", 500


@app.route('/metrics')
def metrics():
    """
    Экспорт метрик в формате Prometheus
    """
    output = []

    # Префикс из варианта
    prefix = "app38_"

    # Базовые метрики
    output.append(f"# HELP {prefix}http_requests_total Total HTTP requests")
    output.append(f"# TYPE {prefix}http_requests_total counter")
    output.append(f"{prefix}http_requests_total {metrics_storage['requests_total']}")

    output.append(f"# HELP {prefix}http_requests_success Successful requests")
    output.append(f"# TYPE {prefix}http_requests_success counter")
    output.append(f"{prefix}http_requests_success {metrics_storage['requests_success']}")

    output.append(f"# HELP {prefix}http_requests_errors Error requests")
    output.append(f"# TYPE {prefix}http_requests_errors counter")
    output.append(f"{prefix}http_requests_errors {metrics_storage['requests_error']}")

    # Метрика задержки
    if metrics_storage['response_times']:
        avg_time = sum(metrics_storage['response_times']) / len(metrics_storage['response_times'])
        output.append(f"# HELP {prefix}response_time_seconds Average response time")
        output.append(f"# TYPE {prefix}response_time_seconds gauge")
        output.append(f"{prefix}response_time_seconds {avg_time:.3f}")

    return Response('\n'.join(output), mimetype='text/plain')


@app.route('/health')
def health():
    """Health check endpoint"""
    return "OK", 200


if __name__ == '__main__':
    # Логирование метаданных при старте
    print(f"Starting app with STU_ID={os.getenv('STU_ID', '220051')}")
    print(f"STU_GROUP={os.getenv('STU_GROUP', 'АС-64')}")
    print(f"STU_VARIANT={os.getenv('STU_VARIANT', '38')}")

    app.run(host='0.0.0.0', port=8080, debug=False)
