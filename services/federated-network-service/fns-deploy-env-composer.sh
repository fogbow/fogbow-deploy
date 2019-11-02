#!/bin/bash

FNS_DEPLOY_CONF_FILE_NAME="site.conf"
SERVICE="federated-network-service"
CONF_FILE_NAME="fns.conf"
SHARED_INFO_FILE_NAME="shared.info"
SERVICES_CONF_FILE_NAME="services.conf"
APPLICATION_PROPERTIES_FILE_NAME="application.properties"
SECRETS_FILE_NAME="secrets"
CONF_FILE_TEMPLATE_DIR_PATH="./conf-files/"
BASE_DIR_PATH="services/"$SERVICE
CONF_FILE_DIR_PATH=$BASE_DIR_PATH/"conf-files"
FNS_SERVICE_DRIVER_DIR_PATH=$CONF_FILE_DIR_PATH/"services/vanilla"
FNS_SERVICE_DRIVER_FILE_NAME="driver.conf"
CONTAINER_BASE_DIR_PATH="/root"/$SERVICE
CONTAINER_CONF_FILES_DIR="src/main/resources/private"

# Copy configuration files
mkdir -p $CONF_FILE_DIR_PATH
## Copy fns.conf
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$CONF_FILE_NAME $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
## Copy shared info
yes | cp -f "./services"/$SHARED_INFO_FILE_NAME $CONF_FILE_DIR_PATH/$SHARED_INFO_FILE_NAME
## Copy services file
yes | cp -f $CONF_FILE_TEMPLATE_DIR_PATH/$SERVICES_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$SERVICES_CONF_FILE_NAME
## Copy application.properties file
yes | cp -f $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME".example" $BASE_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME

# Edit configuration files

## application.properties will be edited from ras/application.properties at deployment time

## Edit fns.conf (part of fns.conf will be edited from ras.conf at deployment time)

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "provider_id=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "service_names=vanilla" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "xmpp_jid=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "xmpp_password=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "xmpp_server_ip=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "xmpp_c2c_port=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "xmpp_timeout=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "as_port=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "as_url=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "ras_port=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "ras_url=" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
PRIVATE_KEY_PATH=$CONF_FILE_DIR_PATH/"id_rsa"
PUBLIC_KEY_PATH=$CONF_FILE_DIR_PATH/"id_rsa.pub"
RSA_KEY_PATH=$CONF_FILE_DIR_PATH/"rsa_key.pem"

openssl genrsa -out $RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
chmod 600 $PRIVATE_KEY_PATH
rm $RSA_KEY_PATH

echo "public_key_file_path="$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILES_DIR/"id_rsa.pub" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "private_key_file_path="$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILES_DIR/"id_rsa" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

echo "" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME
echo "jdbc_database_url=jdbc:sqlite:/root/federated-network-service/fns.db" >> $CONF_FILE_DIR_PATH/$CONF_FILE_NAME

## Create and edit services/vanilla/driver.conf

mkdir -p $FNS_SERVICE_DRIVER_DIR_PATH
touch $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME

echo "driver_class_name=cloud.fogbow.fns.core.drivers.vanilla.VanillaServiceDriver" >> $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME
echo "" >> $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME

VANILLA_AGENT_PRIVATE_IP_PATTERN="vanilla_agent_private_ip"
VANILLA_AGENT_PRIVATE_IP=$(grep $VANILLA_AGENT_PRIVATE_IP_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$FNS_DEPLOY_CONF_FILE_NAME | awk -F "=" '{print $2}')
echo "federated_network_agent_private_address=$VANILLA_AGENT_PRIVATE_IP" >> $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME

VANILLA_AGENT_PUBLIC_IP_PATTERN="vanilla_agent_public_ip"
VANILLA_AGENT_PUBLIC_IP=$(grep $VANILLA_AGENT_PUBLIC_IP_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$FNS_DEPLOY_CONF_FILE_NAME | awk -F "=" '{print $2}')
echo "federated_network_agent_public_address=$VANILLA_AGENT_PUBLIC_IP" >> $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME

PERMISSION_FILE_PATH=$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILES_DIR/"vanilla-agent-id_rsa"
echo "federated_network_agent_permission_file_path=$PERMISSION_FILE_PATH" >> $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME

REMOTE_USER_PATTERN="remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$FNS_DEPLOY_CONF_FILE_NAME | awk -F "=" '{print $2}')
echo "federated_network_agent_user=$REMOTE_USER" >> $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME

VPN_PASSWORD_KEY="vpn_password"
VPN_PASSWORD=$(grep $VPN_PASSWORD_KEY $CONF_FILE_DIR_PATH/$SECRETS_FILE_NAME | awk -F "=" '{print $2}')
echo "federated_network_agent_pre_shared_key=$VPN_PASSWORD" >> $FNS_SERVICE_DRIVER_DIR_PATH/$FNS_SERVICE_DRIVER_FILE_NAME
