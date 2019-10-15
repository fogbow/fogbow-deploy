#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
CONF_FILES_DIR_NAME="conf-files"
BASE_DIR="services/apache-server"
APACHE_CONF_FILES_DIR="apache-confs"

# Copying configuration files
echo "Copying services.conf to service directory"
SERVICES_FILE="services.conf"
yes | cp -f $CONF_FILES_DIR/$SERVICES_FILE $BASE_DIR/$SERVICES_FILE
# Copy shared file
SHARED_INFO="shared.info"
yes | cp -f $DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_INFO $BASE_DIR/$SHARED_INFO

# Moving apache conf files

CONF_FILES_LIST=$(find $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR | grep '.conf' | xargs)

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$BASE_DIR/$conf_file_name
done

# Resolving certification files for https
CERT_CONF_FILE="certificate-files.conf"

CERTIFICATE_FILE="SSL_certificate_file_path"
CERTIFICATE_FILE_PATH=$(grep $CERTIFICATE_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_FILE_NAME=$(basename $CERTIFICATE_FILE_PATH)

CERTIFICATE_KEY_FILE="SSL_certificate_key_file_path"
CERTIFICATE_KEY_FILE_PATH=$(grep $CERTIFICATE_KEY_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_KEY_FILE_NAME=$(basename $CERTIFICATE_KEY_FILE_PATH)

CERTIFICATE_CHAIN_FILE="SSL_certificate_chain_file_path"
CERTIFICATE_CHAIN_FILE_PATH=$(grep $CERTIFICATE_CHAIN_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_CHAIN_FILE_NAME=$(basename $CERTIFICATE_CHAIN_FILE_PATH)

# Fill certificate files in virtual host
VIRTUAL_HOST_FILE_TEMPLATE="000-basic-site.conf.template"
VIRTUAL_HOST_FILE="000-default.conf"
yes | cp -f $BASE_DIR/$VIRTUAL_HOST_FILE_TEMPLATE $BASE_DIR/$VIRTUAL_HOST_FILE
SSL_DIR="/etc/ssl/private"
CERTS_DIR="/etc/ssl/certs"

CERTIFICATE_PATTERN="SSLCertificateFile"
sed -i "s#$CERTIFICATE_PATTERN.*#$CERTIFICATE_PATTERN $CERTS_DIR/$CERTIFICATE_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_KEY_PATTERN="SSLCertificateKeyFile"
sed -i "s#$CERTIFICATE_KEY_PATTERN.*#$CERTIFICATE_KEY_PATTERN $SSL_DIR/$CERTIFICATE_KEY_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_CHAIN_PATTERN="SSLCertificateChainFile"
sed -i "s#$CERTIFICATE_CHAIN_PATTERN.*#$CERTIFICATE_CHAIN_PATTERN $CERTS_DIR/$CERTIFICATE_CHAIN_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

# Fill redirects and proxy configurations in vhost file

# replace internal-host-ip
HOST_CONF="hosts.conf"
BASIC_SITE_HOST_IP_PATTERN="basic_site_host_ip"
BASIC_SITE_HOST_IP=$(grep $BASIC_SITE_HOST_IP_PATTERN $CONF_FILES_DIR/$HOST_CONF | awk -F "=" '{print $2}')

INTERNAL_HOST_IP_PATTERN="internal_host_private_ip"
sed -i "s|$INTERNAL_HOST_IP_PATTERN|$BASIC_SITE_HOST_IP|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace internal-host-name
INTERNAL_HOST_NAME_PATTERN="internal_host_name"
BASIC_SITE_DOMAIN_NAME_PATTERN="ras_domain_name"
DOMAIN_NAME_CONF_FILE="domain-names.conf"
DOMAIN_NAME=$(grep -w $BASIC_SITE_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')
DOMAIN_BASENAME=`basename $(dirname $DOMAIN_NAME)`

sed -i "s|$INTERNAL_HOST_NAME_PATTERN|$DOMAIN_BASENAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace certificate files

CRT_FILE_PATTERN="crt_file"
sed -i "s|$CRT_FILE_PATTERN|$CERTIFICATE_FILE_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

KEY_FILE_PATTERN="key_file"
sed -i "s|$KEY_FILE_PATTERN|$CERTIFICATE_KEY_FILE_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

CHAIN_FILE_PATTERN="chain_file"
sed -i "s|$CHAIN_FILE_PATTERN|$CERTIFICATE_CHAIN_FILE_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

AS_PORT=$(grep ^as_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
AS_PORT_PATTERN="as_port"

RAS_PORT=$(grep ^ras_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
RAS_PORT_PATTERN="ras_port"

sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $BASE_DIR/$VIRTUAL_HOST_FILE
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# Update documentation file
DOCUMENTATION_FILE_TEMPLATE="basic-site-index.html"
DOCUMENTATION_FILE="index.html"

yes | cp $BASE_DIR/$DOCUMENTATION_TEMPLATE_FILE $BASE_DIR/$DOCUMENTATION_FILE

sed -i "s|$INTERNAL_HOST_IP_PATTERN|$BASIC_SITE_HOST_IP|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$INTERNAL_HOST_NAME_PATTERN|$DOMAIN_BASENAME|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $BASE_DIR/$DOCUMENTATION_FILE
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $BASE_DIR/$DOCUMENTATION_FILE