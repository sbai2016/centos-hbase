FROM centos:7

ENV container=docker

ENV ARTIFACTORY_URL=172.22.1.150

RUN yum -y install java-1.8.0-openjdk which openssh openssh-server openssh-clients

#Installation d'HBase
RUN mkdir -p /opt/hbase
RUN useradd -d /opt/hbase hbase
RUN echo "hbase:hbase" | chpasswd
ENV HBASE_VERSION=1.2.6


#conf SSH
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''

RUN echo -e "CheckHostIP no\nNoHostAuthenticationForLocalhost yes\nStrictHostKeyChecking no\nUserKnownHostsFile /dev/null\n" >> /etc/ssh/ssh_config


#conf hbase
COPY ./hbase/.bashrc /opt/hbase/
COPY ./hbase/scripts/entrypoint-master.sh /opt/hbase/
COPY ./hbase/scripts/entrypoint-slave.sh /opt/hbase/
COPY ./hbase/scripts/hbase-create-tables.script /opt/hbase/

RUN chmod ugo+x /opt/hbase/entrypoint-master.sh
RUN chmod ugo+x /opt/hbase/entrypoint-slave.sh
RUN chmod ugo+x /opt/hbase/hbase-create-tables.script

#droits hbase
RUN chown -R hbase:hbase /opt/hbase


USER hbase

#SSH hbase
RUN mkdir -p /opt/hbase/.ssh/
RUN ssh-keygen -t rsa -P '' -f /opt/hbase/.ssh/id_rsa
RUN cat /opt/hbase/.ssh/id_rsa.pub >> /opt/hbase/.ssh/authorized_keys
RUN chmod 0600 /opt/hbase/.ssh/authorized_keys
RUN chown -R hbase:hbase /opt/hbase/.ssh
WORKDIR /tmp

RUN curl -L -O http://${ARTIFACTORY_URL}/artifactory/libs-release-local/fr/cnamts/p8/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}.tar.gz \
     && tar xfz hbase-${HBASE_VERSION}.tar.gz -C /opt/hbase/ \
     && rm hbase-${HBASE_VERSION}.tar.gz
RUN cp -rf /opt/hbase/hbase-${HBASE_VERSION}/* /opt/hbase/

USER root
COPY ./hbase/conf/hbase-site.xml /opt/hbase/conf/hbase-site.xml
RUN echo "export HBASE_MANAGES_ZK=false" >> /opt/hbase/conf/hbase-env.sh

RUN chown -R hbase:hbase /opt/hbase

USER hbase

WORKDIR /opt/hbase

ENTRYPOINT ["bash", "-c", "/opt/hbase/entrypoint-master.sh"]
