from fastapi import FastAPI, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random

app = FastAPI()

REQUEST_COUNT = Counter(
    "app15_http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"]
)

REQUEST_LATENCY = Histogram(
    "app15_http_request_duration_seconds",
    "HTTP request latency",
    buckets=[0.05, 0.1, 0.2, 0.3, 0.5, 1]
)

@app.get("/")
def root():
    start = time.time()
    time.sleep(random.uniform(0.05, 0.15))
    duration = time.time() - start

    REQUEST_COUNT.labels("GET", "/", "200").inc()
    REQUEST_LATENCY.observe(duration)

    return {"message": "Hello from app15"}

@app.get("/error")
def error():
    start = time.time()
    time.sleep(random.uniform(0.05, 0.15))
    duration = time.time() - start

    REQUEST_COUNT.labels("GET", "/error", "500").inc()
    REQUEST_LATENCY.observe(duration)

    return Response(status_code=500, content="Internal error")

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
