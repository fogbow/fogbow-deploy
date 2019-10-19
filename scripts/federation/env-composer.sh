#!/bin/bash

# Define secrets files

SECRETS_FILE_NAME="secrets"
XMPP_CONF_FILE_PATH="../../services/xmpp-server/conf-files"
RAS_CONF_FILE_PATH="../../services/resource-allocation-service/conf-files"
XMPP_SECRETS_FILE_PATH=$XMPP_CONF_FILE_PATH/$SECRETS_FILE_NAME
RAS_SECRETS_FILE_PATH=$RAS_CONF_FILE_PATH/$SECRETS_FILE_NAME

# Create secrets files

mkdir -p $XMPP_CONF_FILE_PATH
touch $XMPP_SECRETS_FILE_PATH
chmod 600 $XMPP_SECRETS_FILE_PATH

mkdir -p $RAS_CONF_FILE_PATH
touch $RAS_SECRETS_FILE_PATH
chmod 600 $RAS_SECRETS_FILE_PATH

# Retrieve xmpp server IP to reconfigure RAS
FEDERATION_CONF_FILE_PATH="../../conf-files/federation.conf"
XMPP_SERVER_IP_PROPERTY="xmpp_server_ip"
XMPP_SERVER_IP=$(grep $XMPP_SERVER_IP_PROPERTY $FEDERATION_CONF_FILE_PATH | awk -F "=" '{print $2}')

# Generate DB password and fill secret files
XMPP_PASSWORD_PROPERTY="xmpp_password"
GENERATED_PASSWORD=$(pwgen 10 1)
echo "$XMPP_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $XMPP_SECRETS_FILE_PATH
echo "$XMPP_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $RAS_SECRETS_FILE_PATH
echo "$XMPP_SERVER_IP_PROPERTY=$XMPP_SERVER_IP" >> $RAS_SECRETS_FILE_PATH

