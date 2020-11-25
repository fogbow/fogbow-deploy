#!/bin/bash

# Source configuration files
CONF_FILES_DIR_PATH="../conf-files"
AS_CONF_FILE_PATH=$CONF_FILES_DIR_PATH/"as.conf"
MS_CONF_FILE_PATH=$CONF_FILES_DIR_PATH/"ms.conf"
SERVICE_CONF_FILE_PATH=$CONF_FILES_DIR_PATH/"service.conf"
SITE_CONF_FILE_PATH=$CONF_FILES_DIR_PATH/"site.conf"
TEMPLATES_DIR_PATH="../templates"
COMMON_TEMPLATES_DIR_PATH="../../common/templates"
COMMON_SCRIPTS_DIR_PATH="../../common/scripts"
DEPLOY_START_SERVICES_FILE_NAME="deploy-and-start-services.sh"

# Reading configuration files

## Reading data from service.conf
### Service ports configuration
AS_PORT_PATTERN="As_port"
AS_PORT=$(grep $AS_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
MS_PORT_PATTERN="Ms_port"
MS_PORT=$(grep $MS_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
RAS_PORT_PATTERN="Ras_port"
RAS_PORT=$(grep $RAS_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
FNS_PORT_PATTERN="Fns_port"
FNS_PORT=$(grep $FNS_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
GUI_PORT_PATTERN="Gui_port"
GUI_PORT=$(grep $GUI_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
DB_PORT_PATTERN="Db_port"
DB_PORT=$(grep $DB_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
HTTP_PORT_PATTERN="Http_port"
HTTP_PORT=$(grep $HTTP_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
HTTPS_PORT_PATTERN="Https_port"
HTTPS_PORT=$(grep $HTTPS_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
### Service tags configuration
AS_TAG_PATTERN="As_tag"
AS_TAG=$(grep $AS_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${AS_TAG// } ]; then
	AS_TAG="latest"
fi
MS_TAG_PATTERN="Ms_tag"
MS_TAG=$(grep $MS_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${MS_TAG// } ]; then
	MS_TAG="latest"
fi
RAS_TAG_PATTERN="Ras_tag"
RAS_TAG=$(grep $RAS_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${RAS_TAG// } ]; then
	RAS_TAG="latest"
fi
FNS_TAG_PATTERN="Fns_tag"
FNS_TAG=$(grep $FNS_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${FNS_TAG// } ]; then
	FNS_TAG="latest"
fi
GUI_TAG_PATTERN="Gui_tag"
GUI_TAG=$(grep $GUI_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${GUI_TAG// } ]; then
	GUI_TAG="latest"
fi
DB_TAG_PATTERN="Db_tag"
DB_TAG=$(grep $DB_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${DB_TAG// } ]; then
	DB_TAG="latest"
fi
APACHE_TAG_PATTERN="Apache_tag"
APACHE_TAG=$(grep $APACHE_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${APACHE_TAG// } ]; then
	APACHE_TAG="latest"
fi

## Reading data from site.conf
REMOTE_USER_PATTERN="remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $SITE_CONF_FILE_PATH | cut -d"=" -f2-)
SERVICE_HOST_IP_PATTERN="service_host_ip"
SERVICE_HOST_IP=$(grep $SERVICE_HOST_IP_PATTERN $SITE_CONF_FILE_PATH | cut -d"=" -f2-)
PROVIDER_ID_PATTERN="service_host_FQDN"
PROVIDER_ID=$(grep $PROVIDER_ID_PATTERN $SITE_CONF_FILE_PATH | cut -d"=" -f2-)
PROVIDER_ID_TAG="provider_id"
DMZ_HOST_PRIVATE_IP_PATTERN="dmz_host_private_ip"
DMZ_HOST_PRIVATE_IP=$(grep $DMZ_HOST_PRIVATE_IP_PATTERN $SITE_CONF_FILE_PATH | cut -d"=" -f2-)
DMZ_HOST_PUBLIC_IP_PATTERN="dmz_host_public_ip"
DMZ_HOST_PUBLIC_IP=$(grep $DMZ_HOST_PUBLIC_IP_PATTERN $SITE_CONF_FILE_PATH | cut -d"=" -f2-)

## Reading data from as.conf
AT_PATTERN="authentication_type"
AT=$(grep $AT_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
OS_PATTERN="openstack_keystone_v3_url"
OS=$(grep $OS_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
CS_PATTERN="cloudstack_url"
CS=$(grep $CS_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
ONE_PATTERN="opennebula_url"
ONE=$(grep $ONE_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
LEP_PATTERN="ldap_url"
LEP=$(grep $LEP_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
LB_PATTERN="ldap_base"
LB=$(grep $LB_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
LET_PATTERN="ldap_encrypt_type"
LET=$(grep $LET_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
DSP_PATTERN="domain_service_provider"
DSP=$(grep $DSP_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
DSU_PATTERN="discovery_service_url"
DSU=$(grep $DSU_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)
DSMU_PATTERN="discovery_service_metadata_url"
DSMU=$(grep $DSMU_PATTERN $AS_CONF_FILE_PATH | cut -d"=" -f2-)

## Reading data from ms.conf
MEMBERS_PATTERN="members_list"
MEMBERS=$(grep $MEMBERS_PATTERN $MS_CONF_FILE_PATH | cut -d"=" -f2-)

# Generating secrets
## Generating XMPP_PASSWORD
XMPP_PASSWORD=$(pwgen 10 1)
## Generating VPN password
VPN_PASSWORD_PROPERTY="vpn_password"
VPN_PASSWORD=$(pwgen 10 1)
## Generating DB passowrd
DB_PASSWORD_PROPERTY="db_password"
DB_PASSWORD=$(pwgen 10 1)

# Generating conf-files for dmz-host
## Creating temporary directory for dmz-host configuration
mkdir -p ./tmp-dmz-host/conf-files
## Copying and editing deploy-and-start-services.sh
cp "dmz-host-"$DEPLOY_START_SERVICES_FILE_NAME ./tmp-dmz-host/$DEPLOY_START_SERVICES_FILE_NAME
chmod 600 ./tmp-dmz-host/$DEPLOY_START_SERVICES_FILE_NAME
sed -i "s|$DB_PASSWORD_PROPERTY|$DB_PASSWORD|g" ./tmp-dmz-host/$DEPLOY_START_SERVICES_FILE_NAME
## IPSEC configuration
### Creating vanilla agent key pair
IPSEC_DIR_PATH=./tmp-dmz-host/conf-files/ipsec
### Creating IPSEC conf directory
mkdir -p $IPSEC_DIR_PATH
### Copying IPSEC configuration and installation files
IPSEC_INSTALLATION_SCRIPT_NAME="ipsec-installation.sh"
IPSEC_CONF_FILE_NAME="ipsec.conf"
cp -f $IPSEC_INSTALLATION_SCRIPT_NAME $IPSEC_DIR_PATH
chmod 600 $IPSEC_DIR_PATH/$IPSEC_INSTALLATION_SCRIPT_NAME
sed -i "s|$VPN_PASSWORD_PROPERTY|$VPN_PASSWORD|g" $IPSEC_DIR_PATH/$IPSEC_INSTALLATION_SCRIPT_NAME
cp -f $TEMPLATES_DIR_PATH/$IPSEC_CONF_FILE_NAME $IPSEC_DIR_PATH
## XMPP configuration
XMPP_DIR_PATH=./tmp-dmz-host/conf-files/xmpp
### Creating directory
mkdir -p $XMPP_DIR_PATH
PROSODY_CONF_TEMPLATE_FILE_NAME="prosody.cfg.lua.example"
PROSODY_CONF_FILE_NAME="prosody.cfg.lua"
yes | cp -f $TEMPLATES_DIR_PATH/$PROSODY_CONF_TEMPLATE_FILE_NAME $XMPP_DIR_PATH/$PROSODY_CONF_FILE_NAME
chmod 600 $XMPP_DIR_PATH/$PROSODY_CONF_FILE_NAME
### Adding comment to identify component credentials
INSERT_LINE_PATTERN="--	component_secret = \"password\""
COMPONENT_COMMENT="-- Manager Component"
sed -i "/$INSERT_LINE_PATTERN/a $COMPONENT_COMMENT" $XMPP_DIR_PATH/$PROSODY_CONF_FILE_NAME
### Adding component domain
COMPONENT_DOMAIN="Component \"ras-$PROVIDER_ID\""
sed -i "/$COMPONENT_COMMENT/a $COMPONENT_DOMAIN" $XMPP_DIR_PATH/$PROSODY_CONF_FILE_NAME
## Adding component password
COMPONENT_PASSWORD="\ \ \ \ \ \ \ \ component_secret = \"$XMPP_PASSWORD\""
sed -i "/$COMPONENT_DOMAIN/a $COMPONENT_PASSWORD" $XMPP_DIR_PATH/$PROSODY_CONF_FILE_NAME

# Generating conf-files for service-host
## Creating temporary directory for service-host configuration
mkdir -p ./tmp-service-host/conf-files
## Copying and editing deploy-and-start-services.sh
cp "service-host-"$DEPLOY_START_SERVICES_FILE_NAME ./tmp-service-host/$DEPLOY_START_SERVICES_FILE_NAME
chmod 600 ./tmp-service-host/$DEPLOY_START_SERVICES_FILE_NAME
sed -i "s|$DB_PASSWORD_PROPERTY|$DB_PASSWORD|g" ./tmp-service-host/$DEPLOY_START_SERVICES_FILE_NAME

## Ports and tags conf-file generation
PORTS_TAGS_CONF_FILE_PATH="./tmp-service-host/conf-files/service.conf"
touch $PORTS_TAGS_CONF_FILE_PATH
echo "$AS_PORT_PATTERN=$AS_PORT" > $PORTS_TAGS_CONF_FILE_PATH
echo "$MS_PORT_PATTERN=$MS_PORT" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$RAS_PORT_PATTERN=$RAS_PORT" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$FNS_PORT_PATTERN=$FNS_PORT" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$GUI_PORT_PATTERN=$GUI_PORT" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$DB_PORT_PATTERN=$DB_PORT" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$HTTP_PORT_PATTERN=$HTTP_PORT" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$HTTPS_PORT_PATTERN=$HTTPS_PORT" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$AS_TAG_PATTERN=$AS_TAG" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$MS_TAG_PATTERN=$MS_TAG" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$RAS_TAG_PATTERN=$RAS_TAG" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$FNS_TAG_PATTERN=$FNS_TAG" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$GUI_TAG_PATTERN=$GUI_TAG" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$DB_TAG_PATTERN=$DB_TAG" >> $PORTS_TAGS_CONF_FILE_PATH
echo "$APACHE_TAG_PATTERN=$APACHE_TAG" >> $PORTS_TAGS_CONF_FILE_PATH

## AS conf-file generation
### Setting AS variables
AS_DIR_PATH="./tmp-service-host/conf-files/as"
AS_CONF_FILE_NAME="as.conf"
AS_CONTAINER_CONF_FILE_DIR_PATH="/root/authentication-service/src/main/resources/private"
AS_PRIVATE_KEY_PATH=$AS_DIR_PATH/"id_rsa"
AS_PUBLIC_KEY_PATH=$AS_DIR_PATH/"id_rsa.pub"
AS_RSA_KEY_PATH=$AS_DIR_PATH/"rsa_key.pem"
### Creating directory
mkdir -p $AS_DIR_PATH
### Adding properties
echo "# Authentication plugin specific properties" > $AS_DIR_PATH/$AS_CONF_FILE_NAME
SIP_PATTERN="system_identity_provider_plugin_class"
case $AT in
  "ldap")
    SIP="cloud.fogbow.as.core.systemidp.plugins.ldap.LdapSystemIdentityProviderPlugin"
    ;;
  "shibboleth")
    SIP="cloud.fogbow.as.core.systemidp.plugins.shibboleth.ShibbolethSystemIdentityProviderPlugin"
    ;;
  "openstack")
    SIP="cloud.fogbow.as.core.systemidp.plugins.openstack.v3.OpenStackSystemIdentityProviderPlugin"
    ;;
  "cloudstack")
    SIP="cloud.fogbow.as.core.systemidp.plugins.cloudstack.CloudStackSystemIdentityProviderPlugin"
    ;;
  "opennebula")
    SIP="cloud.fogbow.as.core.systemidp.plugins.opennebula.OpenNebulaSystemIdentityProviderPlugin"
    ;;
  "googlecloud")
    SIP="cloud.fogbow.as.core.systemidp.plugins.googlecloud.GoogleCloudSystemIdentityProviderPlugin"
    ;;
  *)
    echo "Fatal error: invalid authentication type: [$AT]"
    exit 1
    ;;
esac
echo $SIP_PATTERN=$SIP >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $OS_PATTERN=$OS >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $CS_PATTERN=$CS >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $ONE_PATTERN=$ONE >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $LEP_PATTERN=$LEP >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $LB_PATTERN=$LB >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $LET_PATTERN=$LET >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo "" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo $PROVIDER_ID_TAG=$PROVIDER_ID >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
### Creating and adding key pair
echo "" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
openssl genrsa -out $AS_RSA_KEY_PATH 1024
openssl pkcs8 -topk8 -in $AS_RSA_KEY_PATH -out $AS_PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $AS_PRIVATE_KEY_PATH -outform PEM -pubout -out $AS_PUBLIC_KEY_PATH
chmod 600 $AS_PRIVATE_KEY_PATH
rm $AS_RSA_KEY_PATH
echo "public_key_file_path="$AS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa.pub" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
echo "private_key_file_path="$AS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa" >> $AS_DIR_PATH/$AS_CONF_FILE_NAME

## MS conf-file generation
MS_DIR_PATH="./tmp-service-host/conf-files/ms"
MS_CONF_FILE_NAME="ms.conf"
### Creating directory
mkdir -p $MS_DIR_PATH
touch $MS_DIR_PATH/$MS_CONF_FILE_NAME
### Adding properties
echo $MEMBERS_PATTERN=$MEMBERS >> $MS_DIR_PATH/$MS_CONF_FILE_NAME

## RAS conf-file generation
### Setting RAS variables
RAS_DIR_PATH="./tmp-service-host/conf-files/ras"
RAS_CONF_FILE_NAME="ras.conf"
CLOUDS_DIR_NAME="clouds"
APPLICATION_PROPERTIES_FILE_NAME="application.properties"
RAS_CONTAINER_CONF_FILE_DIR_PATH="/root/resource-allocation-service/src/main/resources/private"
RAS_PRIVATE_KEY_PATH=$RAS_DIR_PATH/"id_rsa"
RAS_PUBLIC_KEY_PATH=$RAS_DIR_PATH/"id_rsa.pub"
RAS_RSA_KEY_PATH=$RAS_DIR_PATH/"rsa_key.pem"
### Creating directory
mkdir -p $RAS_DIR_PATH
touch $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
chmod 600 $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
### Adding properties
CN_PATTERN="cloud_names"
CN=""
for i in `ls $CONF_FILES_DIR_PATH/$CLOUDS_DIR_NAME`
do
  if [ -f "$CONF_FILES_DIR_PATH/$CLOUDS_DIR_NAME/$i" ]; then
    CN=$CN`basename $i .conf`","
  fi
done
CN=`echo $CN | sed 's/.$//'`
echo "# Comma-separated list of the names of the clouds managed by this RAS" > $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "# Their configuration is stored under the directory clouds/<name>" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "# The default cloud is the first name in the list" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo $CN_PATTERN=$CN >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "authorization_plugin_class=cloud.fogbow.ras.core.plugins.authorization.DefaultAuthorizationPlugin" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo $PROVIDER_ID_TAG=$PROVIDER_ID >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "xmpp_enabled=true" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "xmpp_jid=ras-$PROVIDER_ID" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "xmpp_password=$XMPP_PASSWORD"  >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "xmpp_server_ip=$DMZ_HOST_PRIVATE_IP" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
PROTOCOL="http://"
echo "as_url=$PROTOCOL$SERVICE_HOST_IP" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "as_port=$AS_PORT" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "jdbc_database_url=jdbc:sqlite:/root/resource-allocation-service/ras.db" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
### Creating and adding key pair
echo "" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
openssl genrsa -out $RAS_RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $RAS_RSA_KEY_PATH -out $RAS_PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $RAS_PRIVATE_KEY_PATH -outform PEM -pubout -out $RAS_PUBLIC_KEY_PATH
chmod 600 $RAS_PRIVATE_KEY_PATH
rm $RAS_RSA_KEY_PATH
echo "public_key_file_path="$RAS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa.pub" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
echo "private_key_file_path="$RAS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa" >> $RAS_DIR_PATH/$RAS_CONF_FILE_NAME
## Generating cloud configuration files
for i in `ls $CONF_FILES_DIR_PATH/$CLOUDS_DIR_NAME`
do
  if [ -f "$CONF_FILES_DIR_PATH/$CLOUDS_DIR_NAME/$i" ]; then
    bash $COMMON_SCRIPTS_DIR_PATH/generate_cloud_conf.sh $CONF_FILES_DIR_PATH/$CLOUDS_DIR_NAME/$i $RAS_DIR_PATH $COMMON_TEMPLATES_DIR_PATH
    retVal=$?
    if [ $retVal -ne 0 ]; then
        exit $retVal
    fi
  fi
done
### Copying application.properties file
yes | cp -f $COMMON_TEMPLATES_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME".ras" $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
chmod 600 $RAS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
### Editing application.properties
JDBC_PREFIX="jdbc:postgresql:"
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

## FNS conf-file generation
FNS_DIR_PATH="./tmp-service-host/conf-files/fns"
FNS_CONF_FILE_NAME="fns.conf"
FNS_CONTAINER_CONF_FILE_DIR_PATH="/root/federated-network-service/src/main/resources/private"
### Creating directory
mkdir -p $FNS_DIR_PATH
touch $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
chmod 600 $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
### Generating IPSEC agent key pair
PRIVATE_KEY_FILE_PATH="./vanilla-agent-id_rsa"
PUBLIC_KEY_FILE_PATH="./vanilla-agent-id_rsa.pub"
ssh-keygen -f $PRIVATE_KEY_FILE_PATH -t rsa -b 4096 -C "FNS-vanilla-key" -N ""
chmod 600 $PRIVATE_KEY_FILE_PATH
### Moving keys to appropriate directories
mv $PRIVATE_KEY_FILE_PATH $FNS_DIR_PATH
mv $PUBLIC_KEY_FILE_PATH $IPSEC_DIR_PATH
### Adding properties
echo "authorization_plugin_class=cloud.fogbow.fns.core.authorization.DefaultAuthorizationPlugin" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "service_names=vanilla" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo $PROVIDER_ID_TAG=$PROVIDER_ID >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
PROTOCOL="http://"
echo "as_url=$PROTOCOL$SERVICE_HOST_IP" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "as_port=$AS_PORT" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "ras_url=$PROTOCOL$SERVICE_HOST_IP" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "ras_port=$RAS_PORT" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "jdbc_database_url=jdbc:sqlite:/root/federated-network-service/fns.db" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
### Creating and adding key pair
echo "" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
FNS_PRIVATE_KEY_PATH=$FNS_DIR_PATH/"id_rsa"
FNS_PUBLIC_KEY_PATH=$FNS_DIR_PATH/"id_rsa.pub"
FNS_RSA_KEY_PATH=$FNS_DIR_PATH/"rsa_key.pem"
openssl genrsa -out $FNS_RSA_KEY_PATH 2048
openssl pkcs8 -topk8 -in $FNS_RSA_KEY_PATH -out $FNS_PRIVATE_KEY_PATH -nocrypt
openssl rsa -in $FNS_PRIVATE_KEY_PATH -outform PEM -pubout -out $FNS_PUBLIC_KEY_PATH
chmod 600 $FNS_PRIVATE_KEY_PATH
rm $FNS_RSA_KEY_PATH
echo "public_key_file_path="$FNS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa.pub" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
echo "private_key_file_path="$FNS_CONTAINER_CONF_FILE_DIR_PATH/"id_rsa" >> $FNS_DIR_PATH/$FNS_CONF_FILE_NAME
### Copying application.properties file
yes | cp -f $TEMPLATES_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME".fns" $FNS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
chmod 600 $FNS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
### Editing application.properties
FNS_DB_ENDPOINT="fns"
DB_URL=$JDBC_PREFIX"//"$SERVICE_HOST_IP":"$DB_PORT"/"$FNS_DB_ENDPOINT
echo "" >> $FNS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
echo "$DB_URL_PROPERTY=$DB_URL" >> $FNS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
echo "$DB_USERNAME_PATTERN=$DB_USERNAME" >> $FNS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
echo "$DB_PASSWORD_PATTERN=$DB_PASSWORD" >> $FNS_DIR_PATH/$APPLICATION_PROPERTIES_FILE_NAME
### Creating and editing services/vanilla/driver.conf
FNS_VANILLA_SERVICE_DIR_PATH=$FNS_DIR_PATH/"services/vanilla"
DRIVER_FILE_NAME="driver.conf"
mkdir -p $FNS_VANILLA_SERVICE_DIR_PATH
touch $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME
echo "driver_class_name=cloud.fogbow.fns.core.drivers.vanilla.VanillaServiceDriver" > $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME
echo "" >> $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME
echo "federated_network_agent_private_address=$DMZ_HOST_PRIVATE_IP" >> $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME
echo "federated_network_agent_public_address=$DMZ_HOST_PUBLIC_IP" >> $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME
PERMISSION_FILE_PATH="/root/federated-network-service/src/main/resources/private/vanilla-agent-id_rsa"
echo "federated_network_agent_permission_file_path=$PERMISSION_FILE_PATH" >> $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME
echo "federated_network_agent_user=$REMOTE_USER" >> $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME
echo "federated_network_agent_pre_shared_key=$VPN_PASSWORD" >> $FNS_VANILLA_SERVICE_DIR_PATH/$DRIVER_FILE_NAME

## GUI conf-file generation
### Setting AS variables
GUI_DIR_PATH="./tmp-service-host/conf-files/gui"
GUI_CONF_FILE_NAME="api.config.js"
### Creating directory
mkdir -p $GUI_DIR_PATH
### Copying configuration template
yes | cp -f $TEMPLATES_DIR_PATH/$AT"-"$GUI_CONF_FILE_NAME $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
### Setting endpoints
sed -i "s#.*\<as\>:.*#	as: 'https://$PROVIDER_ID/as',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*ms:.*#	ms: 'https://$PROVIDER_ID/ms',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*ras:.*#	ras: 'https://$PROVIDER_ID/ras',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*fns:.*#	fns: 'https://$PROVIDER_ID/fns',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*local:.*#	local: '$PROVIDER_ID',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
### Setting deployType property
sed -i "s#.*deployType.*#	deployType: 'federation',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
sed -i "s#.*fnsServiceNames.*#	fnsServiceNames: ['vanilla'],#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
if [ "$AT" == "shibboleth" ]; then
  sed -i "s#.*\<remoteCredentialsUrl\>:.*#remoteCredentialsUrl: 'https://$DSP',#" $GUI_DIR_PATH/$GUI_CONF_FILE_NAME
fi

## Apache conf-file generation
### Setting apache variables
APACHE_DIR_PATH="./tmp-service-host/conf-files/apache"
PORTS_FILE_NAME="ports.conf"
APACHE_VHOST_FILE_NAME="000-default.conf"
ROOT_WWW_FILE_NAME="index.html"
CERTIFICATE_FILE_PATH=$CONF_FILES_DIR_PATH/"certs/site.crt"
CERTIFICATE_KEY_FILE_PATH=$CONF_FILES_DIR_PATH/"certs/site.key"
CERTIFICATE_CHAIN_FILE_PATH=$CONF_FILES_DIR_PATH/"certs/site.pem"
### Creating directory
mkdir -p $APACHE_DIR_PATH
### Copying certificate files
yes | cp -f $CERTIFICATE_FILE_PATH $APACHE_DIR_PATH
yes | cp -f $CERTIFICATE_KEY_FILE_PATH $APACHE_DIR_PATH
yes | cp -f $CERTIFICATE_CHAIN_FILE_PATH $APACHE_DIR_PATH
### Copying ports.conf
yes | cp -f $COMMON_TEMPLATES_DIR_PATH/$PORTS_FILE_NAME $APACHE_DIR_PATH
### Generating Virtual Host file
yes | cp -f $TEMPLATES_DIR_PATH/$APACHE_VHOST_FILE_NAME $APACHE_DIR_PATH
sed -i "s|$SERVICE_HOST_IP_PATTERN|$SERVICE_HOST_IP|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$MS_PORT_PATTERN|$MS_PORT|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$FNS_PORT_PATTERN|$FNS_PORT|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
sed -i "s|$GUI_PORT_PATTERN|$GUI_PORT|g" $APACHE_DIR_PATH/$APACHE_VHOST_FILE_NAME
### Generating index.html
yes | cp -f $TEMPLATES_DIR_PATH/$ROOT_WWW_FILE_NAME $APACHE_DIR_PATH
sed -i "s|$SERVICE_HOST_IP_PATTERN|$SERVICE_HOST_IP|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$PROVIDER_ID_PATTERN|$PROVIDER_ID|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$AS_PORT_PATTERN|$AS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$MS_PORT_PATTERN|$MS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$RAS_PORT_PATTERN|$RAS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
sed -i "s|$FNS_PORT_PATTERN|$FNS_PORT|g" $APACHE_DIR_PATH/$ROOT_WWW_FILE_NAME
### Copying Shibboleth configuration (if required)
SHIB_CONF_FILE_NAME="shibboleth.conf"
SHIB_ENV_DIR_PATH=$COMMON_TEMPLATES_DIR_PATH/"shibboleth-environment"
if [ "$AT" == "shibboleth" ]; then
  SHIBBOLETH_SERVICE_PROVIDER_CRT_FILE_PATH=$CONF_FILES_DIR_PATH/"certs/shibboleth_service_provider.crt"
  SHIBBOLETH_SERVICE_PROVIDER_KEY_FILE_PATH=$CONF_FILES_DIR_PATH/"certs/shibboleth_service_provider.key"
  yes | cp -f $SHIBBOLETH_SERVICE_PROVIDER_CRT_FILE_PATH $APACHE_DIR_PATH
  yes | cp -f $SHIBBOLETH_SERVICE_PROVIDER_KEY_FILE_PATH $APACHE_DIR_PATH
  echo "# Shibboleth specific properties" > $APACHE_DIR_PATH/$SHIB_CONF_FILE_NAME
  echo $DSP_PATTERN=$DSP >> $APACHE_DIR_PATH/$SHIB_CONF_FILE_NAME
  echo $DSU_PATTERN=$DSU >> $APACHE_DIR_PATH/$SHIB_CONF_FILE_NAME
  echo $DSMU_PATTERN=$DSMU >> $APACHE_DIR_PATH/$SHIB_CONF_FILE_NAME
  #### Fill apache+shibboleth mod
  SHIB_VIRTUAL_HOST_80_FILE_NAME="default.conf"
  yes | cp -f $SHIB_ENV_DIR_PATH/$SHIB_VIRTUAL_HOST_80_FILE_NAME'.example' $APACHE_DIR_PATH/$SHIB_VIRTUAL_HOST_80_FILE_NAME
  SHIB_VIRTUAL_HOST_443_FILE_NAME="shibboleth-sp2.conf"
  yes | cp -f $SHIB_ENV_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME'.example' $APACHE_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME
  SHIB_XML_FILE_NAME="shibboleth2.xml"
  yes | cp -f $SHIB_ENV_DIR_PATH/$SHIB_XML_FILE_NAME'.example' $APACHE_DIR_PATH/$SHIB_XML_FILE_NAME
  ATTRIBUTE_MAP_XML_FILE_NAME="attribute-map.xml"
  yes | cp -f $SHIB_ENV_DIR_PATH/$ATTRIBUTE_MAP_XML_FILE_NAME'.example' $APACHE_DIR_PATH/$ATTRIBUTE_MAP_XML_FILE_NAME
  ATTRIBUTE_POLICY_XML_FILE_NAME="attribute-policy.xml"
  yes | cp -f $SHIB_ENV_DIR_PATH/$ATTRIBUTE_POLICY_XML_FILE_NAME'.example' $APACHE_DIR_PATH/$ATTRIBUTE_POLICY_XML_FILE_NAME
  INDEX_SECURE_HTML_FILE_NAME="index-secure.html"
  yes | cp -f $SHIB_ENV_DIR_PATH/$INDEX_SECURE_HTML_FILE_NAME'.example' $APACHE_DIR_PATH/$INDEX_SECURE_HTML_FILE_NAME
  #### default.conf
  HOSTNAME_PATTERN="_HOSTNAME_"
  sed -i "s#$HOSTNAME_PATTERN#$DSP#" $APACHE_DIR_PATH/$SHIB_VIRTUAL_HOST_80_FILE_NAME
  #### shibboleth-sp2.conf
  sed -i "s#$HOSTNAME_PATTERN#$DSP#" $APACHE_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME
  SHIB_AUTHENTICATION_APPLICATION_ADDRESS_PATTERN="_ADDRESS_SHIBBOLETH_AUTH_APPLICATION_"
  SHIB_AUTHENTICATION_APPLICATION_ADDRESS_DEFAULT_VALUE="127.0.0.1:9000"
  sed -i "s#$SHIB_AUTHENTICATION_APPLICATION_ADDRESS_PATTERN#$SHIB_AUTHENTICATION_APPLICATION_ADDRESS_DEFAULT_VALUE#" $APACHE_DIR_PATH/$SHIB_VIRTUAL_HOST_443_FILE_NAME
  #### shibboleth2.xml
  sed -i "s#$HOSTNAME_PATTERN#$DSP#" $APACHE_DIR_PATH/$SHIB_XML_FILE_NAME
  DS_META_PATTERN="_DS_META_"
  sed -i "s#$DS_META_PATTERN#$DSMU#" $APACHE_DIR_PATH/$SHIB_XML_FILE_NAME
  DS_PATTERN="_DS_"
  sed -i "s#$DS_PATTERN#$DSU#" $APACHE_DIR_PATH/$SHIB_XML_FILE_NAME
  #### Fill apache+shibboleth mod
  LOG4J_PROPERTIES_FILE_NAME="log4j.properties"
  yes | cp -f $SHIB_ENV_DIR_PATH/$LOG4J_PROPERTIES_FILE_NAME'.example' $APACHE_DIR_PATH/$LOG4J_PROPERTIES_FILE_NAME
  SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME="shibboleth-authentication-application.conf"
  yes | cp -f $SHIB_ENV_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME'.example' $APACHE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME
  SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN="fogbow_gui_url="
  FOGBOW_GUI_URL="https://"$PROVIDER_ID/
  sed -i "s#$SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN.*#$SHIB_AUTH_APP_FOGBOW_GUI_URL_PATTERN$FOGBOW_GUI_URL#" $APACHE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME
  SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN="shib_http_port="
  SHIB_HTTP_PORT="9000"
  sed -i "s#$SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN.*#$SHIB_AUTH_APP_SHIB_HTTP_PORT_PATTERN$SHIB_HTTP_PORT#" $APACHE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME
  SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN="service_provider_machine_ip="
  SERVICE_PROVIDER_MACHINE_IP=127.0.0.1
  sed -i "s#$SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN.*#$SHIB_AUTH_APP_SERVICE_PROVIDER_MACHINE_IP_PATTERN$SERVICE_PROVIDER_MACHINE_IP#" $APACHE_DIR_PATH/$SHIB_AUTHENTICATION_APPLICATION_PROPERTIES_FILE_NAME
  #### Generate shib app key pair
  SHIB_RSA_PEM_FILE_NAME="rsa_key_shibboleth.pem"
  SHIB_PRIVATE_KEY_FILE_NAME="shibboleth-app.pri"
  SHIB_PUBLIC_KEY_FILE_NAME="shibboleth-app.pub"
  openssl genrsa -out $APACHE_DIR_PATH/$SHIB_RSA_PEM_FILE_NAME 1024
  openssl pkcs8 -topk8 -in $APACHE_DIR_PATH/$SHIB_RSA_PEM_FILE_NAME -out $APACHE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME -nocrypt
  openssl rsa -in $APACHE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME -outform PEM -pubout -out $APACHE_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME
  chmod 600 $APACHE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME
  rm $APACHE_DIR_PATH/$SHIB_RSA_PEM_FILE_NAME
  #### Copy shib public key to AS conf-files dir
  yes | cp -f $APACHE_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME $AS_DIR_PATH
  echo "shib_public_key_file_path="$AS_CONTAINER_CONF_FILE_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME >> $AS_DIR_PATH/$AS_CONF_FILE_NAME
fi
