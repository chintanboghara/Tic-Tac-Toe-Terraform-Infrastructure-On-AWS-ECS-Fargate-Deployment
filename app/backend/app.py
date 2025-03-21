from flask import Flask, jsonify
import mysql.connector
import os

app = Flask(__name__)

@app.route('/health')
def health():
    try:
        conn = mysql.connector.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            database=os.environ['DB_NAME']
        )
        conn.close()
        return jsonify(status='healthy')
    except Exception as e:
        return jsonify(status='unhealthy', error=str(e))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)