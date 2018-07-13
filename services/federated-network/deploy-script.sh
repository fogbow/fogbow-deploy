#!/bin/bash

DIR_PATH=$(pwd)
EXTRA_FILES_DIR=$DIR_PATH/"extra-files"
CONTAINER_BASE_PATH="/root/federated-network-service"
CONTAINER_EXTRA_FILES_PATH=$CONTAINER_BASE_PATH/"extra-files"

IMAGE_NAME="fogbow/federated-network-service:latest"
CONTAINER_NAME="federated-network-service"

FEDNET_CONF_FILE_NAME="federated-network.conf"
LOG4F_FILE_NAME="log4j.properties"

SERVER_PORT_PATTERN="server_port"
FEDNET_PORT=$(grep $SERVER_PORT_PATTERN $FEDNET_CONF_FILE_NAME | awk -F "=" '{print $2}')
CONTAINER_PORT="8081"

echo "Federated network service server port: $FEDNET_PORT"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $FEDNET_PORT:$CONTAINER_PORT \
	-v $DIR_PATH/$FEDNET_CONF_FILE_NAME:$CONTAINER_BASE_PATH/$FEDNET_CONF_FILE_NAME \
	-v $DIR_PATH/$LOG4F_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4F_FILE_NAME \
	-v $EXTRA_FILES_DIR:$CONTAINER_EXTRA_FILES_PATH \
	$IMAGE_NAME

