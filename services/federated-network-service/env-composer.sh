#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/federated-network-service"
CONF_FILES_DIR=$DIR/"conf-files"
EXTRA_FILES_DIR=$BASE_DIR/"extra-files"
CONTAINER_BASE_DIR="/root/federated-network-service"
GENERAL_CONF_FILE_PATH=$CONF_FILES_DIR/"general.conf"
FNS_CONF_FILES_PATH=$CONF_FILES_DIR/"ras-confs-to-fns"

mkdir -p $EXTRA_FILES_DIR

HOSTS_CONF_FILE=$CONF_FILES_DIR/"hosts.conf"
RAS_CONF_FILE=$CONF_FILES_DIR/"ras.conf"
INTERCOMPONENT_CONF_FILE=$CONF_FILES_DIR/"intercomponent.conf"

# Moving conf files
CONF_FILES_LIST=$(find $FNS_CONF_FILES_PATH | grep '.conf' | xargs)

BASE_CONF_FILES_DIR=$DIR/$BASE_DIR/"conf-files"
mkdir -p $BASE_CONF_FILES_DIR

echo "Moving conf files to "$BASE_CONF_FILES_DIR
for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	yes | cp -f $conf_file_path $BASE_CONF_FILES_DIR/$conf_file_name
done

# Moving RAS aaa.conf
AAA_FILE="aaa.conf"
yes | cp -f $CONF_FILES_DIR/$AAA_FILE $BASE_CONF_FILES_DIR/$AAA_FILE

# Moving keys
GENERAL_PRIVATE_KEY_PATTERN="private_key_file_path"
GENERAL_PUBLIC_KEY_PATTERN="public_key_file_path"

