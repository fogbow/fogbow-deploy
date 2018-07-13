#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/dashboard"

EXTRA_FILES_DIR=$BASE_DIR/"extra-files"
mkdir -p $EXTRA_FILES_DIR

CONTAINER_DIR="/root/fogbow-dashboard-core"
CONTAINER_EXTRA_FILES_DIR=$CONTAINER_DIR/"extra-files"

# Copying related conf files

MANAGER_CONF_FILE="manager.conf"
yes | cp -f $CONF_FILES_DIR/$MANAGER_CONF_FILE $BASE_DIR/$MANAGER_CONF_FILE

INTERCOMPONENT_CONF_FILE="intercomponent.conf"
yes | cp -f $CONF_FILES_DIR/$INTERCOMPONENT_CONF_FILE $BASE_DIR/$INTERCOMPONENT_CONF_FILE

# Setting up local_settings.py

CONF_FILE_NAME="local_settings.py"

yes | cp -f $BASE_DIR/$CONF_FILE_NAME".example" $BASE_DIR/$CONF_FILE_NAME

# Getting manager ip and port 

IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $IP_PATTERN $CONF_FILES_DIR/"hosts.conf" | awk -F "=" '{print $2}')

MANAGER_IP=$INTERNAL_HOST_IP

MANAGER_PORT_PATTERN="manager_server_port"
MANAGER_PORT=$(grep $MANAGER_PORT_PATTERN $CONF_FILES_DIR/"manager.conf" | awk -F "=" '{print $2}')

echo "Manager url: $MANAGER_IP:$MANAGER_PORT"

sed -i "s#.*FOGBOW_MANAGER_CORE_ENDPOINT.*#FOGBOW_MANAGER_CORE_ENDPOINT = 'http://$MANAGER_IP:$MANAGER_PORT'#" $BASE_DIR/$CONF_FILE_NAME

# Getting membership port

MEMBERSHIP_IP=$INTERNAL_HOST_IP

MEMBERSHIP_PORT_PATTERN="server_port"
MEMBERSHIP_PORT=$(grep $MEMBERSHIP_PORT_PATTERN $CONF_FILES_DIR/"membership.conf" | awk -F "=" '{print $2}')

echo "Membership url: $MEMBERSHIP_IP:$MEMBERSHIP_PORT"

sed -i "s#.*FOGBOW_MEMBERSHIP_ENDPOINT.*#FOGBOW_MEMBERSHIP_ENDPOINT = 'http://$MEMBERSHIP_IP:$MEMBERSHIP_PORT'#" $BASE_DIR/$CONF_FILE_NAME

# Getting XMPP JID

XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $CONF_FILES_DIR/$INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')

echo "XMPP JID: $XMPP_JID"

sed -i "s#.*FOGBOW_MANAGER_CORE_XMPP_JID.*#FOGBOW_MANAGER_CORE_XMPP_JID = '$XMPP_JID'#" $BASE_DIR/$CONF_FILE_NAME

# Adding Federated Network Extension

echo "Adding Federated Network Extension"

sed -i "s#.*FEDERATED_NETWORK_EXTENSION.*#FEDERATED_NETWORK_EXTENSION = True#" $BASE_DIR/$CONF_FILE_NAME

# Setting up Authentication Type

AUTH_TYPE_PATTERN="federation_identity_plugin_class"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/"behavior.conf" | awk -F "=" '{print $2}')

FEDERATION_IDENTITY_DIR=$CONF_FILES_DIR/"behavior-plugins"/"federation-identity"/

if [[ $AUTH_TYPE_CLASS = *"Ldap"* ]]; then
	LDAP_CONF_FILE_NAME="ldap-identity-plugin.conf"
	LDAP_CONF_FILE=$FEDERATION_IDENTITY_DIR/$LDAP_CONF_FILE_NAME
	
	# Copying ldap conf file
	yes | cp -f $LDAP_CONF_FILE $EXTRA_FILES_DIR/$LDAP_CONF_FILE_NAME
	
	MANAGER_AUTH_TYPE="ldap"
	
	echo "Dashboard auth type: $MANAGER_AUTH_TYPE"

	sed -i "s#.*FOGBOW_FEDERATION_AUTH_TYPE.*#FOGBOW_FEDERATION_AUTH_TYPE = 'ldap'#" $BASE_DIR/$CONF_FILE_NAME

	# Add authentication conf file 
	
	echo "Dashboard auth conf file: $CONTAINER_EXTRA_FILES_DIR/$LDAP_CONF_FILE_NAME"
	
	sed -i "s#.*FOGBOW_AUTHENTICATION_CONF_PATH.*#FOGBOW_AUTHENTICATION_CONF_PATH = '$CONTAINER_EXTRA_FILES_DIR/$LDAP_CONF_FILE_NAME'#" $BASE_DIR/$CONF_FILE_NAME
	
	# Modifying ldap conf file
	
	PRIVATE_KEY_PATH_PATTERN="private_key_path"
	PRIVATE_KEY_PATH=$(grep $PRIVATE_KEY_PATH_PATTERN $LDAP_CONF_FILE | awk -F "=" '{print $2}')
	PRIVATE_KEY_NAME=$(basename $PRIVATE_KEY_PATH)
	
	echo "Private key path: $PRIVATE_KEY_PATH"
	
	yes | cp -f $PRIVATE_KEY_PATH $EXTRA_FILES_DIR/$PRIVATE_KEY_NAME
	sed -i "s!.*private_key_path.*!private_key_path=$CONTAINER_EXTRA_FILES_DIR/$PRIVATE_KEY_NAME!" $EXTRA_FILES_DIR/$LDAP_CONF_FILE_NAME
	
	echo "Container public key path: $CONTAINER_DIR/$PRIVATE_KEY_NAME"

	PUBLIC_KEY_PATH_PATTERN="public_key_path"
	PUBLIC_KEY_PATH=$(grep $PUBLIC_KEY_PATH_PATTERN $LDAP_CONF_FILE | awk -F "=" '{print $2}')
	PUBLIC_KEY_NAME=$(basename $PUBLIC_KEY_PATH)
	
	echo "Public key path: $PUBLIC_KEY_PATH"
	
	yes | cp -f $PUBLIC_KEY_PATH $EXTRA_FILES_DIR/$PUBLIC_KEY_NAME
	sed -i "s!.*public_key_path.*!public_key_path=$CONTAINER_EXTRA_FILES_DIR/$PUBLIC_KEY_NAME!" $EXTRA_FILES_DIR/$LDAP_CONF_FILE_NAME
	
	echo "Container public key path: $CONTAINER_DIR/$PUBLIC_KEY_NAME"

fi

