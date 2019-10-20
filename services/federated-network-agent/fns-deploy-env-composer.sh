#!/bin/bash
BASE_DIR_PATH="services/federated-network-agent"
CONF_FILES_DIR_PATH=$BASE_DIR_PATH/"conf-files"
FNS_DEPLOY_CONF_FILE_PATH=$CONF_FILES_DIR_PATH/"fns-deploy.conf"
SECRETS_FILE_PATH=$CONF_FILES_DIR_PATH/"secrets"

# Copy fns-deploy.conf file
yes | cp -f $FNS_DEPLOY_CONF_FILE_PATH $CONF_FILES_DIR_PATH
# Copy secrets
yes | cp -f $SECRETS_FILE_PATH $CONF_FILES_DIR_PATH

# Download Agent scripts
RENAMED_CREATE_NETWORK_SCRIPT="create-federated-network"
RENAMED_DELETE_NETWORK_SCRIPT="delete-federated-network"
RENAMED_STRONGSWAN_INSTALLATION_SCRIPT="strongswan-installation"
RENAMED_CREATE_TUNNEL_SCRIPT="create-tunnel-from-agent-to-compute.sh"
RENAMED_CREATE_FEDNET_TUNNEL_SCRIPT="create-fednet-tunnels.sh"

wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/ipsec-installation -O $BASE_DIR_PATH/$RENAMED_STRONGSWAN_INSTALLATION_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/vanilla/config-create-federated-network -O $BASE_DIR_PATH/$RENAMED_CREATE_NETWORK_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/vanilla/config-delete-federated-network -O $BASE_DIR_PATH/$RENAMED_DELETE_NETWORK_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/dfns/create-tunnel-from-agent-to-compute.sh -O $BASE_DIR_PATH/$RENAMED_CREATE_TUNNEL_SCRIPT
wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/develop/bin/agent-scripts/dfns/create-fednet-tunnels.sh -O $BASE_DIR_PATH/$RENAMED_CREATE_FEDNET_TUNNEL_SCRIPT
