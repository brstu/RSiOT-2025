#!/usr/bin/env python3
import os
import json
import time
import signal
import sys
import logging
import http.server
import socketserver
from urllib.parse import urlparse

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                'status': 'healthy',
                'service': os.getenv('APP_NAME', 'web02'),
                'timestamp': time.time()
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif parsed_path.path == '/ready':
            # Проверка готовности (можно добавить проверки БД и т.д.)
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                'status': 'ready',
                'service': os.getenv('APP_NAME', 'web02'),
                'timestamp': time.time()
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif parsed_path.path == '/':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                'message': 'Hello from web02',
                'version': os.getenv('APP_VERSION', '1.0.0'),
                'environment': os.getenv('ENVIRONMENT', 'development'),
                'hostname': os.getenv('HOSTNAME', 'localhost'),
                'timestamp': time.time()
            }
            self.wfile.write(json.dumps(response).encode())
            
        else:
            self.send_response(404)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {'error': 'Not found'}
            self.wfile.write(json.dumps(response).encode())
    
    def log_message(self, format, *args):
        logger.info(f"{self.client_address[0]} - {format % args}")

class GracefulHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

def signal_handler(signum, frame):
    logger.info(f"Received signal {signum}, initiating graceful shutdown...")
    # Сервер автоматически завершит работу при выходе из serve_forever

if __name__ == '__main__':
    port = int(os.getenv('PORT', '8082'))
    host = os.getenv('HOST', '0.0.0.0')
    
    logger.info(f"Starting server on {host}:{port}")
    logger.info(f"PID: {os.getpid()}, UID: {os.getuid()}, GID: {os.getgid()}")
    
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)
    
    server = GracefulHTTPServer((host, port), HealthHandler)
    
    try:
        logger.info(f"Server started successfully on port {port}")
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Keyboard interrupt received")
    except Exception as e:
        logger.error(f"Server error: {e}", exc_info=True)
    finally:
        server.server_close()
        logger.info("Server stopped gracefully")