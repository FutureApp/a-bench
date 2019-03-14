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

for var in "$@"
do
case  $var  in
#----------------------------------------------------------------------------[ Bench-Infrastructure ]--
(auto_install) #                -- Triggers the scripts to automatically install all necessary components
    bench_installMissingComponents 
;;
(senv) #                        -- Start the framework-env based on kubernetes and minikube
    bench_preflight
    
    minikube delete 
    minikube start --cpus 8 --memory 8192 || \
        (   echo "ERROR. Check the error-message, resolve the problem and then try again." && \
            exit 1)
    
    # minikube after work 
    util_sleep 10
    # minikube tunnel --cleanup
    # minikube tunnel
    eval $(minikube docker-env) 
    minikube addons enable heapster

    helm init
    util_sleep 10
    # -----------

    # start the influxDB-collector-client
    kubectl apply -f ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml

    kubernetes_waitUntilAllPodsAvailable 11 40 10 # expected containers; retrys; sleep-time[s]
    #### END
    echo -e     "${bench_tag} Startup procedure was successfully."
    echo -e     "${bench_tag} If you like to interact with docker in minikube then remember to link your docker with the one in minikube."
    echo -e     """${bench_tag} To do so, use the follwing command: 
                eval \$(minikube docker-env)
                
                """
;; 
(cold) #                        -- new code comes here
    client_pod_id=$(kubectl get pods --all-namespaces | grep influxdb-client | awk '{print $2}')
    #./$0 down_subproject
    start_time=$(date +%s%N)
    ./$0 run_sample
    end_time=$(date +%s%N)
    echo "s $start_time | e $end_time"
    echo "ende" 
    kubectl exec -it --namespace=kube-system $client_pod_id --\
    python3 /collector.py   --host monitoring-influxdb  --dbname k8s  \
                            --exportDir /results        --exportFile exp00 \
                            --lTimeBorder $start_time   --rTimeBorder $end_time

    kubectl cp kube-system/$client_pod_id:/results/exp00.xlsx .
    

;;
(server)
    cd dir_bench/images/influxdb-client/image/ && docker build -t data-server . && cd -

    kubectl delete  -f ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml
    kubectl apply   -f ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml
    sleep 15
    client_pod_id=$(kubectl get pods --all-namespaces | grep influxdb-client | awk '{print $2}')
    kubectl exec -it --namespace=kube-system $client_pod_id -- bash 
    python -m flask run --port 8080 --host 0.0.0.0 & 
    curl 'localhost:8080/test/xlsx?host=monitoring-influxdb&port=8086&dbname=k8s&filename=hello&lTimeBorder=0000000000000000000&rTimeBorder=9999999999999999999'
;;
#--------------------------------------------------------------------------------------------[ Demo ]--
(demo_from_scratch) #           -- Installs a complete infrastructure and runs a sample benchmark-experiment via bigbenchV2
    ./$0 auto_install
    ./$0 senv
    
    ./$0 down_subproject
    mini_ip=$(minikube ip)
    xdg-open http://$mini_ip:30002/dashboard/db/pods?orgId=1
    start_time=$(date + "%s")
    ./$0 run_sample
    end_time= $(date + "%s")


;;
#------------------------------------------------------------------------------------------[ Custom ]--
# Here is a good place to insert code which interacts with your framework or benchmark
(down_subproject) #             -- Downloads your custom-benchmark or framework
    mkdir -p submodules
    cd submodules
    git clone https://github.com/FutureApp/bigbenchv2.git
;;
(run_sample) #                  -- Executes the specification of your experiment
    cd submodules/bigbenchv2/a-bench_connector/experiments
    bash experi01.sh run # Contains the implementation of the experiment. Like build,deploy and execution orders.
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