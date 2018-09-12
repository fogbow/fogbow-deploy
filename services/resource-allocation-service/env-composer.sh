#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/resource-allocation-service"
CONF_FILES_DIR="conf-files"
GENERAL_CONF_FILE_PATH=$DIR/$CONF_FILES_DIR/"general.conf"

CONTAINER_BASE_PATH="/root/resource-allocation-service"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"

# Moving conf files

CONF_FILES_LIST=$(find ./$CONF_FILES_DIR | grep '.conf' | xargs)

mkdir -p ./$BASE_DIR/$CONF_FILES_DIR

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$BASE_DIR/$CONF_FILES_DIR/$conf_file_name
done

# Adding Manager JDBC properties

MANAGER_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"ras.conf"

DATABASES_DIR=$CONTAINER_BASE_PATH/"databases"
MANAGER_JDBC_NAME="manager.db"

JDBC_PREFIX="jdbc:sqlite:"

MANAGER_JDBC_URL_PROPERTY="jdbc_database_url"
MANAGER_JDBC_URL=$JDBC_PREFIX$DATABASES_DIR/$MANAGER_JDBC_NAME

echo "Manager JDBC database url: $MANAGER_JDBC_URL"

MANAGER_JDBC_USERNAME_PROPERTY="jdbc_database_username"
MANAGER_JDBC_USERNAME="fogbow"

echo "Manager JDBC database username: $MANAGER_JDBC_USERNAME"

MANAGER_JDBC_PASSWORD_PROPERTY="jdbc_database_password"
GENERAL_PASSWORD_KEY="password"
GENERAL_PASSWORD=$(grep $GENERAL_PASSWORD_KEY $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')

echo "Manager JDBC database password: $GENERAL_PASSWORD"

echo "" >> $MANAGER_CONF_FILE
echo "$MANAGER_JDBC_URL_PROPERTY=$MANAGER_JDBC_URL" >> $MANAGER_CONF_FILE

echo "" >> $MANAGER_CONF_FILE
echo "$MANAGER_JDBC_USERNAME_PROPERTY=$MANAGER_JDBC_USERNAME" >> $MANAGER_CONF_FILE

echo "" >> $MANAGER_CONF_FILE
echo "$MANAGER_JDBC_PASSWORD_PROPERTY=$GENERAL_PASSWORD" >> $MANAGER_CONF_FILE

# Checking manager ssh keys

echo "Fill SSH keys path"

GENERAL_PRIVATE_KEY_PATTERN="private_key_file_path"
GENERAL_PUBLIC_KEY_PATTERN="public_key_file_path"

GENERAL_PRIVATE_KEY_PATH=$(grep $GENERAL_PRIVATE_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
GENERAL_PUBLIC_KEY_PATH=$(grep $GENERAL_PUBLIC_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')

MANAGER_PRIVATE_KEY_PATTERN="manager_ssh_private_key_file_path"
MANAGER_PUBLIC_KEY_PATTERN="manager_ssh_public_key_file_path"

echo "$MANAGER_PRIVATE_KEY_PATTERN=$GENERAL_PRIVATE_KEY_PATH"
echo "$MANAGER_PUBLIC_KEY_PATTERN=$GENERAL_PUBLIC_KEY_PATH"

sed -i "s#.*$MANAGER_PRIVATE_KEY_PATTERN=.*#$MANAGER_PRIVATE_KEY_PATTERN=$GENERAL_PRIVATE_KEY_PATH#" $MANAGER_CONF_FILE
sed -i "s#.*$MANAGER_PUBLIC_KEY_PATTERN=.*#$MANAGER_PUBLIC_KEY_PATTERN=$GENERAL_PUBLIC_KEY_PATH#" $MANAGER_CONF_FILE

# Copying files from conf files specification

echo "Copying files specified in conf files to manager-core directory"

CONF_FILES_LIST=$(ls ./$BASE_DIR/$CONF_FILES_DIR)

SUFFIX_FILE_PATH="path"

for conf_file_name in $CONF_FILES_LIST; do

	file_path_values=$(grep $SUFFIX_FILE_PATH ./$BASE_DIR/$CONF_FILES_DIR/$conf_file_name | awk -F "=" '{print $2}')
	
	for file_path_value in $file_path_values; do
		if [ -n "$file_path_value" ]; then
			echo "Moving $file_path_value to manager-core directory"
			file_name_value=$(basename $file_path_value)
			yes | cp -f $file_path_value ./$BASE_DIR/$CONF_FILES_DIR/$file_name_value
			echo "Replacing files path properties in conf files"
			sed -i "s#$file_path_value#$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILES_DIR/$file_name_value#" ./$BASE_DIR/$CONF_FILES_DIR/$conf_file_name
		fi
	done
done

# Adding xmpp server ip

HOSTS_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"hosts.conf"

DMZ_HOST_PRIVATE_IP_PATTERN="dmz_host_private_ip"
DMZ_HOST_PRIVATE_IP=$(grep $DMZ_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

INTERCOMPONENT_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"intercomponent.conf"
XMPP_SERVER_IP_PATTERN="xmpp_server_ip"
sed -i "s#$XMPP_SERVER_IP_PATTERN=#$XMPP_SERVER_IP_PATTERN=$DMZ_HOST_PRIVATE_IP#" $INTERCOMPONENT_CONF_FILE

XMPP_MANAGER_PORT_PATTERN="xmpp_c2c_port"
XMPP_MANAGER_PORT=$(grep $XMPP_MANAGER_PORT_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')
XMPP_MANAGER_PORT_PROPERTY="xmpp_server_port"
echo "" >> $INTERCOMPONENT_CONF_FILE
echo "$XMPP_MANAGER_PORT_PROPERTY=$XMPP_MANAGER_PORT" >> $INTERCOMPONENT_CONF_FILE

