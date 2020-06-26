#!/bin/bash

BUILD_FILE_NAME="build"
WORK_DIR=$(pwd)
SERVICE_CONF_FILE_PATH="./conf-files/service.conf"

# Read configuration file

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

# Remove containers from earlier installation
sudo docker stop fogbow-apache fogbow-database fogbow-as fogbow-ras fogbow-gui fogbow-fns fogbow-ms
sudo docker rm fogbow-apache fogbow-database fogbow-as fogbow-ras fogbow-gui fogbow-fns fogbow-ms

# Create containers

sudo docker pull fogbow/apache-shibboleth-server:$APACHE_TAG
sudo docker run -tdi --name fogbow-apache \
      -p $HTTP_PORT:80 \
      -p $HTTPS_PORT:443 \
      -v $WORK_DIR/conf-files/apache/site.crt:/etc/ssl/certs/site.crt \
      -v $WORK_DIR/conf-files/apache/site.key:/etc/ssl/private/site.key \
      -v $WORK_DIR/conf-files/apache/site.pem:/etc/ssl/certs/site.pem \
      -v $WORK_DIR/conf-files/apache/ports.conf:/etc/apache2/ports.conf \
      -v $WORK_DIR/conf-files/apache/000-default.conf:/etc/apache2/sites-available/000-default.conf \
      -v $WORK_DIR/conf-files/apache/index.html:/var/www/html/index.html \
      fogbow/apache-shibboleth-server:$APACHE_TAG

sudo docker pull fogbow/database:$DB_TAG
sudo docker run -tdi --name fogbow-database \
      -p $DB_PORT:5432 \
      -e DB_USER="fogbow" \
      -e DB_PASS="db_password" \
      -e DB_NAME="ras" \
      -e DB2_NAME="fns" \
      -v $WORK_DIR/data:/var/lib/postgresql/data \
      fogbow/database:$DB_TAG

sudo docker pull fogbow/authentication-service:$AS_TAG
sudo docker run -tdi --name fogbow-as \
      -p $AS_PORT:8080 \
      -v $WORK_DIR/conf-files/as:/root/authentication-service/src/main/resources/private \
      fogbow/authentication-service:$AS_TAG

sudo docker pull fogbow/resource-allocation-service:$RAS_TAG
sudo docker run -tdi --name fogbow-ras \
      -p $RAS_PORT:8080 \
      -v $WORK_DIR/conf-files/ras:/root/resource-allocation-service/src/main/resources/private \
      -v $WORK_DIR/conf-files/ras/application.properties:/root/resource-allocation-service/application.properties \
      -v $WORK_DIR/timestamp-storage/ras.db:/root/resource-allocation-service/ras.db \
      fogbow/resource-allocation-service:$RAS_TAG

sudo docker pull fogbow/fogbow-gui:$GUI_TAG
sudo docker run -tdi --name fogbow-gui \
      -p $GUI_PORT:3000 \
      -v $WORK_DIR/conf-files/gui/api.config.js:/root/fogbow-gui/src/defaults/api.config.js \
      fogbow/fogbow-gui:$GUI_TAG

sudo docker pull fogbow/membership-service:$MS_TAG
sudo docker run -idt --name "fogbow-ms" \
	-p $MS_PORT:8080 \
	-v $WORK_DIR/conf-files/ms:/root/membership-service/src/main/resources/private \
	fogbow/membership-service:$MS_TAG

sudo docker pull fogbow/federated-network-service:$FNS_TAG
sudo docker run -idt --name "fogbow-fns" \
	-p $FNS_PORT:8080 \
	-v $WORK_DIR/conf-files/fns:/root/federated-network-service/src/main/resources/private \
	-v $WORK_DIR/timestamp-storage/fns.db:/root/federated-network-service/fns.db \
	fogbow/federated-network-service:$FNS_TAG

# Start AS
AS_CONF_FILE_PATH="src/main/resources/private/as.conf"
AS_CONTAINER_NAME="fogbow-as"

sudo docker exec $AS_CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $AS_CONF_FILE_PATH"
sudo docker exec $AS_CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

