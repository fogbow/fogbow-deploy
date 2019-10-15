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

# Fill local_member_id properties (xmpp_jid)
BASIC_SITE_DOMAIN_NAME_PATTERN="ras_domain_name"
APACHE_CONF_FILES_DIR="apache-confs"
DOMAIN_NAME_CONF_FILE="domain-names.conf"
DOMAIN_NAME=$(grep -w $BASIC_SITE_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')
DOMAIN_BASENAME=`basename $(dirname $DOMAIN_NAME)`

echo "" >> $CONF_FILES_PATH/$AS_CONF_NAME
echo "xmpp_jid=$DOMAIN_BASENAME" >> $CONF_FILES_PATH/$AS_CONF_NAME

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