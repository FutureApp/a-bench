from flask import Flask, request, send_from_directory

from logic_querys import *
import os
app = Flask(__name__)



@app.route('/ping', methods=['GET','POST'])
def get_live():
    return "I'm alive. ping* ping*"


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


@app.route('/test/xlsx', methods=['GET','POST'])
def get_test():
    print("get_test(): called")
    host        = request.args.get('host')
    port        = request.args.get('port')
    dbname      = request.args.get('dbname')
    filename    = request.args.get('filename')
    lBorder     = request.args.get('lTimeBorder')
    rBorder     = request.args.get('rTimeBorder')
    filename    = request.args.get('filename')
    
    fixedAbsolutLocation    = "/rest_server/tmp"
    requestHandler          = QueryHandler(fixedAbsolutLocation)
    
    finalFileLocation       = requestHandler.queryAndGetPathToResultsXLSX(
                                            host        = host,     port         = port, 
                                            DBname      = dbname,   filePrefix   = filename,
                                            leftBorder  = lBorder,  rightBorder  = rBorder)
    
    return send_from_directory(
    os.path.dirname(finalFileLocation),
    os.path.basename(finalFileLocation))