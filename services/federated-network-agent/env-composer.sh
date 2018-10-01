#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/federated-network-agent"

# Get Agent access password
GENERAL_CONF_FILE_NAME="general.conf"
CONF_FILES_DIR=$DIR/"conf-files"
echo "Copying $CONF_FILES_DIR/$GENERAL_CONF_FILE_NAME to $BASE_DIR/$GENERAL_CONF_FILE_NAME"
yes | cp -f $CONF_FILES_DIR/$GENERAL_CONF_FILE_NAME $BASE_DIR/$GENERAL_CONF_FILE_NAME

# Get Manager public key file
DMZ_PUBLIC_KEY_PATTERN="dmz_public_key_file_path"
DMZ_PUBLIC_KEY_PATH=$(grep $DMZ_PUBLIC_KEY_PATTERN $CONF_FILES_DIR/$GENERAL_CONF_FILE_NAME | awk -F "=" '{print $2}')
DMZ_PUBLIC_KEY_NAME=$(basename $DMZ_PUBLIC_KEY_PATH)

echo "Copying $DMZ_PUBLIC_KEY_NAME to $BASE_DIR/$DMZ_PUBLIC_KEY_NAME"
yes | cp -f $DMZ_PUBLIC_KEY_NAME $BASE_DIR/$DMZ_PUBLIC_KEY_NAME

# Get hosts.conf file
HOSTS_CONF_FILE_PATH=$CONF_FILES_DIR/"hosts.conf"
echo "Copying $HOSTS_CONF_FILE_PATH to $BASE_DIR directory"
yes | cp -f $HOSTS_CONF_FILE_PATH $BASE_DIR

# Download Agent scripts
echo "Downloading agent scripts"
RENAMED_CREATE_FEDNET_SCRIPT="create-federated-network"
RENAMED_DELETE_FEDNET_SCRIPT="delete-federated-network"
RENAMED_STRONGSWAN_INSTALLATION_SCRIPT="strongswan-installation"

wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-create-federated-network -O $BASE_DIR/$RENAMED_CREATE_FEDNET_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-delete-federated-network -O $BASE_DIR/$RENAMED_DELETE_FEDNET_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/ipsec-installation -O $BASE_DIR/$RENAMED_STRONGSWAN_INSTALLATION_SCRIPT