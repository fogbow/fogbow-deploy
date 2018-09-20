#!/bin/bash

CONF_FILES_PATH=$(pwd)/"conf-files"

MEMBERSHIP_CONF_FILE="membership.conf"
MEMBERSHIP_DIR="services/membership-service"
SERVICES_FILE="services.conf"

# Moving conf file to deployment directory
yes | cp -f $CONF_FILES_PATH/$MEMBERSHIP_CONF_FILE ./$MEMBERSHIP_DIR/$MEMBERSHIP_CONF_FILE

yes | cp -f $CONF_FILES_PATH/$SERVICES_FILE $MEMBERSHIP_DIR/$SERVICES_FILE