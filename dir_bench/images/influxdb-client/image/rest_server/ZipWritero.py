import zipfile as zp 
import glob, os
import datetime
import re


def applyStrToCompressedZipInAMode(zipFileInAMode, fileName, strData):
    zipFileInAMode.writestr(fileName, strData)
    print("Successful -- Data was successfully appended to zip <{}> named as <{}>.".format(zipFileInAMode.filename,fileName))

def applyAllFileInFlatDirToZipInAMode(zipInAMode, dirOfFiles):
    #scr: https://www.mkyong.com/python/python-how-to-list-all-files-in-a-directory/
    files = [f for f in glob.glob(dirOfFiles + "*/*.*", recursive=False)]
    zipFileName=os.path.basename(zipInAMode.filename)
    for path in files:
        filename = os.path.basename(path)
        if(filename != zipFileName): # prevents that the zip-file contains itself
            zipInAMode.write(path,filename, compress_type=zp.ZIP_STORED)

def returnCleanedCurTimeStamp():
    times = datetime.datetime.now()
    #src: https://stackoverflow.com/questions/38162444/python-regex-match-space-only
    return re.sub(' ','-',re.sub('[^a-zA-Z0-9 \n\.]', '_', str(times)))

def applyFileToZipInAMode(zipInAMode,pathToFile):
    zipInAMode.write(pathToFile, os.path.basename(pathToFile))

#    dirz="C:/Users/michaelczaja/Desktop/py"
#    zipFileName="hellozipC.zip"
#    abPath=dirz+'/'+zipFileName
#    messageFromInflux="nice #'#"
#    zipo = zp.ZipFile(abPath,'a')
#    # applyStrToCompressedZipInAMode(zipo,"helloworld1.txt","helloworld1.txt")
#    #applyAllFileInFlatDirToZipInAMode(zipo,dirz)
#    times=datetime.datetime.now()
#    print (str(datetime.datetime.now()))
#    
#    my_str = "hey th~!ere"
#    my_new_string = re.sub(' ','-',re.sub('[^a-zA-Z0-9 \n\.]', '_', str(times)))
#    print (my_new_string)


