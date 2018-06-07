FROM ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget maven && \
  apt-get install -y net-tools iputils-ping && \
  rm -rf /var/lib/apt/lists/*

# Install Java.
RUN \
  apt-get update -y && \
  apt-get install -y openjdk-7-jdk && \
  rm -rf /var/lib/apt/lists/*

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Installing Manager
RUN \
  git clone https://github.com/fogbow/fogbow-manager-core.git && \
  (cd fogbow-manager-core && mvn install)

# Define working directory.
WORKDIR /root/fogbow-manager-core
  
CMD /bin/bash bin/start-manager > log.out 2> log.err && tail -f /dev/null
