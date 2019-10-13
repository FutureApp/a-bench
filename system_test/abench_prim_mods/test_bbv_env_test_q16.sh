#!/bin/bash

# Checks if all pods are available which are expected.
# Based on
# https://unix.stackexchange.com/questions/428614/take-output-from-grep-and-select-parts-for-variables

echo "Checks the execution of q16 on hive. Q16-Hive-Run-Test" &&\
echo "Depending on test_install_on_new_machine.sh"
SECONDS=0
cd ~/wd/abench/a-bench
rm -rf ~/wd/abench/a-bench/tempwrite
mkdir -p ~/wd/abench/a-bench/tempwrite
filePathLog_Hive=~/wd/abench/a-bench/tempwrite/q16_hive.log
filePathLog_Spark=~/wd/abench/a-bench/tempwrite/q16_spark.log
echo "starting abench-infrastructur"
bash admin.sh senv_a
echo "starting abench-experiment-infrastructur"

countFailur=0

# ----------------------------------------------c---------------------------------------[HIVE]
# sleep 60
# export TEST_QUERIES="q16"
# export EX_TAG="hive_q16_test"
# bash ./admin.sh run_by_env_bbv_hive | tee $filePathLog_Hive

# echo "Test on Hive-results"
# sStringCals="webpage#00	1895"
# sStringFetch="seconds, Fetched 10 row"
# if grep -q "$sStringCals" "$filePathLog_Hive"; then
#     echo "Find the calc results. [HIVE]"
# else
#     echo "Didn't find the calc results. [HIVE]"
#     ((countFailur++))
# fi

# -------------------------------------------------------------------------------------[Spark]
#Check if out. contains expected counts.
echo "Checks the execution of q16 on hive. Q16-spark-Run-Test"
echo "sleeping 160s now" && sleep 160
export TEST_QUERIES="q16"
export EX_TAG="spark_q16_test"
bash ./admin.sh run_by_env_bbv_spark | tee $filePathLog_Spark

echo "Test on spark-results"
sStringCals="webpage#00	1895"
sStringFetch="seconds, Fetched 10 row"
if grep -q "$sStringCals" "$filePathLog_Spark"; then
    echo "Find the calc results. [SPARK]"
else
    echo "Didn't find the calc results. [SPARK]"
    ((countFailur++))
fi

if grep -q "$sStringFetch" "$filePathLog_Spark"; then
    echo "Find the calc results. [SPARK]"
else
    echo "Didn't find the calc results. [SPARK]"
    ((countFailur++))
fi

if [ "$countFailur" -eq "0" ]; then
   echo "Test successfully";
   exit;
else
    echo "Error, test failed";
    exit 1;
fi