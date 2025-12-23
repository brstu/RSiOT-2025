from flask import Flask, request, Response
from prometheus_client import Counter, Histogram, generate_latest, CollectorRegistry, CONTENT_TYPE_LATEST
import random
import time

METRIC_PREFIX = "app34_"

REQUEST_COUNTER = Counter(METRIC_PREFIX + 'http_requests_total', 'Total HTTP requests', ['code', 'path'])
REQUEST_LATENCY = Histogram(METRIC_PREFIX + 'http_request_duration_seconds', 'Request latency seconds')

app = Flask(__name__)

@app.route('/')
def index():
    # allow forcing error via ?error=1
    err = request.args.get('error', '0') == '1'
    start = time.time()
    if err or random.random() < 0.05:  # small random chance of 5xx
        # simulate processing
        time.sleep(random.uniform(0.01, 0.12))
        REQUEST_COUNTER.labels(code='500', path='/').inc()
        REQUEST_LATENCY.observe(time.time() - start)
        return ("Internal Error", 500)
    else:
        time.sleep(random.uniform(0.005, 0.05))
        REQUEST_COUNTER.labels(code='200', path='/').inc()
        REQUEST_LATENCY.observe(time.time() - start)
        return ("OK", 200)

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
