#!/bin/bash
echo "Check if hive - env is startable. Hive-Umgebung-Test" &&\
echo "Depending on test_install_on_new_machine.sh"
SECONDS=0
cd ~/wd/abench/a-bench
echo "starting abench-infrastructur"
bash admin.sh senv_a
echo "Sleeping 3 minutes" && sleep 180
# Checks if all pods are available which are expected.
# Based on
# https://unix.stackexchange.com/questions/428614/take-output-from-grep-and-select-parts-for-variables
echo "starting abench-experiment-infrastructur HIVE"
bash admin.sh start_bbv_hive
echo "[Hive-Umgebung-Test] Test is detecting:"

podList=(   thadoop-hadoop-bench-driver thadoop-hadoop-hdfs-dn thadoop-hadoop-hdfs-nn 
            thadoop-hadoop-thrift-server thadoop-hadoop-yarn-nm-0 thadoop-hadoop-yarn-nm-1 
            thadoop-hadoop-yarn-rm-0 thadoop-mysql)
searchWord="Running"
countFailur=0
for pod in "${podList[@]}"
do
    var=( $(kubectl get pods -o wide --all-namespaces | grep $pod) )
    if [  "${var[3]}" == $searchWord ]; then
        echo "[x] $pod is runnning."
    else
        echo "[ ] $pod is not runnning."
        countFailur=$((var+1))
    fi
done

realEnd=$SECONDS
countFailur=0
echo "Time spend (total(install+init+waiting)): $realEnd s"

if [ "$countFailur" -eq "0" ]; then
   echo "Test successfully";
   exit;
else
    echo "Error, test failed";
    exit 1;
fi