FROM openjdk:8

ARG COMMON_BRANCH
ARG MS_BRANCH

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

# Installing Common
RUN \
  git clone https://github.com/fogbow/common.git && \
  (cd common && git checkout $COMMON_BRANCH && mvn install -Dmaven.test.skip=true)

# Installing Membership
RUN \
  git clone https://github.com/fogbow/membership-service.git && \
  (cd membership-service && git checkout $MS_BRANCH && mvn install -Dmaven.test.skip=true)

# Define working directory.
WORKDIR /root/membership-service

# Generates the build number based on the commit checksum
RUN \
    (ms_build_number=$(git rev-parse --short 'HEAD') && \
    cd ../common && common_build_number=$(git rev-parse --short 'HEAD') && \
    cd /root/membership-service && \
    echo "build_number=ms-$ms_build_number-common-$common_build_number" > build)

RUN \
  mvn dependency:sources

