#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[0;31m'
NC='\033[0m' # No Color
bench_tag=${LB}[A-Bench]${NC}
MISSING_tag=${RR}Missing${NC}


problemCounter=0




# Verify if the specific command is executable. Based on the result, a specific message 
# will be printed. For each missing component, a intern counter will be increased. 
#
# Argument 1: $1 -- Command to check for.
function bench_preflightCheck {
    commandToCheck=$1
    
    if ! [ -x "$(command -v $commandToCheck)" ]; then

        echo -e "[ ] ${commandToCheck} is not installed.        | $MISSING_tag" >&2
        problemCounter=$((problemCounter+1))
    else
        echo "[x] ${commandToCheck}  detected."
    fi

}
function finish_message {   

    echo ''
    echo ''
    echo ''
    echo ''
    echo "Number of missing components: $problemCounter"
    echo ''
    if [ $problemCounter -eq 0 ]
        then
        echo "All components are available and the system should be ready for use."
    else
        echo "Please, fix the missing components before proceding further."
        echo "Normally, the benchmark is able to automatically install all needed components. "
        echo "In order to try the automatically installation. Try:"
        echo """
                    $0 autoInstall
            """ 
        echo "If the error message presist, try to install the needed components manually."
    fi
}


# Verifys if all needed components are instsalled. At the end, the number of missing 
# components will be displayed 
#
function bench_preflight {
    echo -e "$bench_tag Preflight in progress..."

   
    for component in git docker virtualbox minikube kubectl lauch
    do
      bench_preflightCheck $component
    done

    finish_message
}

# Runner
bench_preflight