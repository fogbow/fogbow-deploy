#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/fogbow-gui"

# Copying related conf files

MANAGER_CONF_FILE="manager.conf"
yes | cp -f $CONF_FILES_DIR/$MANAGER_CONF_FILE $BASE_DIR/$MANAGER_CONF_FILE

INTERCOMPONENT_CONF_FILE="intercomponent.conf"
yes | cp -f $CONF_FILES_DIR/$INTERCOMPONENT_CONF_FILE $BASE_DIR/$INTERCOMPONENT_CONF_FILE

# Setting up local_settings.py

CONF_FILE_NAME="api.config.js"

yes | cp -f $BASE_DIR/$CONF_FILE_NAME".example" $BASE_DIR/$CONF_FILE_NAME

# Getting manager ip and port 

IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $IP_PATTERN $CONF_FILES_DIR/"hosts.conf" | awk -F "=" '{print $2}')

MANAGER_PORT_PATTERN="manager_server_port"
MANAGER_PORT=$(grep $MANAGER_PORT_PATTERN $CONF_FILES_DIR/"manager.conf" | awk -F "=" '{print $2}')

echo "Manager url: $INTERNAL_HOST_IP:$MANAGER_PORT"
sed -i "s#.*manager:.*#	manager: 'http://$INTERNAL_HOST_IP:$MANAGER_PORT',#" $BASE_DIR/$CONF_FILE_NAME

# Getting federated network service ip and port 

echo "Using Federated network service"
FEDNET_CONF_FILE=$CONF_FILES_DIR/"federated-network.conf"
FEDNET_PORT_PATTERN="server_port"
FEDNET_PORT=$(grep $FEDNET_PORT_PATTERN $FEDNET_CONF_FILE | awk -F "=" '{print $2}')

echo "Federated network service url: $INTERNAL_HOST_IP:$FEDNET_PORT"
sed -i "s#.*fedenet:.*#	fedenet: 'http://$INTERNAL_HOST_IP:$FEDNET_PORT',#" $BASE_DIR/$CONF_FILE_NAME

# Getting membership port

MEMBERSHIP_PORT_PATTERN="server_port"
MEMBERSHIP_PORT=$(grep $MEMBERSHIP_PORT_PATTERN $CONF_FILES_DIR/"membership.conf" | awk -F "=" '{print $2}')

echo "Membership url: $INTERNAL_HOST_IP:$MEMBERSHIP_PORT"
sed -i "s#.*membership:.*#	membership: 'http://$INTERNAL_HOST_IP:$MEMBERSHIP_PORT',#" $BASE_DIR/$CONF_FILE_NAME

# Getting XMPP JID

XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $CONF_FILES_DIR/$INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')

echo "XMPP JID: $XMPP_JID"
sed -i "s#.*local:.*#	local: '$XMPP_JID',#" $BASE_DIR/$CONF_FILE_NAME

# Setting up Authentication Type

AUTH_TYPE_PATTERN="federation_identity_plugin_class"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/"behavior.conf" | awk -F "=" '{print $2}')

FEDERATION_IDENTITY_DIR=$CONF_FILES_DIR/"behavior-plugins"/"federation-identity"/

if [[ $AUTH_TYPE_CLASS = *"Ldap"* ]]; then
	LDAP_CONF_FILE_NAME="ldap-identity-plugin.conf"
	LDAP_CONF_FILE=$FEDERATION_IDENTITY_DIR/$LDAP_CONF_FILE_NAME
	
	AUTH_TYPE_PATTERN="authPlugin"
	AUTH_TYPE="Ldap"
	echo "Dashboard auth type: $AUTH_TYPE"
	
	echo "	$AUTH_TYPE_PATTERN: '$AUTH_TYPE',
	authFields: {
		username: {
			type: 'text',
			label: 'Username'
		},
		password: {
			type: 'password',
			label: 'Password'
		}
	}
};" >> $BASE_DIR/$CONF_FILE_NAME
fi

cat $BASE_DIR/$CONF_FILE_NAME

