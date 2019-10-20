#!/bin/bash

SERVICES_DIR_NAME="services"
DATABASE_SERVICE_DIR=$SERVICES_DIR_NAME/"fogbow-database"
AS_DIR_PATH=$SERVICES_DIR_NAME/"authentication-service"
RAS_DIR_PATH=$SERVICES_DIR_NAME/"resource-allocation-service"
APACHE_SERVER_DIR_PATH=$SERVICES_DIR_NAME/"apache-server"

bash env-composer.sh
cd ../..

SERVICES_LIST="$DATABASE_SERVICE_DIR $AS_DIR_PATH $RAS_DIR_PATH $APACHE_SERVER_DIR_PATH"

for service in $SERVICES_LIST; do
	bash $service/"basic-site-env-composer.sh"
done
