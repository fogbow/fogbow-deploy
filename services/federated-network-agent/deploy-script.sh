#!/bin/bash

DIR_PATH=$(pwd)
CONTAINER_BASE_PATH="/etc"

IMAGE_NAME="fogbow/strongswan:latest"
CONTAINER_NAME="strongswan"

STRONGSWAN_CONF_FILE_NAME="ipsec.secrets"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt \
	--name $CONTAINER_NAME \
	-p 500:500/udp \
	-p 4500:4500/udp \
	-p 1701:1701/udp \
	-v $DIR_PATH/$STRONGSWAN_CONF_FILE_NAME:$CONTAINER_BASE_PATH/$STRONGSWAN_CONF_FILE_NAME \
	$IMAGE_NAME

