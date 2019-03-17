# A-Bench

A-Bench is a framework to run and execute your benchmark in dynamic and mod-friendly enviroment.
The framework itself is based on state of the art technologics like docker, kubernetes and helm.

* The framework will provide you with a skeleton directory infrastructure located under 'a-bench_connector'. Copy and paste this directory in you current benchmark and populate each directory with your code. For a showcast, check out the implementation of the adaption of the bigbenchv2 benchmark.  LINK.

* The framework will provide you a basic experiment-infrastructure. To use it, check out the bench.sh file.

* In order to provide a system which measures some basic-parameteres like cpu, ram, and so on, just be sure that
    your (docker)images inheritate from this image... [A-Bench Image](https://notProvided)

## Get Started

### Requirements

* Ubunto 18.03
* Internet-connection

## Demonstration # From 0 to GO

First, download this Repository and navigate to the root of this project where you can find the admin.sh script.
If you have a working minikube-instance and helm-support then you can skip to step 2. If not, then run the follwing code to install the enviroment which is needed in order to use the full capacity of a-Bench. Execute:

Assuming that have a clean installation of ubuntu 18.03, execute the following step one after another.

### Step 1 # Setup the enviroment

``` sh
    sudo ./admin.sh auto_install
```

If any prompt shows up, then accept them. Please, restart you computer after installisation completed. Otherwise, the current user hasn't access to Docker and can't execute any workflow.

### Step 2 # Deploy the a-bench infrastructure

In order to run any workflow, we have to start the enviroment. To do so, execute the following command from the root-direcotry of this  project. This will start the enviroment and downloads all neccessary modules like the benchmark (BigBenchV2) which implements the working adapter between the ABench and the framework itself.

``` sh
    ./admin.sh senv
    ./admin.sh down_subproject
```

### Step 3 # Run a sample-workflow / experiment

The hole infrastrukture should be up and running now and able to execute our experiments. The framework contains a sample experiments which will show and teach us how to use the framework. Run the following code form the root-directory of this project in order to run a sample experiments which defins his own infrastruture and the experiment-workflow of curse. Right now, it will start a hadoop infrastructure with HIVE and executes the test-case 29 of BigBenchV2. Later on, the framework will collect all neccessary performance-data like cpu-workload, network-trafic etc. .

``` sh
    ./admin.sh run_sample
```

### Step 4 # Analyse and inspect the data

At the end of the experiment, the framework will gather all interesting performance-data(like menioned) and aggregated a excel-file containing these. If the workflow finished, you will be able to see an excel-sheet with the name xxx in your current work-directory.

### Step X # Fast way

Of course, there is a way to execute all steps above, excluded the first one, with a single command. Navigate to the root-directory of this project and execute the following code: Besides the 

``` sh
    ./admin.sh demo_from_scratch
```