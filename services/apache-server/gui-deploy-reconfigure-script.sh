#!/bin/bash
CONTAINER_NAME="apache-server"
VIRTUAL_HOST_DIR_PATH="/etc/apache2/sites-available"
VIRTUAL_HOST_FILE_NAME="000-default.conf"
TMP_VIRTUAL_HOST_FILE_NAME="000-default.conf.tmp"

sudo docker cp $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_FILE_NAME $TMP_VIRTUAL_HOST_FILE_NAME
sudo chown ubuntu.ubuntu $TMP_VIRTUAL_HOST_FILE_NAME

ed -s $TMP_VIRTUAL_HOST_FILE_NAME <<!
/ms
.,+t+
-
.,+1s,ms,  ,g
-
.,+1s,8083,8084
w
q
!

sudo docker cp $TMP_VIRTUAL_HOST_FILE_NAME $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_FILE_NAME

sudo docker exec $CONTAINER_NAME /bin/bash -c "/etc/init.d/apache2 restart"

rm $TMP_VIRTUAL_HOST_FILE_NAME
