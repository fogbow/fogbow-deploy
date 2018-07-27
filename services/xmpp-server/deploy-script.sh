#!/bin/bash
DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/etc/prosody"

CONF_FILE_NAME="prosody.cfg.lua"

IMAGE_NAME="fogbow/xmpp-server"
CONTAINER_NAME="xmpp-server"

INTERCOMPONENT_FILE_PATH="intercomponent.conf"

S2S_PORT_PATTERN="xmpp_s2s_port"
S2S_PORT=$(grep $S2S_PORT_PATTERN $INTERCOMPONENT_FILE_PATH | awk -F "=" '{print $2}')
S2S_CONTAINER_PORT="5269"

C2S_PORT_PATTERN="xmpp_c2s_port"
C2S_PORT=$(grep $C2S_PORT_PATTERN $INTERCOMPONENT_FILE_PATH | awk -F "=" '{print $2}')
C2S_CONTAINER_PORT="5222"

C2C_PORT_PATTERN="xmpp_c2c_port"
C2C_PORT=$(grep $C2C_PORT_PATTERN $INTERCOMPONENT_FILE_PATH | awk -F "=" '{print $2}')
C2C_CONTAINER_PORT="5347"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

echo "Xmpp S2S port: $S2S_PORT"
echo "Xmpp C2S port: $C2S_PORT"
echo "Xmpp C2C port: $C2C_PORT"

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $C2S_PORT:$C2S_CONTAINER_PORT \
	-p $S2S_PORT:$S2S_CONTAINER_PORT \
	-p $C2C_PORT:$C2C_CONTAINER_PORT \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONF_FILE_NAME:ro \
	$IMAGE_NAME

