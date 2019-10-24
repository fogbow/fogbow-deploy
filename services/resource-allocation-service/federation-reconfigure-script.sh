#!/bin/bash
CONF_FILES_DIR_NAME="conf-files"
RAS_CONF_FILE_NAME="ras.conf"
TMP_RAS_CONF_FILE_NAME="ras.conf.tmp"
CONTAINER_CONF_DIR_PATH="/root/resource-allocation-service/src/main/resources/private/"
CONTAINER_NAME="resource-allocation-service"
SECRETS_FILE_PATH="services/reconfiguration/conf-files/secrets"

XMPP_PASSWORD_PATTERN="xmpp_password"
XMPP_PASSWORD=$(grep $XMPP_PASSWORD_PATTERN $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

XMPP_SERVER_IP_PATTERN="xmpp_server_ip"
XMPP_SERVER_IP=$(grep $XMPP_SERVER_IP_PATTERN $SECRETS_FILE_PATH | awk -F "=" '{print $2}')

sudo docker cp $CONTAINER_NAME:$CONTAINER_CONF_DIR_PATH/$RAS_CONF_FILE_NAME $TMP_RAS_CONF_FILE_NAME
sudo chown ubuntu.ubuntu $TMP_RAS_CONF_FILE_NAME

ed -s $TMP_RAS_CONF_FILE_NAME <<!
/false
s,false,true
i
xmpp_password=
xmpp_server_ip=
.
w
q
!

sed -i "s|xmpp_password=|xmpp_password=$XMPP_PASSWORD|g" $TMP_RAS_CONF_FILE_NAME
sed -i "s|xmpp_server_ip=|xmpp_server_ip=$XMPP_SERVER_IP|g" $TMP_RAS_CONF_FILE_NAME

sudo docker stop $CONTAINER_NAME
sudo docker start $CONTAINER_NAME
sudo docker cp $TMP_RAS_CONF_FILE_NAME $CONTAINER_NAME:$CONTAINER_CONF_DIR_PATH/$RAS_CONF_FILE_NAME

rm $TMP_RAS_CONF_FILE_NAME

# Run RAS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

