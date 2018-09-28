#!/bin/bash
DIR=$(pwd)
IMAGE_NAME="fogbow/strongswan"
CONTAINER_NAME="strongswan"

HOSTS_CONF_FILE="hosts.conf"
REMOTE_HOST_USER_PATTERN="remote_hosts_user"
REMOTE_HOST_USER=$(grep $REMOTE_HOST_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

GENERAL_CONF_FILE="general.conf"

# key to provide access from internal host to dmz host
DMZ_PUBLIC_KEY_PATTERN="dmz_public_key_file_path"
DMZ_PUBLIC_KEY_PATH=$(grep $DMZ_PUBLIC_KEY_PATTERN $GENERAL_CONF_FILE | awk -F "=" '{print $2}')
DMZ_PUBLIC_KEY_NAME=$(basename $DMZ_PUBLIC_KEY_PATH)

DMZ_PUBLIC_KEY=$(cat $DMZ_PUBLIC_KEY_NAME)

AUTHORIZED_KEYS_FILE_PATH=/"home"/$REMOTE_HOST_USER/".ssh"/"authorized_keys"
grep "$DMZ_PUBLIC_KEY" $AUTHORIZED_KEYS_FILE_PATH
if [ "$?" -ne "0" ]; then
	echo "Adding dmz ssh public key in authorized keys"
	echo "$DMZ_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
fi

VPN_PASSWORD_KEY="vpn_password"
VPN_PASSWORD=$(grep $VPN_PASSWORD_KEY $GENERAL_CONF_FILE | awk -F "=" '{print $2}')

CREATE_NETWORK_SCRIPT="create-federated-network"
DELETE_NETWORK_SCRIPT="delete-federated-network"
CONFIG_PREFIX="config-"
chmod +x $CONFIG_PREFIX$CREATE_NETWORK_SCRIPT
chmod +x $CONFIG_PREFIX$DELETE_NETWORK_SCRIPT

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
	-e VPN_PSK=$VPN_PASSWORD \
	-v $DIR/$CREATE_NETWORK_SCRIPT:/$CREATE_NETWORK_SCRIPT \
	-v $DIR/$DELETE_NETWORK_SCRIPT:/$DELETE_NETWORK_SCRIPT \
	-v $DIR/$IPSEC_CONF_FILE:$CONTAINER_IPSEC_CONF_FILE_PATH \
	--privileged \
	--net=host \
	--cap-add=NET_ADMIN \
	$IMAGE_NAME

