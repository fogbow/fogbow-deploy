#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/manager-core"
CONF_FILES_DIR="conf-files"

CONTAINER_BASE_PATH="/root/fogbow-manager-core"
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

MANAGER_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"manager.conf"

DATABASES_DIR=$CONTAINER_BASE_PATH/"databases"
MANAGER_JDBC_NAME="manager.db"

MANAGER_JDBC_URL_PROPERTY="jdbc_database_url"
MANAGER_JDBC_URL=$DATABASES_DIR/$MANAGER_JDBC_NAME

echo "$MANAGER_JDBC_URL_PROPERTY=$MANAGER_JDBC_URL"

echo "" >> $MANAGER_CONF_FILE
echo "$MANAGER_JDBC_URL_PROPERTY=$MANAGER_JDBC_URL" >> $MANAGER_CONF_FILE

# Checking manager ssh keys

echo "Checking SSH keys"

MANAGER_PRIVATE_KEY_PATTERN="manager_ssh_private_key_file_path"
MANAGER_PUBLIC_KEY_PATTERN="manager_ssh_public_key_file_path"

MANAGER_PRIVATE_KEY_PATH=$(grep $MANAGER_PRIVATE_KEY_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')
MANAGER_PUBLIC_KEY_PATH=$(grep $MANAGER_PUBLIC_KEY_PATTERN $MANAGER_CONF_FILE | awk -F "=" '{print $2}')

if [ -z "$MANAGER_PRIVATE_KEY_PATH" ] || [ ! -f "$MANAGER_PRIVATE_KEY_PATH" ]; then
	echo "Cannot identify the manager ssh private key"
	echo "Generating manager ssh private key"

	MANAGER_PRIVATE_KEY_PATH=$DIR/"manager-id_rsa"
	MANAGER_PUBLIC_KEY_PATH=$DIR/"manager-id_rsa.pub"
	
	ssh-keygen -f $MANAGER_PRIVATE_KEY_PATH -t rsa -b 4096 -C "fogbow@manager" -N ""
fi

echo "$MANAGER_PRIVATE_KEY_PATTERN=$MANAGER_PRIVATE_KEY_PATH"
echo "$MANAGER_PUBLIC_KEY_PATTERN=$MANAGER_PUBLIC_KEY_PATH"

sed -i "s#.*$MANAGER_PRIVATE_KEY_PATTERN=.*#$MANAGER_PRIVATE_KEY_PATTERN=$MANAGER_PRIVATE_KEY_PATH#" $MANAGER_CONF_FILE
sed -i "s#.*$MANAGER_PUBLIC_KEY_PATTERN=.*#$MANAGER_PUBLIC_KEY_PATTERN=$MANAGER_PUBLIC_KEY_PATH#" $MANAGER_CONF_FILE

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

# Adding xmpp server ip, reverse tunnel public and private ip

HOSTS_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"hosts.conf"

DMZ_HOST_PRIVATE_IP_PATTERN="dmz_host_private_ip"
DMZ_HOST_PRIVATE_IP=$(grep $DMZ_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

DMZ_HOST_PUBLIC_IP_PATTERN="dmz_host_public_ip"
DMZ_HOST_PUBLIC_IP=$(grep $DMZ_HOST_PUBLIC_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

INTERCOMPONENT_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"intercomponent.conf"
XMPP_SERVER_IP_PATTERN="xmpp_server_ip"
sed -i "s#$XMPP_SERVER_IP_PATTERN=#$XMPP_SERVER_IP_PATTERN=$DMZ_HOST_PRIVATE_IP#" $INTERCOMPONENT_CONF_FILE

XMPP_MANAGER_PORT_PATTERN="xmpp_c2c_port"
XMPP_MANAGER_PORT=$(grep $XMPP_MANAGER_PORT_PATTERN $INTERCOMPONENT_CONF_FILE | awk -F "=" '{print $2}')
XMPP_MANAGER_PORT_PROPERTY="xmpp_server_port"
echo "" >> $INTERCOMPONENT_CONF_FILE
echo "$XMPP_MANAGER_PORT_PROPERTY=$XMPP_MANAGER_PORT" >> $INTERCOMPONENT_CONF_FILE

REVERSE_TUNNEL_CONF_FILE=$BASE_DIR/$CONF_FILES_DIR/"reverse-tunnel.conf"
REVERSE_TUNNEL_PUBLIC_IP_PATTERN="reverse_tunnel_public_address"
REVERSE_TUNNEL_PRIVATE_IP_PATTERN="reverse_tunnel_private_address"

sed -i "s#$REVERSE_TUNNEL_PUBLIC_IP_PATTERN=#$REVERSE_TUNNEL_PUBLIC_IP_PATTERN=$DMZ_HOST_PUBLIC_IP#" $REVERSE_TUNNEL_CONF_FILE
sed -i "s#$REVERSE_TUNNEL_PRIVATE_IP_PATTERN=#$REVERSE_TUNNEL_PRIVATE_IP_PATTERN=$DMZ_HOST_PRIVATE_IP#" $REVERSE_TUNNEL_CONF_FILE
