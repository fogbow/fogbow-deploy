#!/bin/bash
DIR_BASE=$(pwd)
CONF_FILES_DIR=$DIR_BASE/"conf-files"

CONF_FILE_PATH=$CONF_FILES_DIR/"reverse-tunnel.conf"
HOST_KEY_PATTERN="host_key_path"

HOST_KEY_FILE_PATH=$(grep $HOST_KEY_PATTERN $CONF_FILE_PATH | awk -F "=" '{print $2}')
HOST_KEY_FILE_NAME=$(basename $HOST_KEY_FILE_PATH)

HOST_KEY_PATH_PATTERN="host_key_path"

if [ -z "$HOST_KEY_FILE_PATH" ]; then
	echo "Cannot identify the host key file, using manager private key"
	
	MANAGER_CONF_FILES_DIR=$DIR_BASE/"services"/"manager-core"/"conf-files"
	MANAGER_CONF_FILE=$MANAGER_CONF_FILES_DIR/"manager.conf"
	
	MANAGER_PRIVATE_KEY_PATTERN="manager_ssh_private_key_file_path"
	HOST_KEY_FILE_NAME=$(grep $MANAGER_PRIVATE_KEY_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')
	HOST_KEY_FILE_PATH=$MANAGER_CONF_FILES_DIR/$HOST_KEY_FILE_NAME
fi

echo "Host key file path: $HOST_KEY_FILE_PATH"
echo "Host key file name: $HOST_KEY_FILE_NAME"

REVERSE_TUNNEL_DIR="services/reverse-tunnel"
REVERSE_TUNNEL_CONF_FILE="reverse-tunnel.conf"

# Moving host key to deployment directory
yes | cp -f $HOST_KEY_FILE_PATH ./$REVERSE_TUNNEL_DIR/$HOST_KEY_FILE_NAME

# Moving conf file to deployment directory
yes | cp -f $CONF_FILE_PATH ./$REVERSE_TUNNEL_DIR/$REVERSE_TUNNEL_CONF_FILE

# Replacing keys and values in reverse-tunnel conf file

# Replacing HOST_KEY_FILE_PATH with HOST_KEY_FILE_NAME
sed -i "s#$HOST_KEY_PATH_PATTERN=#$HOST_KEY_PATH_PATTERN=$HOST_KEY_FILE_NAME#" ./$REVERSE_TUNNEL_DIR/$REVERSE_TUNNEL_CONF_FILE

# Replacing reverse_tunnel_http_port with http_port
sed -i "s#reverse_tunnel_http_port#http_port#" ./$REVERSE_TUNNEL_DIR/$REVERSE_TUNNEL_CONF_FILE
