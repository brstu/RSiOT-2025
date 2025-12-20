from flask import Flask, Response, request
import random
import time
from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY

app = Flask(__name__)

REQUEST_COUNT = Counter(
    'app11_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'app11_http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint'],
    buckets=(0.1, 0.2, 0.5, 1.0, 2.0, 5.0)
)

ACTIVE_CONNECTIONS = Gauge(
    'app11_active_connections',
    'Number of active connections'
)

ERROR_COUNTER = Counter(
    'app11_http_5xx_errors_total',
    'Total 5xx errors'
)

@app.route('/')
def hello():
    start_time = time.time()
    ACTIVE_CONNECTIONS.inc()
    
    delay = random.uniform(0.05, 0.3)
    time.sleep(delay)
    
    if random.random() < 0.05:
        ERROR_COUNTER.inc()
        REQUEST_COUNT.labels(request.method, '/', '500').inc()
        REQUEST_DURATION.labels(request.method, '/').observe(time.time() - start_time)
        ACTIVE_CONNECTIONS.dec()
        return 'Internal Server Error', 500
    
    REQUEST_COUNT.labels(request.method, '/', '200').inc()
    REQUEST_DURATION.labels(request.method, '/').observe(time.time() - start_time)
    ACTIVE_CONNECTIONS.dec()
    
    return f'''
    <h1>App11 Monitoring Demo</h1>
    <p>Student: Куликович Иван Сергеевич</p>
    <p>Group: as-63, Variant: 11</p>
    <p>ID: 220015</p>
    <p>Metrics: <a href="/metrics">/metrics</a></p>
    <p>Health: <a href="/health">/health</a></p>
    '''

@app.route('/metrics')
def metrics():
    return Response(generate_latest(REGISTRY), mimetype='text/plain')

@app.route('/health')
def health():
    return {'status': 'healthy', 'service': 'app11'}

@app.route('/api/data')
def api_data():
    start_time = time.time()
    ACTIVE_CONNECTIONS.inc()
    
    delay = random.uniform(0.1, 0.4)
    time.sleep(delay)
    
    if random.random() < 0.03:
        ERROR_COUNTER.inc()
        REQUEST_COUNT.labels(request.method, '/api/data', '503').inc()
        REQUEST_DURATION.labels(request.method, '/api/data').observe(time.time() - start_time)
        ACTIVE_CONNECTIONS.dec()
        return {'error': 'Service Unavailable'}, 503
    
    REQUEST_COUNT.labels(request.method, '/api/data', '200').inc()
    REQUEST_DURATION.labels(request.method, '/api/data').observe(time.time() - start_time)
    ACTIVE_CONNECTIONS.dec()
    
    return {'data': [{'id': i, 'value': random.randint(1, 100)} for i in range(10)]}

@app.route('/slow')
def slow_endpoint():
    start_time = time.time()
    ACTIVE_CONNECTIONS.inc()
    
    delay = random.uniform(0.15, 0.35)
    time.sleep(delay)
    
    REQUEST_COUNT.labels(request.method, '/slow', '200').inc()
    REQUEST_DURATION.labels(request.method, '/slow').observe(time.time() - start_time)
    ACTIVE_CONNECTIONS.dec()
    
    return f'Slow response: {delay:.3f}s'

if __name__ == '__main__':
    import os
    print(f"Starting app11 with:")
    print(f"STU_ID: {os.environ.get('STU_ID', '220015')}")
    print(f"STU_GROUP: {os.environ.get('STU_GROUP', 'as-63')}")
    print(f"STU_VARIANT: {os.environ.get('STU_VARIANT', '11')}")
    print(f"METRICS_PREFIX: app11_")
    
    app.run(host='0.0.0.0', port=8080)