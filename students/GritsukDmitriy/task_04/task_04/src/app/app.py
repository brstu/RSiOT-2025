#!/usr/bin/env python3
import os
import time
import socket
from http.server import HTTPServer, BaseHTTPRequestHandler
from prometheus_client import start_http_server, Counter

# Простая метрика
REQUEST_COUNTER = Counter('app03_test_requests_total', 'Test requests')

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        REQUEST_COUNTER.inc()
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Hello from Web03!")

def main():
    print("Starting Web03 Application...")
    print(f"Student: {os.getenv('STU_FULLNAME', 'Test')}")
    
    try:
        # Запускаем метрики на порту 9090
        start_http_server(9090)
        print(f"✓ Metrics server started on port 9090")
    except Exception as e:
        print(f"✗ Failed to start metrics server: {e}")
        return
    
    try:
        # Запускаем HTTP сервер на порту 8083
        server = HTTPServer(('0.0.0.0', 8083), Handler)
        print(f"✓ HTTP server started on port 8083")
        print(f"✓ Server is running...")
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped by user")
    except Exception as e:
        print(f"✗ Failed to start HTTP server: {e}")

if __name__ == '__main__':
    main()