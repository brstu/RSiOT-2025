# app/main.py
import os
import signal
import sys

from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)


def get_db_connection():
    conn = psycopg2.connect(
        dbname=os.environ.get("POSTGRES_DB", "app_220005_v2"),
        user=os.environ.get("POSTGRES_USER", "app_user"),
        password=os.environ.get("POSTGRES_PASSWORD", "app_password"),
        host=os.environ.get("POSTGRES_HOST", "db"),
        port=os.environ.get("POSTGRES_PORT", "5432"),
    )
    return conn


@app.route("/")
def index():
    return jsonify(
        message="Lab01 / Docker / Flask + Postgres",
        student_fullname="Выржемковский Даниил Иванович",
        student_id="220005",
        group="АС-63",
        variant="2",
    )


@app.route("/healthz")
def healthz():
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1;")
                cur.fetchone()

        return jsonify(status="ok"), 200
    except Exception as exc:
        app.logger.error("Healthcheck failed: %s", exc)
        return jsonify(status="degraded", error=str(exc)), 500


def handle_sigterm(signum, frame):
    app.logger.info("Received SIGTERM, shutting down...")
    sys.exit(0)


signal.signal(signal.SIGTERM, handle_sigterm)


if __name__ == "__main__":
    port = int(os.environ.get("APP_PORT", "8082"))
    app.run(host="0.0.0.0", port=port)
