#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/authentication-service"
CONTAINER_BASE_DIR="/root/authentication-service"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"
CONF_FILES_DIR_NAME="conf-files"
HOST_CONF_NAME="hosts.conf"
AS_CONF_NAME="as.conf"
SERVICES_FILE_NAME="services.conf"
SHARED_INFO_FILE_NAME="shared.info"
CONF_FILES_DIR=$DIR/$CONF_FILES_DIR_NAME
SERVICE_CONF_FILES_DIR=$BASE_DIR/$CONF_FILES_DIR_NAME
SHARED_INFO_FILE=$DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_INFO_FILE_NAME

# Copy as.conf
mkdir -p $SERVICE_CONF_FILES_DIR
yes | cp -f $CONF_FILES_DIR/$AS_CONF_NAME $SERVICE_CONF_FILES_DIR/$AS_CONF_NAME
# Copy shared info
yes | cp -f $SHARED_INFO_FILE $SERVICE_CONF_FILES_DIR/$SHARED_INFO_FILE_NAME
# Copy services file
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SERVICES_FILE_NAME $SERVICE_CONF_FILES_DIR/$SERVICES_FILE_NAME
# Copy application.properties file
APPLICATION_CONF_FILE=$BASE_DIR/"application.properties"
yes | cp -f $APPLICATION_CONF_FILE".example" $APPLICATION_CONF_FILE

# Fill basic_site_host_name properties (xmpp_jid)
BASIC_SITE_HOST_NAME_PATTERN="basic_site_host_name"
BASIC_SITE_HOST_NAME=$(grep $BASIC_SITE_HOST_NAME_PATTERN $CONF_FILES_DIR/$HOST_CONF_NAME | awk -F "=" '{print $2}')

echo "" >> $SERVICE_CONF_FILES_DIR/$AS_CONF_NAME
echo "xmpp_jid=$BASIC_SITE_HOST_NAME" >> $SERVICE_CONF_FILES_DIR/$AS_CONF_NAME

# Create key pair
echo "" >> $SERVICE_CONF_FILES_DIR/$AS_CONF_NAME
PRIVATE_KEY_PATH=$SERVICE_CONF_FILES_DIR/"id_rsa"
PUBLIC_KEY_PATH=$SERVICE_CONF_FILES_DIR/"id_rsa.pub"
RSA_KEY_PATH=$SERVICE_CONF_FILES_DIR/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "public_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa.pub" >> $SERVICE_CONF_FILES_DIR/$AS_CONF_NAME
echo "private_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa" >> $SERVICE_CONF_FILES_DIR/$AS_CONF_NAME