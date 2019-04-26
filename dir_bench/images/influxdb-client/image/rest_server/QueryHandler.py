#!/usr/bin/python
import argparse
import os
import re
        
import zipfile as zp 
import influxdb as idb
import pandas as pd

import ZipWritero as zw

class QueryHandler():
    def __init__(self, saveDirectory):
        self.saveDirectory  =   saveDirectory

    def queryAndGetPathToResultsXLSX(self, host, port, DBname, filePrefix, fromT, toT):
        print("queryAndGetPathToResults: called -- {} {} {} {} {} {}".format(
                host, port, DBname, filePrefix, fromT, toT))   
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
            resDataFrame        = self.makeDBQueryForDataPoints(client=realClient,nameofmeas=nameOfMeas,fromT=fromT,toT=toT)
            cleanedNameOfMeas   = re.sub('[^A-Za-z0-9]+', '_', nameOfMeas)
            resDataFrame.to_excel(exWriter,sheet_name=cleanedNameOfMeas)
        exWriter.close()
        return fileExportLocation
    
    def queryAndGetPathToResultsCVS(self, host, port, DBname, filePrefix, fromT, toT):
        print("queryAndGetPathToResults: called -- {} {} {} {} {} {}".format(
                host, port, DBname, filePrefix, fromT, toT))
        fileExportLocation      = "{}/{}.zip".format(self.saveDirectory, filePrefix)
        realClient              = idb.InfluxDBClient(host = host, port = port)
        realClient.switch_database(database = DBname)

        listOfMeasurements      = realClient.get_list_measurements()
        print("export to {}".format(fileExportLocation))
        print("Founds <{}> measurements in total. Gathering will start now.".format(len(listOfMeasurements)))
        
        exportZipFile   = zp.ZipFile(fileExportLocation,'a')
        for measurement in listOfMeasurements:
            nameOfMeas          = measurement['name']
            print("Start to collect from {}".format(nameOfMeas))
            resDataFrame        = self.makeDBQueryForDataPoints(client=realClient,nameofmeas=nameOfMeas,fromT=fromT,toT=toT)
            cleanedNameOfMeas   = re.sub('[^A-Za-z0-9]+', '_', nameOfMeas)
            dataAsString=resDataFrame.to_string(index = False)
            
            filename = cleanedNameOfMeas + ".txt"
            zw.applyStrToCompressedZipInAMode(exportZipFile,filename,dataAsString)
        return fileExportLocation  

    def makeDBQueryForDataPoints(self, client, nameofmeas,fromT,toT):
        query               = 'SELECT * FROM "{}" WHERE time >= {} AND time <= {}'.format(nameofmeas, fromT ,toT)
        query               = 'SELECT * FROM "{}"'.format(nameofmeas, fromT ,toT)
        points              = client.query(query, chunked=True, chunk_size=10000).get_points()
        resDataFrame        = pd.DataFrame(points)
        return resDataFrame

    def makeDBQueryForAllDataPoints(self, client, nameofmeas):
        query               = 'SELECT * FROM "{}"'.format(nameofmeas)
        points              = client.query(query, chunked=True, chunk_size=10000).get_points()
        resDataFrame        = pd.DataFrame(points)
        return resDataFrame