#!/bin/bash

BUILD_FILE_NAME="build"
WORK_DIR=$(pwd)

# Create containers

sudo docker run -tdi --name fogbow-apache \
      -p 80:80 \
      -p 443:443 \
      -v $WORK_DIR/conf-files/apache/site.crt:/etc/ssl/certs/site.crt \
      -v $WORK_DIR/conf-files/apache/site.key:/etc/ssl/private/site.key \
      -v $WORK_DIR/conf-files/apache/site.pem:/etc/ssl/certs/site.pem \
      -v $WORK_DIR/conf-files/apache/ports.conf:/etc/apache2/ports.conf \
      -v $WORK_DIR/conf-files/apache/000-default.conf:/etc/apache2/sites-available/000-default.conf \
      -v $WORK_DIR/conf-files/apache/index.html:/var/www/html/index.html \
      fogbow/apache-shibboleth-server:latest

sudo docker run -tdi --name fogbow-database \
      -p 5432:5432 \
      -e DB_USER="fogbow" \
      -e DB_PASS="db_password" \
      -e DB_NAME="ras" \
      -e DB2_NAME="fns" \
      -v $WORK_DIR/data:/var/lib/postgresql/data \
      fogbow/database:latest

sudo docker run -tdi --name fogbow-as \
      -p 8080:8080 \
      -v $WORK_DIR/conf-files/as:/root/authentication-service/src/main/resources/private \
      fogbow/authentication-service:develop

sudo docker run -tdi --name fogbow-ras \
      -p 8082:8080 \
      -v $WORK_DIR/conf-files/ras:/root/resource-allocation-service/src/main/resources/private \
      -v $WORK_DIR/properties/application.properties:/root/resource-allocation-service/application.properties \
      -v $WORK_DIR/timestamp-storage/ras.db:/root/resource-allocation-service/ras.db \
      fogbow/resource-allocation-service:develop

sudo docker run -tdi --name fogbow-gui \
      -p 8084:3000 \
      -v $WORK_DIR/conf-files/gui/api.config.js:/root/fogbow-gui/src/defaults/api.config.js \
      fogbow/fogbow-gui:develop

# Start Apache
ENABLE_MODULES_SCRIPT="basic-site-enable-modules"
APACHE_CONTAINER_NAME="fogbow-apache"

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
