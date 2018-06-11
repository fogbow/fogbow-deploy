#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/manager-core"
CONF_FILES_DIR="conf-files"

# Moving conf files

CONF_FILES_LIST=$(find ./$CONF_FILES_DIR | grep '.conf' | xargs)

mkdir -p ./$BASE_DIR/$CONF_FILES_DIR

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$BASE_DIR/$CONF_FILES_DIR/$conf_file_name
done

# Checking manager ssh keys

MANAGER_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"manager.conf"

MANAGER_PRIVATE_KEY_PATTERN="manager_ssh_private_key_file_path"
MANAGER_PUBLIC_KEY_PATTERN="manager_ssh_public_key_file_path"

MANAGER_PRIVATE_KEY_PATH=$(grep $MANAGER_PRIVATE_KEY_PATTERN $MANAGER_CONF_FILE | awk -F "#" '{print $1}' | awk -F "=" '{print $2}')

if [ -z "$MANAGER_PRIVATE_KEY_PATH" ] || [ ! -f "$MANAGER_PRIVATE_KEY_PATH" ]; then
	echo "Cannot identify the manager ssh private key"
	echo "Generating manager ssh private key"

	MANAGER_PRIVATE_KEY_PATH=$DIR/"manager-id_rsa"
	MANAGER_PUBLIC_KEY_PATH=$DIR/"manager-id_rsa.pub"
	
	ssh-keygen -f $MANAGER_PRIVATE_KEY_PATH -t rsa -b 4096 -C "fogbow@manager" -N ""
	
	sed -i "s#$MANAGER_PRIVATE_KEY_PATTERN=#$MANAGER_PRIVATE_KEY_PATTERN=$MANAGER_PRIVATE_KEY_PATH#" $MANAGER_CONF_FILE
	sed -i "s#$MANAGER_PUBLIC_KEY_PATTERN=#$MANAGER_PUBLIC_KEY_PATTERN=$MANAGER_PUBLIC_KEY_PATH#" $MANAGER_CONF_FILE
	
	echo "$MANAGER_PRIVATE_KEY_PATTERN=$MANAGER_PRIVATE_KEY_PATH"
	echo "$MANAGER_PUBLIC_KEY_PATTERN=$MANAGER_PUBLIC_KEY_PATH"
fi

# Copying files from conf files specification

echo "Copying to manager-core dir files specified in the conf files"

CONF_FILES_LIST=$(ls ./$BASE_DIR/$CONF_FILES_DIR)

SUFFIX_FILE_PATH="path"
for conf_file_name in $CONF_FILES_LIST; do

	file_path_values=$(cat ./$BASE_DIR/$CONF_FILES_DIR/$conf_file_name | grep $SUFFIX_FILE_PATH | awk -F "=" '{print $2}')
	
	for file_path_value in $file_path_values; do
		if [ -n "$file_path_value" ]; then
			echo "Moving $file_path_value to manager-core directory"
			file_name_value=$(basename $file_path_value)
			yes | cp -f $file_path_value ./$BASE_DIR/$CONF_FILES_DIR/$file_name_value
			echo "Replacing files path properties in conf files"
			sed -i "s#$file_path_value#$file_name_value#" ./$BASE_DIR/$CONF_FILES_DIR/$conf_file_name
		fi	
	done
done
