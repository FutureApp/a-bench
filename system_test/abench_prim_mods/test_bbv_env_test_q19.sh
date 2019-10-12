#!/bin/bash

# Checks if all pods are available which are expected.
# Based on
# https://unix.stackexchange.com/questions/428614/take-output-from-grep-and-select-parts-for-variables

echo "Checks the execution of q19 on hive. q19-Hive-Run-Test" &&\
echo "Depending on test_install_on_new_machine.sh"
SECONDS=0
cd ~/wd/abench/a-bench
rm -rf ~/wd/abench/a-bench/tempwrite
mkdir -p ~/wd/abench/a-bench/tempwrite
filePathLog_Hive="~/wd/abench/a-bench/tempwrite/q19_hive.log"
filePathLog_Spark="~/wd/abench/a-bench/tempwrite/q19_spark.log"
echo "starting abench-infrastructur"
bash admin.sh senv_a
echo "starting abench-experiment-infrastructur"

countFailur=0

export TEST_QUERIES="q19"
export EX_TAG="hive_q19_test"
echo "Running now"
bash ./admin.sh run_by_env_bbv_hive | tee $filePathLog_Hive

#Check if out contains expected counts.
searchString=""
if grep -q $searchString $filePathLog_Hive; then
    echo "Found search-string (in hive): $searchString"
else
    echo "Could not found search-string (in hive): $searchString"
    ((countFailur++))
fi



export TEST_QUERIES="q19" &&\
export EX_TAG="spark_q19_test" &&\
bash ./admin.sh run_by_env_bbv_spark | tee $filePathLog_Spark

#Check if out contains expected counts.
searchString=""
if grep -q $searchString $filePathLog_Spark; then
    echo "Found search-string (in spark): $searchString"
else
    echo "Could not found search-string (in spark): $searchString"
    ((countFailur++))
fi


if [ "$countFailur" -eq "0" ]; then
   echo "Test successfully";
   exit;
else
    echo "Error, test failed";
    exit 1;
fi