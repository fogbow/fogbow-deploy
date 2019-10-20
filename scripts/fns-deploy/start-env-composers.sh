#!/bin/bash

SERVICES_DIR_NAME="services"
VANILLA_AGENT_DIR_PATH=$SERVICES_DIR_NAME/"federated-network-agent"
FNS_DIR_PATH=$SERVICES_DIR_NAME/"federated-network-service"
SERVICES_LIST="$VANILLA_AGENT_DIR_PATH $FNS_DIR_PATH"

bash env-composer.sh
cd ../..

for service in $SERVICES_LIST; do
	bash $service/"fns-deploy-env-composer.sh"
done
