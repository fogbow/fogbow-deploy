#!/bin/bash
DIR_PATH=$(pwd)
CONF_FILES_DIR="conf-files"
GENERAL_CONF_FILE_PATH=$DIR/$CONF_FILES_DIR/"general.conf"
SECRETS="secrets"

IMAGE_NAME="fogbow/database"
CONTAINER_NAME="fogbow-database"

CONTAINER_PORT="5432"

DB_USER="fogbow"
DB_PASSWORD=$(grep ^db_password $SECRETS | awk -F "=" '{print $2}')

RAS_DB_NAME=ras

DB_DATA_DIR=$DIR_PATH/"data"
mkdir -p $DB_DATA_DIR
CONTAINER_DATA_DIR="/var/lib/postgresql/data"

SERVICES_CONF=$DIR_PATH/"services.conf"
IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

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
	-v $DB_DATA_DIR:$CONTAINER_DATA_DIR \
	$IMAGE_NAME:$TAG
