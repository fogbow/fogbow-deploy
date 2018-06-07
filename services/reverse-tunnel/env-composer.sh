#!/bin/bash
DIR_BASE=$(pwd)

CONF_FILE_PATH=$1
HOST_KEY_PATTERN="host_key_path"

HOST_KEY_FILE_PATH=$(cat $CONF_FILE_PATH | grep $HOST_KEY_PATTERN | awk -F "=" '{print $2}')
HOST_KEY_FILE_NAME=$(basename $HOST_KEY_FILE_PATH)

echo "Host key file path: $HOST_KEY_FILE_PATH"
echo "Host key file name: $HOST_KEY_FILE_NAME"

REVERSE_TUNNEL_DIR="services/reverse-tunnel"
REVERSE_TUNNEL_CONF_FILE="reverse-tunnel.conf"

# Moving host key to deployment directory
yes | cp -rf $HOST_KEY_FILE_PATH ./$REVERSE_TUNNEL_DIR/$HOST_KEY_FILE_NAME

# Moving conf file to deployment directory
yes | cp -rf $CONF_FILE_PATH ./$REVERSE_TUNNEL_DIR/$REVERSE_TUNNEL_CONF_FILE

# Replacing keys and values in reverse-tunnel conf file

# Removing comments and blank lines
sed -i -e 's/#.*//;/^$/d' ./$REVERSE_TUNNEL_DIR/$REVERSE_TUNNEL_CONF_FILE

# Replacing HOST_KEY_FILE_PATH with HOST_KEY_FILE_NAME
sed -i "s#$HOST_KEY_FILE_PATH#$HOST_KEY_FILE_NAME#" ./$REVERSE_TUNNEL_DIR/$REVERSE_TUNNEL_CONF_FILE

# Replacing reverse_tunnel_http_port with http_port
sed -i "s#reverse_tunnel_http_port#http_port#" ./$REVERSE_TUNNEL_DIR/$REVERSE_TUNNEL_CONF_FILE
