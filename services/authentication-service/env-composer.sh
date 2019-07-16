#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/authentication-service"
CONTAINER_BASE_DIR="/root/authentication-service"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"
AS_CONF_NAME="as.conf"
CONF_FILES_DIR_NAME="conf-files"
CONF_FILES_DIR=$DIR/$CONF_FILES_DIR_NAME
CONF_FILES_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME
SHARED_INFO_FILE=$DIR/"services"/$CONF_FILES_DIR_NAME/"shared.info"
DOMAIN_NAMES_FILE=$DIR/$CONF_FILES_DIR_NAME/"apache-confs"/"domain-names.conf"

# Copy as.conf
mkdir -p $CONF_FILES_PATH
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$AS_CONF_NAME $CONF_FILES_PATH/$AS_CONF_NAME
# Copy shared info
yes | cp -f $SHARED_INFO_FILE $CONF_FILES_PATH/"shared.info"
# Copy services file
SERVICES_FILE="services.conf"
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SERVICES_FILE $CONF_FILES_PATH/$SERVICES_FILE
# Copy application.properties file
APPLICATION_CONF_FILE=$BASE_DIR/"application.properties"
yes | cp -f $APPLICATION_CONF_FILE".example" $APPLICATION_CONF_FILE

# Fill xmpp jid
XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $DOMAIN_NAMES_FILE | awk -F "=" '{print $2}')
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

echo "public_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa.pub" >> $CONF_FILES_PATH/$AS_CONF_NAME
echo "private_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa" >> $CONF_FILES_PATH/$AS_CONF_NAME

CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
GUI_CONF_DIR="gui-confs"
GUI_CONF_FILE="gui.conf"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE | awk -F "=" '{print $2}')

# SHIBBOLETH SCENARY
if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
  ## Adding in the shared folder because the shibboleth authentication application needs
  SHARED_FOLDER_NAME="shared-folder"
  SHARED_FOLDER_DIR=$DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_FOLDER_NAME
  AS_PUBLIC_KEY_NAME="as_public_key.pem"
  yes | cp -f $PUBLIC_KEY_PATH $SHARED_FOLDER_DIR/$AS_PUBLIC_KEY_NAME

  # Copy shared folder
  yes | cp -f -r $SHARED_FOLDER_DIR $CONF_FILES_PATH/$SHARED_FOLDER_NAME
fi