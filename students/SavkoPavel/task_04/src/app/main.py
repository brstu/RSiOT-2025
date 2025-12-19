import os
import time
from flask import Flask, request, Response
from prometheus_client import Counter, Histogram, Gauge, generate_latest

STU_ID = os.getenv("STU_ID", "unknown")
STU_GROUP = os.getenv("STU_GROUP", "unknown")
STU_VARIANT = os.getenv("STU_VARIANT", "unknown")

print(f"StudentID={STU_ID}, Group={STU_GROUP}, Variant={STU_VARIANT}")

app = Flask(__name__)

REQUESTS = Counter(
    "app18_http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"]
)

LATENCY = Histogram(
    "app18_http_request_latency_seconds",
    "Request latency",
    buckets=[0.05, 0.1, 0.25, 0.5, 1, 2]
)

STATUS = Gauge(
    "app18_service_status",
    "Service status (1=up)"
)

@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def record_metrics(response):
    latency = time.time() - request.start_time
    LATENCY.observe(latency)
    REQUESTS.labels(
        request.method,
        request.path,
        response.status_code
    ).inc()
    return response

@app.route("/")
def index():
    return "Hello from app18!"

@app.route("/error")
def error():
    return "Internal error", 500

@app.route("/metrics")
def metrics():
    STATUS.set(1)
    return Response(generate_latest(), mimetype="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
