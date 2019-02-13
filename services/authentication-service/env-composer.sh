#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/authentication-service"
AS_CONF_NAME="as.conf"
CONF_FILES_DIR_NAME="conf-files"
CONF_FILES_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME
SHARED_INFO_FILE=$DIR/$CONF_FILES_DIR_NAME/"shared.info"

# Copy as.conf
mkdir -p $CONF_FILES_PATH
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$AS_CONF_NAME $CONF_FILES_PATH/$AS_CONF_NAME

# Fill xmpp jid
XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $SHARED_INFO_FILE | awk -F "=" '{print $2}')
echo "" >> $CONF_FILES_PATH/$AS_CONF_NAME
echo "xmpp_jid=$XMPP_JID" >> $CONF_FILES_PATH/$AS_CONF_NAME

# Create key pair
echo "" >> $CONF_FILES_PATH/$AS_CONF_NAME
PRIVATE_KEY_PATH=$CONF_FILES_PATH/"id_rsa"
PUBLIC_KEY_PATH=$CONF_FILES_PATH/"id_rsa.pub"
RSA_KEY_PATH=$CONF_FILES_PATH/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "public_key_file_path=$PUBLIC_KEY_PATH" >> $CONF_FILES_PATH/$AS_CONF_NAME
echo "private_key_file_path=$PRIVATE_KEY_PATH" >> $CONF_FILES_PATH/$AS_CONF_NAME
