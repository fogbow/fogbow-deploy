#!/bin/bash

BUILD_FILE_NAME="build"
WORK_DIR=$(pwd)

# Read configuration file
SERVICE_CONF_FILE_PATH="./conf-files/service.conf"
#sudo chmod a+r $SERVICE_CONF_FILE_PATH

AS_PORT_PATTERN="As_port"
AS_PORT=$(grep $AS_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
RAS_PORT_PATTERN="Ras_port"
RAS_PORT=$(grep $RAS_PORT_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
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
RAS_TAG_PATTERN="Ras_tag"
RAS_TAG=$(grep $RAS_TAG_PATTERN $SERVICE_CONF_FILE_PATH | cut -d"=" -f2-)
if [ -z ${RAS_TAG// } ]; then
	RAS_TAG="latest"
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

# Create containers

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

sudo docker run -tdi --name fogbow-database \
      -p $DB_PORT:5432 \
      -e DB_USER="fogbow" \
      -e DB_PASS="db_password" \
      -e DB_NAME="ras" \
      -e DB2_NAME="fns" \
      -v $WORK_DIR/data:/var/lib/postgresql/data \
      fogbow/database:$DB_TAG

sudo docker run -tdi --name fogbow-as \
      -p $AS_PORT:8080 \
      -v $WORK_DIR/conf-files/as:/root/authentication-service/src/main/resources/private \
      fogbow/authentication-service:$AS_TAG

sudo docker run -tdi --name fogbow-ras \
      -p $RAS_PORT:8080 \
      -v $WORK_DIR/conf-files/ras:/root/resource-allocation-service/src/main/resources/private \
      -v $WORK_DIR/properties/application.properties:/root/resource-allocation-service/application.properties \
      -v $WORK_DIR/timestamp-storage/ras.db:/root/resource-allocation-service/ras.db \
      fogbow/resource-allocation-service:$RAS_TAG

sudo docker run -tdi --name fogbow-gui \
      -p $GUI_PORT:3000 \
      -v $WORK_DIR/conf-files/gui/api.config.js:/root/fogbow-gui/src/defaults/api.config.js \
      fogbow/fogbow-gui:$GUI_TAG

# Start Apache
ENABLE_MODULES_SCRIPT="multi-cloud-enable-modules"
APACHE_CONTAINER_NAME="fogbow-apache"

#sudo chmod a+r ./conf-files/apache/index.html
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
echo "/usr/sbin/service shibd restart" >> $ENABLE_MODULES_SCRIPT

sudo chmod +x $ENABLE_MODULES_SCRIPT
sudo docker cp $ENABLE_MODULES_SCRIPT $APACHE_CONTAINER_NAME:/$ENABLE_MODULES_SCRIPT
sudo docker exec $APACHE_CONTAINER_NAME /$ENABLE_MODULES_SCRIPT
sudo docker exec $APACHE_CONTAINER_NAME /bin/bash -c "rm /$ENABLE_MODULES_SCRIPT"
rm $ENABLE_MODULES_SCRIPT

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
