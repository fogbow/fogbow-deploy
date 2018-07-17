#!/bin/bash

DIR=$(pwd)
BASE_DIR="services/federated-network"
CONF_FILES_DIR=$DIR/"conf-files"
EXTRA_FILES_DIR=$BASE_DIR/"extra-files"
CONTAINER_BASE_DIR="/root/federated-network-service"

mkdir -p $EXTRA_FILES_DIR

HOSTS_CONF_FILE=$CONF_FILES_DIR/"hosts.conf"
MANAGER_CONF_FILE=$CONF_FILES_DIR/"manager.conf"

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

# Get Manager ssh private key
MANAGER_CONFIGURED_FILES_DIR=$DIR/"services"/"manager-core"/"conf-files"
MANAGER_CONFIGURED_FILE=$MANAGER_CONFIGURED_FILES_DIR/"manager.conf"

MANAGER_SSH_PRIVATE_KEY_FILE_PATH_PATTERN="manager_ssh_private_key_file_path"
MANAGER_SSH_PRIVATE_KEY_FILE_NAME=$(grep $MANAGER_SSH_PRIVATE_KEY_FILE_PATH_PATTERN $MANAGER_CONFIGURED_FILE | awk -F "=" '{print $2}' | xargs basename)
MANAGER_SSH_PRIVATE_KEY_FILE_PATH=$MANAGER_CONFIGURED_FILES_DIR/$MANAGER_SSH_PRIVATE_KEY_FILE_NAME

echo "Moving manager ssh private key $MANAGER_SSH_PRIVATE_KEY_FILE_PATH to $EXTRA_FILES_DIR directory"

yes | cp -f $MANAGER_SSH_PRIVATE_KEY_FILE_PATH $EXTRA_FILES_DIR

FEDNET_PERMISSION_FILE_PATH=$CONTAINER_BASE_DIR/"extra-files"/$MANAGER_SSH_PRIVATE_KEY_FILE_NAME

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
MANAGER_JDBC_PASSWORD_PROPERTY="jdbc_database_password"
MANAGER_JDBC_PASSWORD=$(grep $MANAGER_JDBC_PASSWORD_PROPERTY $MANAGER_CONFIGURED_FILE | awk -F "=" '{print $2}')

echo "Agent access password: $MANAGER_JDBC_PASSWORD"

echo "" >> $ENV_FEDNET_CONF_FILE
echo "federated_network_agent_pre_shared_key=$MANAGER_JDBC_PASSWORD" >> $ENV_FEDNET_CONF_FILE

# Adding Agent scripts path

DEFAULT_AGENT_SCRIPTS_PATH="~/fogbow-components/federated-network-agent"
CREATE_SCRIPT_NAME="config-create-federated-network"
DELETE_SCRIPT_NAME="config-delete-federated-network"

echo "Agent create network script path: $DEFAULT_AGENT_SCRIPTS_PATH/$CREATE_SCRIPT_NAME"
echo "Agent create network script path: $DEFAULT_AGENT_SCRIPTS_PATH/$DELETE_SCRIPT_NAME"

echo "" >> $ENV_FEDNET_CONF_FILE
echo "add_federated_network_script_path=$DEFAULT_AGENT_SCRIPTS_PATH/$CREATE_SCRIPT_NAME"
echo "remove_federated_network_script_path=$DEFAULT_AGENT_SCRIPTS_PATH/$DELETE_SCRIPT_NAME"
