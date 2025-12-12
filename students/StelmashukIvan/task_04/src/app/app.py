from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

# Правильный параметр: defaults_prefix (с подчёркиванием в конце для стандартного вида метрик)
metrics = PrometheusMetrics(app, defaults_prefix='app20_')

# Опционально: добавить group_by для label endpoint (как в варианте)
# metrics = PrometheusMetrics(app, defaults_prefix='app20_', group_by='endpoint')

# Твои маршруты без изменений
@app.route('/')
def hello():
    return "Hello from app20!"

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