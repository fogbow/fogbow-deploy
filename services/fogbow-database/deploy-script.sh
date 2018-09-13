#!/bin/bash
DIR_PATH=$(pwd)

IMAGE_NAME="postgres"
CONTAINER_NAME="fogbow-database"

CONTAINER_PORT="5432"

DB_USER="fogbow"
GENERAL_PASSWORD="password"
GENERAL_PASSWORD=$(grep $GENERAL_PASSWORD $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')

RAS_DB_NAME=ras
FEDNET_DB_NAME=fns

DB_DATA_DIR=$DIR_PATH/"data"
mkdir -p $DB_DATA_DIR
CONTAINER_DATA_DIR="/var/lib/postgresql/data"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $CONTAINER_PORT:$CONTAINER_PORT \
	-e DB_USER=$DB_USER \
	-e DB_PASS=$GENERAL_PASSWORD \
	-e DB_NAME=$RAS_DB_NAME \
	-e DB2_NAME=$FEDNET_DB_NAME \
	-v $DB_DATA_DIR:$CONTAINER_DATA_DIR \
	$IMAGE_NAME

