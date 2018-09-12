#!/bin/bash

SERVICES_DIR="services"

DATABASE_SERVICE_DIR=$SERVICES_DIR/"fogbow-database"
MANAGER_SERVICE_DIR=$SERVICES_DIR/"resource-allocation-service"
REVERSE_TUNNEL_SERVICE_DIR=$SERVICES_DIR/"reverse-tunnel-service"
XMPP_SERVICE_DIR=$SERVICES_DIR/"xmpp-server"
MEMBERSHIP_SERVICE_DIR=$SERVICES_DIR/"membership-service"
DASHBOARD_SERVICE_DIR=$SERVICES_DIR/"fogbow-gui"
FEDNET_SERVICE_DIR=$SERVICES_DIR/"federated-network-service"
FEDNET_AGENT_DIR=$SERVICES_DIR/"federated-network-agent"

SERVICES_LIST="$DATABASE_SERVICE_DIR $MANAGER_SERVICE_DIR $REVERSE_TUNNEL_SERVICE_DIR $XMPP_SERVICE_DIR $MEMBERSHIP_SERVICE_DIR $DASHBOARD_SERVICE_DIR $FEDNET_SERVICE_DIR $FEDNET_AGENT_DIR"

for service in $SERVICES_LIST; do
	echo ""
	echo "Running $service/env-composer.sh"
	echo ""
	bash $service/"env-composer.sh"
done
