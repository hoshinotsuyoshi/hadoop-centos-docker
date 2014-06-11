FROM centos

#java
RUN yum -y install which wget tar vi openssh-server openssh-clients
#RUN yum -y install java-1.6.0-openjdk

RUN cd /root && wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-linux-x64.tar.gz" 
RUN cd /root && tar zxf jdk-7u60-linux-x64.tar.gz && cp -pr jdk1.7.0_60/ /usr/local/

#hadoop
RUN groupadd hadoop && useradd -d /home/hadoop -g hadoop -m hadoop
RUN wget http://ftp.tsukuba.wide.ad.jp/software/apache/hadoop/common/hadoop-2.2.0/hadoop-2.2.0.tar.gz && tar zxvf hadoop-2.2.0.tar.gz && mv hadoop-2.2.0 /usr/local
RUN chown hadoop:hadoop -R /usr/local/hadoop-2.2.0

RUN echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config
RUN sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
#RUN sed -i 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
#RUN sed -i 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN /usr/bin/ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
RUN /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''

USER hadoop
#RUN ssh-keygen -t rsa -P '' -f /home/hadoop/.ssh/id_rsa
RUN mkdir -p  /home/hadoop/.ssh/
ADD id_rsa.pub /home/hadoop/.ssh/id_rsa_core.pub
#RUN cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys
RUN cat /home/hadoop/.ssh/id_rsa_core.pub > /home/hadoop/.ssh/authorized_keys
RUN chmod 644 /home/hadoop/.ssh/authorized_keys
RUN sed -i 's/export JAVA_HOME.*$/export JAVA_HOME=\/usr\/local\/jdk1.7.0_60/g' /usr/local/hadoop-2.2.0/etc/hadoop/hadoop-env.sh
ADD core-site.xml /usr/local/hadoop-2.2.0/core-site.xml
ADD hdfs-site.xml /usr/local/hadoop-2.2.0/hdfs-site.xml
ADD mapred-site.xml /usr/local/hadoop-2.2.0/mapred-site.xml

USER root
#RUN echo 'export HADOOP_INSTALL=/usr/local/hadoop-2.2.0' >> /home/hadoop/.bashrc
RUN echo 'export HADOOP_INSTALL=/usr/local/hadoop-2.2.0' >> /etc/profile
#RUN echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> /home/hadoop/.bashrc
RUN echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_INSTALL/lib/native' >> /etc/profile
#RUN echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"' >> /home/hadoop/.bashrc
RUN echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"' >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

# service sshd start
#su hadoop
#/usr/local/hadoop-2.2.0/bin/hadoop namenode -format
#/usr/local/hadoop-2.2.0/sbin/start-all.sh
#/usr/local/jdk1.7.0_60/bin/jps



