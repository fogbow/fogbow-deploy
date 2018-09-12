#!/bin/bash
DIR_PATH=$(pwd)

IMAGE_NAME="postgres"
CONTAINER_NAME="fogbow-database"

CONTAINER_PORT="5432"

DB_USER="postgres"
DB_PASSWORD="postgres"

DB_DATA_DIR=$DIR_PATH/"data"
mkdir -p $DB_DATA_DIR
CONTAINER_DATA_DIR="/var/lib/postgresql/data"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $CONTAINER_PORT:$CONTAINER_PORT \
	-e POSTGRES_PASSWORD=$DB_PASSWORD \
	-e POSTGRES_USER=$DB_USER \
	-v $DB_DATA_DIR:$CONTAINER_DATA_DIR \
	$IMAGE_NAME

