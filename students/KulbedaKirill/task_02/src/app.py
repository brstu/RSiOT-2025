import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "message": "Web12 service",
        "variant": os.getenv("STU_VARIANT", "12"),
        "student_id": os.getenv("STU_ID", "220016")
    })

@app.route('/health')
def health():
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    print(f"Starting web12 service...")
    print(f"STU_ID={os.getenv('STU_ID', 'N/A')}")
    print(f"STU_GROUP={os.getenv('STU_GROUP', 'N/A')}")
    print(f"STU_VARIANT={os.getenv('STU_VARIANT', 'N/A')}")
    app.run(host='0.0.0.0', port=8074)
