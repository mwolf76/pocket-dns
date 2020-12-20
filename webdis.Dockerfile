FROM debian:buster
ENV WEBDIS_REPO https://github.com/nicolasff/webdis.git

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y git make gcc libevent-dev && \
    git clone --depth 1 $WEBDIS_REPO /tmp/webdis && \
    cd /tmp/webdis && make clean && make -j $(nproc) all && \
    cp webdis /usr/local/bin/        && \
    cp webdis.json /etc/             && \
    cd /tmp && rm -rf /tmp/webdis    && \
    apt-get remove -y --purge git make gcc  && \
    apt-get clean

COPY webdis-entrypoint.sh /app.sh
ENTRYPOINT ["/app.sh"]