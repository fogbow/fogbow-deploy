#!/bin/bash

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
echo "$FNS_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $FNS_SECRETS_FILE_PATH
echo "$FNA_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $FNA_SECRETS_FILE_PATH
