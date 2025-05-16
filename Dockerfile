FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HBASE_VERSION=2.4.17
ENV HBASE_HOME=/opt/hbase
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$HBASE_HOME/bin:$PATH"
ENV HBASE_HEAPSIZE=4096

# Instalar Java, curl, nano e utilitários
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk curl nano procps net-tools && \
    apt-get clean

# Baixar e extrair o HBase
RUN curl -L https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz | tar -xz -C /opt && \
    mv /opt/hbase-${HBASE_VERSION} /opt/hbase

# Copiar o script de importação
COPY import_csv.sh /import_csv.sh
RUN chmod +x /import_csv.sh

# Expor portas padrão
EXPOSE 16010 2181 9090

# Inicializar HBase, importar CSV e manter o container rodando
CMD bash -c "/opt/hbase/bin/start-hbase.sh && sleep 10 && bash /import_csv.sh && tail -f /opt/hbase/logs/hbase--master-$(hostname).out"


