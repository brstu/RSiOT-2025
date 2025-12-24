from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

metrics = PrometheusMetrics(app, defaults_prefix='app32_')

@app.route('/')
def hello():
    return "Hello from app32!"

@app.route('/slow')
def slow():
    import time
    time.sleep(0.4)
    return "Slow response"

@app.route('/error')
def error():
    return "Internal Server Error", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)