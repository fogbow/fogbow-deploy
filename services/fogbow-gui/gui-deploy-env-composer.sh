#!/bin/bash
SERVICE="fogbow-gui"
CONF_FILE_NAME="gui.conf"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_CONF_FILE_NAME="services.conf"
BASIC_SITE_CONF_FILE_NAME="basic-site.conf"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy gui.conf
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
## Copy shared info
yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME

# Create and edit api.config.js
API_CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR_PATH/$CONF_FILE_NAME | awk -F "=" '{print $2}')

yes | cp -f $BASE_DIR_PATH/$AUTH_TYPE_CLASS"-"$API_CONF_FILE_NAME $BASE_DIR_PATH/$API_CONF_FILE_NAME

PROVIDER_ID_PATTERN="provider_id"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$BASIC_SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

# Setting endpoints

sed -i "s#.*\<as\>:.*#	as: 'https://$PROVIDER_ID/as',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*ras:.*#	ras: 'https://$PROVIDER_ID/ras',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*fns:.*#	fns: 'https://$PROVIDER_ID/fns',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*ms:.*#	ms: 'https://$PROVIDER_ID/ms',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
sed -i "s#.*local:.*#	local: '$PROVIDER_ID',#" $BASE_DIR_PATH/$API_CONF_FILE_NAME
