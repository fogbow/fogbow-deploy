#!/bin/bash

IMAGE_NAME="philplckthun/strongswan"
CONTAINER_NAME="strongswan"

CONF_FILE_PATH="/etc/ipsec.conf"

# Download Agent scripts
echo "Downloading agent scripts"

wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-create-federated-network -O config-create-federated-network
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-delete-federated-network -O config-delete-federated-network

# Mounting shared volume
SHARED_VOLUME_DIR="/etc/ipsec.d"

sudo mkdir -p $SHARED_VOLUME_DIR
SHARED_VOLUME_SUBDIRS="aacerts acerts cacerts certs crls ocspcerts private reqs"
for each in $SHARED_VOLUME_SUBDIRS; do
	sudo mkdir -p $SHARED_VOLUME_DIR/$each
done

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
	-v $SHARED_VOLUME_DIR:$SHARED_VOLUME_DIR \
	$IMAGE_NAME

sudo docker cp $CONTAINER_NAME:$CONF_FILE_PATH $CONF_FILE_PATH

