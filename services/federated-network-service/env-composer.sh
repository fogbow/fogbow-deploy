#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/federated-network-service"
CONTAINER_BASE_DIR="/root/federated-network-service"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"
FNS_CONF_NAME="fns.conf"
CONF_FILES_DIR_NAME="conf-files"
CONF_FILES_PATH=$BASE_DIR/$CONF_FILES_DIR_NAME
HOSTS_CONF_FILE=$DIR/$CONF_FILES_DIR_NAME/"hosts.conf"
SHARED_INFO_FILE=$DIR/$CONF_FILES_DIR_NAME/"shared.info"

# Copy fns.conf
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$FNS_CONF_NAME $CONF_FILES_PATH/$FNS_CONF_NAME
# Copy services
SERVICES_FILE="services.conf"
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SERVICES_FILE $CONF_FILES_PATH/$SERVICES_FILE
# Copy secrets
SECRETS="secrets"
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SECRETS $CONF_FILES_PATH/$SECRETS
# Copy shared.info
SHARED_INFO="shared.info"
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SHARED_INFO ./$CONF_FILES_PATH/$SHARED_INFO
# Copy application.properties
APPLICATION_CONF_FILE=$BASE_DIR/"application.properties"
yes | cp -f $APPLICATION_CONF_FILE".example" $APPLICATION_CONF_FILE

# Configure applicatio.properties
INTERNAL_HOST_PRIVATE_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_PRIVATE_IP=$(grep $INTERNAL_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
JDBC_PREFIX="jdbc:postgresql:"
DB_PORT="5432"
FNS_DB_ENDPOINT="fns"

DB_URL_PROPERTY="spring.datasource.url"
DB_URL=$JDBC_PREFIX"//"$INTERNAL_HOST_PRIVATE_IP":"$DB_PORT"/"$FNS_DB_ENDPOINT
echo "" >> $APPLICATION_CONF_FILE
echo "$DB_URL_PROPERTY=$DB_URL" >> $APPLICATION_CONF_FILE

DB_USERNAME="fogbow"
DB_USERNAME_PATTERN="spring.datasource.username"
echo "$DB_USERNAME_PATTERN=$DB_USERNAME" >> $APPLICATION_CONF_FILE

GENERAL_PASSWORD_PATTERN="^db_password"
SECRETS_FILE=$BASE_DIR/$CONF_FILES_DIR_NAME/$SECRETS
DB_PASSWORD=$(grep $GENERAL_PASSWORD_PATTERN $SECRETS_FILE | awk -F "=" '{print $2}')
DB_PASSWORD_PATTERN="spring.datasource.password"
echo "$DB_PASSWORD_PATTERN=$DB_PASSWORD" >> $APPLICATION_CONF_FILE

INTERNAL_HOST_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $INTERNAL_HOST_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

# Fill AS infos
echo "" >> $CONF_FILES_PATH/$FNS_CONF_NAME
echo "as_url=$INTERNAL_HOST_IP" >> $CONF_FILES_PATH/$FNS_CONF_NAME
AS_PORT=$(grep ^as_port $SHARED_INFO_FILE | awk -F "=" '{print $2}')
echo "as_port=$AS_PORT" >> $CONF_FILES_PATH/$FNS_CONF_NAME

# Fill RAS infos
echo "" >> $CONF_FILES_PATH/$FNS_CONF_NAME
echo "ras_url=$INTERNAL_HOST_IP" >> $CONF_FILES_PATH/$FNS_CONF_NAME
RAS_PORT=$(grep ras_port $SHARED_INFO_FILE | awk -F "=" '{print $2}')
echo "ras_port=$RAS_PORT" >> $CONF_FILES_PATH/$FNS_CONF_NAME

# Fill xmpp jid
XMPP_JID_PATTERN="xmpp_jid"
XMPP_JID=$(grep $XMPP_JID_PATTERN $SHARED_INFO_FILE | awk -F "=" '{print $2}')
echo "" >> $CONF_FILES_PATH/$FNS_CONF_NAME
echo "xmpp_jid=$XMPP_JID" >> $CONF_FILES_PATH/$FNS_CONF_NAME

# Create key pair
echo ""
PRIVATE_KEY_PATH=$CONF_FILES_PATH/"id_rsa"
PUBLIC_KEY_PATH=$CONF_FILES_PATH/"id_rsa.pub"
RSA_KEY_PATH=$CONF_FILES_PATH/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "public_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa" >> $CONF_FILES_PATH/$FNS_CONF_NAME
echo "private_key_file_path="$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"id_rsa.pub" >> $CONF_FILES_PATH/$FNS_CONF_NAME

# Strong Swan agent configurations
FEDNET_PERMISSION_FILE_PATH=$CONTAINER_BASE_DIR/$CONTAINER_CONF_FILES_DIR/"dmz-id_rsa"
echo "federated_network_agent_permission_file_path=$FEDNET_PERMISSION_FILE_PATH" >> $CONF_FILES_PATH/$FNS_CONF_NAME

REMOTE_HOSTS_USER_PATTERN="remote_hosts_user"
REMOTE_HOSTS_USER=$(grep $REMOTE_HOSTS_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "federated_network_agent_user=$REMOTE_HOSTS_USER" >> $CONF_FILES_PATH/$FNS_CONF_NAME

AGENT_PRIVATE_IP_PATTERN="dmz_host_private_ip"
AGENT_PRIVATE_IP=$(grep $AGENT_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "federated_network_agent_private_address=$AGENT_PRIVATE_IP" >> $CONF_FILES_PATH/$FNS_CONF_NAME

AGENT_PUBLIC_IP_PATTERN="dmz_host_public_ip"
AGENT_PUBLIC_IP=$(grep $AGENT_PUBLIC_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "federated_network_agent_address=$AGENT_PUBLIC_IP" >> $CONF_FILES_PATH/$FNS_CONF_NAME

VPN_PASSWORD_KEY="vpn_password"
VPN_PASSWORD=$(grep $VPN_PASSWORD_KEY $SECRETS_FILE | awk -F "=" '{print $2}')
echo "federated_network_agent_pre_shared_key=$VPN_PASSWORD" >> $CONF_FILES_PATH/$FNS_CONF_NAME

DEFAULT_AGENT_SCRIPTS_PATH='~'/"fogbow-components"/"federated-network-agent"
CREATE_SCRIPT_NAME="create-federated-network"
DELETE_SCRIPT_NAME="delete-federated-network"
echo "" >> $CONF_FILES_PATH/$FNS_CONF_NAME
echo "add_federated_network_script_path=$DEFAULT_AGENT_SCRIPTS_PATH/$CREATE_SCRIPT_NAME" >> $CONF_FILES_PATH/$FNS_CONF_NAME
echo "remove_federated_network_script_path=$DEFAULT_AGENT_SCRIPTS_PATH/$DELETE_SCRIPT_NAME" >> $CONF_FILES_PATH/$FNS_CONF_NAME

# Timestamp Database URL
echo "" >> $CONF_FILES_PATH/$FNS_CONF_NAME
echo "jdbc_database_url=jdbc:sqlite:/root/federated-network-service/fns.db" >> $CONF_FILES_PATH/$FNS_CONF_NAME
