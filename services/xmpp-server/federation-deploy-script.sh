#!/bin/bash
CURRENT_DIR_PATH=$(pwd)
CONF_FILES_DIR_PATH=$CURRENT_DIR_PATH/"conf-files"
SERVICES_CONF_FILE_NAME="services.conf"
CONTAINER_BASE_DIR="/etc/prosody"
CONF_FILE_NAME="prosody.cfg.lua"
SERVICE="xmpp-server"
IMAGE_NAME="fogbow/"$SERVICE
CONTAINER_NAME=$SERVICE

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $CONF_FILES_DIR_PATH/$SERVICES_CONF_FILE_NAME | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

sudo docker run -tdi --name $CONTAINER_NAME \
	-p 5269:5269 \
	-p 5347:5347 \
	$IMAGE_NAME:$TAG

chmod 644 $CURRENT_DIR_PATH/$CONF_FILE_NAME
sudo docker cp $CURRENT_DIR_PATH/$CONF_FILE_NAME $CONTAINER_NAME:$CONTAINER_BASE_DIR/$CONF_FILE_NAME
chmod 600 $CURRENT_DIR_PATH/$CONF_FILE_NAME

sudo docker exec $CONTAINER_NAME /bin/bash -c "service prosody restart"
