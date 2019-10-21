#!/bin/bash
CURRENT_DIR_PATH=$(pwd)
IMAGE_NAME="fogbow/fogbow-gui"
CONTAINER_NAME="fogbow-gui"
CONF_FILE_NAME="api.config.js"
SERVICES_CONF_FILE_PATH="./conf-files/services.conf"
CONTAINER_BASE_DIR_PATH="/root/fogbow-gui"
CONTAINER_CONF_FILE_PATH="src/defaults"
SHARED_INFO_FILE_PATH="./conf-files/shared.info"
GUI_CONF_FILE_NAME="gui.conf"
GUI_PORT_PATTERN="fogbow_gui_server_port"

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF_FILE_PATH | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

GUI_PORT=$(grep ^gui_port $SHARED_INFO_FILE_PATH | awk -F "=" '{print $2}')
CONTAINER_PORT="3000"

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $GUI_PORT:$CONTAINER_PORT \
	-v $CURRENT_DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILE_PATH/$CONF_FILE_NAME \
	$IMAGE_NAME:$TAG
