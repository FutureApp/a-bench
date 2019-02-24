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
(auto_install)
    bench_installMissingComponents 
;;
(senv) #                        -- Starts a simple minikube enviroment.
    bench_preflight
    
    minikube delete 
    minikube start  --memory=8000 || \
        (   echo "ERROR. Check the error-message, resolve the problem and then try again." && \
            exit 1)
    
    # minikube after work 
    util_sleep 10
    # minikube tunnel --cleanup
    # minikube tunnel
    eval $(minikube docker-env) 
    minikube addons enable heapster

    helm init
    
    kubernetes_waitUntilAllPodsAvailable 10 40 10 # expected containers; retrys; sleep-time[s]
    echo -e     "${bench_tag} Startup procedure was successfully."
    echo -e     "${bench_tag} If you like to interact with docker in minikube then remember to link your docker with the one in minikube."
    echo -e     """${bench_tag} To do so, use the follwing command: 
                eval \$(minikube docker-env)
                
                """
   # minikube dashboard
;; 
#-----------------------------------------------------------------------------------------[ Samples ]--
(down_subproject) #             -- Execute a sample-experiment
    mkdir -p submodules
    cd submodules
    git clone https://github.com/FutureApp/bigbenchv2.git
;;
(run_sample) #                  -- Execute a sample-experiment
    cd submodules/bigbenchv2/a-bench_connector/experiments
    bash experi01.sh run # Contains the implementation of the experiment. Like build,deploy and execution orders.
;;
#------------------------------------------------------------------------------------------[ Simple ]--
(one_click) #                   -- Installs the framework + bigbench and executes a sample experiment.
    ./$0 auto_install
    ./$0 senv
    
    ./$0 down_subproject
    ./$0 run_sample
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