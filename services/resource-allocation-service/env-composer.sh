#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/resource-allocation-service"
RAS_CONF_NAME="ras.conf"
CONF_FILES_DIR_NAME="conf-files"
RAS_CONF_FILE=$CONF_FILES_PATH/$RAS_CONF_NAME
HOSTS_CONF_FILE=$DIR/$CONF_FILES_DIR_NAME/"hosts.conf"
CONF_FILES_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME
CLOUDS_PATH=$CONF_FILES_DIR_NAME/"clouds"
SECRETS_FILE=$DIR/$CONF_FILES_DIR_NAME/"secrets"

# Copy ras.conf to base dir
yes | cp -f $CONF_FILES_DIR/$RAS_CONF_NAME ./$RAS_CONF_FILE
# Copy clouds directory
yes | cp -fr $CLOUDS_PATH ./$BASE_DIR/$CLOUDS_PATH

# Configuring application.properties file
APPLICATION_CONF_FILE=$BASE_DIR/"application.properties"
yes | cp -f $APPLICATION_CONF_FILE".example" $APPLICATION_CONF_FILE

INTERNAL_HOST_PRIVATE_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_PRIVATE_IP=$(grep $INTERNAL_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
JDBC_PREFIX="jdbc:postgresql:"
DB_PORT="5432"
RAS_DB_ENDPOINT="ras"

DB_URL_PROPERTY="spring.datasource.url"
DB_URL=$JDBC_PREFIX"//"$INTERNAL_HOST_PRIVATE_IP":"$DB_PORT"/"$RAS_DB_ENDPOINT
echo "$DB_URL_PROPERTY=$DB_URL" >> $APPLICATION_CONF_FILE

DB_USERNAME="fogbow"
DB_USERNAME_PATTERN="spring.datasource.username"
echo "$DB_USERNAME_PATTERN=$DB_USERNAME" >> $APPLICATION_CONF_FILE

GENERAL_PASSWORD_PATTERN="^db_password"
DB_PASSWORD=$(grep $GENERAL_PASSWORD_PATTERN $SECRETS_FILE | awk -F "=" '{print $2}')
DB_PASSWORD_PATTERN="spring.datasource.password"
echo "$DB_PASSWORD_PATTERN=$DB_PASSWORD" >> $APPLICATION_CONF_FILE

# Configuring ras.conf file
PRIVATE_KEY_PATH=$CONF_FILES_PATH/"id_rsa"
PUBLIC_KEY_PATH=$CONF_FILES_PATH/"id_rsa.pub"
RSA_KEY_PATH=$CONF_FILES_PATH/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

PUBLIC_KEY_PROPERTY="public_key_file_path"
PRIVATE_KEY_PROPERTY="private_key_file_path"
echo "$PRIVATE_KEY_PROPERTY=$PRIVATE_KEY_PATH" >> $CONF_FILE_PATH
echo "$PUBLIC_KEY_PROPERTY=$PUBLIC_KEY_PATH" >> $CONF_FILE_PATH
