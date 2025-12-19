import os
import redis
from flask import Flask, jsonify

app = Flask(__name__)

# Переменные окружения
STU_ID = os.getenv('STU_ID', '220027')
STU_GROUP = os.getenv('STU_GROUP', 'АС-63')
STU_VARIANT = os.getenv('STU_VARIANT', '22')
REDIS_HOST = os.getenv('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.getenv('REDIS_PORT', '6379'))

# Подключение к Redis
redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

# Логирование при старте
print(f"Starting application...")
print(f"Student ID: {STU_ID}")
print(f"Group: {STU_GROUP}")
print(f"Variant: {STU_VARIANT}")

@app.route('/')
def index():
    # Увеличиваем счетчик посещений в Redis
    key = f"stu:{STU_ID}:v{STU_VARIANT}:visits"
    redis_client.incr(key)
    count = redis_client.get(key)
    
    return jsonify({
        'message': 'Hello from Flask!',
        'student_id': STU_ID,
        'group': STU_GROUP,
        'variant': STU_VARIANT,
        'visits': count
    })

@app.route('/healthz')
def health():
    try:
        # Проверяем подключение к Redis
        redis_client.ping()
        return jsonify({'status': 'healthy', 'redis': 'connected'}), 200
    except:
        return jsonify({'status': 'unhealthy', 'redis': 'disconnected'}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', '8021'))
    app.run(host='0.0.0.0', port=port)
