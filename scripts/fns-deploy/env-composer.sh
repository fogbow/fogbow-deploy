#!/bin/bash

CURRENT_DIR_PATH=$(pwd)

# Define secrets files

SECRETS_FILE_NAME="secrets"
FNS_CONF_FILE_PATH="../../services/federated-network-service/conf-files"
FNA_CONF_FILE_PATH="../../services/federated-network-agent/conf-files"
FNS_SECRETS_FILE_PATH=$FNS_CONF_FILE_PATH/$SECRETS_FILE_NAME
FNA_SECRETS_FILE_PATH=$FNA_CONF_FILE_PATH/$SECRETS_FILE_NAME

# Create secrets files

mkdir -p $FNS_CONF_FILE_PATH
touch $FNS_SECRETS_FILE_PATH
chmod 600 $FNS_SECRETS_FILE_PATH

mkdir -p $FNA_CONF_FILE_PATH
touch $FNA_SECRETS_FILE_PATH
chmod 600 $FNA_SECRETS_FILE_PATH

# Generate VPN password and fill secret files
VPN_PASSWORD_PROPERTY="vpn_password"
GENERATED_PASSWORD=$(pwgen 10 1)
echo "$VPN_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $FNS_SECRETS_FILE_PATH
echo "$VPN_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $FNA_SECRETS_FILE_PATH

# Create vanilla agent key pair
AGENT_PRIVATE_KEY_FILE_PATH=$CURRENT_DIR_PATH/"vanilla-agent-id_rsa"
AGENT_PUBLIC_KEY_FILE_PATH=$CURRENT_DIR_PATH/"vanilla-agent-id_rsa.pub"

ssh-keygen -f $AGENT_PRIVATE_KEY_FILE_PATH -t rsa -b 4096 -C "internal-communication-key" -N ""

NEW_AGENT_PRIVATE_KEY_FILE_PATH="../../services"/"federated-network-service"/"conf-files"/"vanilla-agent-id_rsa"
NEW_AGENT_PUBLIC_KEY_FILE_PATH="../../services"/"federated-network-agent"/"vanilla-agent-id_rsa.pub"

mkdir -p $(dirname $NEW_AGENT_PRIVATE_KEY_FILE_PATH)
mkdir -p $(dirname $NEW_AGENT_PUBLIC_KEY_FILE_PATH)

mv $AGENT_PRIVATE_KEY_FILE_PATH $NEW_AGENT_PRIVATE_KEY_FILE_PATH
mv $AGENT_PUBLIC_KEY_FILE_PATH $NEW_AGENT_PUBLIC_KEY_FILE_PATH

chmod 600 $NEW_AGENT_PRIVATE_KEY_FILE_PATH