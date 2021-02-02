from flask import Flask, render_template, request, jsonify
import requests
from datetime import datetime

app = Flask(__name__)
info_list =[]

@app.route("/", methods=["POST", "GET"])
def Auti():
    if request.method == "POST":
        input_json = request.get_json(force=True)
        global info_list
        info_list = input_json["info"]
    return render_template("index.html", info=info_list)


if __name__ == "__main__":
    app.run(host = "0.0.0.0", debug=True)
