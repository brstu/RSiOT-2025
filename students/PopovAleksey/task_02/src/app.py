from http.server import HTTPServer, BaseHTTPRequestHandler
import os

PORT = int(os.environ.get("PORT", 8002))

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"Hello from web38!")

if __name__ == "__main__":
    print(f"STU_ID={os.environ.get('STU_ID', 'N/A')}")
    print(f"STU_GROUP={os.environ.get('STU_GROUP', 'N/A')}")
    print(f"STU_VARIANT={os.environ.get('STU_VARIANT', 'N/A')}")
    print(f"Starting server on port {PORT}")
    server = HTTPServer(("0.0.0.0", PORT), SimpleHandler)
    server.serve_forever()
