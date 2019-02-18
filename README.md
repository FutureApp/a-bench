# A-Bench

A-Bench is a framework to run and execute your benchmark in dynamic and mod-friendly enviroment.
The framework itself is based on state of the art technologics like docker, kubernetes and helm.

* The framework will provide you with a skeleton directory infrastructure located under 'a-bench_connector'. Copy and paste this directory in you current benchmark and populate each directory with your code. For a showcast, check out the implementation of the adaption of the bigbenchv2 benchmark.  LINK. 

* The framework will provide you a basic experiment-infrastructure. To use it, check out the bench.sh file.

* In order to provide a system which measures some basic-parameteres like cpu, ram, and so on, just be sure that 
    your (docker)images inheritate from this image... [A-Bench Image](https://notProvided)

## Requirements

* Ubunto 18.03
* Internetconnection

## Get Started
. run admin.sh senv