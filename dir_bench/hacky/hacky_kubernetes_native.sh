#!/usr/bin/env bash

# Install all components
sudo apt-get update && apt-get install -y apt-transport-https

sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add 
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list


apt-get update
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# start the kubernetes infrastructure
sudo kubeadm init                                           && \
mkdir -p $HOME/.kube                                        && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config    && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config             

sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml

sudo kubectl run --image=nginx nginx-app --port=80 --env="DOMAIN=cluster"
sudo kubectl expose deployment nginx-app --port=80 --name=nginx-http


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-bionic main"
sudo apt install kubeadm 
sudo swapoff -a

# sudo hostnamectl set-hostname kubernetes-master
# sudo hostnamectl set-hostname kubernetes-slave


# REAL start kubernetes infrastructure
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# used to create a pod-network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl get pods --all-namespaces

#allow master to run applications
kubectl taint node $(hostname) node-role.kubernetes.io/master:NoSchedule-





kubectl get svc
curl -I 10.101.230.239

# clean
kubectl delete --all pods,deployments,services --namespace=default
kubectl delete --all deployments --namespace=default
kubeadm reset

#############################


kubectl run hello-world --replicas=5 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
kubectl expose deployment hello-world --type=LoadBalancer --name=my-service



kubectl run --image=nginx nginx-server --port=80 --env="DOMAIN=cluster" 
kubectl expose deployment nginx-servers --port=80 --name=nginx-http --type=LoadBalancer

# SSH tunnel
ssh -C2qTnN -D 8080 fipoc@fipoc01.tonbeller.com

############################