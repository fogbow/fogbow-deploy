#!/bin/bash

CONF_FILES_PATH=$(pwd)/"conf-files"

MEMBERSHIP_CONF_FILE="ms.conf"
MEMBERSHIP_DIR="services/membership-service"
SERVICES_FILE="services.conf"

# Moving conf file to deployment directory
yes | cp -f $CONF_FILES_PATH/$MEMBERSHIP_CONF_FILE ./$MEMBERSHIP_DIR/$MEMBERSHIP_CONF_FILE

yes | cp -f $CONF_FILES_PATH/$SERVICES_FILE $MEMBERSHIP_DIR/$SERVICES_FILE

# Copy shared file
SHARED_INFO_PATH="services/conf-files"
SHARED_INFO="shared.info"
yes | cp -f $SHARED_INFO_PATH/$SHARED_INFO ./$MEMBERSHIP_DIR/$SHARED_INFO
