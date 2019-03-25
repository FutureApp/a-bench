#!/usr/bin/python
import argparse
import os
import re

import influxdb as idb
import pandas as pd

class QueryHandler():
    def __init__(self, saveDirectory):
        self.saveDirectory  =   saveDirectory

    def queryAndGetPathToResultsXLSX(self, host, port, DBname, filePrefix, leftBorder, rightBorder):
        print("queryAndGetPathToResults: called -- {} {} {} {} {} {}".format(
                host, port, DBname, filePrefix, leftBorder, rightBorder))   
        fileExportLocation      = "{}/{}.xlsx".format(self.saveDirectory, filePrefix)
        realClient              = idb.InfluxDBClient(host = host, port = port)
        realClient.switch_database(database = DBname)

        listOfMeasurements      = realClient.get_list_measurements()
        print("export to {}".format(fileExportLocation))
        exWriter                = pd.ExcelWriter(fileExportLocation)
        print("Founds <{}> measurements in total. Gathering will start now.".format(len(listOfMeasurements)))
        for measurement in listOfMeasurements:
            nameOfMeas          = measurement['name']
            print("Start to collect from {}".format(nameOfMeas))
           # resDataFrame        = self.makeDBQueryForAllDataPoints(client=realClient,nameofmeas=nameOfMeas,lborder=leftBorder,rborder=rightBorder)
            resDataFrame        = self.makeDBQueryForDataPoints(client=realClient,nameofmeas=nameOfMeas,lborder=leftBorder,rborder=rightBorder)
            cleanedNameOfMeas   = re.sub('[^A-Za-z0-9]+', '_', nameOfMeas)
            resDataFrame.to_excel(exWriter,sheet_name=cleanedNameOfMeas)
        exWriter.close()
        return fileExportLocation

    def makeDBQueryForDataPoints(self, client, nameofmeas,lborder,rborder):
        query               = 'SELECT * FROM "{}" WHERE time >= {} AND time <= {}'.format(nameofmeas, lborder ,rborder)
        points              = client.query(query, chunked=True, chunk_size=10000).get_points()
        resDataFrame        = pd.DataFrame(points)
        return resDataFrame

    def makeDBQueryForAllDataPoints(self, client, nameofmeas,lborder,rborder):
        query               = 'SELECT * FROM "{}"'.format(nameofmeas)
        points              = client.query(query, chunked=True, chunk_size=10000).get_points()
        resDataFrame        = pd.DataFrame(points)
        return resDataFrame