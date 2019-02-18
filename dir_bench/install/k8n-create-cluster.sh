#!/bin/bash
# src: https://www.mirantis.com/blog/how-install-kubernetes-kubeadm/ 
sudo su
kubeadm init --pod-network-cidr=192.168.0.0/16

## new terminal
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
kubectl get pods --all-namespaces

# IMPORTANT for single machine execution!
kubectl taint nodes --all node-role.kubernetes.io/master-

# TEST
kubectl create namespace sock-shop
kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"

# CLEAN
kubectl delete namespace sock-shop
sudo kubeadm reset

# Kill kuber
kubectl -n kube-system delete deployment tiller-deploy
kubectl delete clusterrolebinding tiller
kubectl -n kube-system delete serviceaccount tiller

# removes the ip tabels
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X