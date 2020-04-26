#!/bin/bash

SERVICE="resource-allocation-service"
CONF_FILE_NAME="ras.conf"
CLOUDS_DIR_NAME="clouds"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_CONF_FILE_NAME="services.conf"
APPLICATION_PROPERTIES_FILE_NAME="application.properties"
SITE_CONF_FILE_NAME="site.conf"
SECRETS_FILE_NAME="secrets"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"ras/conf-files"
CONTAINER_BASE_DIR_PATH="/root"/$SERVICE
CONTAINER_CONF_FILES_DIR="src/main/resources/private"




# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy ras.conf
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
## Copy clouds directory
yes | cp -fr $CONF_FILE_TEMPLATE_DIR_PATH/$CLOUDS_DIR_NAME $CONF_FILE_DIR_PATH
## Copy shared info
yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME
## Copy application.properties file
yes | cp -f $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME".example" $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME

# Edit configuration files

## Edit application.properties

BASIC_SITE_IP_PATTERN="basic_site_ip"
BASIC_SITE_IP=$(grep $BASIC_SITE_IP_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')
JDBC_PREFIX="jdbc:postgresql:"
DB_PORT="5432"
RAS_DB_ENDPOINT="ras"

DB_URL_PROPERTY="spring.datasource.url"
DB_URL=$JDBC_PREFIX"//"$BASIC_SITE_IP":"$DB_PORT"/"$RAS_DB_ENDPOINT
echo "" >> $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
echo "$DB_URL_PROPERTY=$DB_URL" >> $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME

DB_USERNAME="fogbow"
DB_USERNAME_PATTERN="spring.datasource.username"
echo "$DB_USERNAME_PATTERN=$DB_USERNAME" >> $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME

PASSWORD_PATTERN="^db_password"
DB_PASSWORD=$(grep $PASSWORD_PATTERN $CONF_FILE_DIR_PATH/$SECRETS_FILE_NAME | awk -F "=" '{print $2}')
DB_PASSWORD_PATTERN="spring.datasource.password"
echo "$DB_PASSWORD_PATTERN=$DB_PASSWORD" >> $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME

## Edit ras.conf

PROVIDER_ID_PATTERN="provider_id"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "provider_id=$PROVIDER_ID" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

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

# Fill AS info
PROTOCOL="http://"
echo "as_url=$PROTOCOL$BASIC_SITE_IP" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
AS_PORT=$(grep ^as_port $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME | awk -F "=" '{print $2}')
echo "as_port=$AS_PORT" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

# Timestamp Database URL
echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "jdbc_database_url=jdbc:sqlite:/root/resource-allocation-service/ras.db" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
