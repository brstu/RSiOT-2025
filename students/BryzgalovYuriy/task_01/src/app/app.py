import os
import signal
import sys
import time
from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)

STU_ID = os.getenv("STU_ID")
STU_GROUP = os.getenv("STU_GROUP")
STU_VARIANT = os.getenv("STU_VARIANT")

DB_HOST = os.getenv("DB_HOST", "postgres")
DB_NAME = os.getenv("POSTGRES_DB")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")

running = True

def handle_sigterm(signum, frame):
    global running
    print("[INFO] SIGTERM received. Graceful shutdown started...")
    running = False
    time.sleep(2)
    print("[INFO] Application stopped gracefully.")
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_sigterm)

@app.route("/")
def index():
    return jsonify(
        message="Flask app is running",
        student=STU_ID,
        group=STU_GROUP,
        variant=STU_VARIANT
    )

@app.route("/healthz")
def health():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            connect_timeout=2
        )
        conn.close()
        return jsonify(status="ok"), 200
    except Exception as e:
        return jsonify(status="fail", error=str(e)), 500

if __name__ == "__main__":
    print(f"[START] STU_ID={STU_ID}, GROUP={STU_GROUP}, VARIANT={STU_VARIANT}")
    app.run(host="0.0.0.0", port=8082)
