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





if [[ $# -eq 0 ]] ; then
    util_print_help
    exit 0
fi

for var in "$@"
do
case  $var  in
#----------------------------------------------------------------------------[ Bench-Infrastructure ]--
(mini) #                    -- Starts a simple minikube enviroment.
    minikube stop
    minikube delete 
    minikube start  --memory=12000
    
    eval $(minikube docker-env) 
    minikube addons enable heapster

    helm init
    
    kubernetes_waitUntilAllPodsAvailable 10 40 10 # expected containers; retrys; sleep-time[s]
    echo -e     "${bench_tag} Startup procedure was successfully."
    echo -e     "${bench_tag} If you like to interact with docker in minikube then remember to link your docker with the one in minikube."
    echo -e     """${bench_tag} To do so, use the follwing command: 
                eval \$(minikube docker-env)
                
                """
;; 
(images) #                  -- Builds the desired images. At the moment thadoop only
    eval $(minikube docker-env)
    home_dockerfile='./images/hive'
    cd $home_dockerfile
    docker build -t thadoop .
;;

#------------------------------------------------------------------------------------------[ Runner ]--

(run_ex) #                  -- Executes a specific experiment. -deploy,prepare,workload,collect_result,finish message-
    echo -e "$bench_tag Running defined experiment... "
    ./$0 cus_deploy
    util_sleep 60
    ./$0 cus_prepare
    util_sleep 20
    ./$0 cus_workload
    util_sleep 20
    ./$0 cus_collect
    util_sleep 20
    ./$0 cus_clean
    ./$0 cus_finish
;;
#------------------------------------------------------------------------------------------[ Custom ]--
(cus_deploy) #              -- Deploy a custom (benchmark) enviroment on minikube   via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR cus_deploy $NC"
    nameOfHadoopCluster='thadoop'
    cd $home_framework/charts
    helm delete     --purge $nameOfHadoopCluster
    helm install    --name  $nameOfHadoopCluster hadoop
    cd $home_start
    echo -e  "${bench_tag} hadoop cluster started and named as < $nameOfHadoopCluster > ..."
;;
(cus_prepare) #             -- Prepare the infrastructure for the experiments       via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR cus_prepare"
    loc_des_container="thadoop-hadoop-hdfs-nn-0"
    kubectl cp $home_bench_sub_bigbench $loc_des_container:/
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            echo Copying benchmark-data to HDFS         && \
    														bash ./schema/CopyData2HDFS.sh              && \
                                                            echo Copying benchmark-data was successfull && \
                                                            echo Starting to initialize db-schema       && \
    														schematool -dbType derby -initSchema 
                                                        "  
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            echo Creating BigBenchV2-DB                 && \
                                                            hive -f schema/HiveCreateSchema.sql 
                                                        "
;;
(cus_workload) #            -- Execute your workload (experiment)                   via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.          | $RR cus_workload $NC"
    loc_des_container="thadoop-hadoop-hdfs-nn-0"
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            hive -f queries/q29.hql 
                                                        "
;;
(cus_collect) #             -- Collect the results of your experiment               via custom script.
    echo -e "$bench_tag Downloading the results of the experiment          | $RR cus_collect $NC"
    loc_des_container="thadoop-hadoop-hdfs-nn-0"
    kubectl exec -ti $loc_des_container -- bash -c      "   cd $home_container_bench                    && \
                                                            mkdir 'results'                             && \
                                                            hadoop fs -get '/' './results'              && \
                                                            echo 'Hadoop export successfull.'
                                                        "
    # defines the result-dir name
    pathToCollectDir=$(util_relResultDirPath $home_framework)
    kubectl cp $loc_des_container:$home_container_bench/results $pathToCollectDir
    echo -e "$bench_tag Download complete. Your data are located under <${LB} $pathToCollectDir ${NC}>"
;;
(cus_clean) #               -- Clean up the infrastructure                          via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR cus_clean $NC"
;;
(cus_finish) #              -- Prints the 'ex finish' message
    echo -e "$bench_tag Experiment finished.                            | $RR cus_finish $NC"
;;
(cus_con) #                 -- [DEBUG] Connects the current shell with the shell of the des. container.
    loc_des_container="thadoop-hadoop-hdfs-nn-0"
    kubectl exec -ti $loc_des_container -- bash -c   "      bash"
;;
#--------------------------------------------------------------------------------------------[ Help ]--
(--help) #                  -- Prints the help and usage message
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