#!/bin/bash
SERVICE="fogbow-database"
CONF_FILES_DIR_PATH="./conf-files"
SECRETS_FILE_PATH=$CONF_FILES_DIR_PATH/"secrets"
SERVICES_CONF_FILE_PATH=$CONF_FILES_DIR_PATH/"services.conf"

CONTAINER_DATA_DIR_PATH="/var/lib/postgresql/data"
DB_DATA_DIR_NAME="data"
RAS_DB_NAME=ras
FNS_DB_NAME=fns
IMAGE_NAME="fogbow/database"
CONTAINER_NAME=$SERVICE
CONTAINER_PORT="5432"

DB_USER="fogbow"
DB_PASSWORD=$(grep ^db_password $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

mkdir $DB_DATA_DIR_NAME

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF_FILE_PATH | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker pull $IMAGE_NAME:$TAG
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $CONTAINER_PORT:$CONTAINER_PORT \
	-e DB_USER=$DB_USER \
	-e DB_PASS=$DB_PASSWORD \
	-e DB_NAME=$RAS_DB_NAME \
	-e DB2_NAME=$FNS_DB_NAME \
	-v $DB_DATA_DIR_NAME:$CONTAINER_DATA_DIR_PATH \
	$IMAGE_NAME:$TAG
