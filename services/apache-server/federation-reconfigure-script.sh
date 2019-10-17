#!/bin/bash
DIR_PATH=$(pwd)
CONF_FILES_DIR=$DIR_PATH

CONTAINER_NAME="apache-server"
VIRTUAL_HOST_DIR="/etc/apache2/sites-available"
ROOT_DIR="/var/www/html"
INDEX_FILE="index.html"
VIRTUAL_HOST_FILE="000-default.conf"

sudo docker cp $CONTAINER_NAME:$VIRTUAL_HOST_DIR/$VIRTUAL_HOST_FILE $VIRTUAL_HOST_FILE
sudo docker cp $CONTAINER_NAME:$ROOT_DIR/$INDEX_FILE $INDEX_FILE
sudo chown ubuntu.ubuntu $VIRTUAL_HOST_FILE $INDEX_FILE

ed -s $VIRTUAL_HOST_FILE <<!
/ras
.,+t+
-
-,.s,ras,ms ,g
-,.s,8082,8083
w
q
!

ed -s $INDEX_FILE <<!
/8082
-2,+2t+2
-2
s,8082,8083
s,Resource allocation,Membership
w
q
!

sudo docker cp $VIRTUAL_HOST_FILE $CONTAINER_NAME:$VIRTUAL_HOST_DIR/$VIRTUAL_HOST_FILE
sudo docker cp $INDEX_FILE $CONTAINER_NAME:$ROOT_DIR
