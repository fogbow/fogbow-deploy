#!/bin/bash

DIR_PATH=$(pwd)
CONF_FILES_DIR="conf-files"
CONTAINER_BASE_PATH="/root/resource-allocation-service"
CONTAINER_RESOURCES_PATH="src/main/resources"
CONTAINER_CONF_FILES_DIR=$CONTAINER_RESOURCES_PATH/"private"

APPLICATION_CONF_FILE="application.properties"

IMAGE_NAME="fogbow/resource-allocation-service"
CONTAINER_NAME="resource-allocation-service"

MANAGER_CONF_FILE=$CONF_FILES_DIR/"ras.conf"
SERVER_PORT_PATTERN="manager_server_port"
MANAGER_PORT=$(grep $SERVER_PORT_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')
CONTAINER_PORT="8080"

echo "Manager server port: $MANAGER_PORT"

INTERCOMPONENT_CONF_FILE=$CONF_FILES_DIR/"intercomponent.conf"
XMPP_PORT_PATTERN="xmpp_server_port"
XMPP_PORT=$(grep $XMPP_PORT_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')
CONTAINER_XMPP_PORT="5327"

echo "Manager xmpp port: $XMPP_PORT"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $MANAGER_PORT:$CONTAINER_PORT \
	-p $XMPP_PORT:$CONTAINER_XMPP_PORT \
	-v $DIR_PATH/$CONF_FILES_DIR:$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILES_DIR \
	-v $DIR_PATH/$APPLICATION_CONF_FILE:$CONTAINER_BASE_PATH/$CONTAINER_RESOURCES_PATH/$APPLICATION_CONF_FILE \
	$IMAGE_NAME

