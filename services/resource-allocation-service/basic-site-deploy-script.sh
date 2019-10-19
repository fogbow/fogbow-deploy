#!/bin/bash
CURRENT_DIR_PATH=$(pwd)
PARENT_DIR_PATH=$(dirname $CURRENT_DIR_PATH)
SERVICE="resource-allocation-service"
CONF_FILES_DIR_PATH="conf-files"
SERVICES_CONF_FILE_NAME="services.conf"
LOG4F_FILE_NAME="log4j.properties"
RAS_CONF_FILE_PATH=$CONF_FILES_DIR_NAME/"ras.conf"
SHARED_INFO_FILE_PATH=$CONF_FILES_DIR_NAME/"shared.info"
APPLICATION_CONF_FILE_NAME="application.properties"
CONTAINER_BASE_PATH="/root/"$SERVICE
CONTAINER_RESOURCES_PATH=$CONTAINER_BASE_PATH/src/main/resources
CONTAINER_CONF_FILES_DIR_PATH=$CONTAINER_RESOURCES_PATH/"private"
IMAGE_NAME="fogbow/"$SERVICE
CONTAINER_NAME=$SERVICE
RAS_TIMESTAMP_DB_FILE_NAME="ras.db"
TIMESTAMP_DB_DIRECTORY_NAME="timestamp-storage"

RAS_PORT=$(grep ^ras_port $SHARED_INFO_FILE_PATH | awk -F "=" '{print $2}')

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $CONF_FILES_DIR_NAME/$SERVICES_CONF_FILE_NAME | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

# Resolving timestamp db
if [ ! -d ../$TIMESTAMP_DB_DIRECTORY_NAME ]; then
	mkdir -p ../$TIMESTAMP_DB_DIRECTORY_NAME
fi
if [ ! -f ../$TIMESTAMP_DB_DIRECTORY_NAME/$RAS_TIMESTAMP_DB_FILE_NAME ]; then
	touch ../$TIMESTAMP_DB_DIRECTORY_NAME/$RAS_TIMESTAMP_DB_FILE_NAME
fi
DB_KEY_PATTERN="jdbc_database_url"
CONTAINER_DB_FILE_PATH=$(grep $DB_KEY_PATTERN $RAS_CONF_FILE_PATH | awk -F ":" '{print $3}')

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $RAS_PORT:8080 \
	-v $CURRENT_DIR_PATH/$CONF_FILES_DIR_NAME:$CONTAINER_CONF_FILES_DIR_PATH \
	-v $CURRENT_DIR_PATH/$LOG4F_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4F_FILE_NAME \
	-v $CURRENT_DIR_PATH/$APPLICATION_CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONTAINER_RESOURCES_PATH/$APPLICATION_CONF_FILE_NAME \
	-v $PARENT_DIR_PATH/$TIMESTAMP_DB_DIRECTORY_NAME/$RAS_TIMESTAMP_DB_FILE_NAME:$CONTAINER_DB_FILE_PATH\
	$IMAGE_NAME:$TAG

# Add build value into ras.conf
BUILD_FILE_NAME="build"
CONTAINER_RAS_CONF_FILE_PATH="src/main/resources/private/ras.conf"
sudo docker exec $CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $CONTAINER_RAS_CONF_FILE_PATH"

# Run RAS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &
