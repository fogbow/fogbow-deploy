#!/bin/bash
DIR=$(pwd)
IMAGE_NAME="fogbow/strongswan"
CONTAINER_NAME="strongswan"

FOGBOW_PUBLIC_KEY_FILE_NAME="fogbow-id_rsa.pub"
FOGBOW_SSH_PUBLIC_KEY=$(cat $FOGBOW_PUBLIC_KEY_FILE_NAME)

HOSTS_CONF_FILE="hosts.conf"
REMOTE_HOST_USER_PATTERN="remote_hosts_user"
REMOTE_HOST_USER=$(grep $REMOTE_HOST_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

AUTHORIZED_KEYS_FILE_PATH=/"home"/$REMOTE_HOST_USER/".ssh"/"authorized_keys"
grep "$FOGBOW_SSH_PUBLIC_KEY" $AUTHORIZED_KEYS_FILE_PATH
if [ "$?" -ne "0" ]; then
	echo "Adding fogbow ssh public in authorized keys"
	echo "$FOGBOW_SSH_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
fi

GENERAL_CONF_FILE="general.conf"
PASSWORD_PROPERTY="PASSWORD_PROPERTY"
PASSWORD=$(grep $PASSWORD_PROPERTY $GENERAL_CONF_FILE | awk -F "=" '{print $2}')

echo "VPN PSK: $PASSWORD"

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
	-e VPN_PSK=$PASSWORD \
	-v $DIR/$CREATE_NETWORK_SCRIPT:/$CREATE_NETWORK_SCRIPT \
	-v $DIR/$DELETE_NETWORK_SCRIPT:/$DELETE_NETWORK_SCRIPT \
	-v $DIR/$IPSEC_CONF_FILE:$CONTAINER_IPSEC_CONF_FILE_PATH \
	--privileged \
	$IMAGE_NAME

