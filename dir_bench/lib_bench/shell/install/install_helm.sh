#!/usr/bin/env bash

curl -Lo helm.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-v2.12.3-linux-amd64.tar.gz && \
tar -zxvf helm.tar.gz && \
sudo mv linux-amd64/helm /usr/local/bin/helm && \
rm helm.tar.gz && \
rm -rf linux-amd64