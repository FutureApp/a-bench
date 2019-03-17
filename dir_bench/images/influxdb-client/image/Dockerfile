FROM influxdb

ENV pip=pip3
ENV python=python3


# System install procedure
RUN \
    apt update && \
    apt install -y nano python3 dnsutils  python3-pip   && \
    echo 'alias python="python3 "' >> ~/.bashrc         && \
    echo 'alias pip="pip3 "' >> ~/.bashrc

# Pip install procedure
RUN \
    pip3 install pandas influxdb openpyxl flask

# Prepare system for a-bench workflow
RUN \
    mkdir -p /results

ENV  LC_ALL=C.UTF-8
ENV  LANG=C.UTF-8
ENV  FLASK_APP=/rest_server/main.py


ADD rest_server /rest_server
ADD script/collector.py /collector.py
ADD script/entrypoint.sh /entrypoint2.sh

#ENTRYPOINT ["sh", "-c", "echo $HOME && tail -f /dev/null" ]
#CMD ["python3 -m flask run --port 8080 --host 0.0.0.0"]
ENTRYPOINT ["sh", "-c"]
CMD ["python3 -m flask run --port 8080 --host 0.0.0.0 & tail -f /dev/null"]

EXPOSE 8080