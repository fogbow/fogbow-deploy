#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
SECRETS_FILE_PATH=$CONF_FILES_DIR/"secrets"
DOMAIN_NAMES_FILE=$CONF_FILES_DIR/"apache-confs"/"domain-names.conf"

XMPP_SERVER_DIR="services/xmpp-server"
PROSODY_CONF_TEMPLATE="prosody.cfg.lua.example"
PROSODY_CONF_FILE="prosody.cfg.lua"

XMPP_ID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_ID_PATTERN $DOMAIN_NAMES_FILE | awk -F "=" '{print $2}')

XMPP_PASSWORD_PATTERN="xmpp_password"
XMPP_PASSWORD=$(grep $XMPP_PASSWORD_PATTERN $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

yes | cp -f ./$XMPP_SERVER_DIR/$PROSODY_CONF_TEMPLATE ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

echo "Manager XMPP ID: $XMPP_JID"
echo "Manager XMPP Password: $MANAGER_PASSWORD"

# Adding comment to identify component credentials
INSERT_LINE_PATTERN="--	component_secret = \"password\""
COMPONENT_COMMENT="-- Manager Component"

sed -i "/$INSERT_LINE_PATTERN/a $COMPONENT_COMMENT" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Adding component domain
COMPONENT_DOMAIN="Component $COMPONENT_DOMAIN_PREFIX\"$XMPP_JID\""
sed -i "/$COMPONENT_COMMENT/a $COMPONENT_DOMAIN" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Adding component password
COMPONENT_PASSWORD="\ \ \ \ \ \ \ \ component_secret = \"$XMPP_PASSWORD\""
sed -i "/$COMPONENT_DOMAIN/a $COMPONENT_PASSWORD" ./$XMPP_SERVER_DIR/$PROSODY_CONF_FILE

# Copying service.conf file
echo "Copying services.conf to service directory"
SERVICES_FILE="services.conf"

yes | cp -f $CONF_FILES_DIR/$SERVICES_FILE $XMPP_SERVER_DIR/$SERVICES_FILE
