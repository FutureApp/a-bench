#!/usr/bin/env bash

LB='\033[1;34m'
RR='\033[1;31m'
NC='\033[0m' # No Color

bench_tag=${LB}[A-Bench]${NC}
ex_tag="template_ex"


if [[ $# -eq 0 ]] ; then
    ./$0 --help
    exit 0
fi

for var in "$@"
do
case  $var  in
(promle) #  -- run prometheus on local host with node exporter.

    wget https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz
    tar xvfz node_exporter-*.*-amd64.tar.gz
    cd node_exporter-*.*-amd64
    ./node_exporter &

    wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz
    tar xvf prometheus-*.*-amd64.tar.gz
    cd prometheus-*
    ./prometheus --config.file=./prometheus.yml &
;;

(promlec) #  -- Checks output of promlc
    curl http://localhost:9100/metrics
    curl http://localhost:9100/metrics | grep "node_"
;;
(promlet) #  -- Checks output of promlc
    cd /tmp

    curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.16.0/node
    tar -xvf node_exporter-0.16.0.linux-amd64.tar.gz
    sudo mv node_exporter-0.16.0.linux-amd64/node_exporter /usr/local/bin/

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