FROM    centos:7

ENV     ES_HOME=/app \
        ES_USER=elasticsearch
ADD     files/elasticsearch.tar.gz ${ES_HOME}
RUN     useradd ${ES_USER} && \
        chown -R ${ES_USER}: ${ES_HOME} && \
        mkdir -p /var/lib/elasticsearch && \
        chown -R ${ES_USER}: /var/lib/elasticsearch && \
        mkdir /snapshots && \
        chown -R ${ES_USER}: /snapshots
COPY    files/elasticsearch.yml ${ES_HOME}/config
WORKDIR ${ES_HOME}
USER    ${ES_USER}
EXPOSE  9200 9300

ENTRYPOINT ["./bin/elasticsearch"]
