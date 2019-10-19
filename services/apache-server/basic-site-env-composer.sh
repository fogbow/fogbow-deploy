#!/bin/bash

SERVICE="apache-server"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_CONF_FILE_NAME="services.conf"
CERT_CONF_FILE_NAME="certificate-files.conf"
BASIC_SITE_CONF_FILE_NAME="basic-site.conf"
APACHE_CONF_DIR_NAME="apache-confs"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy apache conf files
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$APACHE_CONF_DIR_NAME/$CERT_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$CERT_CONF_FILE_NAME
## Copy shared info
yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME

# Resolving certification files for https
CERTIFICATE_FILE_PATTERN="SSL_certificate_file_path"
CERTIFICATE_FILE_PATH=$(grep $CERTIFICATE_FILE_PATTERN $CONF_FILE_DIR_PATH/$CERT_CONF_FILE_NAME | awk -F "=" '{print $2}')
CERTIFICATE_FILE_NAME=$(basename $CERTIFICATE_FILE_PATH)

CERTIFICATE_KEY_FILE_PATTERN="SSL_certificate_key_file_path"
CERTIFICATE_KEY_FILE_PATH=$(grep $CERTIFICATE_KEY_FILE_PATTERN $CONF_FILE_DIR_PATH/$CERT_CONF_FILE_NAME | awk -F "=" '{print $2}')
CERTIFICATE_KEY_FILE_NAME=$(basename $CERTIFICATE_KEY_FILE_PATH)

CERTIFICATE_CHAIN_FILE_PATTERN="SSL_certificate_chain_file_path"
CERTIFICATE_CHAIN_FILE_PATH=$(grep $CERTIFICATE_CHAIN_FILE_PATTERN $CONF_FILE_DIR_PATH/$CERT_CONF_FILE_NAME | awk -F "=" '{print $2}')
CERTIFICATE_CHAIN_FILE_NAME=$(basename $CERTIFICATE_CHAIN_FILE_PATH)

# Fill certificate files in virtual host
VIRTUAL_HOST_FILE_TEMPLATE="000-basic-site.conf.template"
VIRTUAL_HOST_FILE="000-default.conf"
yes | cp -f $BASE_DIR_PATH/$VIRTUAL_HOST_FILE_TEMPLATE $BASE_DIR_PATH/$VIRTUAL_HOST_FILE
SSL_DIR="/etc/ssl/private"
CERTS_DIR="/etc/ssl/certs"

CERTIFICATE_PATTERN="SSLCertificateFile"
sed -i "s#$CERTIFICATE_PATTERN.*#$CERTIFICATE_PATTERN $CERTS_DIR/$CERTIFICATE_FILE_NAME#" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

CERTIFICATE_KEY_PATTERN="SSLCertificateKeyFile"
sed -i "s#$CERTIFICATE_KEY_PATTERN.*#$CERTIFICATE_KEY_PATTERN $SSL_DIR/$CERTIFICATE_KEY_FILE_NAME#" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

CERTIFICATE_CHAIN_PATTERN="SSLCertificateChainFile"
sed -i "s#$CERTIFICATE_CHAIN_PATTERN.*#$CERTIFICATE_CHAIN_PATTERN $CERTS_DIR/$CERTIFICATE_CHAIN_FILE_NAME#" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

# Fill redirects and proxy configurations in vhost file

# replace basic_site_ip and provider_id
BASIC_SITE_IP_PATTERN="basic_site_ip"
BASIC_SITE_IP=$(grep $BASIC_SITE_IP_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$BASIC_SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')
PROVIDER_ID_PATTERN="provider_id"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$BASIC_SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

sed -i "s|$BASIC_SITE_HOST_IP_PATTERN|$BASIC_SITE_HOST_IP|g" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

# replace certificate files

CRT_FILE_PATTERN="crt_file"
sed -i "s|$CRT_FILE_PATTERN|$CERTIFICATE_FILE_NAME|g" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

KEY_FILE_PATTERN="key_file"
sed -i "s|$KEY_FILE_PATTERN|$CERTIFICATE_KEY_FILE_NAME|g" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

CHAIN_FILE_PATTERN="chain_file"
sed -i "s|$CHAIN_FILE_PATTERN|$CERTIFICATE_CHAIN_FILE_NAME|g" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

AS_PORT=$(grep ^as_port $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME | awk -F "=" '{print $2}')
AS_PORT_PATTERN="as_port"

RAS_PORT=$(grep ^ras_port $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME | awk -F "=" '{print $2}')
RAS_PORT_PATTERN="ras_port"

sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $BASE_DIR_PATH/$VIRTUAL_HOST_FILE

# Update documentation file
DOCUMENTATION_TEMPLATE_FILE="basic-site-index.html"
DOCUMENTATION_FILE="index.html"

yes | cp -f $BASE_DIR_PATH/$DOCUMENTATION_TEMPLATE_FILE $BASE_DIR_PATH/$DOCUMENTATION_FILE

sed -i "s|$BASIC_SITE_HOST_IP_PATTERN|$BASIC_SITE_HOST_IP|g" $BASE_DIR_PATH/$DOCUMENTATION_FILE
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $BASE_DIR_PATH/$DOCUMENTATION_FILE
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $BASE_DIR_PATH/$DOCUMENTATION_FILE
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $BASE_DIR_PATH/$DOCUMENTATION_FILE