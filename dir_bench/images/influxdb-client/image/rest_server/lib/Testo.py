#!/usr/bin/python
import argparse
import os
import re

import influxdb as idb
import pandas as pd


class Testo():
    def __init__(self, saveDirectory):
        self.saveDirectory = saveDirectory

    def querySelAllFromMeasureResAsDataFrame(client, meas, lborder, rborder):
        query = 'SELECT * FROM "{}" where time > {} and time < {}'.format(
            meas, lborder, rborder)
        points = client.query(query, chunked=True,
                              chunk_size=10000).get_points()
        return pd.DataFrame(points)

    def queryAndGetPathToResults(self, host, port, DBname, filePrefix, leftBorder, rightBorder):
        print("Starting to query results")
        client = idb.InfluxDBClient(host=host, port=port)
        client.switch_database(database=DBname)

        listOfMeasurements = client.get_list_measurements()
        print ("List Of Meas: {}".format(listOfMeasurements))
        exportPath = '{}/{}.xlxs'.format(self.saveDirectory, filePrefix)
        exWriter = pd.ExcelWriter(exportPath)
        print("Found <{}> measurements in total. Gathering will start now.".format(
            len(listOfMeasurements)))
        for measurement in listOfMeasurements:
            nameOfMeas = measurement['name']
            print("Start to collect from {}".format(nameOfMeas))

            resDataFrame = self.querySelAllFromMeasureResAsDataFrame(
                client, nameOfMeas, 000000000000, 9999999999)
            cleanedNameOfMeas = re.sub('[^A-Za-z0-9]+', '_', nameOfMeas)
            resDataFrame.to_excel(exWriter, sheet_name=cleanedNameOfMeas)
        exWriter.close()

        return exportPath
