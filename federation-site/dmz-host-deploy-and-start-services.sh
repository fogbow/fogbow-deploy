#!/bin/bash

BUILD_FILE_NAME="build"
WORK_DIR=$(pwd)
SERVICE_CONF_FILE_PATH="./conf-files/service.conf"

# Remove containers from earlier installation
sudo docker stop xmpp-server ipsec-server
sudo docker rm xmpp-server ipsec-server

# Create containers

#sudo docker run -tdi --name fogbow-apache \
#      -p $HTTP_PORT:80 \
#      -p $HTTPS_PORT:443 \
#      -v $WORK_DIR/conf-files/apache/site.crt:/etc/ssl/certs/site.crt \
#      -v $WORK_DIR/conf-files/apache/site.key:/etc/ssl/private/site.key \
#      -v $WORK_DIR/conf-files/apache/site.pem:/etc/ssl/certs/site.pem \
#      -v $WORK_DIR/conf-files/apache/ports.conf:/etc/apache2/ports.conf \
#      -v $WORK_DIR/conf-files/apache/000-default.conf:/etc/apache2/sites-available/000-default.conf \
#      -v $WORK_DIR/conf-files/apache/index.html:/var/www/html/index.html \
#      fogbow/apache-shibboleth-server:$APACHE_TAG

#sudo docker run -tdi --name fogbow-database \
#      -p $DB_PORT:5432 \
#      -e DB_USER="fogbow" \
#      -e DB_PASS="db_password" \
#      -e DB_NAME="ras" \
#      -e DB2_NAME="fns" \
#      -v $WORK_DIR/data:/var/lib/postgresql/data \
#      fogbow/database:$DB_TAG
