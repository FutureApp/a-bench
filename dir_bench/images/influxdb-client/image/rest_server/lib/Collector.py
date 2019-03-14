#!/usr/bin/python

import argparse
import os
import re

import influxdb as idb
import pandas as pd
import Testo


def main(): 
    args                = parseArguments()
    searchingForDB      = args.dbname
    host                = args.host
    port                = args.port
    exportTyp           = args.exportTyp
    exportDir           = args.exportDir
    exportFilename      = args.exportFile
    leftTimeBorder      = args.lTimeBorder
    rightTimeBorder     = args.rTimeBorder

    print("Collector was called with the following parameters:\n{}".format(args))
    client              = idb.InfluxDBClient(host = host, port = port)
    myDBExists          = isDBavailable(client, searchingForDB)
    
    if not myDBExists:
        abortExecBecauseDBNotFound(searchingForDB)

    if not os.path.exists(exportDir):
        os.makedirs(exportDir)
    
    
    client.switch_database(database = searchingForDB)
    listOfMeasurements  = client.get_list_measurements()
    exportPath          = '{}/{}.xlsx'.format(exportDir, exportFilename)
    exWriter            = pd.ExcelWriter(exportPath)
    
    print("Found <{}> measurements in total. Gathering will start now.".format(len(listOfMeasurements)))
    for measurement in listOfMeasurements:
        nameOfMeas          = measurement['name']
        print("Start to collect from {}".format(nameOfMeas))

        resDataFrame        = querySelAllFromMeasureResAsDataFrame(client, nameOfMeas)
        cleanedNameOfMeas   = re.sub('[^A-Za-z0-9]+', '_', nameOfMeas)
        resDataFrame.to_excel(exWriter,sheet_name=cleanedNameOfMeas)
    
    exWriter.close()
    print("Export successfully. See --$ {} $--".format(exportPath))


def querySelAllFromMeasureResAsDataFrame(client, meas):
    query   = 'SELECT * FROM "{}"'.format(meas)
    points  = client.query(query, chunked=True, chunk_size=10000).get_points()
    return pd.DataFrame(points)

def abortExecBecauseDBNotFound(dbname):
    print('Execution will stop because the required DB < {} > was not found.'.format(dbname))
    print('Stoping now.')
    exit(1)

def isDBavailable(influxdbClient, DBName):
    available = False
    for dbs in influxdbClient.get_list_database():
        if dbs['name'] == DBName:
            available = True
            break
    return available

def parseArguments():
    # Returns the all handled arguments which were given during the programm start.
    parser  =   argparse.ArgumentParser()
    parser.description="""
    The purpose of the script is it to call a given InfluxDB-instance in order to download all performance data from a specific
    database and export each measurement. (d) means that this is the default value. 
    E.g call: bash collector.py --host=localhost --port=8086"""
    
    parser.add_argument('--host',           default='localhost', metavar="<hostname>",
                                            help='Specifies here how to access the influxdb-server. localhost(d)')
    parser.add_argument('--port',           default=8086, metavar="<port>",
                                            help='Port of the influxdb-server where to connect to. (d)8086')
    parser.add_argument('--dbname',         default='k8s', metavar="<name>",
                                            help='Name of the DB where to collect data from.')
    parser.add_argument('--exportTyp',      default='xlxs', metavar="<xlxs|sep-xlxs|cvs>",
                                            help="""
                                            [xlxs]        - for excel-export. One measurement to diffrente sheet but same workbook.
                                            [sep-xlxs]    - for excel-export. Each measurment will be saved in a diffrente workbook
                                            [cvs]         - for cvs-export. Each measurment will be saved in different file.""")
    parser.add_argument('--exportDir',      default='/results', metavar="<path>",
                                            help='Path to directory where to export all files. If Dir not exists then a new dir will be created.')
    parser.add_argument('--exportFile',     default='exp_00', metavar="<name>",
                                            help='The name of the outputfile if applicable.')
    parser.add_argument('--lTimeBorder',    default=0000000000000000000, metavar="<number>",
                                            help='Specifie the lowest/latest timestamp you are intressted in.      Default 00000000')
    parser.add_argument('--rTimeBorder',    default=9999999999999999999	, metavar="<number>",  
                                            help='Specifie the highest/recently timestamp you are intressted in.   Default 99999999')
    #0000000000000000000
    #9999999999999999999

    #1551974700000000000
    #2100000000000000000
    return parser.parse_args() 

main()