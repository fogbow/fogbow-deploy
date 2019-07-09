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
  apt-get install -y apache2 \ 
  apt-get install -y libapache2-mod-php5 libapache2-mod-shib2

# Set the correct time 
RUN apt-get install -y ntp ntpdate && \ 
  service ntp restart

# Install Shibboleth Authentication Application
RUN apt-get install -y openjdk-8-jdk maven git

WORKDIR /home/ubuntu/

RUN git clone https://github.com/fogbow/common.git

WORKDIR /home/ubuntu/common

RUN mvn install -DskipTests

WORKDIR /home/ubuntu/

RUN git clone https://github.com/fogbow/shibboleth-authentication-application.git

WORKDIR /home/ubuntu/shibboleth-authentication-application

RUN git pull
RUN git checkout bug-fixes-07-2019

RUN mvn install -DskipTests

EXPOSE 80 443

CMD tail -f /dev/null