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

# Install Python Env.
RUN \
  apt-get update -y && \
  apt-get install -y python-dev python-virtualenv libssl-dev libffi-dev libxml2-dev libxslt1-dev && \
  rm -rf /var/lib/apt/lists/*

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Installing Dashboard
RUN \
  git clone https://github.com/fogbow/fogbow-dashboard-core.git

# Define working directory.
WORKDIR /root/fogbow-dashboard-core

RUN \
  yes | ./run_tests.sh

CMD nohup ./run_tests.sh --runserver 0.0.0.0:8080 &
