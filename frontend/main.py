import flask
from flask import Flask, render_template, request, jsonify, url_for
import requests
from datetime import datetime


app = Flask(__name__)
info_list =[] # the history
getD = dict() # the data from the backend
@app.route("/", methods=["POST", "GET"])
def index():
    # get the aws public ip
    ip_address = (requests.get("http://169.254.169.254/latest/meta-data/public-ipv4").content).decode('utf-8')

    if request.method == "POST":
        input_json = request.get_json(force=True)
        global getD
        getD = input_json
    return render_template("index2.html", info=getD, val = http://" + ip_address + ":5000, val2 = http://" + ip_address + ":5000/Auti/)


if __name__ == "__main__":
    app.run(host = "0.0.0.0", debug=True)
