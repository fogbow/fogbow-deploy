#!/bin/bash

BUILD_FILE_NAME="build"

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
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

# Start RAS
CONTAINER_RAS_CONF_FILE_PATH="src/main/resources/private/ras.conf"
RAS_CONTAINER_NAME="fogbow-ras"

sudo docker exec $RAS_CONTAINER_NAME /bin/bash -c "cat $BUILD_FILE_NAME >> $CONTAINER_RAS_CONF_FILE_PATH"
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &
