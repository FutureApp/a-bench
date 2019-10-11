#!/bin/bash

echo "[Test-Dashboard] Check that live-monitoring is working"
echo "The test of presence must be performed with human eyes, at the moment"
myLocation=$(pwd)
adminModul_location=../..
cd $adminModul_location
bash ./admin.sh senv_a
echo "sleeping 5 minutes" && sleep 300
bash ./admin.sh show_all_das&

echo "sleeping 10 minutes" && sleep 600
echo "Test ends";
exit