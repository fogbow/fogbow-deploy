#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
CONF_FILE_PATH=$CONF_FILES_DIR/"general.conf"

PRIVATE_KEY_PROPERTY="private_key_file_path"
PUBLIC_KEY_PROPERTY="public_key_file_path"
PASSWORD_PROPERTY="password"

PRIVATE_KEY_PATH=$(grep $PRIVATE_KEY_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
PUBLIC_KEY_PATH=$(grep $PUBLIC_KEY_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
PASSWORD_VALUE=$(grep $PASSWORD_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')

if [ -z "${PRIVATE_KEY_PATH// }" ] || [ ! -s "${PRIVATE_KEY_PATH// }" ] || [ ! -s "${PUBLIC_KEY_PATH// }" ] || [ ! -s "${PUBLIC_KEY_PATH// }" ]; then
	echo "Cannot identify the manager ssh private key"
	echo "Generating manager ssh private key"

	PRIVATE_KEY_PATH=$DIR/"fogbow-id_rsa"
	PUBLIC_KEY_PATH=$DIR/"fogbow-id_rsa.pub"
	
	ssh-keygen -f $PRIVATE_KEY_PATH -t rsa -b 4096 -C "fogbow@manager" -N ""

	sed -i "s#.*$PRIVATE_KEY_PROPERTY=.*#$PRIVATE_KEY_PROPERTY=$PRIVATE_KEY_PATH#" $CONF_FILE_PATH
	sed -i "s#.*$PUBLIC_KEY_PROPERTY=.*#$PUBLIC_KEY_PROPERTY=$PUBLIC_KEY_PATH#" $CONF_FILE_PATH
fi

if [ -z ${PASSWORD_VALUE// } ]; then
	GENERATED_PASSWORD=$(pwgen 10 1)
	echo "Password generated: $GENERATED_PASSWORD"
	sed -i "s#.*$PASSWORD_PROPERTY=.*#$PASSWORD_PROPERTY=$GENERATED_PASSWORD#" $CONF_FILE_PATH
fi