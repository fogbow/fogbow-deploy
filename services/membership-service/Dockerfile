FROM openjdk:8

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

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Installing Reverse Tunnel
RUN \
  git clone https://github.com/fogbow/fogbow-membership-service.git && \
  (cd fogbow-membership-service && mvn install)

# Define working directory.
WORKDIR /root/fogbow-membership-service

CMD /bin/bash bin/start-membership-service > log.out && tail -f /dev/null
