from flask import Flask, request, send_from_directory

from QueryHandler import *
import os
app = Flask(__name__)


@app.route('/ping', methods=['GET', 'POST'])
def get_live():
    return "pong*"

@app.route('/pings', methods=['GET', 'POST'])
def get_lives():
    return "lings"

@app.route('/files', methods=['GET', 'POST'])
def get_files():
    os.path("rest_server/static")
    return "files"

@app.route('/xlsx', methods=['GET', 'POST'])
def get_xlsx():
    print("get_xlsx(): called")
    host = request.args.get('host')
    port = request.args.get('port')
    dbname = request.args.get('dbname')
    filename = request.args.get('filename')
    fromT = request.args.get('fromT')
    toT = request.args.get('toT')
    filename = request.args.get('filename')

    fixedAbsolutLocation = "/rest_server/tmp"
    requestHandler = QueryHandler(fixedAbsolutLocation)

    finalFileLocation = requestHandler.queryAndGetPathToResultsXLSX(
        host=host,      port=port,
        DBname=dbname,  filePrefix=filename,
        fromT=fromT,    toT=toT)

    return send_from_directory(
        os.path.dirname(finalFileLocation),
        os.path.basename(finalFileLocation))

@app.route('/csv', methods=['GET', 'POST'])
def get_csv():
    print("get_csv(): called")
    host = request.args.get('host')
    port = request.args.get('port')
    dbname = request.args.get('dbname')
    filename = request.args.get('filename')
    fromT = request.args.get('fromT')
    toT = request.args.get('toT')
    filename = request.args.get('filename')

    fixedAbsolutLocation = "/rest_server/tmp"
    requestHandler = QueryHandler(fixedAbsolutLocation)

    finalFileLocation = requestHandler.queryAndGetPathToResultsCVS(
        host=host,      port=port,
        DBname=dbname,  filePrefix=filename,
        fromT=fromT,    toT=toT)

    return send_from_directory(
        os.path.dirname(finalFileLocation),
        os.path.basename(finalFileLocation))
