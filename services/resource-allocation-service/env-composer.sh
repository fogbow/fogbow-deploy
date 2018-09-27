#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/resource-allocation-service"
CONF_FILES_DIR="conf-files"
GENERAL_CONF_FILE_PATH=$DIR/$CONF_FILES_DIR/"general.conf"
RAS_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"ras.conf"
FNS_CONF_PATH=$CONF_FILES_DIR/"ras-confs-to-fns"

CONTAINER_BASE_PATH="/root/resource-allocation-service"
CONTAINER_CONF_FILES_DIR="src/main/resources/private"

HOSTS_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"hosts.conf"

# Moving conf files

CONF_FILES_LIST=$(find ./$CONF_FILES_DIR -path ./$FNS_CONF_PATH -prune -o -print | grep '.conf' | xargs)

mkdir -p ./$BASE_DIR/$CONF_FILES_DIR

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$BASE_DIR/$CONF_FILES_DIR/$conf_file_name
done

# RAS application.properties configuration
APPLICATION_CONF_FILE=$BASE_DIR/"application.properties"
yes | cp -f $APPLICATION_CONF_FILE".example" $APPLICATION_CONF_FILE

INTERNAL_HOST_PRIVATE_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_PRIVATE_IP=$(grep $INTERNAL_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
JDBC_PREFIX="jdbc:postgresql:"
DB_PORT="5432"
RAS_DB_ENDPOINT="ras"

DB_URL_PROPERTY="spring.datasource.url"
DB_URL=$JDBC_PREFIX"//"$INTERNAL_HOST_PRIVATE_IP":"$DB_PORT"/"$RAS_DB_ENDPOINT
sed -i "s#.*$DB_URL_PROPERTY=.*#$DB_URL_PROPERTY=$DB_URL#" $APPLICATION_CONF_FILE

DB_USERNAME="fogbow"
DB_USERNAME_PATTERN="spring.datasource.username"
sed -i "s#.*$DB_USERNAME_PATTERN=.*#$DB_USERNAME_PATTERN=$DB_USERNAME#" $APPLICATION_CONF_FILE

GENERAL_PASSWORD_PATTERN="password"
DB_PASSWORD=$(grep $GENERAL_PASSWORD_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
DB_PASSWORD_PATTERN="spring.datasource.password"
sed -i "s#.*$DB_PASSWORD_PATTERN=.*#$DB_PASSWORD_PATTERN=$DB_PASSWORD#" $APPLICATION_CONF_FILE

echo "RAS JDBC database url: $DB_URL"
echo "Fogbow database username: $DB_USERNAME"
echo "Fogbow database password: $DB_PASSWORD"

# Checking manager keys

echo "Fill keys path"

GENERAL_PRIVATE_KEY_PATTERN="private_key_file_path"
GENERAL_PUBLIC_KEY_PATTERN="public_key_file_path"

GENERAL_PRIVATE_KEY_PATH=$(grep "^"$GENERAL_PRIVATE_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
GENERAL_PUBLIC_KEY_PATH=$(grep "^"$GENERAL_PUBLIC_KEY_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')

MANAGER_PRIVATE_KEY_PATTERN="ras_private_key_file_path"
MANAGER_PUBLIC_KEY_PATTERN="ras_public_key_file_path"

echo "$MANAGER_PRIVATE_KEY_PATTERN=$GENERAL_PRIVATE_KEY_PATH"
echo "$MANAGER_PUBLIC_KEY_PATTERN=$GENERAL_PUBLIC_KEY_PATH"

sed -i "s#.*$MANAGER_PRIVATE_KEY_PATTERN=.*#$MANAGER_PRIVATE_KEY_PATTERN=$GENERAL_PRIVATE_KEY_PATH#" $RAS_CONF_FILE
sed -i "s#.*$MANAGER_PUBLIC_KEY_PATTERN=.*#$MANAGER_PUBLIC_KEY_PATTERN=$GENERAL_PUBLIC_KEY_PATH#" $RAS_CONF_FILE

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
DMZ_HOST_PRIVATE_IP_PATTERN="dmz_host_private_ip"
DMZ_HOST_PRIVATE_IP=$(grep $DMZ_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

INTERCOMPONENT_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"intercomponent.conf"
XMPP_SERVER_IP_PATTERN="xmpp_server_ip"
sed -i "s#$XMPP_SERVER_IP_PATTERN=#$XMPP_SERVER_IP_PATTERN=$DMZ_HOST_PRIVATE_IP#" $INTERCOMPONENT_CONF_FILE

XMPP_MANAGER_PORT_PATTERN="xmpp_c2s_port"
XMPP_MANAGER_PORT=$(grep $XMPP_MANAGER_PORT_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')
XMPP_MANAGER_PORT_PROPERTY="xmpp_c2s_port"
echo "" >> $INTERCOMPONENT_CONF_FILE
echo "$XMPP_MANAGER_PORT_PROPERTY=$XMPP_MANAGER_PORT" >> $INTERCOMPONENT_CONF_FILE

XMPP_PASSWORD_PATTERN="xmpp_password"
XMPP_PASSWORD=$(grep $XMPP_PASSWORD_PATTERN $GENERAL_CONF_FILE_PATH | awk -F "=" '{print $2}')
sed -i "s#.*$XMPP_PASSWORD_PATTERN=.*#$XMPP_PASSWORD_PATTERN=$XMPP_PASSWORD#" $INTERCOMPONENT_CONF_FILE