GENERAL_PRIVATE_KEY_PATH=$(grep $GENERAL_PRIVATE_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
GENERAL_PUBLIC_KEY_PATH=$(grep $GENERAL_PUBLIC_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
yes | cp -f $GENERAL_PRIVATE_KEY_PATH $BASE_CONF_FILES_DIR
yes | cp -f $GENERAL_PUBLIC_KEY_PATH $BASE_CONF_FILES_DIR

# Checking manager keys
echo "Fill keys path"

MANAGER_PRIVATE_KEY_PATTERN="ras_private_key_file_path"
MANAGER_PUBLIC_KEY_PATTERN="ras_public_key_file_path"

echo "$MANAGER_PRIVATE_KEY_PATTERN=$GENERAL_PRIVATE_KEY_PATH"
echo "$MANAGER_PUBLIC_KEY_PATTERN=$GENERAL_PUBLIC_KEY_PATH"

sed -i "s#.*$MANAGER_PRIVATE_KEY_PATTERN=.*#$MANAGER_PRIVATE_KEY_PATTERN=$GENERAL_PRIVATE_KEY_PATH#" $RAS_CONF_FILE
sed -i "s#.*$MANAGER_PUBLIC_KEY_PATTERN=.*#$MANAGER_PUBLIC_KEY_PATTERN=$GENERAL_PUBLIC_KEY_PATH#" $RAS_CONF_FILE

# Config Fed net application properties
APPLICATION_CONF_FILE=$BASE_DIR/"application.properties"
yes | cp -f $APPLICATION_CONF_FILE".example" $APPLICATION_CONF_FILE

INTERNAL_HOST_PRIVATE_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_PRIVATE_IP=$(grep $INTERNAL_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
JDBC_PREFIX="jdbc:postgresql:"
DB_PORT="5432"
FNS_DB_ENDPOINT="fns"

DB_URL_PROPERTY="spring.datasource.url"
DB_URL=$JDBC_PREFIX"//"$INTERNAL_HOST_PRIVATE_IP":"$DB_PORT"/"$FNS_DB_ENDPOINT
sed -i "s#.*$DB_URL_PROPERTY=.*#$DB_URL_PROPERTY=$DB_URL#" $APPLICATION_CONF_FILE

DB_USERNAME="fogbow"
DB_USERNAME_PATTERN="spring.datasource.username"
sed -i "s#.*$DB_USERNAME_PATTERN=.*#$DB_USERNAME_PATTERN=$DB_USERNAME#" $APPLICATION_CONF_FILE

GENERAL_PASSWORD_PATTERN="password"
DB_PASSWORD=$(grep $GENERAL_PASSWORD_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
DB_PASSWORD_PATTERN="spring.datasource.password"
sed -i "s#.*$DB_PASSWORD_PATTERN=.*#$DB_PASSWORD_PATTERN=$DB_PASSWORD#" $APPLICATION_CONF_FILE

echo "FNS JDBC database url: $DB_URL"
echo "Fogbow database username: $DB_USERNAME"
echo "Fogbow database password: $DB_PASSWORD"

# Copying fed net conf file
FEDNET_FILE_NAME="fns.conf"
FEDNET_CONF_FILE=$FNS_CONF_FILES_PATH/$FEDNET_FILE_NAME
ENV_FEDNET_CONF_FILE=$FNS_CONF_FILES_PATH/$FEDNET_FILE_NAME

echo "Moving $FEDNET_CONF_FILE to $ENV_FEDNET_CONF_FILE"

yes | cp -f $FEDNET_CONF_FILE $ENV_FEDNET_CONF_FILE

# Get Manager IP
RAS_IP_PATTERN="internal_host_private_ip"
RAS_IP=$(grep $RAS_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Manager ip: $RAS_IP"

RAS_IP_KEY="ras_ip"
sed -i "s#.*$RAS_IP_KEY=.*#$RAS_IP_KEY=$RAS_IP#" $ENV_FEDNET_CONF_FILE

# Get Manager server port
RAS_SERVER_PORT_PATTERN="ras_server_port"
RAS_SERVER_PORT=$(grep $RAS_SERVER_PORT_PATTERN $RAS_CONF_FILE | awk -F "=" '{print $2}')
echo "Manager server port: $RAS_SERVER_PORT"

RAS_PORT_KEY="ras_port"
sed -i "s#.*$RAS_PORT_KEY=.*#$RAS_PORT_KEY=$RAS_SERVER_PORT#" $ENV_FEDNET_CONF_FILE

# Get site name
SITE_NAME_PATTERN="xmpp_jid"
SITE_NAME=$(grep $SITE_NAME_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')
echo "Site name: $SITE_NAME"

RAS_NAME_KEY="ras_name"
sed -i "s#.*$RAS_NAME_KEY=.*#$RAS_NAME_KEY=$SITE_NAME#" $ENV_FEDNET_CONF_FILE

# Get ssh private key
GENERAL_PRIVATE_KEY_PATTERN="private_key_file_path"
GENERAL_PRIVATE_KEY_PATH=$(grep $GENERAL_PRIVATE_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
GENERAL_PRIVATE_KEY_NAME=$(basename $GENERAL_PRIVATE_KEY_PATH)

echo "Moving manager ssh private key $GENERAL_PRIVATE_KEY_NAME to $EXTRA_FILES_DIR directory"

yes | cp -f $GENERAL_PRIVATE_KEY_NAME $EXTRA_FILES_DIR

FEDNET_PERMISSION_FILE_PATH=$CONTAINER_BASE_DIR/"extra-files"/$GENERAL_PRIVATE_KEY_NAME
echo "federated_network_agent_permission_file_path=$FEDNET_PERMISSION_FILE_PATH"

AGENT_PEM_PATH="federated_network_agent_permission_file_path"
sed -i "s#.*$AGENT_PEM_PATH=.*#$AGENT_PEM_PATH=$FEDNET_PERMISSION_FILE_PATH#" $ENV_FEDNET_CONF_FILE

# Get remote hosts user
REMOTE_HOSTS_USER_PATTERN="remote_hosts_user"
REMOTE_HOSTS_USER=$(grep $REMOTE_HOSTS_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Remote hosts user: $REMOTE_HOSTS_USER"

REMOTE_USER="federated_network_agent_user"
sed -i "s#.*$REMOTE_USER=.*#$REMOTE_USER=$REMOTE_HOSTS_USER#" $ENV_FEDNET_CONF_FILE

# Get Agent private address
AGENT_PRIVATE_IP_PATTERN="dmz_host_private_ip"
AGENT_PRIVATE_IP=$(grep $AGENT_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Agent private ip: $AGENT_PRIVATE_IP"

AGENT_PRIVATE_IP_KEY="federated_network_agent_private_address"
sed -i "s#.*$AGENT_PRIVATE_IP_KEY=.*#$AGENT_PRIVATE_IP_KEY=$AGENT_PRIVATE_IP#" $ENV_FEDNET_CONF_FILE

# Get Agent public address
AGENT_PUBLIC_IP_PATTERN="dmz_host_public_ip"
AGENT_PUBLIC_IP=$(grep $AGENT_PUBLIC_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Agent public ip: $AGENT_PUBLIC_IP"

AGENT_PUBLIC_IP_KEY="federated_network_agent_address"
sed -i "s#.*$AGENT_PUBLIC_IP_KEY=.*#$AGENT_PUBLIC_IP_KEY=$AGENT_PUBLIC_IP#" $ENV_FEDNET_CONF_FILE

# Get Agent access password
VPN_PASSWORD_KEY="vpn_password"
VPN_PASSWORD=$(grep $VPN_PASSWORD_KEY $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
echo "Agent access password: $VPN_PASSWORD"

VPN_PSK_KEY="federated_network_agent_pre_shared_key"
sed -i "s#.*$VPN_PSK_KEY=.*#$VPN_PSK_KEY=$VPN_PASSWORD#" $ENV_FEDNET_CONF_FILE

# Adding Agent scripts path
DEFAULT_AGENT_SCRIPTS_PATH='~'/"fogbow-components"/"federated-network-agent"
CREATE_SCRIPT_NAME="config-create-federated-network"
DELETE_SCRIPT_NAME="config-delete-federated-network"

echo "Agent create network script path: $DEFAULT_AGENT_SCRIPTS_PATH/$CREATE_SCRIPT_NAME"
echo "Agent create network script path: $DEFAULT_AGENT_SCRIPTS_PATH/$DELETE_SCRIPT_NAME"

ADD_FEDNET_SCRIPT_KEY="add_federated_network_script_path"
REMOVE_FEDNET_SCRIPT_KEY="remove_federated_network_script_path"
sed -i "s#.*$ADD_FEDNET_SCRIPT_KEY=.*#$ADD_FEDNET_SCRIPT_KEY=$DEFAULT_AGENT_SCRIPTS_PATH/$CREATE_SCRIPT_NAME#" $ENV_FEDNET_CONF_FILE
sed -i "s#.*$REMOVE_FEDNET_SCRIPT_KEY=.*#$REMOVE_FEDNET_SCRIPT_KEY=$DEFAULT_AGENT_SCRIPTS_PATH/$DELETE_SCRIPT_NAME#" $ENV_FEDNET_CONF_FILE