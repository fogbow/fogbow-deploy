#!/bin/bash

DIR=$(pwd)
BASE_DIR="services/federated-network-agent"

STRONGSWAN_CONF_FILE=$BASE_DIR/"ipsec.secrets"

# Get Agent access password
MANAGER_CONFIGURED_FILES_DIR=$DIR/"services"/"manager-core"/"conf-files"
MANAGER_CONFIGURED_FILE=$MANAGER_CONFIGURED_FILES_DIR/"manager.conf"

MANAGER_JDBC_PASSWORD_PROPERTY="jdbc_database_password"
MANAGER_JDBC_PASSWORD=$(grep $MANAGER_JDBC_PASSWORD_PROPERTY $MANAGER_CONFIGURED_FILE | awk -F "=" '{print $2}')

echo "Agent access password: $MANAGER_JDBC_PASSWORD"

echo ": PSK '$MANAGER_JDBC_PASSWORD'" > $STRONGSWAN_CONF_FILE
