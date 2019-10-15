#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/resource-allocation-service"
CONTAINER_BASE_DIR="/root/resource-allocation-service"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"
RAS_CONF_NAME="ras.conf"
CLOUDS_FILE_NAME="clouds"
CONF_FILES_DIR_NAME="conf-files"
CONF_FILES_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME
CONF_FILE_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME/$RAS_CONF_NAME
HOSTS_CONF_FILE=$DIR/$CONF_FILES_DIR_NAME/"hosts.conf"
SECRETS_FILE=$DIR/$CONF_FILES_DIR_NAME/"secrets"
SHARED_INFO_FILE=$DIR/"services"/$CONF_FILES_DIR_NAME/"shared.info"
DOMAIN_NAMES_FILE=$DIR/$CONF_FILES_DIR_NAME/"apache-confs"/"domain-names.conf"

# Copy ras.conf
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$RAS_CONF_NAME ./$CONF_FILES_PATH/$RAS_CONF_NAME
# Copy clouds directory
yes | cp -fr $DIR/$CONF_FILES_DIR_NAME/$CLOUDS_FILE_NAME ./$CONF_FILES_PATH
# Copy services file
SERVICES_FILE="services.conf"
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SERVICES_FILE ./$CONF_FILES_PATH/$SERVICES_FILE
# Copy shared file
SHARED_INFO="shared.info"
yes | cp -f $DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_INFO ./$CONF_FILES_PATH/$SHARED_INFO

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
PRIVATE_KEY_PATH=$CONF_FILES_PATH/"id_rsa"
PUBLIC_KEY_PATH=$CONF_FILES_PATH/"id_rsa.pub"
RSA_KEY_PATH=$CONF_FILES_PATH/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "public_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa.pub" >> $CONF_FILE_PATH
echo "private_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa" >> $CONF_FILE_PATH

# Fill local_member_id properties
XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $DOMAIN_NAMES_FILE | awk -F "=" '{print $2}')
echo "" >> $CONF_FILE_PATH
echo "xmpp_jid=$XMPP_JID" >> $CONF_FILE_PATH

# Fill AS infos
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
