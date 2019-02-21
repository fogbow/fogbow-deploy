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
yes | cp -f $DIR/$CONF_FILES_DIR_NAME/$SHARED_INFO $BASE_DIR/$SHARED_INFO

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

VIRTUAL_HOST_FILE="000-default.conf"
yes | cp -f $BASE_DIR/$VIRTUAL_HOST_FILE'.example' $BASE_DIR/$VIRTUAL_HOST_FILE
SSL_DIR="/etc/ssl/private"

CERTIFICATE_PATTERN="SSLCertificateFile"
sed -i "s#$CERTIFICATE_PATTERN.*#$CERTIFICATE_PATTERN $SSL_DIR/$CERTIFICATE_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_KEY_PATTERN="SSLCertificateKeyFile"
sed -i "s#$CERTIFICATE_KEY_PATTERN.*#$CERTIFICATE_KEY_PATTERN $SSL_DIR/$CERTIFICATE_KEY_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_CHAIN_PATTERN="SSLCertificateChainFile"
sed -i "s#$CERTIFICATE_CHAIN_PATTERN.*#$CERTIFICATE_CHAIN_PATTERN $SSL_DIR/$CERTIFICATE_CHAIN_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

# Fill redirects and proxy configurations in vhost file

DOMAIN_NAME_CONF_FILE="domain-names.conf"

# replace dashboard-domain-name
DASHBOARD_DOMAIN_NAME_PATTERN="dashboard_domain_name"
DASHBOARD_DOMAIN_NAME=$(grep -w $DASHBOARD_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$DASHBOARD_DOMAIN_NAME_PATTERN|$DASHBOARD_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace fns-domain-name
FNS_DOMAIN_NAME_PATTERN="fns_domain_name"
FNS_DOMAIN_NAME=$(grep -w $FNS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$FNS_DOMAIN_NAME_PATTERN|$FNS_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace ras-domain-name
RAS_DOMAIN_NAME_PATTERN="ras_domain_name"
RAS_DOMAIN_NAME=$(grep -w $RAS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$RAS_DOMAIN_NAME_PATTERN|$RAS_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace as-domain-name
AS_DOMAIN_NAME_PATTERN="as_domain_name"
AS_DOMAIN_NAME=$(grep -w $AS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$AS_DOMAIN_NAME_PATTERN|$AS_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace ms-domain-name
MS_DOMAIN_NAME_PATTERN="ms_domain_name"
MS_DOMAIN_NAME=$(grep -w $MS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$MS_DOMAIN_NAME_PATTERN|$MS_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace dashboard-basename
DASHBOARD_BASENAME_PATTERN="dashboard_basename"
DASHBOARD_BASENAME=$(basename $DASHBOARD_DOMAIN_NAME)
sed -i "s/$DASHBOARD_BASENAME_PATTERN\b/$DASHBOARD_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace fns-basename
FNS_BASENAME_PATTERN="fns_basename"
FNS_BASENAME=$(basename $FNS_DOMAIN_NAME)
sed -i "s/$FNS_BASENAME_PATTERN\b/$FNS_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace ras-basename
RAS_BASENAME_PATTERN="ras_basename"
RAS_BASENAME=$(basename $RAS_DOMAIN_NAME)
sed -i "s/$RAS_BASENAME_PATTERN\b/$RAS_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace as-basename
AS_BASENAME_PATTERN="as_basename"
AS_BASENAME=$(basename $AS_DOMAIN_NAME)
sed -i "s/\<$AS_BASENAME_PATTERN\>/$AS_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace ms-basename
MS_BASENAME_PATTERN="ms_basename"
MS_BASENAME=$(basename $MS_DOMAIN_NAME)
sed -i "s/$MS_BASENAME_PATTERN\b/$MS_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace internal-host-ip
HOST_CONF="hosts.conf"
INTERNAL_HOST_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $INTERNAL_HOST_IP_PATTERN $CONF_FILES_DIR/$HOST_CONF | awk -F "=" '{print $2}')

sed -i "s|$INTERNAL_HOST_IP_PATTERN|http://$INTERNAL_HOST_IP|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# Get and replace services port
GUI_PORT=$(grep ^gui_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
DASHBOARD_PORT_PATTERN="dashboard_port"
sed -i "s/$DASHBOARD_PORT_PATTERN\b/$GUI_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE

FNS_PORT=$(grep ^fns_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
FNS_PORT_PATTERN="fns_port"
sed -i "s/$FNS_PORT_PATTERN\b/$FNS_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE

AS_PORT=$(grep ^as_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
AS_PORT_PATTERN="as_port"
sed -i "s/\<$AS_PORT_PATTERN\>/$AS_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE

RAS_PORT=$(grep ^ras_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
RAS_PORT_PATTERN="ras_port"
sed -i "s/$RAS_PORT_PATTERN\b/$RAS_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE

MS_PORT=$(grep ^ms_port $BASE_DIR/$SHARED_INFO | awk -F "=" '{print $2}')
MS_PORT_PATTERN="ms_port"
sed -i "s/$MS_PORT_PATTERN\b/$MS_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE
