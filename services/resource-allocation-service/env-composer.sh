#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/resource-allocation-service"
RAS_CONF_NAME="ras.conf"
CLOUDS_FILE_NAME="clouds"
CONF_FILES_DIR_NAME="conf-files"
CONF_FILES_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME
HOSTS_CONF_FILE=$DIR/$CONF_FILES_DIR_NAME/"hosts.conf"
SECRETS_FILE=$DIR/$CONF_FILES_DIR_NAME/"secrets"

# Copy ras.conf
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$RAS_CONF_NAME ./$CONF_FILES_PATH/$RAS_CONF_NAME
# Copy clouds directory
yes | cp -fr $DIR/$CONF_FILES_DIR_NAME/$CLOUDS_FILE_NAME ./$CONF_FILES_PATH/$CLOUDS_FILE_NAME
# Copy services file
SERVICES_FILE="services.conf"
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SERVICES_FILE ./$CONF_FILES_PATH/$SERVICES_FILE

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
# Create key pair
PRIVATE_KEY_PATH=$CONF_FILES_PATH/"id_rsa"
PUBLIC_KEY_PATH=$CONF_FILES_PATH/"id_rsa.pub"
RSA_KEY_PATH=$CONF_FILES_PATH/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "private_key_file_path=$PRIVATE_KEY_PATH" >> $CONF_FILE_PATH
echo "public_key_file_path=$PUBLIC_KEY_PATH" >> $CONF_FILE_PATH

# Fill xmpp properties
XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $SHARED_INFO_FILE | awk -F "=" '{print $2}')
echo "" >> $CONF_FILE_PATH
echo "xmpp_jid=$XMPP_JID" >> $CONF_FILE_PATH

DMZ_PUBLIC_IP_PATTERN="dmz_host_public_ip"
DMZ_PUBLIC_IP=$(grep $DMZ_PUBLIC_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "xmpp_server_ip=$DMZ_PUBLIC_IP" >> $CONF_FILE_PATH

DMZ_PUBLIC_IP_PATTERN="dmz_host_public_ip"
DMZ_PUBLIC_IP=$(grep $DMZ_PUBLIC_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "xmpp_server_ip=$DMZ_PUBLIC_IP" >> $CONF_FILE_PATH

XMPP_PASSWORD_KEY="xmpp_password"
XMPP_PASSWORD=$(grep $XMPP_PASSWORD_KEY $SECRETS_FILE | awk -F "=" '{print $2}')
echo "xmpp_password=$XMPP_PASSWORD" >> $CONF_FILE_PATH

# Fill AS infos
echo "" >> $CONF_FILES_PATH/$FNS_CONF_NAME
INTERNAL_HOST_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $INTERNAL_HOST_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "as_url=$INTERNAL_HOST_IP" >> $CONF_FILES_PATH/$FNS_CONF_NAME
AS_PORT=$(grep as_port $SHARED_INFO_FILE | awk -F "=" '{print $2}')
echo "as_port=$AS_PORT" >> $CONF_FILES_PATH/$FNS_CONF_NAME
