from flask import Flask, request
#from lib import Collector
import subprocess

app = Flask(__name__)

@app.route('/user', methods=['GET','POST'])
def get_user():
    username = request.form['username']
    password = request.form['password'] 
    return "True"

@app.route('/mes', methods=['GET','POST'])
def get_measurements():
    host        = request.args.get('host')
    port        = request.args.get('port')
    dbname      = request.args.get('dbname')
    filename    = request.args.get('filename')
    lBorder     = request.args.get('lTimeBorder') 
    rBorder     = request.args.get('rTimeBorder') 

    # pipe into python-script
    # return the output file
    return "True"


@app.route('/test', methods=['GET','POST'])
def get_test():
    #from lib import Test

    print("hey1")
    filename    = request.args.get('filename')
    subprocess
    print("hey2")
    return "True"
