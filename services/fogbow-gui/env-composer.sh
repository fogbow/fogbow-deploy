#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/fogbow-gui"
APACHE_CONF_FILES_DIR="apache-confs"

# Copying related conf files

GUI_CONF_DIR="gui-confs"
GUI_CONF_FILE="gui.conf"
yes | cp -f $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE $BASE_DIR/$GUI_CONF_FILE

INTERCOMPONENT_CONF_FILE="intercomponent.conf"
yes | cp -f $CONF_FILES_DIR/$INTERCOMPONENT_CONF_FILE $BASE_DIR/$INTERCOMPONENT_CONF_FILE

SERVICES_CONF_FILE="services.conf"
yes | cp -f $CONF_FILES_DIR/$SERVICES_CONF_FILE $BASE_DIR/$SERVICES_CONF_FILE

# Setting up local_settings.py

CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE | awk -F "=" '{print $2}')
API_CONFIG_FILE_NAME="api.config.js"

yes | cp -f $CONF_FILES_DIR/$GUI_CONF_DIR/$AUTH_TYPE_CLASS"-"$API_CONFIG_FILE_NAME $BASE_DIR/$API_CONFIG_FILE_NAME

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
