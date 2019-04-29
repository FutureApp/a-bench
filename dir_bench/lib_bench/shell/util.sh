#!/usr/bin/env bash

# Prints a dynamic help-message derived from the calling script. 
# Don't forget that the script must have to be in a specific format, otherwise
# the message will not show the expected result. Have fun!
# Greetings to Ma_Sys.ma -- https://github.com/m7a --
# The code-snipped was implemented by him.
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
    echo "Execution will pause for $1 seconds."
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
# Return    :    -- Path to  directory.
function util_relResultDirPath()
{   
    home_framework=$1
    current_time=$(date "+%Y%m%d_%H_%M_%S")
    dir_name=$current_time
    pathToCollectDir=$home_framework/results/$dir_name
    
    # Return
    echo $pathToCollectDir
}

# Collects the measurements by connecting to a influxdb-client which holds a specific 
# python-script to do the work. The collected data will be then saved in specific directory for later
# analysis. All data will be saved in the provided directory. Path will be created if the location 
# doesn't exists. If



# Argument 1: $1    -- Unix-timestamp as start-stamp in seconds e.g from date + "%s"
# Argument 2: $2    -- Unix-timestamp as end-stamp in seconds e.g from date + "%s"
# Argument 3: $3    -- Identifier of the container where method can connect to in order to  
#                      have access to the measurements
# Argument 3: $4    -- Optional -- If not provided, a timesamp for the dir-name will be used

# Returns   :       -- Path to location where the data was saved
function util_collectMeasurements()
{   
    default_prefix_dirname="~"
    start_stamp=$1
    end_stamp=$2
    client_container=$3
    opt_dirname=$4
#              &&   empty          || not empty
    [  -z $4 ] &&   opt_dirname=`util_relResultDirPath $default_prefix_dirname` \
                ||  opt_dirname=$4
    
    echo "Collector called with the following parameters:"
    echo "start: <$1>, end:<$2>, client:<$3>, dirname:<$opt_dirname>"
}