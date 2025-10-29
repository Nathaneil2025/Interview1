from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Welcome to Flask App on EKS! new ver1',
        'status': 'running',
        'hostname': socket.gethostname(),
        'version': os.getenv('APP_VERSION', '1.0.0')
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'flask-app'
    }), 200

@app.route('/info')
def info():
    return jsonify({
        'app': 'Flask Application',
        'environment': os.getenv('ENVIRONMENT', 'production'),
        'kubernetes': {
            'pod_name': os.getenv('POD_NAME', 'N/A'),
            'pod_namespace': os.getenv('POD_NAMESPACE', 'N/A'),
            'node_name': os.getenv('NODE_NAME', 'N/A')
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)