#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/fogbow-database/"

# Copying service.conf file
echo "Copying services.conf to service directory"
SERVICES_FILE="services.conf"
yes | cp -f $CONF_FILES_DIR/$SERVICES_FILE $BASE_DIR/$SERVICES_FILE

# Copy shared file
SECRETS="secrets"
yes | cp -f $CONF_FILES_DIR/$SECRETS $BASE_DIR/$SECRETS
