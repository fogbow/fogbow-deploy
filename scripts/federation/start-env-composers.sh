#!/bin/bash

DIR=$(pwd)
SERVICES_DIR_NAME="services"
XMPP_SERVER_PATH=$SERVICES_DIR_NAME/"xmpp-server"
MS_DIR_PATH=$SERVICES_DIR_NAME/"membership-service"
SERVICES_LIST="$XMPP_SERVER_PATH $MS_DIR_PATH"

bash env-composer.sh
cd ../..

for service in $SERVICES_LIST; do
	bash $service/"federation-env-composer.sh"
done
