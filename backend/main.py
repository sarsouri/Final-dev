import flask
from flask import Flask, render_template, request, jsonify, url_for
import requests
from datetime import datetime
import urllib, json
import urllib.request
import socket
from pip._internal import req
from werkzeug.utils import redirect

app = Flask(__name__)
info_list =[]

@app.route("/", methods=["POST", "GET"])
def index():
    # get the public ip of the aws ec2
    ip_address = (requests.get("http://169.254.169.254/latest/meta-data/public-ipv4").content).decode('utf-8')
    
    # when req a post from the front end take all the data and make a culculet to return the result
    if request.method == "POST":
        CurrencyOne = request.form.get("firstCurrency")
        CurrencyTwe = request.form.get("secondCurrency")
        ############################################
        amount = request.form.get("amount")
        response = requests.get("http://data.fixer.io/api/latest?access_key=85aa5a4fb3533fbae7223f74ccb1befb")
        app.logger.info(response)
        dat = response.json()
        ############################################
        valueOne = dat["rates"][CurrencyOne]
        valueTwo = dat["rates"][CurrencyTwe]
        result = (valueTwo / valueOne) * float(amount)
        ############################################
        currencyInfo = dict()
        currencyInfo["firstCurrency"] = CurrencyOne
        currencyInfo["secondCurrency"] = CurrencyTwe
        currencyInfo["amount"] = amount
        currencyInfo["result"] = result
        ############################################
        now = datetime.now()
        currentTime = now.strftime("%H:%M:%S")
        list1 = [currentTime, amount, CurrencyOne, CurrencyTwe, valueTwo, result]
        info_list.append(list1)
        res = requests.post('http://' + ip_address + ':7000/', json=currencyInfo)
        return redirect('http://' + ip_address + ':7000/', code=302) # return to the frontend  page
    else:
        return redirect('http://' + ip_address + ':7000/', code=302)

@app.route("/Auti/", methods=["POST", "GET"])
def Auti():
    ip_address2 = (requests.get("http://169.254.169.254/latest/meta-data/public-ipv4").content).decode('utf-8')
    dict1 = dict()
    dict1["info"] = info_list
    res = requests.post('http://' + ip_address2 + ':6000/', json=dict1)
    return redirect('http://' + ip_address2 + ':6000/', code=302)

if __name__ == "__main__":
    app.run(host = "0.0.0.0", debug=True)

