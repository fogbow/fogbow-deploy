#!/bin/bash
CONF_FILES_DIR="conf-files"
CONF_FILES_PATH="../../"$CONF_FILES_DIR
FEDERATION_CONF_FILE_NAME="federation.conf"
RAS_CONF_FILE_NAME="ras.conf"
RAS_CONF_FILE_PATH=$CONF_FILES_DIR/$RAS_CONF_FILE_NAME
CONTAINER_CONF_DIR="/root/resource-allocation-service/src/main/resources/private/"
CONTAINER_NAME="resource-allocation-service"
SECRETS_FILE_PATH=$CONF_FILES_PATH/"secrets"

XMPP_PASSWORD_PATTERN="xmpp_password"
XMPP_PASSWORD=$(grep $XMPP_PASSWORD_PATTERN $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

XMPP_HOST_IP_PATTERN="xmpp_server_ip"
XMPP_HOST_IP=$(grep $XMPP_HOST_IP_PATTERN $CONF_FILES_DIR/$FEDERATION_CONF_FILE_NAME | awk -F "=" '{print $2}')

ed -s $RAS_CONF_FILE_PATH <<!
/false
s,false,true
i
xmpp_password=
xmpp_server_ip=
.
w
q
!

sed -i "s|xmpp_password=|xmpp_password=$XMPP_PASSWORD|g" $RAS_CONF_FILE_PATH
sed -i "s|xmpp_server_ip=|xmpp_server_ip=$XMPP_HOST_IP|g" $RAS_CONF_FILE_PATH

sudo docker stop $CONTAINER_NAME
sudo docker start $CONTAINER_NAME
sudo docker cp $RAS_CONF_FILE_PATH $CONTAINER_NAME:$CONTAINER_CONF_DIR/$RAS_CONF_FILE_NAME

# Run RAS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

