#!/bin/bash

IMAGE_NAME="philplckthun/strongswan"
CONTAINER_NAME="strongswan"

CONF_FILE_PATH="/etc/ipsec.conf"

# Download Agent scripts
echo "Downloading agent scripts"

wget https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-create-federated-network
wget https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-delete-federated-network

MANAGER_CONF_FILE="manager.conf"
MANAGER_JDBC_PASSWORD_PROPERTY="jdbc_database_password"
MANAGER_JDBC_PASSWORD=$(grep $MANAGER_JDBC_PASSWORD_PROPERTY $MANAGER_CONF_FILE | awk -F "=" '{print $2}')

echo "VPN PSK: $MANAGER_JDBC_PASSWORD"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -idt \
	-p 500:500/udp \
	-p 4500:4500/udp \
	-p 1701:1701/udp \
	--privileged \
	--name $CONTAINER_NAME \
	-e VPN_PSK=$MANAGER_JDBC_PASSWORD \
	$IMAGE_NAME

sudo docker cp $CONTAINER_NAME:$CONF_FILE_PATH $CONF_FILE_PATH

