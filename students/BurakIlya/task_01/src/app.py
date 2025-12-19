from flask import Flask, jsonify
import os
import redis

app = Flask(__name__)

# Переменные окружения
STU_ID = os.environ.get('STU_ID', '220035')
STU_GROUP = os.environ.get('STU_GROUP', 'AS-64')
STU_VARIANT = os.environ.get('STU_VARIANT', '29')

# Redis подключение
REDIS_HOST = os.environ.get('REDIS_HOST', 'localhost')
REDIS_PORT = int(os.environ.get('REDIS_PORT', 6379))

print(f"Starting app with STU_ID={STU_ID}, STU_GROUP={STU_GROUP}, STU_VARIANT={STU_VARIANT}")

try:
    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
except:
    r = None

@app.route('/')
def index():
    return jsonify({
        "message": "Hello from Flask",
        "student_id": STU_ID,
        "variant": STU_VARIANT
    })

@app.route('/healthz')
def health():
    return jsonify({"status": "ok"})

@app.route('/data')
def data():
    if r:
        key = f"stu:{STU_ID}:v{STU_VARIANT}:counter"
        val = r.incr(key)
        return jsonify({"counter": val})
    return jsonify({"error": "Redis not available"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8021)
