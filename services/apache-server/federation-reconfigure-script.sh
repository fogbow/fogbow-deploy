#!/bin/bash
DIR_PATH=$(pwd)
CONF_FILES_DIR=$DIR_PATH

CONTAINER_NAME="apache-server"
VIRTUAL_HOST_DIR="/etc/apache2/sites-enabled"
ROOT_DIR="/var/www/html"
INDEX_FILE="index.html"
VIRTUAL_HOST_FILE="000-default.conf"

sudo docker cp $VIRTUAL_HOST_FILE $CONTAINER_NAME:$VIRTUAL_HOST_DIR/$VIRTUAL_HOST_FILE
sudo docker cp $INDEX_FILE $CONTAINER_NAME:$ROOT_DIR