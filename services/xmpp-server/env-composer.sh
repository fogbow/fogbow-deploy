#!/bin/bash

XMPP_SERVER_DIR="services/xmpp-server"
PROSODY_CONF_TEMPLATE="prosody.cfg.lua.example"
PROSODY_CONF_FILE="prosody.cfg.lua"

CONF_FILE_PATH=$(pwd)/"conf-files"/"intercomponent.conf"
yes | cp -f $CONF_FILE_PATH $XMPP_SERVER_DIR

MANAGER_XMPP_ID_PATTERN="xmpp_jid"
MANAGER_XMPP_ID=$(grep $MANAGER_XMPP_ID_PATTERN $CONF_FILE_PATH | awk -F "=" '{print $2}')

MANAGER_PASSWORD_PATTERN="xmpp_password"
MANAGER_PASSWORD=$(grep $MANAGER_PASSWORD_PATTERN $CONF_FILE_PATH | awk -F "=" '{print $2}')

yes | cp -f ./$XMPP_SERVER_DIR/$PROSODY_CONF_TEMPLATE ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

echo "Manager XMPP ID: $MANAGER_XMPP_ID"
echo "Manager XMPP Password: $MANAGER_PASSWORD"

# Adding comment to identify component credentials
INSERT_LINE_PATTERN="--	component_secret = \"password\""
COMPONENT_COMMENT="-- Manager Component"

sed -i "/$INSERT_LINE_PATTERN/a $COMPONENT_COMMENT" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Adding component domain
COMPONENT_DOMAIN="Component $COMPONENT_DOMAIN_PREFIX\"$MANAGER_XMPP_ID\""
sed -i "/$COMPONENT_COMMENT/a $COMPONENT_DOMAIN" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Adding component password
COMPONENT_PASSWORD="\ \ \ \ \ \ \ \ component_secret = \"$MANAGER_PASSWORD\""
sed -i "/$COMPONENT_DOMAIN/a $COMPONENT_PASSWORD" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE
