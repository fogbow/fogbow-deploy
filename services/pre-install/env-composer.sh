#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
CONF_FILES_DIR_NAME="conf-files"
BASE_DIR="services/apache-server"
APACHE_CONF_FILES_DIR="apache-confs"

GUI_CONF_DIR="gui-confs"
GUI_CONF_FILE="gui.conf"

CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILES_DIR/$GUI_CONF_DIR/$GUI_CONF_FILE | awk -F "=" '{print $2}')

# SHIBBOLETH SCENARY
if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
  SHARED_FOLDER_NAME="shared-folder"
  SHARED_FOLDER_DIR=$DIR/"services"/$CONF_FILES_DIR_NAME/$SHARED_FOLDER_NAME
  mkdir -p $SHARED_FOLDER_DIR

  SHIB_RAS_PEM_NAME="rsa_key_shibboleth.pem"
  SHIB_PRIVATE_KEY_NAME="shibboleth_authentication_application_private_key.pem"
  SHIB_PUBLIC_KEY_NAME="shibboleth_authentication_application_public_key.pem"  

  openssl genrsa -out $SHARED_FOLDER_DIR/$SHIB_RAS_PEM_NAME 1024
  openssl pkcs8 -topk8 -in $SHARED_FOLDER_DIR/$SHIB_RAS_PEM_NAME -out $SHARED_FOLDER_DIR/$SHIB_PRIVATE_KEY_NAME -nocrypt
  openssl rsa -in $SHARED_FOLDER_DIR/$SHIB_PRIVATE_KEY_NAME -outform PEM -pubout -out $SHARED_FOLDER_DIR/$SHIB_PUBLIC_KEY_NAME
  chmod 600 $SHARED_FOLDER_DIR/$SHIB_PRIVATE_KEY_NAME
  rm $SHARED_FOLDER_DIR/$SHIB_RAS_PEM_NAME
fi
