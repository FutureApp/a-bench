#!/bin/bash


sudo apt-get update
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

## alternative  version -- no conflict for minikube
#sudo apt-get update && sudo apt-get install  -y docker-ce=18.06.0~ce~3-0~ubuntu

sudo apt-get -y install docker-ce
sudo docker run hello-world

sudo groupadd docker
sudo usermod -aG docker $USER

