#!/bin/bash

SERVICE="authentication-service"
CONF_FILE_NAME="as.conf"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_CONF_FILE_NAME="services.conf"
APPLICATION_PROPERTIES_FILE_NAME="application.properties"
SITE_CONF_FILE_NAME="site.conf"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"
CONTAINER_BASE_DIR_PATH="/root"/$SERVICE
CONTAINER_CONF_FILES_DIR="src/main/resources/private"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy as.conf
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
## Copy shared info
yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME
## Copy application.properties file
yes | cp -f $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME".example" $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME

# Edit configuration files

# Include provider_id
PROVIDER_ID_PATTERN="provider_id"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "provider_id=$PROVIDER_ID" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

## Create and include key pair
echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
PRIVATE_KEY_PATH=$CONF_FILE_DIR_PATH/"id_rsa"
PUBLIC_KEY_PATH=$CONF_FILE_DIR_PATH/"id_rsa.pub"
RSA_KEY_PATH=$CONF_FILE_DIR_PATH/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "public_key_file_path="$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILES_DIR/"id_rsa.pub" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "private_key_file_path="$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILES_DIR/"id_rsa" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME