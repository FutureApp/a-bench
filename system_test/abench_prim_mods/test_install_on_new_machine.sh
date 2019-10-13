#!/bin/bash
echo "Installationsprozess der ABench - Infrastruktur. Neue Umgebung-Test" &&\
SECONDS=0
sudo apt-get update
sudo apt-get install -y git
rm -fr ~/wd/abench
mkdir -p ~/wd/abench
cd ~/wd/abench
git clone https://github.com/FutureApp/a-bench.git
cd a-bench && chmod +x admin.sh
bash admin.sh auto_install
end_install=$SECONDS
SECONDS=0
sudo -u "$SUDO_USER" bash admin.sh down_submodules

chown -R $SUDO_USER ~/wd
chmod -R u+rX ~/wd

chown -R $SUDO_USER /home/$SUDO_USER
chmod -R u+rX /home/$SUDO_USER

sudo -u "$SUDO_USER" bash admin.sh senv_a
end_run=$SECONDS


SECONDS=0
echo "Sleeping 5 minutes" && sleep 300
# Checks if all pods are available which are expected.
# Based on
# https://unix.stackexchange.com/questions/428614/take-output-from-grep-and-select-parts-for-variables
echo "[Neue-Umgebung-Test] Test is detecting:"
podList=(   etcd-minikube heapster influxdb-client influxdb-grafana kube-addon-manager-minikube 
            kube-apiserver-minikube kube-controller-manager-minikube kube-dns kube-proxy kube-scheduler-minikube
            kubernetes-dashboard storage-provisioner tiller-deploy )
searchWord="Running"
countFailur=0
for pod in "${podList[@]}"
do
    var=( $(kubectl get pods -o wide --all-namespaces | grep $pod) )
    if [  "${var[3]}" == $searchWord ]; then
        echo "[x] $pod is runnning."
    else
        echo "[ ] $pod is not runnning."
        countFailur=$((var+1))
    fi
done



realEnd=$SECONDS
finalEnd=$((end_install+end_run+realEnd))
countFailur=0
echo "Time spend (installing):   $end_install s"
echo "Time spend (initializing): $end_run s"
echo "Time spend (total(install+init+waiting)): $finalEnd s"

if [ "$countFailur" -eq "0" ]; then
   echo "Test successfully";
   exit;
else
    echo "Error, test failed";
    exit 1;
fi