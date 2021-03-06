#!/bin/bash
DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/etc/prosody"

CONF_FILE_NAME="prosody.cfg.lua"

IMAGE_NAME="fogbow/xmpp-server"
CONTAINER_NAME="xmpp-server"

SERVICES_CONF=$DIR_PATH/"services.conf"
IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker pull $IMAGE_NAME:$TAG
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

echo "Xmpp S2S port: $S2S_PORT"
echo "Xmpp C2S port: $C2S_PORT"
echo "Xmpp C2C port: $C2C_PORT"

sudo docker run -tdi --name $CONTAINER_NAME \
	-p 5269:5269 \
	-p 5347:5347 \
	$IMAGE_NAME:$TAG

chmod 644 $DIR_PATH/$CONF_FILE_NAME

sudo docker cp $DIR_PATH/$CONF_FILE_NAME $CONTAINER_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME

chmod 600 $DIR_PATH/$CONF_FILE_NAME

sudo docker exec $CONTAINER_NAME /bin/bash -c "service prosody restart"
