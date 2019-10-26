#!/bin/bash
BASE_DIR_PATH="services/federated-network-agent"
CONF_FILES_DIR_PATH=$BASE_DIR_PATH/"conf-files"
TEMPLATE_CONF_FILES_DIR_PATH="./conf-files"
SITE_CONF_FILE_NAME="site.conf"
SECRETS_FILE_NAME="secrets"

# Copy site.conf file
mkdir -p $CONF_FILES_DIR_PATH
yes | cp -f $TEMPLATE_CONF_FILES_DIR_PATH/$SITE_CONF_FILE_NAME $CONF_FILES_DIR_PATH/$SITE_CONF_FILE_NAME
# Copy secrets
yes | cp -f $TEMPLATE_CONF_FILES_DIR_PATH/$SECRETS_FILE_NAME $CONF_FILES_DIR_PATH/$SECRETS_FILE_NAME

RENAMED_STRONGSWAN_INSTALLATION_SCRIPT="strongswan-installation"
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/ipsec-installation -O $BASE_DIR_PATH/$RENAMED_STRONGSWAN_INSTALLATION_SCRIPT
