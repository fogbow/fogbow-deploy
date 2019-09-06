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
RENAMED_CREATE_NETWORK_SCRIPT="create-federated-network"
RENAMED_DELETE_NETWORK_SCRIPT="delete-federated-network"
RENAMED_STRONGSWAN_INSTALLATION_SCRIPT="strongswan-installation"
RENAMED_CREATE_TUNNEL_SCRIPT="create-tunnel-from-agent-to-compute.sh"
RENAMED_CREATE_FEDNET_TUNNEL_SCRIPT="create-fednet-tunnels.sh"

wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/ipsec-installation -O $BASE_DIR/$RENAMED_STRONGSWAN_INSTALLATION_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/vanilla/config-create-federated-network -O $BASE_DIR/$RENAMED_CREATE_NETWORK_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/vanilla/config-delete-federated-network -O $BASE_DIR/$RENAMED_DELETE_NETWORK_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/dfns/create-tunnel-from-agent-to-compute.sh -O $BASE_DIR/$RENAMED_CREATE_TUNNEL_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/dfns/create-fednet-tunnels.sh -O $BASE_DIR/$RENAMED_CREATE_FEDNET_TUNNEL_SCRIPT
