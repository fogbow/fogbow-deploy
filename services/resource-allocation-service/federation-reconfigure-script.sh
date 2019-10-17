#!/bin/bash
RAS_CONF_FILE_NAME="ras.conf"
RAS_CONF_FILE_PATH="conf-files"/$RAS_CONF_FILE_NAME
CONTAINER_CONF_DIR="/root/resource-allocation-service/src/main/resources/private/"
CONTAINER_NAME="resource-allocation-service"

ed -s $RAS_FILE_PATH <<!
/false
s,false,true
w
q
!

sudo docker stop $CONTAINER_NAME
sudo docker start $CONTAINER_NAME
sudo docker cp $RAS_CONF_FILE_PATH $CONTAINER_NAME:$CONTAINER_CONF_DIR/$RAS_CONF_FILE_NAME

# Run RAS
sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

