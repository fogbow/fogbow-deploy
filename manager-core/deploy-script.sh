#!/bin/bash

DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/root/fogbow-manager-core"

LOG4J_FILE_NAME="log4j.properties"

IMAGE_NAME="fogbow/manager-core:latest"
CONTAINER_NAME="manager-core"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

# We are using the host network because is necessary to expose thousands of ports for the reverse tunnel, and for each exposed port the docker runs a process to connect the host and the container.
sudo docker run -idt --network host \
	--name $CONTAINER_NAME \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME:ro \
	-v $DIR_PATH/$LOG4J_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4J_FILE_NAME:ro \
	$IMAGE_NAME

