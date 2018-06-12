#!/bin/bash

CONF_FILE_PATH=$(pwd)/"conf-files"/"membership.conf"

MEMBERSHIP_CONF_FILE="membership.conf"
MEMBERSHIP_DIR="services/membership-service"

# Moving conf file to deployment directory
yes | cp -f $CONF_FILE_PATH ./$MEMBERSHIP_DIR/$MEMBERSHIP_CONF_FILE

