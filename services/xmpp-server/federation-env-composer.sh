#!/bin/bash

SERVICE="xmpp-server"
SERVICES_CONF_FILE_NAME="services.conf"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"
SITE_CONF_FILE_NAME="site.conf"
SECRETS_FILE_PATH=$CONF_FILE_DIR_PATH/"secrets"
PROSODY_CONF_TEMPLATE_FILE_NAME="prosody.cfg.lua.example"
PROSODY_CONF_FILE_NAME="prosody.cfg.lua"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME

PROVIDER_ID_PATTERN="provider_id"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

XMPP_PASSWORD_PATTERN="xmpp_password"
XMPP_PASSWORD=$(grep $XMPP_PASSWORD_PATTERN $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

yes | cp -f ./$BASE_DIR_PATH/$PROSODY_CONF_TEMPLATE_FILE_NAME ./$BASE_DIR_PATH/$PROSODY_CONF_FILE_NAME

# Adding comment to identify component credentials
INSERT_LINE_PATTERN="--	component_secret = \"password\""
COMPONENT_COMMENT="-- Manager Component"

sed -i "/$INSERT_LINE_PATTERN/a $COMPONENT_COMMENT" ./$BASE_DIR_PATH/$PROSODY_CONF_FILE_NAME

# Adding component domain
COMPONENT_DOMAIN="Component \"ras-$PROVIDER_ID\""
sed -i "/$COMPONENT_COMMENT/a $COMPONENT_DOMAIN" ./$BASE_DIR_PATH/$PROSODY_CONF_FILE_NAME

# Adding component password
COMPONENT_PASSWORD="\ \ \ \ \ \ \ \ component_secret = \"$XMPP_PASSWORD\""
sed -i "/$COMPONENT_DOMAIN/a $COMPONENT_PASSWORD" ./$BASE_DIR_PATH/$PROSODY_CONF_FILE_NAME
