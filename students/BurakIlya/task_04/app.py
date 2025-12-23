"""Flask application with Prometheus metrics for monitoring."""
# pylint: disable=duplicate-code
import os
import time

from flask import Flask, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# РњРµС‚СЂРёРєРё СЃ РїСЂРµС„РёРєСЃРѕРј СЃРѕРіР»Р°СЃРЅРѕ РІР°СЂРёР°РЅС‚Сѓ 29
REQUEST_COUNT = Counter('app29_requests_total', 'Total requests')
REQUEST_LATENCY = Histogram('app29_request_duration_seconds', 'Request latency')

# Р›РѕРіРёСЂРѕРІР°РЅРёРµ РјРµС‚Р°РґР°РЅРЅС‹С… РїСЂРё СЃС‚Р°СЂС‚Рµ
STU_ID = os.getenv('STU_ID', '220035')
STU_GROUP = os.getenv('STU_GROUP', 'РђРЎ-64')
STU_VARIANT = os.getenv('STU_VARIANT', '29')

print(f"Starting application - Student ID: {STU_ID}, Group: {STU_GROUP}, Variant: {STU_VARIANT}")


@app.route('/')
def hello():
    """Return hello message and record metrics."""
    start = time.time()
    REQUEST_COUNT.inc()
    result = f"Hello from variant {STU_VARIANT}!"
    REQUEST_LATENCY.observe(time.time() - start)
    return result


@app.route('/metrics')
def metrics():
    """Expose Prometheus metrics endpoint."""
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