# Start RAS
CONTAINER_RAS_CONF_FILE_PATH="src/main/resources/private/ras.conf"
RAS_CONTAINER_NAME="fogbow-ras"

sudo docker exec $RAS_CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $CONTAINER_RAS_CONF_FILE_PATH"
sudo docker exec $RAS_CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

# Start Apache
ENABLE_MODULES_SCRIPT="enable-modules"
APACHE_CONTAINER_NAME="fogbow-apache"
APACHE_CONF_DIR_PATH="./conf-files/apache"
AT_PATTERN="authenticationPlugin"
AT=$(grep $AT_PATTERN $WORK_DIR/conf-files/gui/api.config.js | awk -F "'" '{print $2}')

echo "#!/bin/bash" > $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod ssl_load" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod proxy.load" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod proxy_http.load" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod shib2" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod ssl" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod rewrite" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod headers" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/a2enmod proxy_http" >> $ENABLE_MODULES_SCRIPT
echo "/usr/sbin/service apache2 restart" >> $ENABLE_MODULES_SCRIPT

if [ "$AT" == "Shibboleth" ]; then
  echo "/usr/sbin/service shibd restart" >> $ENABLE_MODULES_SCRIPT

  REMOTE_USER="ubuntu"
  VIRTUAL_HOST_DIR_PATH="/etc/apache2/sites-available"
  CERTS_DIR_PATH="/etc/ssl/certs"
  SSL_DIR_PATH="/etc/ssl/private"
  SHIB_CONF_DIR_PATH="/etc/shibboleth"
  SHIB_AUTH_APP_DIR_PATH="/home/"$REMOTE_USER"/shibboleth-authentication-application"
  SECURE_INDEX_PATH="/var/www/secure/index.html"
  VIRTUAL_HOST_SHIB_ENVIRONMENT_80_FILE_NAME="default.conf"
  VIRTUAL_HOST_SHIB_ENVIRONMENT_443_FILE="shibboleth-sp2.conf"
  CONF_SHIB_ENV_ATT_MAP_FILE_NAME="attribute-map.xml"
  CONF_SHIB_ENV_ATT_POLICY_FILE_NAME="attribute-policy.xml"
  CONF_SHIB_ENV_SHIB_XML_FILE_NAME="shibboleth2.xml"
  CONF_SHIB_ENV_INDEX_SECURE_FILE_NAME="index-secure.html"
  SHIB_AUTH_APP_CONF_FILE_NAME="shibboleth-authentication-application.conf"
  SHIB_AUTH_APP_LOG4J_FILE_NAME="log4j.properties"
  SHIB_CONF_FILE_NAME="shibboleth.conf"
  SHIB_PRIVATE_KEY_FILE_NAME="shibboleth-app.pri"
  AS_CONF_DIR_PATH="./conf-files/as"
  AS_PUB_KEY_FILE_NAME="id_rsa.pub"
  SERVICE_PROVIDER_CERTIFICATE_FILE_NAME="shibboleth_service_provider.crt"
  SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME="shibboleth_service_provider.key"
  SERVICE_PROVIDER_DOMAIN_PATTERN="domain_service_provider"
  SERVICE_PROVIDER_DOMAIN_NAME=$(grep $SERVICE_PROVIDER_DOMAIN_PATTERN $APACHE_CONF_DIR_PATH/$SHIB_CONF_FILE_NAME | cut -d"=" -f2-)
  sudo docker cp $APACHE_CONF_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_80_FILE_NAME $APACHE_CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_80_FILE_NAME
  sudo docker cp $APACHE_CONF_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_443_FILE $APACHE_CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_443_FILE
  sudo docker cp $APACHE_CONF_DIR_PATH/$CONF_SHIB_ENV_ATT_MAP_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_CONF_DIR_PATH/$CONF_SHIB_ENV_ATT_MAP_FILE_NAME
  sudo docker cp $APACHE_CONF_DIR_PATH/$CONF_SHIB_ENV_SHIB_XML_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_CONF_DIR_PATH/$CONF_SHIB_ENV_SHIB_XML_FILE_NAME
  sudo docker exec -it $APACHE_CONTAINER_NAME chmod 644 $SHIB_CONF_DIR_PATH/$CONF_SHIB_ENV_SHIB_XML_FILE_NAME
  sudo docker cp $APACHE_CONF_DIR_PATH/$CONF_SHIB_ENV_ATT_POLICY_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_CONF_DIR_PATH/$CONF_SHIB_ENV_ATT_POLICY_FILE_NAME
  sudo docker exec -it $APACHE_CONTAINER_NAME mkdir -p /var/www/secure
  sudo docker cp $APACHE_CONF_DIR_PATH/$CONF_SHIB_ENV_INDEX_SECURE_FILE_NAME $APACHE_CONTAINER_NAME:$SECURE_INDEX_PATH
  sudo docker cp $APACHE_CONF_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_AUTH_APP_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME
  sudo docker cp $APACHE_CONF_DIR_PATH/$SHIB_AUTH_APP_LOG4J_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_AUTH_APP_DIR_PATH/$SHIB_AUTH_APP_LOG4J_FILE_NAME
  sudo docker exec -it $APACHE_CONTAINER_NAME sed -i "s/^DAEMON_USER=_shibd/DAEMON_USER=root/g" /etc/init.d/shibd
  sudo docker cp $APACHE_CONF_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_AUTH_APP_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME
  sudo docker cp $AS_CONF_DIR_PATH/$AS_PUB_KEY_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_AUTH_APP_DIR_PATH/$AS_PUB_KEY_FILE_NAME
  sudo docker cp $APACHE_CONF_DIR_PATH/$SERVICE_PROVIDER_CERTIFICATE_FILE_NAME $APACHE_CONTAINER_NAME:$CERTS_DIR_PATH/$SERVICE_PROVIDER_DOMAIN_NAME.crt
  sudo docker cp $APACHE_CONF_DIR_PATH/$SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME $APACHE_CONTAINER_NAME:$SSL_DIR_PATH/$SERVICE_PROVIDER_DOMAIN_NAME.key
  sudo docker exec $APACHE_CONTAINER_NAME a2ensite $VIRTUAL_HOST_SHIB_ENVIRONMENT_80_FILE_NAME
  sudo docker exec $APACHE_CONTAINER_NAME a2ensite $VIRTUAL_HOST_SHIB_ENVIRONMENT_443_FILE
  SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN="shib_private_key_path="
  sed -i "s#$SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN.*#$SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN$SHIB_AUTH_APP_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME#" $APACHE_CONF_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME
  SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN="as_public_key_path="
  sed -i "s#$SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN.*#$SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN$SHIB_AUTH_APP_DIR_PATH/$AS_PUB_KEY_FILE_NAME#" $APACHE_CONF_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME
  sudo docker cp $APACHE_CONF_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME $APACHE_CONTAINER_NAME:$SHIB_AUTH_APP_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME
  sudo docker exec $APACHE_CONTAINER_NAME /bin/bash -c "bash $SHIB_AUTH_APP_DIR_PATH/bin/start-shib-app.sh" &
fi

sudo chmod +x $ENABLE_MODULES_SCRIPT
sudo docker cp $ENABLE_MODULES_SCRIPT $APACHE_CONTAINER_NAME:/$ENABLE_MODULES_SCRIPT
sudo docker exec $APACHE_CONTAINER_NAME /$ENABLE_MODULES_SCRIPT
sudo docker exec $APACHE_CONTAINER_NAME /bin/bash -c "rm /$ENABLE_MODULES_SCRIPT"
rm $ENABLE_MODULES_SCRIPT

# Start MS
CONTAINER_MS_CONF_FILE_PATH="src/main/resources/private/ms.conf"
MS_CONTAINER_NAME="fogbow-ms"

sudo docker exec $MS_CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $CONTAINER_MS_CONF_FILE_PATH"
sudo docker exec $MS_CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

# Start FNS
CONTAINER_FNS_CONF_FILE_PATH="src/main/resources/private/fns.conf"
FNS_CONTAINER_NAME="fogbow-fns"

sudo docker exec $FNS_CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $CONTAINER_FNS_CONF_FILE_PATH"
sudo docker exec $FNS_CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &
