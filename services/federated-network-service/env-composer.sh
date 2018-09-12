#!/bin/bash

DIR=$(pwd)
BASE_DIR="services/federated-network-service"
CONF_FILES_DIR=$DIR/"conf-files"
EXTRA_FILES_DIR=$BASE_DIR/"extra-files"
CONTAINER_BASE_DIR="/root/federated-network-service"
GENERAL_CONF_FILE_PATH=$CONF_FILES_DIR/"general.conf"

mkdir -p $EXTRA_FILES_DIR

HOSTS_CONF_FILE=$CONF_FILES_DIR/"hosts.conf"
MANAGER_CONF_FILE=$CONF_FILES_DIR/"ras.conf"
INTERCOMPONENT_CONF_FILE=$CONF_FILES_DIR/"intercomponent.conf"

# Copying fed net conf file
FEDNET_FILE_NAME="federated-network.conf"
FEDNET_CONF_FILE=$CONF_FILES_DIR/$FEDNET_FILE_NAME
ENV_FEDNET_CONF_FILE=$BASE_DIR/$FEDNET_FILE_NAME

echo "Moving $FEDNET_CONF_FILE to $ENV_FEDNET_CONF_FILE"

yes | cp -f $FEDNET_CONF_FILE $ENV_FEDNET_CONF_FILE

# Get Manager IP
MANAGER_IP_PATTERN="internal_host_private_ip"
MANAGER_IP=$(grep $MANAGER_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "Manager ip: $MANAGER_IP"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "manager_core_ip=$MANAGER_IP" >> $ENV_FEDNET_CONF_FILE

# Get Manager server port
MANAGER_SERVER_PORT_PATTERN="manager_server_port"
MANAGER_SERVER_PORT=$(grep $MANAGER_SERVER_PORT_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')

echo "Manager server port: $MANAGER_SERVER_PORT"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "manager_core_port=$MANAGER_SERVER_PORT" >> $ENV_FEDNET_CONF_FILE

# Get site name
SITE_NAME_PATTERN="xmpp_jid"
SITE_NAME=$(grep $SITE_NAME_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')

echo "Site name: $SITE_NAME"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "member_name=$SITE_NAME" >> $ENV_FEDNET_CONF_FILE

# Get ssh private key
GENERAL_PRIVATE_KEY_PATTERN="private_key_file_path"
GENERAL_PRIVATE_KEY_PATH=$(grep $GENERAL_PRIVATE_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
GENERAL_PRIVATE_KEY_NAME=$(basename $GENERAL_PRIVATE_KEY_PATH)

echo "Moving manager ssh private key $GENERAL_PRIVATE_KEY_NAME to $EXTRA_FILES_DIR directory"

yes | cp -f $GENERAL_PRIVATE_KEY_NAME $EXTRA_FILES_DIR

FEDNET_PERMISSION_FILE_PATH=$CONTAINER_BASE_DIR/"extra-files"/$GENERAL_PRIVATE_KEY_NAME

echo "federated_network_agent_permission_file_path=$FEDNET_PERMISSION_FILE_PATH"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "federated_network_agent_permission_file_path=$FEDNET_PERMISSION_FILE_PATH" >> $ENV_FEDNET_CONF_FILE

# Get remote hosts user
REMOTE_HOSTS_USER_PATTERN="remote_hosts_user"
REMOTE_HOSTS_USER=$(grep $REMOTE_HOSTS_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "Remote hosts user: $REMOTE_HOSTS_USER"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "federated_network_agent_user=$REMOTE_HOSTS_USER" >> $ENV_FEDNET_CONF_FILE

# Get Agent private address
AGENT_PRIVATE_IP_PATTERN="dmz_host_private_ip"
AGENT_PRIVATE_IP=$(grep $AGENT_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "Agent private ip: $AGENT_PRIVATE_IP"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "federated_network_agent_private_address=$AGENT_PRIVATE_IP" >> $ENV_FEDNET_CONF_FILE

# Get Agent public address
AGENT_PUBLIC_IP_PATTERN="dmz_host_public_ip"
AGENT_PUBLIC_IP=$(grep $AGENT_PUBLIC_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "Agent public ip: $AGENT_PUBLIC_IP"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "federated_network_agent_address=$AGENT_PUBLIC_IP" >> $ENV_FEDNET_CONF_FILE

# Get Agent access password
GENERAL_PASSWORD="password"
GENERAL_PASSWORD=$(grep $GENERAL_PASSWORD $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')

echo "Agent access password: $GENERAL_PASSWORD"
echo "" >> $ENV_FEDNET_CONF_FILE
echo "federated_network_agent_pre_shared_key=$GENERAL_PASSWORD" >> $ENV_FEDNET_CONF_FILE

# Adding Agent scripts path
DEFAULT_AGENT_SCRIPTS_PATH='~'/"fogbow-components"/"federated-network-agent"
CREATE_SCRIPT_NAME="config-create-federated-network"
DELETE_SCRIPT_NAME="config-delete-federated-network"

echo "Agent create network script path: $DEFAULT_AGENT_SCRIPTS_PATH/$CREATE_SCRIPT_NAME"
echo "Agent create network script path: $DEFAULT_AGENT_SCRIPTS_PATH/$DELETE_SCRIPT_NAME"

echo "" >> $ENV_FEDNET_CONF_FILE
echo "add_federated_network_script_path=$DEFAULT_AGENT_SCRIPTS_PATH/$CREATE_SCRIPT_NAME" >> $ENV_FEDNET_CONF_FILE
echo "remove_federated_network_script_path=$DEFAULT_AGENT_SCRIPTS_PATH/$DELETE_SCRIPT_NAME" >> $ENV_FEDNET_CONF_FILE
