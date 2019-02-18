#!/bin/bash

# instructions from :https://www.mirantis.com/blog/how-install-kubernetes-kubeadm/ 
sudo su
swapoff -a
nano /etc/fstab

# comment line with tells something about swap!
# like #UUID=d0200036-b211-4e6e-a194-ac2e51dfb27d none         swap sw 

nano /etc/ufw/sysctl.conf

# net/bridge/bridge-nf-call-ip6tables = 1
# net/bridge/bridge-nf-call-iptables = 1
# net/bridge/bridge-nf-call-arptables = 1

# REBOOT NOW
sudo su
apt-get install ebtables ethtool

# REBOoT NOW

sudo su
apt-get update
apt-get install -y docker.io apt-transport-https curl
systemctl enable docker && systemctl start docker




curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y kubelet kubeadm kubectl


# Be sure that the current user is your general user, too. (eg: mikle and not root)

# postone steps for docker - to run smoothly #..#
sudo groupadd docker
sudo usermod -aG docker $USER



## END
