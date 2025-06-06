FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HBASE_VERSION=2.4.17
ENV HBASE_HOME=/opt/hbase
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$HBASE_HOME/bin:$PATH"
ENV HBASE_HEAPSIZE=4096

# Instalar dependências
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk curl nano procps net-tools dos2unix wget openssh-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Baixar e configurar o HBase
RUN curl -L https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz | \
    tar -xz -C /opt && \
    mv /opt/hbase-${HBASE_VERSION} $HBASE_HOME

# Copiar arquivo de configuração do HBase
COPY hbase-site.xml $HBASE_HOME/conf/hbase-site.xml

# Script de importação
COPY import_csv.sh /import_csv.sh
RUN dos2unix /import_csv.sh && chmod +x /import_csv.sh

# Expor portas do HBase (UI, RPC, HTTP info)
EXPOSE 16010 16020 16030

# Comando de inicialização
CMD bash -c "\
  if [ \"$HBASE_ROLE\" = \"master\" ]; then \
    $HBASE_HOME/bin/start-hbase.sh && \
    echo 'Aguardando HBase iniciar...' && sleep 10 && \
    echo 'Executando import_csv.sh...' && /import_csv.sh && \
    tail -f $HBASE_HOME/logs/hbase--master-$(hostname).out; \
  elif [ \"$HBASE_ROLE\" = \"regionserver\" ]; then \
    $HBASE_HOME/bin/hbase-daemon.sh start regionserver && \
    tail -f $HBASE_HOME/logs/hbase-*-regionserver-*.log; \
  else \
    echo 'Papel HBASE_ROLE não definido corretamente.' && exit 1; \
  fi"


