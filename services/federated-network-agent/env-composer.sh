#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/federated-network-agent"
CONF_FILES_DIR=$DIR/"conf-files"
SHARED_INFO_FILE="services"/"conf-files"/"shared.info"
SECRETS=$CONF_FILES_DIR/"secrets"

# Copy hosts.conf file
HOSTS_CONF_FILE_PATH=$CONF_FILES_DIR/"hosts.conf"
echo "Copying $HOSTS_CONF_FILE_PATH to $BASE_DIR directory"
yes | cp -f $HOSTS_CONF_FILE_PATH $BASE_DIR

# Copy shared info
yes | cp -f $SHARED_INFO_FILE $BASE_DIR
# Copy secrets
yes | cp -f $SECRETS $BASE_DIR

# Download Agent scripts
echo "Downloading agent scripts"
RENAMED_CREATE_FEDNET_SCRIPT="create-federated-network"
RENAMED_DELETE_FEDNET_SCRIPT="delete-federated-network"
RENAMED_STRONGSWAN_INSTALLATION_SCRIPT="strongswan-installation"

wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-create-federated-network -O $BASE_DIR/$RENAMED_CREATE_FEDNET_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-delete-federated-network -O $BASE_DIR/$RENAMED_DELETE_FEDNET_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/ipsec-installation -O $BASE_DIR/$RENAMED_STRONGSWAN_INSTALLATION_SCRIPT