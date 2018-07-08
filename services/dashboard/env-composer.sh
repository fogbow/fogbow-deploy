#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/dashboard"
CONTAINER_DIR="/root/fogbow-dashboard-core"

MANAGER_CONF_FILE="manager.conf"

yes | cp -f $CONF_FILES_DIR/$MANAGER_CONF_FILE $BASE_DIR/$MANAGER_CONF_FILE

# Getting manager and membership ip and port\
IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $IP_PATTERN $CONF_FILES_DIR/"hosts.conf" | awk -F "=" '{print $2}')

MANAGER_IP=$INTERNAL_HOST_IP

PORT_PATTERN="server_port"
MANAGER_PORT=$(grep $PORT_PATTERN $CONF_FILES_DIR/"manager.conf" | awk -F "=" '{print $2}')

MEMBERSHIP_IP=$INTERNAL_HOST_IP
MEMBERSHIP_PORT=$(grep $PORT_PATTERN $CONF_FILES_DIR/"membership.conf" | awk -F "=" '{print $2}')

echo "Manager url: $MANAGER_IP:$MANAGER_PORT"
echo "Membership url: $MEMBERSHIP_IP:$MEMBERSHIP_PORT"

AUTH_TYPE_PATTERN="federation_identity_plugin_class"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/"behavior.conf" | awk -F "=" '{print $2}')

CONF_FILE_NAME="local_settings.py"

yes | cp -f $BASE_DIR/$CONF_FILE_NAME".example" $BASE_DIR/$CONF_FILE_NAME

FEDERATION_IDENTITY_DIR=$CONF_FILES_DIR/"behavior-plugins"/"federation-identity"/

if [[ $AUTH_TYPE_CLASS = *"Ldap"* ]]; then
	LDAP_CONF_FILE=$FEDERATION_IDENTITY_DIR/"ldap-identity-plugin.conf"
	
	MANAGER_AUTH_TYPE="ldap"
	
	MANAGER_AUTH_URL_PATTERN="ldap_identity_url"
	MANAGER_AUTH_ENDPOINT=$(grep $MANAGER_AUTH_URL_PATTERN $LDAP_CONF_FILE | awk -F "=" '{print $2}')
	
	echo "Manager auth type: $MANAGER_AUTH_TYPE"
	echo "Manager auth endpoint: $MANAGER_AUTH_ENDPOINT"

	sed -i "s#.*FOGBOW_MANAGER_ENDPOINT.*#FOGBOW_MANAGER_ENDPOINT = 'http://$MANAGER_IP:$MANAGER_PORT'#" $BASE_DIR/$CONF_FILE_NAME

	sed -i "s#.*FOGBOW_MEMBERSHIP_ENDPOINT.*#FOGBOW_MEMBERSHIP_ENDPOINT = 'http://$MEMBERSHIP_IP:$MEMBERSHIP_PORT'#" $BASE_DIR/$CONF_FILE_NAME

	sed -i "s#.*FOGBOW_FEDERATION_AUTH_ENDPOINT.*#FOGBOW_FEDERATION_AUTH_ENDPOINT = '$MANAGER_AUTH_ENDPOINT'#" $BASE_DIR/$CONF_FILE_NAME

	sed -i "s#.*FOGBOW_FEDERATION_AUTH_TYPE.*#FOGBOW_FEDERATION_AUTH_TYPE = 'ldap'#" $BASE_DIR/$CONF_FILE_NAME

	PRIVATE_KEY_PATH_PATTERN="private_key_path"
	PRIVATE_KEY_PATH=$(grep $PRIVATE_KEY_PATH_PATTERN $LDAP_CONF_FILE | awk -F "=" '{print $2}')
	PRIVATE_KEY_NAME=$(basename $PRIVATE_KEY_PATH)
	
	echo "Private key path: $PRIVATE_KEY_PATH"
	
	yes | cp -f $PRIVATE_KEY_PATH $BASE_DIR/$PRIVATE_KEY_NAME
	sed -i "s!.*# PRIVATE_KEY_PATH.*!PRIVATE_KEY_PATH = '$CONTAINER_DIR/$PRIVATE_KEY_NAME'!" $BASE_DIR/$CONF_FILE_NAME
	
	echo "Container public key path: $CONTAINER_DIR/$PRIVATE_KEY_NAME"

	PUBLIC_KEY_PATH_PATTERN="public_key_path"
	PUBLIC_KEY_PATH=$(grep $PUBLIC_KEY_PATH_PATTERN $LDAP_CONF_FILE | awk -F "=" '{print $2}')
	PUBLIC_KEY_NAME=$(basename $PUBLIC_KEY_PATH)
	
	echo "Public key path: $PUBLIC_KEY_PATH"
	
	yes | cp -f $PUBLIC_KEY_PATH $BASE_DIR/$PUBLIC_KEY_NAME
	sed -i "s!.*# PUBLIC_KEY_PATH.*!PUBLIC_KEY_PATH = '$CONTAINER_DIR/$PUBLIC_KEY_NAME'!" $BASE_DIR/$CONF_FILE_NAME
	
	echo "Container public key path: $CONTAINER_DIR/$PUBLIC_KEY_NAME"

	LDAP_BASE_PATTERN="ldap_base"
	FOGBOW_LDAP_BASE=$(grep $LDAP_BASE_PATTERN $LDAP_CONF_FILE | awk -F "=" '{print $2}')
	
	echo "LDAP base: $FOGBOW_LDAP_BASE"
	
	sed -i "s!.*# FOGBOW_LDAP_BASE.*!FOGBOW_LDAP_BASE = '$FOGBOW_LDAP_BASE'!" $BASE_DIR/$CONF_FILE_NAME

	LDAP_ENCRYPT_PATTERN="ldap_encrypt_type"
	FOGBOW_LDAP_ENCRYPT=$(grep $LDAP_ENCRYPT_PATTERN $LDAP_CONF_FILE | awk -F "=" '{print $2}')
	
	echo "LDAP encrypt type: $FOGBOW_LDAP_ENCRYPT"
	
	sed -i "s!.*# FOGBOW_LDAP_ENCRYPT.*!FOGBOW_LDAP_ENCRYPT = '$FOGBOW_LDAP_ENCRYPT'!" $BASE_DIR/$CONF_FILE_NAME
fi

