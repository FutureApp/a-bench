

# Pauses the execution of the script until at least the desired number 
# containers are up.
#
# Argument $1: number of container which you expect at least.
# Argument $2: numbers of retry's before  proceed further.
# Argument $3: sleep-time between the retry's.
#
# Return $return_value: 0 containers showed up; 1 otherwise
function kubernetes_waitUntilAllPodsAvailable {
    return_value=1
    COUNTER=0
    PODS_EXPECTED=$1
    COUNTER_MAX=$2
    sleep_time=$3
    while [ $COUNTER -lt $COUNTER_MAX ]; do
    	pods=$(kubectl get pods --all-namespaces | awk '$4=="Running" { ++count } END { print count }')
    	podcount=$((0 + $pods))
    	if (( $podcount >= $PODS_EXPECTED )); then
           echo -e "${bench} All expected Pods are running. Seems that the system is in a good mode and ready to proceed further"
           return_value=0
    	   break
        else
           	echo -e " ${bench} $podcount of $PODS_EXPECTED expected pods are available. Waiting $sleep_time s for up-rising. \
    		Before timeout ($COUNTER/$COUNTER_MAX)"  
    		let COUNTER=COUNTER+1 
    		sleep $sleep_time
        fi
    done
}
