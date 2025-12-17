from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from web22!"

@app.route('/health')
def health():
    return "OK"

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8042))
    print(f"Starting server on port {port}")
    app.run(host='0.0.0.0', port=port)
