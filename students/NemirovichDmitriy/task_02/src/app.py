#!/usr/bin/env python3
import os
import signal
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime

# Метаданные из переменных окружения
STU_ID = os.getenv('STU_ID', '220050')
STU_GROUP = os.getenv('STU_GROUP', 'АС-64')
STU_VARIANT = os.getenv('STU_VARIANT', '37')
PORT = int(os.getenv('PORT', '8001'))

class SimpleHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Отключаем стандартное логирование запросов
        pass
    
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            html = f"""
            <html>
            <head><title>web37</title></head>
            <body>
                <h1>Лабораторная работа №02 - Вариант {STU_VARIANT}</h1>
                <p><b>Студент:</b> {STU_GROUP}, ID: {STU_ID}</p>
                <p><b>Время:</b> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
            </body>
            </html>
            """
            self.wfile.write(html.encode())
        
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status":"ok"}')
        
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

server = None

def shutdown_handler(signum, frame):
    print(f"[{datetime.now().isoformat()}] Получен сигнал {signum}, завершение работы...", flush=True)
    if server:
        server.shutdown()
    sys.exit(0)

if __name__ == '__main__':
    signal.signal(signal.SIGTERM, shutdown_handler)
    signal.signal(signal.SIGINT, shutdown_handler)
    
    print(f"[{datetime.now().isoformat()}] Запуск сервиса web37", flush=True)
    print(f"[{datetime.now().isoformat()}] STU_ID={STU_ID}, STU_GROUP={STU_GROUP}, STU_VARIANT={STU_VARIANT}", flush=True)
    print(f"[{datetime.now().isoformat()}] Порт: {PORT}", flush=True)
    
    server = HTTPServer(('0.0.0.0', PORT), SimpleHandler)
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        print(f"[{datetime.now().isoformat()}] Сервис остановлен", flush=True)
