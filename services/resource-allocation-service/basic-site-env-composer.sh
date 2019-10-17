#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/resource-allocation-service"
CONTAINER_BASE_DIR="/root/resource-allocation-service"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"
HOST_CONF_NAME="hosts.conf"
RAS_CONF_NAME="ras.conf"
CLOUDS_FILE_NAME="clouds"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_FILE_NAME="services.conf"
CONF_FILES_DIR_NAME="conf-files"
CONF_FILES_DIR=$DIR/$CONF_FILES_DIR_NAME
SERVICE_CONF_FILES_DIR=$BASE_DIR/$CONF_FILES_DIR_NAME
CONF_FILE_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME/$RAS_CONF_NAME
HOSTS_CONF_FILE=$DIR/$CONF_FILES_DIR_NAME/$HOST_CONF_NAME
SECRETS_FILE=$DIR/$CONF_FILES_DIR_NAME/"secrets"
SHARED_INFO_FILE=$DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_INFO_FILE_NAME

# Copy ras.conf
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$RAS_CONF_NAME ./$SERVICE_CONF_FILES_DIR/$RAS_CONF_NAME
# Copy clouds directory
yes | cp -fr $DIR/$CONF_FILES_DIR_NAME/$CLOUDS_FILE_NAME ./$SERVICE_CONF_FILES_DIR
# Copy services file
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SERVICES_FILE_NAME ./$SERVICE_CONF_FILES_DIR/$SERVICES_FILE_NAME
# Copy shared file
yes | cp -f $DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_INFO_FILE_NAME ./$SERVICE_CONF_FILES_DIR/$SHARED_INFO_FILE_NAME

# Configuring application.properties file
APPLICATION_CONF_FILE=$BASE_DIR/"application.properties"
yes | cp -f $APPLICATION_CONF_FILE".example" $APPLICATION_CONF_FILE

BASIC_SITE_HOST_PRIVATE_IP_PATTERN="basic_site_host_ip"
BASIC_SITE_HOST_PRIVATE_IP=$(grep $BASIC_SITE_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
JDBC_PREFIX="jdbc:postgresql:"
DB_PORT="5432"
RAS_DB_ENDPOINT="ras"

DB_URL_PROPERTY="spring.datasource.url"
DB_URL=$JDBC_PREFIX"//"$BASIC_SITE_HOST_PRIVATE_IP":"$DB_PORT"/"$RAS_DB_ENDPOINT
echo "" >> $APPLICATION_CONF_FILE
echo "$DB_URL_PROPERTY=$DB_URL" >> $APPLICATION_CONF_FILE

DB_USERNAME="fogbow"
DB_USERNAME_PATTERN="spring.datasource.username"
echo "$DB_USERNAME_PATTERN=$DB_USERNAME" >> $APPLICATION_CONF_FILE

GENERAL_PASSWORD_PATTERN="^db_password"
DB_PASSWORD=$(grep $GENERAL_PASSWORD_PATTERN $SECRETS_FILE | awk -F "=" '{print $2}')
DB_PASSWORD_PATTERN="spring.datasource.password"
echo "$DB_PASSWORD_PATTERN=$DB_PASSWORD" >> $APPLICATION_CONF_FILE

# Configuring ras.conf file
# Create key pair
echo "" >> $CONF_FILE_PATH
PRIVATE_KEY_PATH=$SERVICE_CONF_FILES_DIR/"id_rsa"
PUBLIC_KEY_PATH=$SERVICE_CONF_FILES_DIR/"id_rsa.pub"
RSA_KEY_PATH=$SERVICE_CONF_FILES_DIR/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "public_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa.pub" >> $CONF_FILE_PATH
echo "private_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa" >> $CONF_FILE_PATH

# Fill basic_site_host_name properties (xmpp_jid)
BASIC_SITE_HOST_NAME_PATTERN="basic_site_host_name"
BASIC_SITE_HOST_NAME=$(grep $BASIC_SITE_HOST_NAME_PATTERN $CONF_FILES_DIR/$HOST_CONF_NAME | awk -F "=" '{print $2}')

echo "" >> $SERVICE_CONF_FILES_DIR/$RAS_CONF_NAME
echo "xmpp_jid=$BASIC_SITE_HOST_NAME" >> $SERVICE_CONF_FILES_DIR/$RAS_CONF_NAME

# Fill AS info
echo "" >> $CONF_FILE_PATH
BASIC_SITE_HOST_IP_PATTERN="basic_site_host_ip"
BASIC_SITE_HOST_IP=$(grep $BASIC_SITE_HOST_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

PROTOCOL="http://"
echo "as_url=$PROTOCOL$BASIC_SITE_HOST_IP" >> $CONF_FILE_PATH
AS_PORT=$(grep ^as_port $SHARED_INFO_FILE | awk -F "=" '{print $2}')
echo "as_port=$AS_PORT" >> $CONF_FILE_PATH

# Timestamp Database URL
echo "" >> $CONF_FILE_PATH
echo "jdbc_database_url=jdbc:sqlite:/root/resource-allocation-service/ras.db" >> $CONF_FILE_PATH
