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
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME \
	-v $DIR_PATH/$LOG4J_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4J_FILE_NAME:ro \
	$IMAGE_NAME:$TAG

# Add build value into ms.conf
BUILD_FILE_NAME="build"
MS_CONF_PATH="./ms.conf"
sudo docker exec cat $BUILD_FILE_NAME >> $MS_CONF_PATH

# Run MS
sudo docker exec ./mvnw spring-boot:run -X > log.out 2> log.err || tail -f /dev/null
