#!/usr/bin/env bash
#@ Author: Michael Czaja <michael-czaja-arbeit@hotmail.de>

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
#--------------------------------------------------------------------------------[ ABench - Presteps ]--
(auto_install) #                -- Triggers all scripts to automatically install all necessary components.
    bench_installMissingComponents 
;;

#---------------------------------------------------------------------[ ABench - Infrastructure ]--
(senv_a) #                      -- Starts the framework-env in configuration A with kubernetes and minikube.
    bench_preflight
    numberCPUs=${2:-4}      # Sets default value 4 CPUs
    numberMemory=${3:-6144} # Sets default value 6144 MB
    numberDiskSizeGB="${4:-16}g"
    minikube delete 
    minikube start --cpus $numberCPUs --memory $numberMemory --disk-size $numberDiskSizeGB || \
        (   echo "ERROR. Check the error-message, resolve the problem and then try again." && \
            exit 1)
    
    # minikube after work 
    # workaround to handle time based desync  between host and  minikube
    # src: https://github.com/kubernetes/minikube/issues/1378
    minikube ssh -- docker run  -it --rm --privileged --pid=host alpine nsenter \
                                -t 1 -m -u -n -i date -u $(date -u +%m%d%H%M%Y)
    util_sleep 10
    eval $(minikube docker-env) 
    minikube addons enable addon-manager
    minikube addons enable default-storageclass
    minikube addons enable dashboard
    minikube addons enable storage-provisioner   
    minikube addons enable heapster

    helm init
    util_sleep 10
    # -----------

    # starts the influxDB-collector-client
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

(senv_b) #                      -- Starts the framework-env. in configuration B within a cloud-infrastructure - not supported-
    echo "The framework doesn't support the configuration B (cloud-env) right now."
;;



#----------------------------------------------------------------------------------------[ Examples ]--
(demo_from_scratch_sre) #       -- Deploys the (config A)-environment;Executes a single-run-experiment specification from the BBV2-Modul
    ./$0 senv_a
    sleep 15
    mini_ip=$(minikube ip)
    linkToDashboard="http://$(minikube ip):30002/dashboard/db/pods?orgId=1&var-namespace=kube-system&var-podname=etcd-minikube&from=now-15m&to=now&refresh=10s"

    # opens some dash-boards    
    xdg-open $linkToDashboard &
    minikube dashboard &

    # downloads the sub-module bbv2
    ./$0 down_submodules
    # experiment execution
    ./$0 run_sample_sre_bbv
    url="http://$ipxport_data_client/csv-zip?host=monitoring-influxdb&port=8086&dbname=k8s&filename=experi01&fromT=$s_time&toT=$e_time"
;;
(demo_from_scratch_mre) #       -- Deploys the (config A)-environment; Executes a multi-run-experiment specification from the BBV2-Modul
    ./$0 senv_a
    sleep 15
    mini_ip=$(minikube ip)
    linkToDashboard="http://$(minikube ip):30002/dashboard/db/pods?orgId=1&var-namespace=kube-system&var-podname=etcd-minikube&from=now-15m&to=now&refresh=10s"

    # opens some dash-boards    
    xdg-open $linkToDashboard &
    minikube dashboard &

    # downloads the sub-module bbv2
    ./$0 down_submodules
    # experiment execution
    ./$0 run_sample_mre_bbv
    #url="http://$ipxport_data_client/csv-zip?host=monitoring-influxdb&port=8086&dbname=k8s&filename=experi01&fromT=$s_time&toT=$e_time"
;;
(demo_from_scratch_env) #       -- Deploys the (config A)-environment; Executes a env-run-experiment specification from the BBV2-Modul
    ./$0 senv_a
    sleep 15
    mini_ip=$(minikube ip)
    linkToDashboard="http://$(minikube ip):30002/dashboard/db/pods?orgId=1&var-namespace=kube-system&var-podname=etcd-minikube&from=now-15m&to=now&refresh=10s"

    # opens some dash-boards    
    xdg-open $linkToDashboard &
    minikube dashboard &

    # downloads the sub-module bbv2
    ./$0 down_submodules
    
    export TEST_QUERIES="q16" &&\
    export EX_TAG="experiment_tag_sample" &&\
    ./$0 run_by_env_bbv
    #url="http://$ipxport_data_client/csv-zip?host=monitoring-influxdb&port=8086&dbname=k8s&filename=experi01&fromT=$s_time&toT=$e_time"
;;
#-----------------------------------------------------------------------------------------[ Modules ]--
# Here is a good place to insert code which download your framework or benchmark
(down_submodules) #             -- Downloads or updates all abench-modules.
    ./$0 down_bbv_two
    echo "Download has finished [down_all]"
;;
(down_bbv_two) #                -- Downloads or updates the bbv2-modul.
    mkdir -p submodules
    cd submodules
    git clone https://github.com/FutureApp/bigbenchv2.git
    cd bigbenchv2 && git pull
    echo "Download has finished [bbv2-modul]"
