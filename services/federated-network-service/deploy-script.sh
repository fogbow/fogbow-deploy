#!/bin/bash
DIR_PATH=$(pwd)
EXTRA_FILES_DIR=$DIR_PATH/"extra-files"
CONF_FILES_DIR_PATH="conf-files"
CONF_FILES_DIR=$DIR_PATH/"conf-files"

CONTAINER_BASE_PATH="/root/federated-network-service"
CONTAINER_EXTRA_FILES_PATH=$CONTAINER_BASE_PATH/"extra-files"
CONTAINER_RESOURCES_PATH=$CONTAINER_BASE_PATH/src/main/resources
CONTAINER_CONF_FILES_DIR=$CONTAINER_RESOURCES_PATH/"private"

FNS_TIMESTAMP_DB_FILE="fns.db"
PARENT_PATH=$(dirname $DIR_PATH)
TIMESTAMP_DB_DIRECTORY="timestamp-storage"

IMAGE_NAME="fogbow/federated-network-service"
CONTAINER_NAME="federated-network-service"

FEDNET_CONF_FILE_NAME="fns.conf"
LOG4F_FILE_NAME="log4j.properties"

APPLICATION_CONF_FILE="application.properties"

SERVER_PORT_PATTERN="server_port"
FEDNET_PORT=$(grep $SERVER_PORT_PATTERN $CONF_FILES_DIR_PATH/$FEDNET_CONF_FILE_NAME | awk -F "=" '{print $2}')
CONTAINER_PORT="8081"

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
SERVICES_CONF=services.conf
TAG=$(grep $IMAGE_BASE_NAME $CONF_FILES_DIR_PATH/$SERVICES_CONF | awk -F "=" '{print $2}')

echo "Federated network service server port: $FEDNET_PORT"

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

# Resolving timestamp db
if [ ! -d $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY ]; then
	mkdir -p $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY
fi
if [ ! -f $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY/$FNS_TIMESTAMP_DB_FILE ]; then
	touch $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY/$FNS_TIMESTAMP_DB_FILE
fi
DB_KEY_PATTERN="jdbc_database_url"
RAS_CONF_FILE=$CONF_FILES_DIR/"ras.conf"
CONTAINER_DB_FILE_PATH=$(grep $DB_KEY_PATTERN $RAS_CONF_FILE | awk -F ":" '{print $3}')

FEDNET_AGENT_SSH_PRIVATE_KEY_PATTERN="federated_network_agent_permission_file_path"
FEDNET_AGENT_SSH_PRIVATE_KEY=$(grep $FEDNET_AGENT_SSH_PRIVATE_KEY_PATTERN $FEDNET_CONF_FILE_NAME | awk -F "=" '{print $2}')
FEDNET_AGENT_SSH_PRIVATE_KEY=$(basename $FEDNET_AGENT_SSH_PRIVATE_KEY)

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p $FEDNET_PORT:$CONTAINER_PORT \
	-v $CONF_FILES_DIR:$CONTAINER_CONF_FILES_DIR \
	-v $DIR_PATH/$APPLICATION_CONF_FILE:$CONTAINER_RESOURCES_PATH/$APPLICATION_CONF_FILE \
	-v $DIR_PATH/$LOG4F_FILE_NAME:$CONTAINER_BASE_PATH/$LOG4F_FILE_NAME \
	-v $EXTRA_FILES_DIR:$CONTAINER_EXTRA_FILES_PATH \
	-v $PARENT_PATH/$TIMESTAMP_DB_DIRECTORY/$FNS_TIMESTAMP_DB_FILE:$CONTAINER_DB_FILE_PATH\
	$IMAGE_NAME:$TAG

# Add build value into fns.conf
BUILD_FILE_NAME="build"
FNS_CONF_PATH="src/main/resources/private/fns.conf"
sudo docker exec $CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $FNS_CONF_PATH"

# Run FNS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &
