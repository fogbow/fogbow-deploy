#!/bin/bash
DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/root/reverse-tunnel-service"

LOG4J_FILE_NAME="log4j.properties"
CONF_FILE_NAME="reverse-tunnel.conf"

HOST_KEY_PATTERN="host_key_path"
HOST_KEY_NAME=$(grep $HOST_KEY_PATTERN $CONF_FILE_NAME | awk -F "=" '{print $2}')

echo "Host key name: $HOST_KEY_NAME"

IMAGE_NAME="fogbow/reverse-tunnel-service"
CONTAINER_NAME="reverse-tunnel-service"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

# We are using the host network because is necessary to expose thousands of ports for the reverse tunnel, and for each exposed port the docker runs a process to connect the host and the container.
sudo docker run -idt --network host \
	--name $CONTAINER_NAME \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME:ro \
	-v $DIR_PATH/$HOST_KEY_NAME:$CONTAINER_BASE_PATH/$HOST_KEY_NAME \
	-v $DIR_PATH/$LOG4J_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4J_FILE_NAME:ro \
	$IMAGE_NAME
