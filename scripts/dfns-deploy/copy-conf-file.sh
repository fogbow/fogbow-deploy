#!/bin/bash

SERVICE="dfns-agents"
DFNS_CONF_FILE_NAME="site.conf"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy dfns conf files
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$DFNS_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$DFNS_CONF_FILE_NAME
