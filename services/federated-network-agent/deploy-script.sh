#!/bin/bash
DIR=$(pwd)
HOSTS_CONF_FILE="hosts.conf"
REMOTE_HOST_USER_PATTERN="remote_hosts_user"
REMOTE_HOST_USER=$(grep $REMOTE_HOST_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

GENERAL_CONF_FILE="general.conf"

echo "Installing Strongswan"

VPN_PASSWORD_KEY="vpn_password"
VPN_PASSWORD=$(grep $VPN_PASSWORD_KEY $GENERAL_CONF_FILE | awk -F "=" '{print $2}')

STRONGSWAN_INSTALLATION_SCRIPT="strongswan-installation"
sudo bash $STRONGSWAN_INSTALLATION_SCRIPT $VPN_PASSWORD

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

CREATE_NETWORK_SCRIPT="create-federated-network"
DELETE_NETWORK_SCRIPT="delete-federated-network"
chmod +x $CREATE_NETWORK_SCRIPT
chmod +x $DELETE_NETWORK_SCRIPT
