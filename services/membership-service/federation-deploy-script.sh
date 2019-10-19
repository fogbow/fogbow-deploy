#!/bin/bash
CURRENT_DIR_PATH=$(pwd)
SERVICE="membership-service"
CONF_FILES_DIR_PATH=$CURRENT_DIR_PATH/"conf-files"
SERVICES_CONF_FILE_NAME="services.conf"
SHARED_INFO_FILE_PATH=$CONF_FILES_DIR_PATH/"shared.info"
APPLICATION_CONF_FILE_NAME="application.properties"
CONTAINER_BASE_PATH="/root/"$SERVICE
CONTAINER_RESOURCES_PATH=$CONTAINER_BASE_PATH/src/main/resources
CONTAINER_CONF_FILES_DIR_PATH=$CONTAINER_RESOURCES_PATH/"private"
LOG4F_FILE_NAME="log4j.properties"
IMAGE_NAME="fogbow/"$SERVICE
CONTAINER_NAME=$SERVICE

SERVER_PORT_PATTERN="^ms_port"
MS_PORT=$(grep $SERVER_PORT_PATTERN $SHARED_INFO_FILE_PATH | awk -F "=" '{print $2}')

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $CONF_FILES_DIR_PATH/$SERVICES_CONF_FILE_NAME | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $MS_PORT:8080 \
	-v $CONF_FILES_DIR_PATH:$CONTAINER_CONF_FILES_DIR_PATH \
	-v $CURRENT_DIR_PATH/$LOG4F_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4F_FILE_NAME \
	-v $CURRENT_DIR_PATH/$APPLICATION_CONF_FILE_NAME:$CONTAINER_RESOURCES_PATH/$APPLICATION_CONF_FILE_NAME \
	$IMAGE_NAME:$TAG

# Add build value into ms.conf
BUILD_FILE_NAME="build"
MS_CONF_PATH="src/main/resources/private/ms.conf"
sudo docker exec $CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $MS_CONF_PATH"

# Run MS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &
