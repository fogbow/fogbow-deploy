#!/bin/bash
DIR_PATH=$(pwd)

IMAGE_NAME="fogbow/fogbow-gui"
CONTAINER_NAME="fogbow-gui"

CONF_FILE_NAME="local_settings.py"

CONTAINER_BASE_PATH="/root/fogbow-gui"
CONTAINER_CONF_FILE_PATH="openstack_dashboard/local"

EXTRA_FILES_DIR=$DIR_PATH/"extra-files"
CONTAINER_EXTRA_FILES_DIR=$CONTAINER_BASE_PATH/"extra-files"

MANAGER_CONF_FILE="manager.conf"
DASHBOARD_PORT_PATTERN="fogbow_dashboard_server_port"
DASHBOARD_PORT=$(grep $DASHBOARD_PORT_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')

if [ -z "$DASHBOARD_PORT" ]; then
	DASHBOARD_PORT="80"
fi

echo "Dashboard port: $DASHBOARD_PORT"

CONTAINER_PORT="8080"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $DASHBOARD_PORT:$CONTAINER_PORT \
	-v $EXTRA_FILES_DIR:$CONTAINER_EXTRA_FILES_DIR \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILE_PATH/$CONF_FILE_NAME \
	$IMAGE_NAME

