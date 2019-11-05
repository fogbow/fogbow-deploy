#!/bin/bash
CONTAINER_NAME="apache-server"
VIRTUAL_HOST_DIR_PATH="/etc/apache2/sites-available"
ROOT_DIR_PATH="/var/www/html"
INDEX_FILE_NAME="index.html"
VIRTUAL_HOST_FILE_NAME="000-default.conf"
TMP_INDEX_FILE_NAME="index.html.fns"
TMP_VIRTUAL_HOST_FILE_NAME="000-default.conf.fns"

cp $VIRTUAL_HOST_FILE_NAME".fed" $TMP_VIRTUAL_HOST_FILE_NAME
cp $INDEX_FILE_NAME".fed" $TMP_INDEX_FILE_NAME

ed -s $TMP_VIRTUAL_HOST_FILE_NAME <<!
/\/as
.,+t+
-
.,+1s,\/as,\/fns,g
-
.,+1s,8080,8081
-
.,+1s, http,http
w
q
!

ed -s $TMP_INDEX_FILE_NAME <<!
/8080
-2,+2t+2
-2
s,8080,8081
s,Authentication,Federated network
w
q
!

sudo docker cp $TMP_VIRTUAL_HOST_FILE_NAME $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_FILE_NAME
sudo docker cp $TMP_INDEX_FILE_NAME $CONTAINER_NAME:$ROOT_DIR_PATH/$INDEX_FILE_NAME

sudo docker exec $CONTAINER_NAME /bin/bash -c "/etc/init.d/apache2 restart"
