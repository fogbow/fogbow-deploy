#!/bin/bash

DIR=$(pwd)
SERVICES_DIR="services"

XMPP_SERVICE_DIR=$SERVICES_DIR/"xmpp-server"
MEMBERSHIP_SERVICE_DIR=$SERVICES_DIR/"membership-service"
SERVICES_LIST="$XMPP_SERVICE_DIR $MEMBERSHIP_SERVICE_DIR"

echo ""
echo "Running federation/env-composer.sh"
bash env-composer.sh
cd ../..

for service in $SERVICES_LIST; do
	echo "Running $service/federation-env-composer.sh"
	bash $service/"federation-env-composer.sh"
done
