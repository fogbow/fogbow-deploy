#!/bin/bash

BUILD_FILE_NAME="build"

# Create containers

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $SECURE_PORT:$SECURE_PORT \
	-p $INSECURE_PORT:$INSECURE_PORT \
	-v $CURRENT_DIR_PATH/$CERTIFICATE_FILE_NAME:$CERTS_DIR_PATH/$CERTIFICATE_FILE_NAME \
	-v $CURRENT_DIR_PATH/$CERTIFICATE_KEY_FILE_NAME:$SSL_DIR_PATH/$CERTIFICATE_KEY_FILE_NAME \
	-v $CURRENT_DIR_PATH/$CERTIFICATE_CHAIN_FILE_NAME:$CERTS_DIR_PATH/$CERTIFICATE_CHAIN_FILE_NAME \
	$IMAGE_NAME:$TAG

sudo docker run -tdi --name fogbow-apache \
      -p 80:80 \
      -p 443:443 \
      -v /home/ubuntu/conf-files/apache/site.crt:/etc/ssl/certs/site.crt \
      -v /home/ubuntu/conf-files/apache/site.key:/etc/ssl/private/site.key \
      -v /home/ubuntu/conf-files/apache/site.pem:/etc/ssl/certs/site.pem \
      -v /home/ubuntu/conf-files/apache/ports.conf:/etc/apache2/ports.conf \
      -v /home/ubuntu/conf-files/apache/000-default.conf:/etc/apache2/sites-availability/000-default.conf \
      -v /home/ubuntu/conf-files/apache/index.html:/var/www/html/index.html \
      fogbow/apache-shibboleth-server:latest

sudo docker run -tdi --name fogbow-database \
      -p 5432:5432 \
      -e DB_USER="fogbow" \
      -e DB_PASS="db_password" \
      -e DB_NAME="ras" \
      -e DB2_NAME="fns" \
      -v /home/ubuntu/data:/var/lib/postgresql/data \
      fogbow/database:latest

sudo docker run -tdi --name fogbow-as \
      -p 8080:8080 \
      -v /home/ubuntu/conf-files/as:/root/authentication-service/src/main/resources/private \
      fogbow/authentication-service:develop

sudo docker run -tdi --name fogbow-ras \
      -p 8082:8080 \
      -v /home/ubuntu/conf-files/ras:/root/resource-allocation-service/src/main/resources/private \
      -v /home/ubuntu/properties/application.properties:/root/resource-allocation-service/application.properties \
      -v /home/ubuntu/timestamp-storage/ras.db:/root/resource-allocation-service/ras.db \
      fogbow/resource-allocation-service:develop

sudo docker run -tdi --name fogbow-gui \
      -p 8084:8080 \
      -v /home/ubuntu/conf-files/gui/api.config.js:/root/fogbow-gui/src/defaults/api.config.js \
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
