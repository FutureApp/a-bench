#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color
bench_tag=${LB}[A-Bench]${NC}


home_framework=$(pwd)
home_bench_sub_bigbench=$home_framework/submodules/bigbenchv2
home_container_bench=/bigbenchv2

# all functions calls are indicated by prefix <util_xxx>
source dir_bench/lib_bench/shell/util.sh
# all functions calls are indicated by prefix <kubernetes_xxx>
source dir_bench/lib_bench/shell/kubernetes.sh
# all functions calls are indicated by prefix <bench_xx>
source dir_bench/lib_bench/shell/bench.sh




if [[ $# -eq 0 ]] ; then
    util_print_help
    exit 0
fi

for var in "$1"
do
case  $var  in
#------------------------------------------------------------------------------------[ ABench - prim ]--
(auto_install) #                -- Triggers the scripts to automatically install all necessary components
    bench_installMissingComponents 
;;
(senv_a) #                        -- Start the framework-env based on kubernetes and minikube
    bench_preflight
    
    minikube delete 
    minikube start --cpus 8 --memory 8192 || \
        (   echo "ERROR. Check the error-message, resolve the problem and then try again." && \
            exit 1)
    
    # minikube after work 
    # workaround to handle time based desync  between host and  minikube
    # src: https://github.com/kubernetes/minikube/issues/1378
    minikube ssh -- docker run  -it --rm --privileged --pid=host alpine nsenter \
                                -t 1 -m -u -n -i date -u $(date -u +%m%d%H%M%Y)
    util_sleep 10
    eval $(minikube docker-env) 
    minikube addons enable heapster

    helm init
    util_sleep 10
    # -----------

    # start the influxDB-collector-client
    cd ./dir_bench/images/influxdb-client/image/ && docker build -t data-server . && cd -
    kubectl apply  -f   ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml
    kubectl create -f   ./dir_bench/images/influxdb-client/kubernetes/service_influxdb-client.yaml

    kubernetes_waitUntilAllPodsAvailable 11 40 10 # expected containers; retrys; sleep-time[s]
    #### END
    echo -e     "${bench_tag} Startup procedure was successfully."
    echo -e     "${bench_tag} If you like to interact with docker in minikube then remember to link your docker with the one in minikube."
    echo -e     """${bench_tag} To do so, use the follwing command: 
                eval \$(minikube docker-env)
                
                """
;; 
(senv_b) #                        -- Start the framework-env in configuration B with cloud-infrastructure (not available right now)
    echo "The framework in configuration B is not available right now."
;;

#----------------------------------------------------------------------------------------[ Examples ]--
(demo_from_scratch) #           -- Installs a complete infrastructure and runs a sample benchmark-experiment via bigbenchV2
    ./$0 senv_a
    sleep 15
    export_file_name="exo001.xlsx"
    mini_ip=$(minikube ip)
    linkToDashboard="http://$(minikube ip):30002/dashboard/db/pods?orgId=1&var-namespace=kube-system&var-podname=etcd-minikube&from=now-15m&to=now&srefresh=10s"
    ./$0 down_subproject
    xdg-open $linkToDashboard

    # experiment execution
    s_time="$(date -u +%s%N)"
    ./$0 run_sample
    e_time="$(date -u +%s%N)"
    util_sleep 60 # Gives the System some time to write all mes-data into the influxdb - instance
    
    data_location="./exo001.xlsx"
    ipxport_data_client=$(bench_minikube_nodeExportedK8sService_IPxPORT influxdb-client) # Port of the service is dynamic, therefore this query
    url="http://$ipxport_data_client/xlsx?host=monitoring-influxdb&port=8086&dbname=k8s&filename=hello&lTimeBorder=$s_time&rTimeBorder=$e_time"

    echo "Calling the following URl <$url>"
    curl "$url" --output $data_location
    echo "Data is saved under $data_location"
;;
#------------------------------------------------------------------------------------------[ Custom ]--
# Here is a good place to insert code which interacts with your framework or benchmark
(down_subproject) #             -- Downloads your custom-benchmark or framework
    mkdir -p submodules
    cd submodules
    git clone https://github.com/FutureApp/bigbenchv2.git
;;
(run_sample) #                  -- Executes the experi01.sh experiment from bigbenchv2
    cd submodules/bigbenchv2/a-bench_connector/experiments
    bash experi01.sh run # Contains the implementation of the experiment. Like build,deploy and execution orders.
;;
#---------------------------------------------------------------------------------------------[ DEV ]--
(dev_hacky) #                   -- Hacky-Code
    echo "Hacky got triggered"
    echo "Param 0 $0"
    echo "Param 1 $1"
    echo "Param 2 $2"
;;
(dev_code) #                    -- Executes dev-code Development-purpose
    docker rmi -f data-server
    kubectl delete  -f   ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml
    kubectl delete  -f   ./dir_bench/images/influxdb-client/kubernetes/service_influxdb-client.yaml
    util_sleep 60
    cd ./dir_bench/images/influxdb-client/image/ && docker build -t data-server . && cd -
    kubectl apply   -f   ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml
    kubectl create  -f   ./dir_bench/images/influxdb-client/kubernetes/service_influxdb-client.yaml
    
    util_sleep 60
    ipxport_data_client=$(bench_minikube_nodeExportedK8sService_IPxPORT influxdb-client)
    xdg-open "http://$ipxport_data_client/pings"
;;
(dev_pcc) #                     -- Executes the process to collect some measurements from the data-client
    ./$0 dev_code
    s_time=$(bench_UTC_TimestampInNanos)
    util_sleep 120
    e_time=$(bench_UTC_TimestampInNanos)
    
    ipxport_data_client=$(bench_minikube_nodeExportedK8sService_IPxPORT influxdb-client)
    url="http://$ipxport_data_client/csv?host=monitoring-influxdb&port=8086&dbname=k8s&filename=experi01&fromT=$s_time&toT=$e_time"

    data_location="./experi.zip"
    echo "Calling the following URl <$url>"
    curl "$url" --output $data_location
    echo "Data is saved under $data_location"
;;

#--------------------------------------------------------------------------------------------[ Help ]--
(--help) #                      -- Prints the help and usage message
    util_print_help
;;
    (*) 
    util_parameter_unkown $var
    echo ""
    echo "Execution failed with exit-code 1"
    util_print_help
    exit 1
;;
esac     
done