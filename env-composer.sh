#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
SECRETS_FILE_PATH=$CONF_FILES_DIR/"secrets"
SHARED_INFO_FILE=$CONF_FILES_DIR/"shared.info"

VPN_PASSWORD_PROPERTY="vpn_password"
XMPP_PASSWORD_PROPERTY="xmpp_password"
DB_PASSWORD_PROPERTY="db_password"

touch $SECRETS_FILE_PATH
chmod 600 $SECRETS_FILE_PATH

# Fill passwords
GENERATED_PASSWORD=$(pwgen 10 1)
echo "$DB_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $SECRETS_FILE_PATH

GENERATED_PASSWORD=$(pwgen 10 1)
echo "$VPN_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $SECRETS_FILE_PATH

GENERATED_PASSWORD=$(pwgen 10 1)
echo "$XMPP_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $SECRETS_FILE_PATH

# Create DMZ key pair
DMZ_PRIVATE_KEY_PATH=$DIR/"dmz-id_rsa"
DMZ_PUBLIC_KEY_PATH=$DIR/"dmz-id_rsa.pub"

ssh-keygen -f $DMZ_PRIVATE_KEY_PATH -t rsa -b 4096 -C "internal-communication-key" -N ""

DMZ_PRIVATE_KEY_NEW_PATH="services"/"federated-network-service"/"conf-files"/"dmz-id_rsa"
DMZ_PUBLIC_KEY_NEW_PATH="services"/"federated-network-agent"/"dmz-id_rsa.pub"

mkdir -p $(dirname $DMZ_PRIVATE_KEY_NEW_PATH)
mkdir -p $(dirname $DMZ_PUBLIC_KEY_NEW_PATH)

mv $DMZ_PRIVATE_KEY_PATH $DMZ_PRIVATE_KEY_NEW_PATH
mv $DMZ_PUBLIC_KEY_PATH $DMZ_PUBLIC_KEY_NEW_PATH

chmod 600 $DMZ_PRIVATE_KEY_NEW_PATH
