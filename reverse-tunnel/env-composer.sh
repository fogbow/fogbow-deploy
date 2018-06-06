#!/bin/bash

CONF_FILE_PATH=$1
HOST_KEY_PATTERN="host_key_path"

echo "Reading $CONF_FILE_PATH"

HOST_KEY_FILE_PATH=$(cat $CONF_FILE_PATH | grep $HOST_KEY_PATTERN | awk -F "=" '{print $2}')
HOST_KEY_FILE_NAME=$(basename $HOST_KEY_FILE_PATH)

echo "Host key file path: $HOST_KEY_FILE_PATH"
echo "Host ket file name: $HOST_KEY_FILE_NAME"

cp -u $HOST_KEY_FILE_PATH ./reverse-tunnel/$HOST_KEY_FILE_NAME