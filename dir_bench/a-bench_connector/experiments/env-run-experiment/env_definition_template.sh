#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

# dep-locations
exutils="../../utils/exutils.sh"


# imports
source $exutils


bench_tag=${LB}[A-Bench]${NC}
ex_tag="experiment#01"

function check_query_number () {
    queryLikeToRun=$1
    if [ -z "$queryLikeToRun" ]; then
        echo "Error, you called the experiment without defining which experiment you would like to executes."; \
        exit 1
    fi
    
    echo "$queryLikeToRun"
}


if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$1"
do
case  $var  in

#--------------------------------------------------------------------------------------[ Experiment ]--
(run_ex) #                  -- ProcFedure to run the experiment described by the steps below. 
    # This is a simple skeleton to run your experiment in a normed order.
    # Normaly, there is nothing to change.
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    
    # Checks if a query is given at runtime and passed as an argument to this file
    queryLikeToRun=$2
    if [ -z "$queryLikeToRun" ]; then
        echo "Error, you called the experiment without defining which experiment you would like to executes."; \
        exit 1
    fi
    echo "Query-Mapper has recognized a query for execution: $queryLikeToRun"

    ./$0 cus_build
    util_sleep 10
    ./$0 cus_deploy
    util_sleep 60
    ./$0 cus_prepare
    util_sleep 10

    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 cus_workload $queryLikeToRun
    sleep 30
    end_time=$(exutils_UTC_TimestampInNanos)
    util_sleep 10

    pathToCollectDir=$(util_relResultDirPath $home_framework)
    exutils_auto_collectMeasurementsToZip $start_time $end_time $pathToCollectDir $ex_tag
    ./$0 cus_collect $start_time $end_time $pathToCollectDir $ex_tag

    util_sleep 10
    ./$0 cus_clean
    ./$0 cus_finish
;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(cus_build) #               -- Procedure to build your kube infrastructure (docker). via custom script.
    echo -e "$bench_tag System is building the infrastructure of the experiment.     | $RR cus_build $NC"
#    //TODO Your code comes here 
;;
(cus_deploy) #              -- Procedure to deploy your benchmark on kubernetes.     via custom script.
    echo -e "$bench_tag Deploying the infrastructure of the experiment.     | $RR cus_deploy $NC"
#    //TODO Your code comes here 
;;
(cus_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR cus_prepare $NC"
    #    //TODO Your code comes here 
;;
(cus_workload) #            -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR cus_workload $NC"
#   ----------------------------------------------
#    //TODO Your code comes here 
#   ---------------------------------------------- 
;;
(cus_collect) #             -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR cus_collect $NC"
    #    //TODO Your code comes here 
;;
(cus_clean) #               -- Procedure to clean up the enviroment if needed        via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR cus_clean $NC"
#    //TODO Your code comes here 
;;
(cus_finish) #              -- Procedure to signal that the experiment has finished. via custom script.   
    echo -e "$bench_tag Experiment finished.                                | $RR cus_finish $NC"
#    //TODO Your code comes here 
;;
#--------------------------------------------------------------------------------------------[ Help ]--
(--help|*) #                -- Prints the help and usage message
    exutils_dynmic_helpByCodeParse
;;
(check_query_number) # --- private
    echo "Calling check"
;;
esac     
done