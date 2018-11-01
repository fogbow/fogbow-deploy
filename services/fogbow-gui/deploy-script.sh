#!/bin/bash
DIR_PATH=$(pwd)

IMAGE_NAME="fogbow/fogbow-gui"
CONTAINER_NAME="fogbow-gui"
CONF_FILE_NAME="api.config.js"

CONTAINER_BASE_PATH="/root/fogbow-gui"
CONTAINER_CONF_FILE_PATH="src/defaults"

GUI_CONF_FILE="gui.conf"
DASHBOARD_PORT_PATTERN="fogbow_gui_server_port"
DASHBOARD_PORT=$(grep $DASHBOARD_PORT_PATTERN $GUI_CONF_FILE | awk -F "=" '{print $2}')

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
SERVICES_CONF=services.conf
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

if [ -z "$DASHBOARD_PORT" ]; then
	DASHBOARD_PORT="81"
fi
echo "Dashboard port: $DASHBOARD_PORT"

CONTAINER_PORT="3000"

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $DASHBOARD_PORT:$CONTAINER_PORT \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILE_PATH/$CONF_FILE_NAME \
	$IMAGE_NAME:$TAG
