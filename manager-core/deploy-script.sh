#!/bin/bash

DIR_PATH=$(pwd)
CONF_FILES_DIR="conf-files"
CONTAINER_BASE_PATH="/root/fogbow-manager-core"
CONTAINER_CONF_FILES_DIR=".fogbow"

IMAGE_NAME="fogbow/manager-core:latest"
CONTAINER_NAME="manager-core"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

# We are using the host network because is necessary to expose thousands of ports for the reverse tunnel, and for each exposed port the docker runs a process to connect the host and the container.
sudo docker run -idt --network host \
	--name $CONTAINER_NAME \
	--read-only -v $DIR_PATH/$CONF_FILES_DIR:$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILES_DIR \
	$IMAGE_NAME

