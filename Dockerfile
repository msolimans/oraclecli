FROM ubuntu:16.04
FROM golang:1.10

ENV MAJOR 12
ENV MINOR 2
ENV MAINTENANCE 0
ENV BUILD 1.0
ENV VERSION ${MAJOR}.${MINOR}.${MAINTENANCE}.${BUILD} 
ENV MAJOR_VERSION ${MAJOR}.${MINOR}

ENV ORACLE_HOME /opt/oracle
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:${ORACLE_HOME}
ENV PATH $PATH:${ORACLE_HOME}/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$ORACLE/include/oracle/$ORACLE_INSTANTCLIENT_MAJOR/client64

RUN apt-get update && apt-get install -y libaio1 wget libsasl2-dev bsdtar \
    && mkdir -p $ORACLE_HOME && TMP_DIR="$(mktemp -d)" && cd "$TMP_DIR" \
    && wget https://s3.amazonaws.com/resources.idt.net/oracle/${MAJOR_VERSION}/instantclient-basic-linux.x64-${VERSION}.zip \
    && wget https://s3.amazonaws.com/resources.idt.net/oracle/${MAJOR_VERSION}/instantclient-sdk-linux.x64-${VERSION}.zip \
    && wget https://s3.amazonaws.com/resources.idt.net/oracle/${MAJOR_VERSION}/instantclient-sqlplus-linux.x64-${VERSION}.zip \
    && cd "$ORACLE_HOME" \
    && bsdtar -xf ${TMP_DIR}/instantclient-basic-linux.x64-${VERSION}.zip -s '|[^/]*/||' \ 
    && bsdtar -xf ${TMP_DIR}/instantclient-sdk-linux.x64-${VERSION}.zip -s '|[^/]*/||' \ 
    && bsdtar -xf ${TMP_DIR}/instantclient-sqlplus-linux.x64-${VERSION}.zip -s '|[^/]*/||' \ 
    && ln -s libclntsh.so.12.1 libclntsh.so.${MAJOR_VERSION} \
    && ln -s libclntsh.so.12.1 libclntsh.so \
    && ln -s libocci.so.12.1 libocci.so.${MAJOR_VERSION} \
    && ln -s libocci.so.12.1 libocci.so \
    && echo "$ORACLE_HOME" > /etc/ld.so.conf.d/oracle.conf && chmod o+r /etc/ld.so.conf.d/oracle.conf && ldconfig \
    && rm -R -f /tmp/* \
    && rm -rf /var/lib/apt/lists/* && apt-get purge -y --auto-remove wget 
