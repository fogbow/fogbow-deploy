#!/bin/bash

CONF_FILE_PATH=$1

MEMBERSHIP_CONF_FILE="membership.conf"
MEMBERSHIP_DIR="services/membership-service"

# Moving conf file to deployment directory
yes | cp -rf $CONF_FILE_PATH ./$MEMBERSHIP_DIR/$MEMBERSHIP_CONF_FILE

