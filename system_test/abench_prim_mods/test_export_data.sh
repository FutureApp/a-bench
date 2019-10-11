#!/bin/bash

echo "[Test-Data-Export] Export measurments"
myLocation=$(pwd)
adminModul_location=../..
libsBench=../../dir_bench/lib_bench/shell/bench.sh
libsUtil=../../dir_bench/lib_bench/shell/util.sh
locationPath="./results"
exportFilePath="./results/test-data-export.zip"

source $libsBench
source $libsUtil
cd $adminModul_location
mkdir -p $locationPath
rm $exportFilePath
rm -r "./results/test-data-export"
#bash ./admin.sh senv_a
#echo "sleeping 5 minutes" && sleep 300

expectedNumberOfFiles=36

s_time=$(bench_UTC_TimestampInNanos)
echo "sleep 100s"
util_sleep 100
e_time=$(bench_UTC_TimestampInNanos)

echo "Calling admin.sh with export_data $s_time $e_time $exportFilePath"
bash ./admin.sh export_data $s_time $e_time $exportFilePath
cd "./results"
unzip -o test-data-export.zip -d "./test-data-export"
## number
## https://stackoverflow.com/questions/11307257/is-there-a-bash-command-which-counts-files
numberOfFiles=$(ls -1q ./test-data-export | wc -l)
echo "Found $numberOfFiles files"

if [ "$numberOfFiles" -ne "$expectedNumberOfFiles" ]; then
   echo "Error, test failed. Didn't found the expected number of files.";
   exit 1;
else
    echo "Weiter";
fi

##https://askubuntu.com/questions/750664/check-if-input-string-exists-in-file
echo "Current location: $(pwd)"
searchString="kubedns"
if grep -qF "$searchString" "./test-data-export/filesystem_usage.txt";then
   echo "Found it"
else
   echo "Sorry this $searchString not in file"
   exit 1
fi
echo "Test successfully finished";
exit