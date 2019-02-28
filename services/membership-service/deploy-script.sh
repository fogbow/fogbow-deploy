#!/bin/bash
DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/root/membership-service"
PROJECT_RESOURCES_PATH="src/main/resources/private"

LOG4J_FILE_NAME="log4j.properties"
CONF_FILE_NAME="ms.conf"
SHARED_INFO=$DIR_PATH/"shared.info"

IMAGE_NAME="fogbow/membership-service"
CONTAINER_NAME="membership-service"

MS_PORT=$(grep ^ms_port $SHARED_INFO | awk -F "=" '{print $2}')

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
SERVICES_CONF=services.conf
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

echo "Membership port: $MEMBERSHIP_HOST_PORT"

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

sudo docker run -idt --name $CONTAINER_NAME \
	-p $MS_PORT:8080 \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$PROJECT_RESOURCES_PATH/$CONF_FILE_NAME \
	-v $DIR_PATH/$LOG4J_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4J_FILE_NAME:ro \
	$IMAGE_NAME:$TAG

# Add build value into ms.conf
BUILD_FILE_NAME="build"
MS_CONF_PATH="./ms.conf"
sudo docker exec $CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $MS_CONF_PATH"

# Run MS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &
