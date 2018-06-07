#!/bin/bash

CONF_FILES_DIR="conf-files"

CONF_FILES_LIST=$(find ./$CONF_FILES_DIR | grep '.conf' | xargs)

MANAGER_DIR="manager-core"
mkdir -p ./$MANAGER_DIR/$CONF_FILES_DIR

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$MANAGER_DIR/$CONF_FILES_DIR/$conf_file_name
done

echo "Copying to manager-core dir files specified in the conf files"

CONF_FILES_LIST=$(ls ./$MANAGER_DIR/$CONF_FILES_DIR)

SUFFIX_FILE_PATH="path"
for conf_file_name in $CONF_FILES_LIST; do

	file_path_values=$(cat ./$MANAGER_DIR/$CONF_FILES_DIR/$conf_file_name | grep $SUFFIX_FILE_PATH | awk -F "=" '{print $2}')
	
	for file_path_value in $file_path_values; do
		if [ -n "$file_path_value" ]; then
			echo "Moving $file_path_value to manager-core directory"
			file_name_value=$(basename $file_path_value)
			yes | cp -f $file_path_value ./$MANAGER_DIR/$CONF_FILES_DIR/$file_name_value
			echo "Replacing files path properties in conf files"
			sed -i "s#$file_path_value#$file_name_value#" ./$MANAGER_DIR/$CONF_FILES_DIR/$conf_file_name
		fi	
	done
done
