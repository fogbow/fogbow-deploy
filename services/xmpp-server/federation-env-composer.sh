#!/bin/bash
DIR=$(pwd)
HOST_CONF_NAME="hosts.conf"
CONF_FILES_DIR=$DIR/"conf-files"
SECRETS_FILE_PATH=$CONF_FILES_DIR/"secrets"

XMPP_SERVER_DIR="services/xmpp-server"
PROSODY_CONF_TEMPLATE="prosody.cfg.lua.example"
PROSODY_CONF_FILE="prosody.cfg.lua"

BASIC_SITE_HOST_NAME_PATTERN="basic_site_host_name"
BASIC_SITE_HOST_NAME=$(grep $BASIC_SITE_HOST_NAME_PATTERN $CONF_FILES_DIR/$HOST_CONF_NAME | awk -F "=" '{print $2}')

XMPP_PASSWORD_PATTERN="xmpp_password"
XMPP_PASSWORD=$(grep $XMPP_PASSWORD_PATTERN $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

yes | cp -f ./$XMPP_SERVER_DIR/$PROSODY_CONF_TEMPLATE ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

echo "Manager XMPP ID: $BASIC_SITE_HOST_NAME"
echo "Manager XMPP Password: $MANAGER_PASSWORD"

# Adding comment to identify component credentials
INSERT_LINE_PATTERN="--	component_secret = \"password\""
COMPONENT_COMMENT="-- Manager Component"

sed -i "/$INSERT_LINE_PATTERN/a $COMPONENT_COMMENT" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Adding component domain
COMPONENT_DOMAIN="Component \"$BASIC_SITE_HOST_NAME\""
sed -i "/$COMPONENT_COMMENT/a $COMPONENT_DOMAIN" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Adding component password
COMPONENT_PASSWORD="\ \ \ \ \ \ \ \ component_secret = \"$XMPP_PASSWORD\""
sed -i "/$COMPONENT_DOMAIN/a $COMPONENT_PASSWORD" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Copying service.conf file
echo "Copying services.conf to service directory"
SERVICES_FILE="services.conf"

yes | cp -f $CONF_FILES_DIR/$SERVICES_FILE $XMPP_SERVER_DIR/$SERVICES_FILE
