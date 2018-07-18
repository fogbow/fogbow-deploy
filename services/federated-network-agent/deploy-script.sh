#!/bin/bash
DIR=$(pwd)
IMAGE_NAME="fogbow/strongswan"
CONTAINER_NAME="strongswan"

MANAGER_CONF_FILE="manager.conf"
MANAGER_JDBC_PASSWORD_PROPERTY="jdbc_database_password"
MANAGER_JDBC_PASSWORD=$(grep $MANAGER_JDBC_PASSWORD_PROPERTY $MANAGER_CONF_FILE | awk -F "=" '{print $2}')

echo "VPN PSK: $MANAGER_JDBC_PASSWORD"

CREATE_NETWORK_SCRIPT="create-federated-network"
DELETE_NETWORK_SCRIPT="delete-federated-network"

IPSEC_CONF_FILE="ipsec.conf"
CONTAINER_IPSEC_CONF_FILE_PATH=/"etc"/$IPSEC_CONF_FILE

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt \
	-p 500:500/udp \
	-p 4500:4500/udp \
	-p 1701:1701/udp \
	--name $CONTAINER_NAME \
	-e VPN_PSK=$MANAGER_JDBC_PASSWORD \
	-v $DIR/$CREATE_NETWORK_SCRIPT:/$CREATE_NETWORK_SCRIPT \
	-v $DIR/$DELETE_NETWORK_SCRIPT:/$DELETE_NETWORK_SCRIPT \
	-v $DIR/$IPSEC_CONF_FILE:$CONTAINER_IPSEC_CONF_FILE_PATH \
	--privileged \
	$IMAGE_NAME

