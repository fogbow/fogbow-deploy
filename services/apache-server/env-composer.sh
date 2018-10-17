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
yes | cp -f $CERTIFICATE_FILE_PATH $BASE_DIR/$CERTIFICATE_FILE_NAME

CERTIFICATE_KEY_FILE="SSL_certificate_key_file_path"
CERTIFICATE_KEY_FILE_PATH=$(grep $CERTIFICATE_KEY_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_KEY_FILE_NAME=$(basename $CERTIFICATE_KEY_FILE_PATH)
yes | cp -f $CERTIFICATE_KEY_FILE_PATH $BASE_DIR/$CERTIFICATE_KEY_FILE_NAME

CERTIFICATE_CHAIN_FILE="SSL_certificate_chain_file_path"
CERTIFICATE_CHAIN_FILE_PATH=$(grep $CERTIFICATE_CHAIN_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_CHAIN_FILE_NAME=$(basename $CERTIFICATE_CHAIN_FILE_PATH)
yes | cp -f $CERTIFICATE_CHAIN_FILE_PATH $BASE_DIR/$CERTIFICATE_CHAIN_FILE_NAME

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
DASHBOARD_DOMAIN_NAME=$(grep $DASHBOARD_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$DASHBOARD_DOMAIN_NAME_PATTERN|$DASHBOARD_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace fns-domain-name
FNS_DOMAIN_NAME_PATTERN="fns_domain_name"
FNS_DOMAIN_NAME=$(grep $FNS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$FNS_DOMAIN_NAME_PATTERN|$FNS_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace ms-domain-name
MS_DOMAIN_NAME_PATTERN="ms_domain_name"
MS_DOMAIN_NAME=$(grep $MS_DOMAIN_NAME_PATTERN $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAME_CONF_FILE | awk -F "=" '{print $2}')

sed -i "s|$MS_DOMAIN_NAME_PATTERN|$MS_DOMAIN_NAME|g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace dashboard-basename
DASHBOARD_BASENAME_PATTERN="dashboard_basename"
DASHBOARD_BASENAME=$(basename $DASHBOARD_DOMAIN_NAME)
sed -i "s/$DASHBOARD_BASENAME_PATTERN\b/$DASHBOARD_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace fns-basename
FNS_BASENAME_PATTERN="fns_basename"
FNS_BASENAME=$(basename $FNS_DOMAIN_NAME)
sed -i "s/$FNS_BASENAME_PATTERN\b/$FNS_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace ms-basename
MS_BASENAME_PATTERN="ms_basename"
MS_BASENAME=$(basename $MS_DOMAIN_NAME)
sed -i "s/$MS_BASENAME_PATTERN\b/$MS_BASENAME/g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace internal-host-ip
HOST_CONF="hosts.conf"
INTERNAL_HOST_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_IP=$(grep $INTERNAL_HOST_IP_PATTERN $CONF_FILES_DIR/$HOST_CONF | awk -F "=" '{print $2}')

sed -i "s/$INTERNAL_HOST_IP_PATTERN\b/$INTERNAL_HOST_IP/g" $BASE_DIR/$VIRTUAL_HOST_FILE
# replace dashboard-port
RAS_CONF="ras.conf"
GUI_PORT_PATTERN="fogbow_gui_server_port"
GUI_PORT=$(grep $GUI_PORT_PATTERN $CONF_FILES_DIR/$RAS_CONF | awk -F "=" '{print $2}')

DASHBOARD_PORT_PATTERN="dashboard_port"
sed -i "s/$DASHBOARD_PORT_PATTERN\b/$GUI_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE

SERVER_PORT_PATTERN="server_port"
# replace fns-port
FNS_CONFS_DIR="ras-confs-to-fns"
FNS_CONF="fns.conf"
FNS_PORT=$(grep $SERVER_PORT_PATTERN $CONF_FILES_DIR/$FNS_CONFS_DIR/$FNS_CONF | awk -F "=" '{print $2}')

FNS_PORT_PATTERN="fns_port"
sed -i "s/$FNS_PORT_PATTERN\b/$FNS_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE

# replace ms-port
MS_CONF="membership.conf"
MS_PORT=$(grep $SERVER_PORT_PATTERN $CONF_FILES_DIR/$MS_CONF | awk -F "=" '{print $2}')

MS_PORT_PATTERN="ms_port"
sed -i "s/$MS_PORT_PATTERN\b/$MS_PORT/g" $BASE_DIR/$VIRTUAL_HOST_FILE
