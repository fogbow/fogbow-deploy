#!/bin/bash
DIR_PATH=$(pwd)
CONF_FILES_DIR=$DIR_PATH

GUI_CONF_DIR="gui-confs"
GUI_CONF_FILE="gui.conf"

# TODO create new image
IMAGE_NAME="fogbow/apache-shibboleth-server"
CONTAINER_NAME="apache-server"

INSECURE_PORT="80"
SECURE_PORT="443"

# Certificate files
## All fogbow environment
CERT_CONF_FILE="certificate-files.conf"

CERTIFICATE_FILE="SSL_certificate_file_path"
CERTIFICATE_FILE_PATH=$(grep $CERTIFICATE_FILE $CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_FILE_NAME=$(basename $CERTIFICATE_FILE_PATH)

CERTIFICATE_KEY_FILE="SSL_certificate_key_file_path"
CERTIFICATE_KEY_FILE_PATH=$(grep $CERTIFICATE_KEY_FILE $CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_KEY_FILE_NAME=$(basename $CERTIFICATE_KEY_FILE_PATH)

CERTIFICATE_CHAIN_FILE="SSL_certificate_chain_file_path"
CERTIFICATE_CHAIN_FILE_PATH=$(grep $CERTIFICATE_CHAIN_FILE $CERT_CONF_FILE | awk -F "=" '{print $2}')
CERTIFICATE_CHAIN_FILE_NAME=$(basename $CERTIFICATE_CHAIN_FILE_PATH)

CONF_FILE_NAME="api.config.js"
AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $DIR_PATH/$GUI_CONF_FILE | awk -F "=" '{print $2}')
if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
  SHIBBOLETH_CONF_FILE="shibboleth.conf"

  ## Shibbolethh
  SERVICE_PROVIDER_CERTIFICATE_FILE="certificate_service_provider_path"
  SERVICE_PROVIDER_CERTIFICATE_FILE_PATH=$(grep $SERVICE_PROVIDER_CERTIFICATE_FILE $SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')
  SERVICE_PROVIDER_CERTIFICATE_FILE_NAME=$(basename $SERVICE_PROVIDER_CERTIFICATE_FILE_PATH)

  SERVICE_PROVIDER_CERTIFICATE_KEY_FILE="key_service_provider_path"
  SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATH=$(grep $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE $SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')
  SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME=$(basename $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_PATH)

  SERVICE_PROVIDER_DOMAIN="domain_service_provider"
  SERVICE_PROVIDER_DOMAIN_NAME=$(grep $SERVICE_PROVIDER_DOMAIN $SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')
fi

CERTS_DIR="/etc/ssl/certs"
SSL_DIR="/etc/ssl/private"
VIRTUAL_HOST_DIR="/etc/apache2/sites-enabled"
ROOT_DIR="/var/www/html"
CONF_DIR="/etc/apache2"
INDEX_FILE="index.html"
PORTS_FILE="ports.conf"
VIRTUAL_HOST_FILE="000-default.conf"
if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
  SHIBBOLETH_CONF_DIR="/etc/shibboleth"
  SHIBBOLETH_AUTHENTICATION_APPLICATION_DIR="/home/ubuntu/shibboleth-authentication-application"
  SECURE_INDEX_PATH="/var/www/secure/index.html"
  VIRTUAL_HOST_SHIBBOLETH_ENVIRONMENT_80_FILE="default.conf"
  VIRTUAL_HOST_SHIBBOLETH_ENVIRONMENT_443_FILE="shibboleth-sp2.conf"
  CONFIGURATION_SHIBBOLETH_ENVIRONMENT_ATTRIBUTES_MAP_FILE="attribute-map.xml"
  CONFIGURATION_SHIBBOLETH_ENVIRONMENT_ATTRIBUTES_POLICY_FILE="attribute-policy.xml"
  CONFIGURATION_SHIBBOLETH_ENVIRONMENT_SHIBBOLETH_XML_FILE="shibboleth2.xml"
  CONFIGURATION_SHIBBOLETH_ENVIRONMENT_INDEX_SECURE_FILE="index-secure.html"
  SHIBBOLETH_AUTHENTICATION_APPLICATION_CONFIGURATION_FILE="shibboleth-authentication-application.conf"
  SHIBBOLETH_AUTHENTICATION_APPLICATION_LOG4J_FILE="log4j.properties"
  AS_PUBLIC_KEY_NAME='authentication_service_public_key.pem'
  SHIB_PRIVATE_KEY_NAME='shibboleth_authentication_application_private_key.pem'
fi

SERVICES_CONF=$DIR_PATH/"services.conf"
IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE_NAME:$TAG

CONTAINER_BASE_DIR="/home/ubuntu"
SHARED_FOLDER="shared-folder"
sudo docker run -tdi --name $CONTAINER_NAME \
	-p $SECURE_PORT:$SECURE_PORT \
	-p $INSECURE_PORT:$INSECURE_PORT \
	-v $DIR_PATH/$CERTIFICATE_FILE_NAME:$CERTS_DIR/$CERTIFICATE_FILE_NAME \
	-v $DIR_PATH/$CERTIFICATE_KEY_FILE_NAME:$SSL_DIR/$CERTIFICATE_KEY_FILE_NAME \
	-v $DIR_PATH/$CERTIFICATE_CHAIN_FILE_NAME:$CERTS_DIR/$CERTIFICATE_CHAIN_FILE_NAME \
	$IMAGE_NAME:$TAG

sudo docker cp $VIRTUAL_HOST_FILE $CONTAINER_NAME:$VIRTUAL_HOST_DIR/$VIRTUAL_HOST_FILE
sudo docker cp $INDEX_FILE $CONTAINER_NAME:$ROOT_DIR
sudo docker cp $PORTS_FILE $CONTAINER_NAME:$CONF_DIR

# Shibboleth
if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
  sudo docker cp $VIRTUAL_HOST_SHIBBOLETH_ENVIRONMENT_80_FILE $CONTAINER_NAME:$VIRTUAL_HOST_DIR/$VIRTUAL_HOST_SHIBBOLETH_ENVIRONMENT_80_FILE
  sudo docker cp $VIRTUAL_HOST_SHIBBOLETH_ENVIRONMENT_443_FILE $CONTAINER_NAME:$VIRTUAL_HOST_DIR/$VIRTUAL_HOST_SHIBBOLETH_ENVIRONMENT_443_FILE
  sudo docker cp $CONFIGURATION_SHIBBOLETH_ENVIRONMENT_ATTRIBUTES_MAP_FILE $CONTAINER_NAME:$SHIBBOLETH_CONF_DIR/$CONFIGURATION_SHIBBOLETH_ENVIRONMENT_ATTRIBUTES_MAP_FILE
  sudo docker cp $CONFIGURATION_SHIBBOLETH_ENVIRONMENT_SHIBBOLETH_XML_FILE $CONTAINER_NAME:$SHIBBOLETH_CONF_DIR/$CONFIGURATION_SHIBBOLETH_ENVIRONMENT_SHIBBOLETH_XML_FILE
  sudo docker cp $CONFIGURATION_SHIBBOLETH_ENVIRONMENT_ATTRIBUTES_POLICY_FILE $CONTAINER_NAME:$SHIBBOLETH_CONF_DIR/$CONFIGURATION_SHIBBOLETH_ENVIRONMENT_ATTRIBUTES_POLICY_FILE
  sudo docker exec -it $CONTAINER_NAME mkdir -p /var/www/secure
  sudo docker cp $CONFIGURATION_SHIBBOLETH_ENVIRONMENT_INDEX_SECURE_FILE $CONTAINER_NAME:$SECURE_INDEX_PATH
  sudo docker cp $SHIBBOLETH_AUTHENTICATION_APPLICATION_CONFIGURATION_FILE $CONTAINER_NAME:$SHIBBOLETH_AUTHENTICATION_APPLICATION_DIR
  sudo docker cp $SHIBBOLETH_AUTHENTICATION_APPLICATION_LOG4J_FILE $CONTAINER_NAME:$SHIBBOLETH_AUTHENTICATION_APPLICATION_DIR
  sudo docker exec -it $CONTAINER_NAME sed "s/#DAEMON_USER=_shibd/DAEMON_USER=root/g" /etc/init.d/shibd  

  sudo docker cp $SERVICE_PROVIDER_CERTIFICATE_FILE_NAME $CONTAINER_NAME:$CERTS_DIR/$SERVICE_PROVIDER_DOMAIN_NAME.crt
  sudo docker cp $SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME $CONTAINER_NAME:$SSL_DIR/$SERVICE_PROVIDER_DOMAIN_NAME.key
  sudo docker cp $SHARED_FOLDER/. $CONTAINER_NAME:$CONTAINER_BASE_DIR/$SHARED_FOLDER
fi

ENABLE_MODULES_SCRIPT="enable-modules"

sudo chmod +x $ENABLE_MODULES_SCRIPT
sudo docker cp $ENABLE_MODULES_SCRIPT $CONTAINER_NAME:$CONTAINER_BASE_PATH/$ENABLE_MODULES_SCRIPT
sudo docker exec $CONTAINER_NAME $CONTAINER_BASE_PATH/$ENABLE_MODULES_SCRIPT

if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
  sudo docker exec $CONTAINER_NAME /bin/bash -c "bash bin/start-shib-app.sh" &
fi
