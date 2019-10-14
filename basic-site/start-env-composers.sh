#!/bin/bash

cd ..

DIR=$(pwd)
SERVICES_DIR="services"

GENERAL_CONFIGURATIONS=$DIR/"basic-site"
DATABASE_SERVICE_DIR=$SERVICES_DIR/"fogbow-database"
AUTHENTICATION_SERVICE_DIR=$SERVICES_DIR/"authentication-service"
RESOURCE_ALLOCATION_SERVICE_DIR=$SERVICES_DIR/"resource-allocation-service"
APACHE_SERVICE_DIR=$SERVICES_DIR/"apache-server"

SERVICES_LIST="$GENERAL_CONFIGURATIONS $DATABASE_SERVICE_DIR $AUTHENTICATION_SERVICE_DIR $RESOURCE_ALLOCATION_SERVICE_DIR $APACHE_SERVICE_DIR"

for service in $SERVICES_LIST; do
	echo ""
	echo "Running $service/env-composer.sh"
	echo ""
	bash $service/"env-composer.sh"
done
