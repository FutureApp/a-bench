FROM influxdb

ENV pip=pip3
ENV python=python3

ADD script/collector.py /collector.py

# System install procedure
RUN \
    apt update && \
    apt install -y nano python3 dnsutils  python3-pip  && \
    echo 'alias python="python3 "' >> ~/.bashrc     && \
    echo 'alias pip="pip3 "' >> ~/.bashrc

# Pip install procedure
RUN \
    pip3 install pandas influxdb openpyxl

# Prepare system for a-bench workflow
RUN \
    mkdir -p /results