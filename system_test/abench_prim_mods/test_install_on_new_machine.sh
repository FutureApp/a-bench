#!/bin/bash
echo "Installationsprozess der ABench - Infrastruktur. Neue Umgebung-Test" &&\
start=$(date +%s)&&\
sudo apt-get install -y git && \
rm -fr ~/wd/abench;
mkdir -p ~/wd/abench &&
cd ./wd/abench &&
git clone https://github.com/FutureApp/a-bench.git && \
cd a-bench && bash admin.sh auto_install && \
exec sudo su -l $USER &&\
chmod +x admin.sh &&\
end_install=(date +%s) &&\
bash admin.sh senv_a &&\
end_run=(date +%s) &&\
install_runtime=$((end_install-start)) &&\
total_runtime=$((end_run-start)) &&\
echo "Total execution time: $total_runtime s | Install time: $install_runtime"