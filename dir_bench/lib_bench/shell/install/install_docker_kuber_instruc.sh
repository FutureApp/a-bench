#src: https://kubernetes.io/docs/setup/cri/#docker // 22.01.19 // 18.30
# Install Docker CE
## Set up the repository:
### Update the apt package index

    apt-get purge -y docker-ce; sudo rm -rf /var/lib/docker ## delete current docker-env
    apt-get update

### Install packages to allow apt to use a repository over HTTPS
    apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common

### Add Dockers official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add docker apt repository.
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

## Install docker ce.
apt-get update && apt-get install docker-ce=18.06.0~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart 

## 
sudo groupadd docker
sudo usermod -aG docker $USER