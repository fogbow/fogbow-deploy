#!/bin/bash

# Source configuration files
SERVICE_CONF_FILE_PATH="./multi-cloud.conf"
HOST_CONF_FILE_PATH="./host.conf"
TEMPLATES_DIR_PATH="./conf-files/templates"

# Ports configuration
AS_PORT_PATTERN="As_port"
RAS_PORT_PATTERN="Ras_port"
AS_PORT="8080"
RAS_PORT="8082"

# Reading configuration files
## Reading data from host.conf
SERVICE_HOST_IP_PATTERN="service_host_ip"
SERVICE_HOST_IP=$(grep $SERVICE_HOST_IP_PATTERN $HOST_CONF_FILE_PATH | awk -F "=" '{print $2}')
PROVIDER_ID_PATTERN="service_host_DNS"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $HOST_CONF_FILE_PATH | awk -F "=" '{print $2}')
PROVIDER_ID_TAG="provider_id"
## Reading data from multi-cloud.conf
### Apache Shibboleth configuration
DSP_PATTERN="domain_service_provider"
DSP=$(grep $DSP_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
CSPP_PATTERN="certificate_service_provider_path"
CSPP=$(grep $CSPP_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
DSP_PATTERN="key_service_provider_path"
DSP=$(grep $DSP_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
DSU_PATTERN="discovery_service_url"
DSU=$(grep $DSU_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
DSMU_PATTERN="discovery_service_metadata_url"
DSMU=$(grep $DSMU_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
### AS configuration
SIP_PATTERN="system_identity_provider_plugin_class"
SIP=$(grep $SIP_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
OS_PATTERN="openstack_keystone_v3_url"
OS=$(grep $OS_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
CS_PATTERN="cloudstack_url"
CS=$(grep $CS_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
ONE_PATTERN="opennebula_url"
ONE=$(grep $ONE_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
LEP_PATTERN="ldap_endpoint"
LEP=$(grep $LEP_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
LB_PATTERN="ldap_base"
LB=$(grep $LB_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
LET_PATTERN="ldap_encrypt_type"
LET=$(grep $LET_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
SHIB_PATTERN="shib_public_key_file_path"
SHIB=$(grep $SHIB_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
## RAS configuration
CN_PATTERN="cloud_names"
CN=$(grep $CN_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
AUTH_PATTERN="authorization_plugin_class"
AUTH=$(grep $AUTH_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')
## GUI configuration
AT_PATTERN="authentication_type"
AT=$(grep $AT_PATTERN $SERVICE_CONF_FILE_PATH | awk -F "=" '{print $2}')

# Generating secrets
DB_PASSWORD_PROPERTY="db_password"
DB_PASSWORD=$(pwgen 10 1)

# Updating docker-compose.yml
DOCKER_COMPOSE_FILE="docker-compose.yml"
chmod 600 $DOCKER_COMPOSE_FILE
sed -i "s|DB_PASS|$DB_PASSWORD|g" $DOCKER_COMPOSE_FILE

# Apache conf-file generation
## Setting apache variables
APACHE_DIR_PATH="./conf-files/apache"
APACHE_VHOST_FILE_NAME="000-default.conf"
ROOT_WWW_FILE_NAME="index.html"
PORTS_FILE_PATH=$TEMPLATES_DIR_PATH/"ports.conf"
CERTIFICATE_FILE_PATH=$TEMPLATES_DIR_PATH/"certs/site.crt"
CERTIFICATE_KEY_FILE_PATH=$TEMPLATES_DIR_PATH/"certs/site.key"
CERTIFICATE_CHAIN_FILE_PATH=$TEMPLATES_DIR_PATH/"certs/site.pem"
## Creating directory
mkdir -p $APACHE_DIR_PATH
## Copying certificate files
yes | cp -f $CERTIFICATE_FILE_PATH $APACHE_DIR_PATH
yes | cp -f $CERTIFICATE_KEY_FILE_PATH $APACHE_DIR_PATH
yes | cp -f $CERTIFICATE_CHAIN_FILE_PATH $APACHE_DIR_PATH
## Copying ports.conf file
yes | cp -f $PORTS_FILE_PATH $APACHE_DIR_PATH
## Generating Virtual Host file
yes | cp -f $TEMPLATES_DIR_PATH/$APACHE_VHOST_FILE_NAME $APACHE_DIR_PATH
sed -i "s|$SERVICE_HOST_IP_PATTERN|$SERVICE_HOST_IP|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
## Generating index.html
yes | cp -f $TEMPLATES_DIR_PATH/$ROOT_WWW_FILE_NAME $APACHE_DIR_PATH
sed -i "s|$SERVICE_HOST_IP_PATTERN|$SERVICE_HOST_IP|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME

# AS conf-file generation
## Setting AS variables
AS_DIR_PATH="./conf-files/as"
AS_CONF_FILE_NAME="as.conf"
AS_CONTAINER_CONF_FILE_DIR_PATH="/root/authentication-service/src/main/resources/private"
AS_PRIVATE_KEY_PATH=$AS_DIR_PATH/"id_rsa"
AS_PUBLIC_KEY_PATH=$AS_DIR_PATH/"id_rsa.pub"
AS_RSA_KEY_PATH=$AS_DIR_PATH/"rsa_key.pem"
## Creating directory
mkdir -p $AS_DIR_PATH
touch $AS_DIR_PATH/$AS_CONF_FILE_NAME
chmod 600 $AS_DIR_PATH/$AS_CONF_FILE_NAME
## Adding properties
echo "# Authentication plugin specific properties" > $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $SIP_PATTERN=$SIP >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $OS_PATTERN=$OS >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $CS_PATTERN=$CS >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $ONE_PATTERN=$ONE >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $LEP_PATTERN=$LEP >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $LB_PATTERN=$LB >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $LET_PATTERN=$LET >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo "" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $PROVIDER_ID_TAG=$PROVIDER_ID >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
## Creating and adding key pair
echo "" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
openssl genrsa -out $AS_RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $AS_RSA_KEY_PATH -out $AS_PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $AS_PRIVATE_KEY_PATH -outform PEM -pubout -out $AS_PUBLIC_KEY_PATH
chmod 600 $AS_PRIVATE_KEY_PATH
rm $AS_RSA_KEY_PATH
echo "public_key_file_path="$AS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa.pub" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo "private_key_file_path="$AS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME

# RAS conf-file generation
## Setting AS variables
RAS_DIR_PATH="./conf-files/ras"
RAS_CONF_FILE_NAME="ras.conf"
CLOUDS_DIR_NAME="clouds"
APPLICATION_PROPERTIES_FILE_NAME="application.properties"
RAS_CONTAINER_CONF_FILE_DIR_PATH="/root/resource-allocation-service/src/main/resources/private"
RAS_PRIVATE_KEY_PATH=$RAS_DIR_PATH/"id_rsa"
RAS_PUBLIC_KEY_PATH=$RAS_DIR_PATH/"id_rsa.pub"
RAS_RSA_KEY_PATH=$RAS_DIR_PATH/"rsa_key.pem"
## Creating directory
mkdir -p $RAS_DIR_PATH
touch $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
chmod 600 $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
## Adding properties
echo "# Comma-separated list of the names of the clouds managed by this RAS" > $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "# Their configuration is stored under the directory clouds/<name>" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "# The default cloud is the first name in the list" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo $CN_PATTERN=$CN >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo $AUTH_PATTERN=$AUTH >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo $PROVIDER_ID_TAG=$PROVIDER_ID >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
PROTOCOL="http://"
echo "as_url=$PROTOCOL$SERVICE_HOST_IP" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "as_port=$AS_PORT" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "jdbc_database_url=jdbc:sqlite:/root/resource-allocation-service/ras.db" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
## Creating and adding key pair
echo "" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
openssl genrsa -out $RAS_RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RAS_RSA_KEY_PATH -out $RAS_PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $RAS_PRIVATE_KEY_PATH -outform PEM -pubout -out $RAS_PUBLIC_KEY_PATH
chmod 600 $RAS_PRIVATE_KEY_PATH
rm $RAS_RSA_KEY_PATH
echo "public_key_file_path="$RAS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa.pub" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "private_key_file_path="$RAS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
## Copying clouds directory
yes | cp -fr $TEMPLATES_DIR_PATH/$CLOUDS_DIR_NAME $RAS_DIR_PATH
## Copying application.properties file
yes | cp -f $TEMPLATES_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME".ras" $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
chmod 600 $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
## Editing application.properties
JDBC_PREFIX="jdbc:postgresql:"
DB_PORT="5432"
RAS_DB_ENDPOINT="ras"
DB_URL_PROPERTY="spring.datasource.url"
DB_URL=$JDBC_PREFIX"//"$SERVICE_HOST_IP":"$DB_PORT"/"$RAS_DB_ENDPOINT
echo "" >> $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
echo "$DB_URL_PROPERTY=$DB_URL" >> $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
DB_USERNAME="fogbow"
DB_USERNAME_PATTERN="spring.datasource.username"
echo "$DB_USERNAME_PATTERN=$DB_USERNAME" >> $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
DB_PASSWORD_PATTERN="spring.datasource.password"
echo "$DB_PASSWORD_PATTERN=$DB_PASSWORD" >> $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME

# GUI conf-file generation
## Setting AS variables
GUI_DIR_PATH="./conf-files/gui"
GUI_CONF_FILE_NAME="api.config.js"
## Creating directory
mkdir -p $GUI_DIR_PATH
## Copying configuration template
yes | cp -f $TEMPLATES_DIR_PATH/$AT"-"$GUI_CONF_FILE_NAME $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
# Setting endpoints
sed -i "s#.*\<as\>:.*#	as: 'https://$PROVIDER_ID/as',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*ras:.*#	ras: 'https://$PROVIDER_ID/ras',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*local:.*#	local: '$PROVIDER_ID',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
## Setting deployType property
sed -i "s#.*deployType.*#	deployType: 'basic-site',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*fnsServiceNames.*#	fnsServiceNames: [],#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
