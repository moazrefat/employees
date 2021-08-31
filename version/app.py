from flask import Flask , json, request, render_template, jsonify
from db_conn import db
import requests
import socket
import os
import json

app = Flask(__name__,template_folder='templetes/')
app.config['JSON_SORT_KEYS'] = False

version="V1"
hostname=socket.gethostname()

@app.route("/")
def home():
    return "Hello, World version application {}".format(socket.gethostname())

@app.route("/version")
def version():
    return "V1"

@app.route("/health")
def health():
    status = ""
    query = '''select avail from version.version where version="v1";'''
    # print(query)
    with db() as conn:
        conn.execute(query)
        data = conn.fetchall()
        for i in data:
            status = i[0]

    return jsonify(
        hostname=hostname,
        version=version,
        status=status
    )

if __name__ == '__main__':
    app.debug = True
    host = os.environ.get('IP', '0.0.0.0')
    # print(host)
    port = int(os.environ.get('PORT', 8080))
    app.run(host=host, port=port)