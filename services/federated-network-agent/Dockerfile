FROM ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget maven && \
  apt-get install -y net-tools iputils-ping

# Install strongswan
RUN \
  set -e && \ 
  apt-get install strongswan -y && \
  apt-get install opensc -y && \
  apt-get install libgmp10 -y && \
  apt-get install libgmp-dev -y && \
  apt-get install libssl-dev -y && \
  rm -rf /var/lib/apt/lists/*

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Installing Manager
RUN \
  git clone https://github.com/fogbow/federated-network-service.git
  
RUN \
  cp -a /root/federated-network-service/bin/agent-scripts/. ~

EXPOSE 4500/udp 500/udp 1701/udp
  
CMD ipsec rereadsecrets > log.out 2> log.err && tail -f /dev/null