;;

#----------------------------------------------------------------------------------[ Custom-runners ]--
(run_sample_sre_bbv) #          -- Executes the SRE_experiment_demoHIVE.sh experiment from bigbenchv2
    cd submodules/bigbenchv2/a-bench_connector/experiments/single-run-experiment/
    bash SRE_experiment_demoHIVE.sh run_ex # Contains the implementation of the experiment. Like build,deploy and execution orders.
;;
(run_sample_mre_bbv) #          -- Executes the MRE_experiment_demoHIVE.sh experiment from bigbenchv2 two times
    cd submodules/bigbenchv2/a-bench_connector/experiments/multi-run-experiment/
    bash MRE_experiment_demoHIVE.sh run_ex 2 # Contains the implementation of the experiment. Like build,deploy and execution orders.
;;
(run_sample_sre_spark) #        -- Executes the SRE_experiment_demoSPARK.sh experiment from bigbenchv2
    cd submodules/bigbenchv2/a-bench_connector/experiments/single-run-experiment/
    bash SRE_experiment_demoSPARK.sh run_ex # Contains the implementation of the experiment. Like build,deploy and execution orders.
;;
#----------------------------------------------------------------------------------------[ API-Interface ]--

(run_by_env_bbv_hive) #         -- Performs series of experiments using the bbv2-modul +HIVE Enviroment+
    TEST_QUERIES_TO_CALL=($TEST_QUERIES)
    if [ -z "$TEST_QUERIES_TO_CALL" ] ; then
        echo "Attention. No queries detected. Check the System-ENV > TEST_QUERIES"
    else
        echo "ENV-Looper-Experiment is starting now."
        for test_query in ${TEST_QUERIES_TO_CALL[@]}; do
            echo "Running $test_query"
            cd submodules/bigbenchv2/a-bench_connector/experiments/env-run-experiment/
            bash ENV_experiment_demoHIVE.sh run_ex  $test_query
        done
    fi
    cd -
;;
(run_by_env_bbv_spark) #        -- Performs series of experiments using the bbv2-modul +SPARK Enviroment+
    TEST_QUERIES_TO_CALL=($TEST_QUERIES)
    if [ -z "$TEST_QUERIES_TO_CALL" ] ; then
        echo "Attention. No queries detected. Check the System-ENV > TEST_QUERIES"
    else
        echo "ENV-Looper-Experiment is starting now."
        for test_query in ${TEST_QUERIES_TO_CALL[@]}; do
            echo "Running $test_query"
            cd submodules/bigbenchv2/a-bench_connector/experiments/env-run-experiment/
            bash ENV_experiment_demoSPARK.sh run_ex  $test_query
        done
    fi
    cd -
;;
#------------------------------------------------------------------------------[ Abench-Images ]--
(build_all_dockerimages) #      -- Builds all docker-images below.
    ./$0 dev_build_dataserver
    ./$0 dev_build_bbv_two_modul
;;
(build_dataserver) #            -- Builds the image  abench data-server image. 
    #builds the data-server componente
    cd ./dir_bench/images/influxdb-client/image/ && docker build -t data-server . && \
    docker build -t jwgumcz/data-server . && \
    cd -
    # code to build other componentes belongs here
;;
(build_bbv_two_modul) #         -- Builds the image for the bbv2-modul. 
    #builds the bbv2-modul image
    ./$0 down_bbv_two
    cd submodules/bigbenchv2/a-bench_connector/images/hive
    docker build -t jwgumcz/abench_bbv2 .
    cd -
;;
#---------------------------------------------------------------------------------------[ DEV ]--
(dev_con) #                     -- Connects to the bench-driver pod via kubernates-function. 
    kubectl exec -it thadoop-hadoop-bench-driver-0  bash
;;
(dev_code) #                    -- Executes dev-related code.
    docker rmi -f data-server
    kubectl delete  -f   ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml
    kubectl delete  -f   ./dir_bench/images/influxdb-client/kubernetes/service_influxdb-client.yaml
    util_sleep 60

    kubectl apply   -f   ./dir_bench/images/influxdb-client/kubernetes/deploy_influxdb-client.yaml
    kubectl create  -f   ./dir_bench/images/influxdb-client/kubernetes/service_influxdb-client.yaml
    
    util_sleep 60
    ipxport_data_client=$(bench_minikube_nodeExportedK8sService_IPxPORT influxdb-client)
;;
(dev_pcc) #                     -- Executes dev-related code for testing code-snipped's
    ./$0 dev_code
    s_time=$(bench_UTC_TimestampInNanos)
    util_sleep 10
    e_time=$(bench_UTC_TimestampInNanos)
    
    ipxport_data_client=$(bench_minikube_nodeExportedK8sService_IPxPORT influxdb-client)
    url="http://$ipxport_data_client/csv-zip?host=monitoring-influxdb&port=8086&dbname=k8s&filename=experi01&fromT=$s_time&toT=$e_time"

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
