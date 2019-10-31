#!/bin/bash

CURRENT_DIR_PATH=$(pwd)
SERVICE="federated-network-service"
SITE_CONF_FILE_NAME="site.conf"
DFNS_CONF_FILE_NAME="dfns.conf"
CONF_FILE_TEMPLATE_DIR_PATH="../../conf-files"
BASE_DIR_PATH="../../services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy site conf files
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SITE_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SITE_CONF_FILE_NAME
## Copy dfns conf files
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$DFNS_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$DFNS_CONF_FILE_NAME

# Create dfns agent key pair
AGENT_PRIVATE_KEY_FILE_PATH=$CURRENT_DIR_PATH/"dfns-agent-id_rsa"
AGENT_PUBLIC_KEY_FILE_PATH=$CURRENT_DIR_PATH/"dfns-agent-id_rsa.pub"

ssh-keygen -f $AGENT_PRIVATE_KEY_FILE_PATH -t rsa -b 4096 -C "internal-communication-key" -N ""

NEW_AGENT_PRIVATE_KEY_FILE_PATH="../../services/federated-network-service/conf-files/dfns-agent-id_rsa"
NEW_AGENT_PUBLIC_KEY_FILE_PATH="../../services/dfns-agents/install/dfns-agent-id_rsa.pub"

mkdir -p $(dirname $NEW_AGENT_PRIVATE_KEY_FILE_PATH)
mkdir -p $(dirname $NEW_AGENT_PUBLIC_KEY_FILE_PATH)

mv $AGENT_PRIVATE_KEY_FILE_PATH $NEW_AGENT_PRIVATE_KEY_FILE_PATH
mv $AGENT_PUBLIC_KEY_FILE_PATH $NEW_AGENT_PUBLIC_KEY_FILE_PATH

chmod 600 $NEW_AGENT_PRIVATE_KEY_FILE_PATH