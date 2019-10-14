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
filePathLog_Hive=~/wd/abench/a-bench/tempwrite/q19_hive.log
filePathLog_Spark=~/wd/abench/a-bench/tempwrite/q19_spark.log
echo "starting abench-infrastructur"
bash admin.sh senv_a
echo "starting abench-experiment-infrastructur"

countFailur=0

# ----------------------------------------------c---------------------------------------[HIVE]
sleep 60
export TEST_QUERIES="q19"
export EX_TAG="hive_q19_test"
bash ./admin.sh run_by_env_bbv_hive | tee $filePathLog_Hive
echo "Test on Hive-results"

sStringCals="Fetched: 10 row(s)"
sStringFetch="seconds, Fetched 10 row"
if grep -q "$sStringCals" "$filePathLog_Hive"; then
    echo "Found the calc results. [HIVE]"
else
    echo "Didn't find the calc results. [HIVE]"
    ((countFailur++))
fi

# -------------------------------------------------------------------------------------[Spark]
#Check if out. contains expected counts.
echo "Checks the execution of q19 on hive. q19-spark-Run-Test"
echo "sleeping 160s now" && sleep 160
export TEST_QUERIES="q19"
export EX_TAG="spark_q19_test"
bash ./admin.sh run_by_env_bbv_spark | tee $filePathLog_Spark

echo "Test on spark-results"
sStringCals="Fetched 10 row"
if grep -q "$sStringCals" "$filePathLog_Spark"; then
    echo "Found the calc results. [SPARK]"
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

# Example output of cal in hive or spark
# 3       11      2013    2
# 25      8       2013    2
# 21      1       2013    1
# 1       5       2014    1
# 24      3       2013    1
# 30      7       2013    1
# 28      11      2014    1
# 14      9       2013    1
# 16      12      2013    1
# 10      12      2013    1