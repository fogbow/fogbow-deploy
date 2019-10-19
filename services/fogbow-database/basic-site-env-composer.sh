#!/bin/bash

SERVICE="fogbow-database"
SERVICES_CONF_FILE_NAME="services.conf"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME
