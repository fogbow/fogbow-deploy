#!/bin/bash

DIR_PATH=$(pwd)
CONF_FILES_DIR="conf-files"
CONTAINER_BASE_PATH="/root/resource-allocation-service"
CONTAINER_RESOURCES_PATH="src/main/resources"
CONTAINER_CONF_FILES_DIR=$CONTAINER_RESOURCES_PATH/"private"

APPLICATION_CONF_FILE="application.properties"

RAS_TIMESTAMP_DB_FILE="ras.db"
PARENT_PATH=$(dirname $DIR_PATH)
TIMESTAMP_DB_DIRECTORY="timestamp-storage"

IMAGE_NAME="fogbow/resource-allocation-service"
CONTAINER_NAME="resource-allocation-service"

MANAGER_CONF_FILE=$CONF_FILES_DIR/"ras.conf"
SERVER_PORT_PATTERN="ras_server_port"
MANAGER_PORT=$(grep $SERVER_PORT_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')
CONTAINER_PORT="8080"

echo "Manager server port: $MANAGER_PORT"

INTERCOMPONENT_CONF_FILE=$CONF_FILES_DIR/"intercomponent.conf"
XMPP_PORT_PATTERN="xmpp_server_port"
XMPP_PORT=$(grep $XMPP_PORT_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')
CONTAINER_XMPP_PORT="5327"

SERVICES_CONF=$CONF_FILES_DIR/"services.conf"
IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

echo "Manager xmpp port: $XMPP_PORT"

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

# Resolving timestamp db
if [ ! -d $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY ]; then
	mkdir -p $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY
fi
if [ ! -f $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY/$RAS_TIMESTAMP_DB_FILE ]; then
	touch $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY/$RAS_TIMESTAMP_DB_FILE
fi
DB_KEY_PATTERN="jdbc_database_url"
CONTAINER_DB_FILE_PATH=$(grep $DB_KEY_PATTERN $MANAGER_CONF_FILE | awk -F ":" '{print $3}')

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $MANAGER_PORT:$CONTAINER_PORT \
	-p $XMPP_PORT:$CONTAINER_XMPP_PORT \
	-v $DIR_PATH/$CONF_FILES_DIR:$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILES_DIR \
	-v $DIR_PATH/$APPLICATION_CONF_FILE:$CONTAINER_BASE_PATH/$CONTAINER_RESOURCES_PATH/$APPLICATION_CONF_FILE \
	-v $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY/$RAS_TIMESTAMP_DB_FILE:$CONTAINER_DB_FILE_PATH\
	$IMAGE_NAME:$TAG

# Add build value into ras.conf
BUILD_FILE_NAME="build"
RAS_CONF_PATH="src/main/resources/private/ras.conf"
sudo docker exec $CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $RAS_CONF_PATH"

# Run RAS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &
