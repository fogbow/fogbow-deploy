#!/bin/bash

# Define secrets files

SECRETS_FILE_NAME="secrets"
DB_CONF_FILE_PATH="../../services/fogbow-database/conf-files"
RAS_CONF_FILE_PATH="../../services/resource-allocation-service/conf-files"
DB_SECRETS_FILE_PATH=$DB_CONF_FILE_PATH/$SECRETS_FILE_NAME
RAS_SECRETS_FILE_PATH=$RAS_CONF_FILE_PATH/$SECRETS_FILE_NAME

# Create secrets files

mkdir -p $DB_CONF_FILE_PATH
touch $DB_SECRETS_FILE_PATH
chmod 600 $DB_SECRETS_FILE_PATH

mkdir -p $RAS_CONF_FILE_PATH
touch $RAS_SECRETS_FILE_PATH
chmod 600 $RAS_SECRETS_FILE_PATH

# Generate DB password and fill secret files
DB_PASSWORD_PROPERTY="db_password"
GENERATED_PASSWORD=$(pwgen 10 1)
echo "$DB_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $DB_SECRETS_FILE_PATH
echo "$DB_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $RAS_SECRETS_FILE_PATH

