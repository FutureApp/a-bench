#!/bin/bash

# code from: 
#https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver
DEBIAN_FRONTEND=noninteractive; \
sudo  apt-get -y install qemu-kvm libvirt-bin virt-top  libguestfs-tools virtinst bridge-utils



sudo apt install -y libvirt-clients libvirt-daemon-system qemu-kvm
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
sudo usermod -a -G libvirt $(whoami)
newgrp libvirt
curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2 \
  && sudo install docker-machine-driver-kvm2 /usr/local/bin/