#!/bin/bash

CONF_FILES_DIR="conf-files"

CONF_FILES_LIST=$(find ./$CONF_FILES_DIR | grep .conf | xargs)

MANAGER_DIR="manager-core"
mkdir -p ./$MANAGER_DIR/$CONF_FILES_DIR

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$MANAGER_DIR/$CONF_FILES_DIR/$conf_file_name
done
