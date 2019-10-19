#!/bin/bash

SERVICE="membership-service"
CONF_FILE_NAME="ms.conf"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_CONF_FILE_NAME="services.conf"
APPLICATION_PROPERTIES_FILE_NAME="application.properties"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy ms.conf
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
## Copy shared info
yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME
## Copy application.properties file
yes | cp -f $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME".example" $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
