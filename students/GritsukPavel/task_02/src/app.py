from flask import Flask, jsonify
import os
import logging

app = Flask(__name__)

# Простое логирование
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Получаем переменные окружения (но не логируем их при старте - недочёт!)
STU_ID = os.getenv('STU_ID', 'unknown')
STU_GROUP = os.getenv('STU_GROUP', 'unknown')
STU_VARIANT = os.getenv('STU_VARIANT', 'unknown')

@app.route('/')
def home():
    return jsonify({
        "service": "web04",
        "status": "running",
        "student_id": STU_ID,
        "group": STU_GROUP,
        "variant": STU_VARIANT
    })

@app.route('/health')
def health():
    # Простейшая health проверка
    return jsonify({"status": "ok"}), 200

@app.route('/api/data')
def get_data():
    return jsonify({
        "message": "Hello from web04",
        "variant": STU_VARIANT
    })

if __name__ == '__main__':
    # Запуск без graceful shutdown и без логирования старта
    app.run(host='0.0.0.0', port=8084, debug=False)
