#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/fogbow-gui"
FNS_CONF_FILES_DIR="ras-confs-to-fns"
APACHE_CONF_FILES_DIR="apache-confs"

# Copying related conf files

MANAGER_CONF_FILE="ras.conf"
yes | cp -f $CONF_FILES_DIR/$MANAGER_CONF_FILE $BASE_DIR/$MANAGER_CONF_FILE

INTERCOMPONENT_CONF_FILE="intercomponent.conf"
yes | cp -f $CONF_FILES_DIR/$INTERCOMPONENT_CONF_FILE $BASE_DIR/$INTERCOMPONENT_CONF_FILE

SERVICES_CONF_FILE="services.conf"
yes | cp -f $CONF_FILES_DIR/$SERVICES_CONF_FILE $BASE_DIR/$SERVICES_CONF_FILE

# Setting up local_settings.py

CONF_FILE_NAME="api.config.js"

yes | cp -f $BASE_DIR/$CONF_FILE_NAME".example" $BASE_DIR/$CONF_FILE_NAME

# Getting internal host ip

IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $IP_PATTERN $CONF_FILES_DIR/"hosts.conf" | awk -F "=" '{print $2}')

# Getting federated network service ip and port 

echo "Using Federated network service"
DOMAIN_NAME_FILE="domain-names.conf"
FNS_DOMAIN_NAME_PATTERN="fns_domain_name"
FNS_DOMAIN_NAME=$(grep $FNS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_FILE | awk -F "=" '{print $2}')
FNS_DOMAIN_BASENAME=$(basename $FNS_DOMAIN_NAME)

echo "Federated network service domain name: $FEDNET_DOMAIN_NAME"
sed -i "s#.*fns:.*#	fns: 'https://$FNS_DOMAIN_BASENAME',#" $BASE_DIR/$CONF_FILE_NAME

# Getting membership port

MS_DOMAIN_NAME_PATTERN="ms_domain_name"
MS_DOMAIN_NAME=$(grep $MS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_FILE | awk -F "=" '{print $2}')
MS_DOMAIN_BASENAME=$(basename $MS_DOMAIN_NAME)

echo "Membership domain name: $MS_DOMAIN_NAME"
sed -i "s#.*ms:.*#	ms: 'https://$MS_DOMAIN_BASENAME',#" $BASE_DIR/$CONF_FILE_NAME

# Getting XMPP JID

XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $CONF_FILES_DIR/$INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')

echo "XMPP JID: $XMPP_JID"
sed -i "s#.*local:.*#	local: '$XMPP_JID',#" $BASE_DIR/$CONF_FILE_NAME

# Setting up Authentication Type

AUTH_TYPE_PATTERN="federation_identity_plugin_class"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/"aaa.conf" | awk -F "=" '{print $2}')

FEDERATION_IDENTITY_DIR=$CONF_FILES_DIR/"aaa-plugins"/"federation-identity"/

if [[ $AUTH_TYPE_CLASS = *"Ldap"* ]]; then
	AUTH_TYPE_PATTERN="authenticationPlugin"
	AUTH_TYPE="Ldap"
	echo "Dashboard auth type: $AUTH_TYPE"
	
	echo "	$AUTH_TYPE_PATTERN: '$AUTH_TYPE',
	credentialFields: {
		username: {
			type: 'text',
			label: 'Username'
		},
		password: {
			type: 'password',
			label: 'Password'
		}
	}" >> $BASE_DIR/$CONF_FILE_NAME
elif [[ $AUTH_TYPE_CLASS = *"OpenStack"* ]]; then
	AUTH_TYPE_PATTERN="authenticationPlugin"
	AUTH_TYPE="KeystoneV3"
	echo "Dashboard auth type: $AUTH_TYPE"
	
	echo "	$AUTH_TYPE_PATTERN: '$AUTH_TYPE',
	credentialFields: {
		username: {
			type: 'text',
			label: 'User Name'
		},
		password: {
			type: 'password',
			label: 'Password'
		},
		domain: {
			type: 'text',
			label: 'Domain'
		},
		projectname: {
			type: 'text',
			label: 'Project Name'
		}
	}" >> $BASE_DIR/$CONF_FILE_NAME
fi
echo "};" >> $BASE_DIR/$CONF_FILE_NAME
