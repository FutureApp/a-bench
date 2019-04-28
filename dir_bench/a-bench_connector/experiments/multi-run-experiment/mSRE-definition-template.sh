#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

# dep-locations
exutils="../../utils/exutils.sh"

# imports
source $exutils


bench_tag=${LB}[A-Bench]${NC}

if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$1"
do
case  $var  in

#--------------------------------------------------------------------------------------[ Experiment ]--
(run_ex) #                  -- ProcFedure to run the experiment described by the steps below. 
    echo -e "Experiment TAG: #$ex_tag"
    echo -e "$bench_tag Running defined experiment... "
    callerExportDirectory=${2:-"./"}
    exTag=${3:-unkown3}
    exRunID=${4:-unkown4}
    exportLocationOfExperiment=$callerExportDirectory/$exRunID
    echo -e "$bench_tag --------------------------------------------------- [mSRE -$exRunID- S] "
    
    echo  $exportLocationOfExperiment
    ./$0 mSRE_prepare

    start_time=$(exutils_UTC_TimestampInNanos)
    ./$0 mSRE_workload 
    end_time=$(exutils_UTC_TimestampInNanos)
    exutils_auto_collectMeasurementsToZip $start_time $end_time $exportLocationOfExperiment $exTag
    
    ./$0 mSRE_collect $start_time $end_time $exportLocationOfExperiment $exTag
    ./$0 mSRE_clean
    echo -e "$bench_tag --------------------------------------------------- [mSRE -$exRunID- E] "

;;
#----------------------------------------------------------------------------[ Experiment-Functions ]--
(mSRE_prepare) #             -- Procedure to prepare a running enviroment.            via custom script.
    echo -e "$bench_tag Preparing the infrastructure for the workloads.     | $RR mSRE_prepare"
#    //TODO Your code comes here 
;;
(mSRE_workload) #            -- Procedure to run the experiment related workload.     via custom script.
    echo -e "$bench_tag Executing the workload of the experiment.           | $RR mSRE_workload $NC"

;;
(mSRE_collect) #             -- Procedure to collect the results of the experiment.   via custom script.
    echo -e "$bench_tag Downloading the results of the experiment.          | $RR mSRE_collect $NC"
    # Variables which are available for you at runtime. 
    experiment_start=$2
    experiment_end=$3
    exportDirectory=$4
    exportExperimentID=$5

#    //TODO Your code comes here 
;;
(mSRE_clean) #               -- Procedure to clean up the enviroment if needed        via custom script.
    echo -e "$bench_tag Cleaning the infrastructure.                        | $RR mSRE_clean $NC"
#    //TODO Your code comes here 
;;
 
#--------------------------------------------------------------------------------------------[ Help ]--
(--help|*) #                -- Prints the help and usage message
    echo -e  "${bench} USAGE $var <case>"
    echo -e 
    echo -e  The following cases are available:
    echo -e 
    # An intelligent means of printing out all cases available and their
 	# section. WARNING: -E is not portable!
    grep -E '^(#--+\[ |\([a-z_\|\*-]+\))' < "$0" | cut -c 2- | \
    sed -E -e 's/--+\[ (.+) \]--/\1/g' -e 's/(.*)\)$/ * \1/g' \
    -e 's/(.*)\) # (.*)/ * \1 \2/g'
;;
esac     
done