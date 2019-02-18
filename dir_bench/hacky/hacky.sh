kubectl exec -t thadoop-hadoop-hdfs-nn-0 -- bash -c "mkdir -p /export; cd /export; \
                                                    hdfs dfs -get /. /export"; \
kubectl cp thadoop-hadoop-hdfs-nn-0:/export .                                                     