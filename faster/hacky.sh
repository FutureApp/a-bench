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
(pre-install)
    sudo apt-get update && apt-get install -y apt-transport-https
    
    sudo apt install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker

    # ? helm

    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

    sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-bionic main"
    sudo apt install kubeadm 
    sudo swapoff -a
;;
(start) #  -- starts the kube infrastructure
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16
    mkdir -p $HOME/.kube
    sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    # used to create a pod-network
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    kubectl get pods --all-namespaces

    #allow master to run applications
    kubectl taint node $(hostname) node-role.kubernetes.io/master:NoSchedule-
;;
(rbac_tiller_admin) #  -- Installs tiller on rbac cluster.
    kubectl create -f ./rbac-config.yml
    helm init --service-account tiller
;;
(test-app)
    helm install stable/nginx-ingress --name nginx
    helm install -f test-app.yaml --name test-mon
    kubectl create -f service-monitor.yml
;;
(prom) #  -- starts prometheus
    echo "Run prom"
    helm install --name prom stable/prometheus
;;
(prom-op) #  -- Runs the prometheus-
    # Based on https://itnext.io/kubernetes-monitoring-with-prometheus-in-15-minutes-8e54d1de2e13
    helm install stable/prometheus-operator --name prometheus-operator --namespace monitoring
    kubectl port-forward -n monitoring prometheus-prometheus-operator-prometheus-0 9090 &
    kubectl \
        port-forward $(kubectl get  pods --selector=app=grafana -n  monitoring --output=jsonpath="{.items..metadata.name}") \
        -n monitoring  3000 &

    kubectl port-forward -n monitoring alertmanager-prometheus-operator-alertmanager-0 9093 &
;;
(debug) #  -- Debug
    echo "Run Debug"
    kubectl proxy &
    http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
;;
(clean) #  -- Clean-operation
    echo "Run clean"
;;
(hclean) #  -- hard clean
    echo "Run hard clean"
    kubectl delete --all pods,deployments,services --namespace=default
    kubectl delete --all deployments --namespace=default
    sudo kubeadm reset
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