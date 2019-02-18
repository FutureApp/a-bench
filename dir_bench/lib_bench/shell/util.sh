#!/usr/bin/env bash

# Prints a dynamic help-message derived from the calling script. 
# Don't forget that the script must have to be in a specific format, otherwise
# the message will not show the expected result. Have fun!
function util_print_help () {
    echo -e  "${bench} USAGE $var <case>"
    echo -e 
    echo -e  The following cases are available:
    echo -e 
    # An intelligent means of printing out all cases available and their
 	# section. WARNING: -E is not portable!
    grep -E '^(#--+\[ |\([a-z_\|\*-]+\))' < "$0" | cut -c 2- | \
    sed -E -e 's/--+\[ (.+) \]--/\1/g' -e 's/(.*)\)$/ * \1/g' \
    -e 's/(.*)\) # (.*)/ * \1 \2/g'
}

# Prints a argument no applicable message with the provided argument itself.
#
# Argument 1: $1 -- Argument which is given
function util_parameter_unkown () {
    unknowArgument=$1
    echo "Argument is not applicable. Check the help of the script."
    echo "Provided arguement: < $unknowArgument >"
}

# Stops the exection for a specific sleep-time
#
# Argument 1: $1 -- Time to sleep in seconds
function util_sleep()
{   
    # scr:  https://stackoverflow.com/questions/12498304/using-bash-to-display-a-progress-working-indicator
    # user: William Pursell
    echo "Execution will stop for $1 seconds."
    sleep $1 &
    pid=$! # Process Id of the previous running command
    spin='-\|/'

    i=0
    counter=$(($1-1))   
    lCounter=0
    mod=0
    while kill -0 $pid 2>/dev/null
    do
      i=$(( (i+1) %4 ))
      printf "\r${spin:$i:1}    | $counter [s]"
      sleep .1
      lCounter=$((lCounter+1))
      mod=$((lCounter%10))
        if [ $mod -eq 0 ]
            then
            lCounter=0
            counter=$((counter-1))
        fi
    done
    echo ''
}

# Defines a unique time-based name for a result-directory, creates the directory if needed.
# The location is relative to the provied prefix. The function will return the absolut path
# via echoing.
# E.g:      /usr/home/test   // < Input
# Return:   /usr/home/test/results/20190101145559

# Argument 1: $1 -- Prefix - Path for the directory
# Return    :    -- Path to the directory.
function util_relResultDirPath()
{   
    home_framework=$1
    current_time=$(date "+%Y%m%d_%H_%M_%S")
    dir_name=$current_time
    pathToCollectDir=$home_framework/results/$dir_name
    #mkdir -p $pathToCollectDir
    
    # Return
    echo $pathToCollectDir
}