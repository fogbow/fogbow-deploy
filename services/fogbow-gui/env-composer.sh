#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/fogbow-gui"
APACHE_CONF_FILES_DIR="apache-confs"

# Copying related conf files

GUI_CONF_DIR="gui-confs"
GUI_CONF_FILE="gui.conf"
yes | cp -f $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE $BASE_DIR/$GUI_CONF_FILE

SERVICES_CONF_FILE="services.conf"
yes | cp -f $CONF_FILES_DIR/$SERVICES_CONF_FILE $BASE_DIR/$SERVICES_CONF_FILE

# Setting up local_settings.py

CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE | awk -F "=" '{print $2}')

yes | cp -f $CONF_FILES_DIR/$GUI_CONF_DIR/$AUTH_TYPE_CLASS"-"$CONF_FILE_NAME $BASE_DIR/$CONF_FILE_NAME

# Getting internal host ip

IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $IP_PATTERN $CONF_FILES_DIR/"hosts.conf" | awk -F "=" '{print $2}')

# Copy shared file
SHARED_INFO_PATH=$DIR/"services"/"conf-files"
SHARED_INFO="shared.info"
yes | cp -f $SHARED_INFO_PATH/$SHARED_INFO $BASE_DIR/$SHARED_INFO

# Getting authentication service endpoint

DOMAIN_NAME_FILE="domain-names.conf"
AS_DOMAIN_NAME_PATTERN="^as_domain_name"
AS_DOMAIN_NAME=$(grep $AS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_FILE | awk -F "=" '{print $2}')
AS_DOMAIN_BASENAME=$(basename $AS_DOMAIN_NAME)

echo "Federated network service domain name: $AS_DOMAIN_NAME"
sed -i "s#.*\<as\>:.*#	as: 'https://$AS_DOMAIN_BASENAME',#" $BASE_DIR/$CONF_FILE_NAME

# Getting resource allocation service endpoint

DOMAIN_NAME_FILE="domain-names.conf"
RAS_DOMAIN_NAME_PATTERN="ras_domain_name"
RAS_DOMAIN_NAME=$(grep $RAS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_FILE | awk -F "=" '{print $2}')
RAS_DOMAIN_BASENAME=$(basename $RAS_DOMAIN_NAME)

echo "Federated network service domain name: $RAS_DOMAIN_NAME"
sed -i "s#.*ras:.*#	ras: 'https://$RAS_DOMAIN_BASENAME',#" $BASE_DIR/$CONF_FILE_NAME

# Getting federated network service endpoint

FNS_DOMAIN_NAME_PATTERN="fns_domain_name"
FNS_DOMAIN_NAME=$(grep $FNS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_FILE | awk -F "=" '{print $2}')
FNS_DOMAIN_BASENAME=$(basename $FNS_DOMAIN_NAME)

echo "Federated network service domain name: $FNS_DOMAIN_NAME"
sed -i "s#.*fns:.*#	fns: 'https://$FNS_DOMAIN_BASENAME',#" $BASE_DIR/$CONF_FILE_NAME

# Getting membership endpoint

MS_DOMAIN_NAME_PATTERN="ms_domain_name"
MS_DOMAIN_NAME=$(grep $MS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_FILE | awk -F "=" '{print $2}')
MS_DOMAIN_BASENAME=$(basename $MS_DOMAIN_NAME)

echo "Membership domain name: $MS_DOMAIN_NAME"
sed -i "s#.*ms:.*#	ms: 'https://$MS_DOMAIN_BASENAME',#" $BASE_DIR/$CONF_FILE_NAME

# Getting XMPP JID

DOMAIN_NAMES_FILE=$CONF_FILES_DIR/"apache-confs"/"domain-names.conf"
XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $DOMAIN_NAMES_FILE | awk -F "=" '{print $2}')

echo "XMPP JID: $XMPP_JID"
sed -i "s#.*local:.*#	local: '$XMPP_JID',#" $BASE_DIR/$CONF_FILE_NAME
