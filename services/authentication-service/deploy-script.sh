#!/bin/bash
DIR_PATH=$(pwd)
CONF_FILES_DIR_PATH="conf-files"
CONF_FILES_DIR=$DIR_PATH/"conf-files"
SHARED_INFO_FILE=$CONF_FILES_DIR/"shared.info"

APPLICATION_CONF_FILE="application.properties"

CONTAINER_BASE_PATH="/root/authentication-service"
CONTAINER_RESOURCES_PATH=$CONTAINER_BASE_PATH/src/main/resources
CONTAINER_CONF_FILES_DIR=$CONTAINER_RESOURCES_PATH/"private"

LOG4F_FILE_NAME="log4j.properties"
IMAGE_NAME="fogbow/authentication-service"
CONTAINER_NAME="authentication-service"

SERVER_PORT_PATTERN="^as_port"
AS_PORT=$(grep $SERVER_PORT_PATTERN $SHARED_INFO_FILE | awk -F "=" '{print $2}')

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
SERVICES_CONF=services.conf
TAG=$(grep $IMAGE_BASE_NAME $CONF_FILES_DIR_PATH/$SERVICES_CONF | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $AS_PORT:8080 \
	-v $CONF_FILES_DIR:$CONTAINER_CONF_FILES_DIR \
	-v $DIR_PATH/$LOG4F_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4F_FILE_NAME \
	-v $DIR_PATH/$APPLICATION_CONF_FILE:$CONTAINER_RESOURCES_PATH/$APPLICATION_CONF_FILE \
	$IMAGE_NAME:$TAG

# Add build value into as.conf
BUILD_FILE_NAME="build"
AS_CONF_PATH="src/main/resources/private/as.conf"
sudo docker exec $CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $AS_CONF_PATH"

# Run FNS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &