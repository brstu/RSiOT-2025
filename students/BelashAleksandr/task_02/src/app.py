from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from web25!'

@app.route('/health')
def health():
    return 'OK'

if __name__ == '__main__':
    # Простое логирование старта (без graceful shutdown)
    print(f"Starting web25 service...")
    print(f"STU_ID: {os.getenv('STU_ID', 'N/A')}")
    print(f"STU_GROUP: {os.getenv('STU_GROUP', 'N/A')}")
    print(f"STU_VARIANT: {os.getenv('STU_VARIANT', 'N/A')}")
    
    app.run(host='0.0.0.0', port=8031)
