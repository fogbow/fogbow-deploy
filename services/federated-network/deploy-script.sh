#!/bin/bash

DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/root/federated-network-service"

IMAGE_NAME="fogbow/federated-network:latest"
CONTAINER_NAME="federated-network"

FEDNET_CONF_FILE_NAME="federated-network.conf"

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
	$IMAGE_NAME

