#!/bin/bash

SERVICES_DIR_NAME="services"
GUI_SERVICE_DIR_PATH=$SERVICES_DIR_NAME/"fogbow-gui"
SERVICES_LIST="$GUI_SERVICE_DIR_PATH"

cd ../..

for service in $SERVICES_LIST; do
	bash $service/"gui-deploy-env-composer.sh"
done
