#!/bin/bash
DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/root/membership-service"
PROJECT_RESOURCES_PATH="src/main/resources"

LOG4J_FILE_NAME="log4j.properties"
CONF_FILE_NAME="ms.conf"

IMAGE_NAME="fogbow/membership-service"
CONTAINER_NAME="membership-service"

SERVER_PORT_PATTERN="server_port"
MEMBERSHIP_HOST_PORT=$(grep $SERVER_PORT_PATTERN $CONF_FILE_NAME | awk -F "=" '{print $2}')
MEMBERSHIP_CONTAINER_PORT="8080"

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
SERVICES_CONF=services.conf
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

echo "Membership port: $MEMBERSHIP_HOST_PORT"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt --name $CONTAINER_NAME \
	-p $MEMBERSHIP_HOST_PORT:$MEMBERSHIP_CONTAINER_PORT \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME:ro \
	-v $DIR_PATH/$LOG4J_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4J_FILE_NAME:ro \
	$IMAGE_NAME:$TAG

