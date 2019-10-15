#!/bin/bash

DIR=$(pwd)
SERVICES_DIR="services"

DATABASE_SERVICE_DIR=$SERVICES_DIR/"fogbow-database"
AUTHENTICATION_SERVICE_DIR=$SERVICES_DIR/"authentication-service"
RESOURCE_ALLOCATION_SERVICE_DIR=$SERVICES_DIR/"resource-allocation-service"
APACHE_SERVICE_DIR=$SERVICES_DIR/"apache-server"

echo ""
echo "Running basic-site/env-composer.sh"
bash env-composer.sh

SERVICES_LIST="$DATABASE_SERVICE_DIR $AUTHENTICATION_SERVICE_DIR $RESOURCE_ALLOCATION_SERVICE_DIR $APACHE_SERVICE_DIR"

for service in $SERVICES_LIST; do
	echo ""
	echo "Running $service/env-composer.sh"
	cd ..
	bash $service/"env-composer.sh"
	cd $DIR
done
