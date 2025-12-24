#!/usr/bin/env python3
"""
Flask application with Prometheus metrics for Lab 04 Variant 14
Student: Логинов Глеб Олегович (AS-63-220018-v14)
"""

import os
import time
import random
import logging
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from prometheus_client import make_wsgi_app

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Student metadata from environment
STU_ID = os.getenv('STU_ID', '220018')
STU_GROUP = os.getenv('STU_GROUP', 'AS-63')
STU_VARIANT = os.getenv('STU_VARIANT', '14')

# Log startup information
logger.info(f"Starting app14-monitoring application")
logger.info(f"Student ID: {STU_ID}")
logger.info(f"Student Group: {STU_GROUP}")
logger.info(f"Variant: {STU_VARIANT}")

# Define Prometheus metrics with app14_ prefix (as per variant 14 requirements)

# Counter: Total HTTP requests
app14_http_requests_total = Counter(
    'app14_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

# Histogram: Request duration
app14_http_request_duration_seconds = Histogram(
    'app14_http_request_duration_seconds',
    'HTTP request latency in seconds',
    ['method', 'endpoint'],
    buckets=(0.01, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0)
)

# Gauge: Requests in progress
app14_http_requests_in_progress = Gauge(
    'app14_http_requests_in_progress',
    'HTTP requests currently in progress',
    ['method', 'endpoint']
)

# Counter: 5xx errors
app14_http_errors_5xx_total = Counter(
    'app14_http_errors_5xx_total',
    '5xx server errors',
    ['method', 'endpoint', 'status']
)


def track_request(func):
    """Decorator to track request metrics"""
    def wrapper(*args, **kwargs):
        method = request.method
        endpoint = request.endpoint or 'unknown'
        
        # Track in-progress requests
        app14_http_requests_in_progress.labels(method=method, endpoint=endpoint).inc()
        
        # Measure request duration
        start_time = time.time()
        try:
            response = func(*args, **kwargs)
            duration = time.time() - start_time
            
            # Get status code
            if isinstance(response, tuple):
                status_code = response[1]
            else:
                status_code = 200
            
            # Update metrics
            app14_http_request_duration_seconds.labels(
                method=method,
                endpoint=endpoint
            ).observe(duration)
            
            app14_http_requests_total.labels(
                method=method,
                endpoint=endpoint,
                status=status_code
            ).inc()
            
            # Track 5xx errors separately
            if 500 <= status_code < 600:
                app14_http_errors_5xx_total.labels(
                    method=method,
                    endpoint=endpoint,
                    status=status_code
                ).inc()
                logger.warning(f"5xx error: {method} {endpoint} -> {status_code}")
            
            logger.info(f"{method} {endpoint} -> {status_code} ({duration:.3f}s)")
            
            return response
        finally:
            app14_http_requests_in_progress.labels(method=method, endpoint=endpoint).dec()
    
    wrapper.__name__ = func.__name__
    return wrapper


@app.route('/')
@track_request
def index():
    """Main page"""
    return jsonify({
        "application": "app14-monitoring",
        "student": {
            "id": STU_ID,
            "group": STU_GROUP,
            "variant": STU_VARIANT,
            "name": "Логинов Глеб Олегович"
        },
        "endpoints": {
            "/": "Main page",
            "/health": "Health check",
            "/metrics": "Prometheus metrics",
            "/simulate/ok": "Simulate normal response",
            "/simulate/slow": "Simulate slow response",
            "/simulate/error": "Simulate 5xx error"
        }
    }), 200


@app.route('/health')
@track_request
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "student_id": STU_ID,
        "group": STU_GROUP,
        "variant": STU_VARIANT
    }), 200


@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


@app.route('/simulate/ok')
@track_request
def simulate_ok():
    """Simulate normal response with small delay"""
    delay = random.uniform(0.01, 0.1)
    time.sleep(delay)
    return jsonify({
        "status": "ok",
        "delay": f"{delay:.3f}s"
    }), 200


@app.route('/simulate/slow')
@track_request
def simulate_slow():
    """Simulate slow response for P95 latency testing"""
    delay = random.uniform(0.2, 0.4)
    time.sleep(delay)
    return jsonify({
        "status": "slow",
        "delay": f"{delay:.3f}s",
        "warning": "This endpoint simulates high latency"
    }), 200


@app.route('/simulate/error')
@track_request
def simulate_error():
    """Simulate 5xx error for alert testing"""
    return jsonify({
        "error": "Internal server error",
        "message": "This is a simulated error for testing alerts"
    }), 500


if __name__ == '__main__':
    # Run with Flask development server
    # In production, use gunicorn (see Dockerfile)
    app.run(host='0.0.0.0', port=8000, debug=False)
