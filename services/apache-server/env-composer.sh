#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
BASE_DIR="services/apache-server"
CERT_CONF_FILES_DIR="cert-confs"

# Resolving certification files for https

echo "Copying certification files to service directory"
CERT_CONF_FILE="certificate-files.conf"
yes | cp -f $CERT_CONF_FILE $BASE_DIR/$CERT_CONF_FILE

CERTIFICATE_FILE="SSL_certificate_file_path"
CERTIFICATE_FILE_PATH=$(grep $CERTIFICATE_FILE $CONF_FILES_DIR/$CERT_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_FILE_NAME=$(basename $CERTIFICATE_FILE_PATH)
yes | cp -f $CERTIFICATE_FILE_PATH $BASE_DIR/$CERTIFICATE_FILE_NAME

CERTIFICATE_KEY_FILE="SSL_certificate_key_file_path"
CERTIFICATE_KEY_FILE_PATH=$(grep $CERTIFICATE_KEY_FILE $CONF_FILES_DIR/$CERT_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_KEY_FILE_NAME=$(basename $CERTIFICATE_KEY_FILE_PATH)
yes | cp -f $CERTIFICATE_KEY_FILE_PATH $BASE_DIR/$CERTIFICATE_KEY_FILE_NAME

CERTIFICATE_CHAIN_FILE="SSL_certificate_chain_file_path"
CERTIFICATE_CHAIN_FILE_PATH=$(grep $CERTIFICATE_CHAIN_FILE $CONF_FILES_DIR/$CERT_CONF_FILES_DIR/$CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_CHAIN_FILE_NAME=$(basename $CERTIFICATE_CHAIN_FILE_PATH)
yes | cp -f $CERTIFICATE_CHAIN_FILE_PATH $BASE_DIR/$CERTIFICATE_CHAIN_FILE_NAME

# Fill virtual host file

VIRTUAL_HOST_FILE="000-default.conf"
yes | cp -f $BASE_DIR/$VIRTUAL_HOST_FILE'.example' $BASE_DIR/$VIRTUAL_HOST_FILE
SSL_DIR="/etc/ssl/private"

CERTIFICATE_PATTERN="SSLCertificateFile"
sed -i "s#$CERTIFICATE_PATTERN.*#$CERTIFICATE_PATTERN $SSL_DIR/$CERTIFICATE_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_KEY_PATTERN="SSLCertificateKeyFile"
sed -i "s#$CERTIFICATE_KEY_PATTERN.*#$CERTIFICATE_KEY_PATTERN $SSL_DIR/$CERTIFICATE_KEY_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

CERTIFICATE_CHAIN_PATTERN="SSLCertificateChainFile"
sed -i "s#$CERTIFICATE_CHAIN_PATTERN.*#$CERTIFICATE_CHAIN_PATTERN $SSL_DIR/$CERTIFICATE_CHAIN_FILE_NAME#" $BASE_DIR/$VIRTUAL_HOST_FILE

# Moving cert conf files

CONF_FILES_LIST=$(find $CONF_FILES_DIR/$CERT_CONF_FILES_DIR | grep '.conf' | xargs)

for conf_file_path in $CONF_FILES_LIST; do
	conf_file_name=$(basename $conf_file_path)
	echo "Conf file path: $conf_file_path"
	echo "Conf file name: $conf_file_name"
	yes | cp -f $conf_file_path ./$BASE_DIR/$conf_file_name
done
