#!/usr/bin/env python3
"""Простой HTTP-сервер для ЛР02"""

import os
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = int(os.getenv('PORT', 8001))

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'Hello from web37!')

if __name__ == '__main__':
    print(f"STU_ID={os.getenv('STU_ID', 'not set')}")
    print(f"STU_GROUP={os.getenv('STU_GROUP', 'not set')}")
    print(f"STU_VARIANT={os.getenv('STU_VARIANT', 'not set')}")
    print(f"Server starting on port {PORT}")
    server = HTTPServer(('0.0.0.0', PORT), SimpleHandler)
    server.serve_forever()
