FROM node:8

ARG BRANCH

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update -y && \
  apt-get upgrade -y && \
  apt-get install -y byobu curl git htop man unzip vim nano wget && \
  apt-get install -y net-tools iputils-ping

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

RUN \
  git clone https://github.com/fogbow/fogbow-gui.git && \
  (cd fogbow-gui && git checkout $BRANCH)

# Define working directory.
WORKDIR /root/fogbow-gui

# Generates the build number based on the commit checksum
RUN \
  (build_number=$(git rev-parse --short 'HEAD') && echo "{\"build_number\": \"$build_number\"}" > /root/fogbow-gui/src/defaults/build.json)

RUN \
  npm i

CMD \
  npm start > fogbow-gui.log || tail -f /dev/null
