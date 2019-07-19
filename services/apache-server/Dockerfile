# It is following RNP tutorial
## https://wiki.rnp.br/pages/viewpage.action?pageId=69969868

# In the RNP tutorial the Ubuntu 14:04 is required because da dependency 'libapache2-mod-php5'
FROM ubuntu:14.04

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y byobu curl git htop man unzip vim nano wget && \
  apt-get install -y net-tools iputils-ping && \
  apt-get install -y apache2 && \ 
  apt-get install -y libapache2-mod-php5 libapache2-mod-shib2 maven

# Avoid Poddle vulnerability
RUN sed -i "s#SSLProtocol all#SSLProtocol All -SSLv2 -SSLv3#g" /etc/apache2/mods-available/ssl.conf

# Set the correct time 
RUN apt-get install -y ntp ntpdate && \ 
  service ntp restart

# Install Shibboleth Authentication Application
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa 
RUN apt-get update 
RUN apt-get install -y --no-install-recommends openjdk-8-jdk 
RUN rm -rf /var/lib/apt/lists/* 
RUN apt-get install -y git

RUN update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64

WORKDIR /home/ubuntu/

RUN git clone https://github.com/fogbow/common.git

WORKDIR /home/ubuntu/common

RUN mvn install -DskipTests

WORKDIR /home/ubuntu/

RUN git clone https://github.com/fogbow/shibboleth-authentication-application.git

RUN mkdir /home/ubuntu/shared-folder

WORKDIR /home/ubuntu/shibboleth-authentication-application

RUN mvn install -DskipTests

EXPOSE 80 443

CMD tail -f /dev/null
