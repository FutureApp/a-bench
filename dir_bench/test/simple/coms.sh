# CREATION
kubectl create -f namenode.yaml; kubectl create -f datanode.yaml

# Deletion
kubectl delete -f namenode.yaml; kubectl delete -f datanode.yaml


# FORWARDING
kubectl port-forward hdfs-namenode-0 50070:50070 & firefox http://localhost:50070/dfshealth.html#tab-datanode
kubectl port-forward thadoop-hadoop-hdfs-nn-0 50070:50070 & firefox http://localhost:50070/dfshealth.html#tab-datanode

kubectl scale statefulset hdfs-datanode --replicas=1

#firefox
http://localhost:50070/dfshealth.html#tab-datanode

# TEST
## creates a basic file

kubectl exec -t hdfs-namenode-0 -- bash -c "hadoop fs -mkdir /tmp; hadoop fs -put /bin/systemd /tmp/;hadoop fs -ls /tmp"
kubectl exec -t hadoop-hadoop-hdfs-nn-0 -- bash -c "hadoop fs -mkdir /tmp; hadoop fs -put /bin/systemd /tmp/;hadoop fs -ls /tmp"
kubectl exec -t hadoop-hadoop-hdfs-nn-0 -- bash -c "apt-get update && apt-get install net-tools; arp -a"

# hadoop fs -mkdir /tmp
# hadoop fs -put /bin/systemd /tmp/ # just upload the systemd binary into hdfs to see if it working (could be any file)
# hadoop fs -ls /tmp
Found 1 items
-rw-r--r--   3 root supergroup    1313160 2017-05-03 21:15 /tmp/systemd


# input
## Auf so einen link versucht das system zuzugreifen
hdfs://hdfs-namenode-0.hdfs-namenode.default.svc.cluster.local:8020/user/dats

# Download over website trys to get the data from --- 
curl "http://hdfs-datanode-0.hdfs-datanode.default.svc.cluster.local:50075/webhdfs/v1/tmp/systemd?"\
"op=OPEN&namenoderpcaddress=hdfs-namenode-0.hdfs-namenode.default.svc.cluster.local:8020&offset=0"  \
--output result

