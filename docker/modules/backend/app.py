from flask import Flask, jsonify
import os

app = Flask(__name__)

# Add CORS headers to allow frontend requests
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "service": "backend"})

@app.route("/data")
def data():
    return jsonify({"message": "Hello from Backend API!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
