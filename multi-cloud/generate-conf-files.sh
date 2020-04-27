#!/bin/bash

# Source configuration files
SERVICE_CONF_FILE_PATH="./multi-cloud.conf"
HOST_CONF_FILE_PATH="./host.conf"
TEMPLATES_DIR_PATH="../templates"

# Ports configuration
AS_PORT_PATTERN="As_port"
RAS_PORT_PATTERN"Ras_port"
AS_PORT="8080"
RAS_PORT="8082"

# Apache variables
APACHE_DIR_PATH="../conf-files/apache"
APACHE_VHOST_FILE_NAME="000-default.conf"
ROOT_WWW_FILE_NAME="index.html"
CERTIFICATE_FILE_PATH="../conf-files/certs/site.crt"
CERTIFICATE_KEY_FILE_PATH="../conf-files/certs/site.key"
CERTIFICATE_CHAIN_FILE_PATH="../conf-files/certs/site.pem"

# Apache conf-file generation

## Getting data from host.conf
SERVICE_HOST_IP_PATTERN="service_host_ip"
SERVICE_HOST_IP=$(grep $SERVICE_HOST_IP_PATTERN $HOST_CONF_FILE_PATH | awk -F "=" '{print $2}')
PROVIDER_ID_PATTERN="service_host_DNS"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $HOST_CONF_FILE_PATH | awk -F "=" '{print $2}')

## Creating directory
mkdir -p $APACHE_DIR_PATH

## Copying certificate files
yes | cp -f $CERTIFICATE_FILE_PATH $APACHE_DIR_PATH/"site.crt"
yes | cp -f $CERTIFICATE_KEY_FILE_PATH $APACHE_DIR_PATH/"site.key"
yes | cp -f $CERTIFICATE_CHAIN_FILE_PATH $APACHE_DIR_PATH/"site.pem"

## Generating Virtual Host file
yes | cp -f $TEMPLATES_DIR_PATH/$VIRTUAL_HOST_FILE_NAME $APACHE_DIR_PATH/$VIRTUAL_HOST_FILE_NAME
sed -i "s|$SERVICE_HOST_IP_PATTERN|$SERVICE_HOST_IP|g" $APACHE_DIR_PATH/$VIRTUAL_HOST_FILE_NAME
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $APACHE_DIR_PATH/$VIRTUAL_HOST_FILE_NAME
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $APACHE_DIR_PATH/$VIRTUAL_HOST_FILE_NAME
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $APACHE_DIR_PATH/$VIRTUAL_HOST_FILE_NAME

## Generating index.html
yes | cp -f $TEMPLATES_DIR_PATH/$ROOT_WWW_FILE_NAME $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$SERVICE_HOST_IP_PATTERN|$SERVICE_HOST_IP|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME

# AS conf-file generation

