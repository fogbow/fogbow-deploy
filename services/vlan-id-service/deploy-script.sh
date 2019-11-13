#!/bin/bash

CONTAINER_NAME="vlan-id-service"

IMAGE_NAME="fogbow/vlan-id-service"

IMAGE_BASE_NAME=$(basename $IMAGE_NAME)
SERVICES_CONF=services.conf
TAG=$(grep $IMAGE_BASE_NAME $SERVICES_CONF | awk -F "=" '{print $2}')

if [ -z ${TAG// } ]; then
	TAG="latest"
fi

VLAN_ID_PORT=$(grep ^vlanid_port $SHARED_INFO_FILE_PATH | awk -F "=" '{print $2}')

IMAGE=$IMAGE_NAME:$TAG
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME
sudo docker pull $IMAGE

container_id=`sudo docker run --name $CONTAINER_NAME -p $VLAN_ID_PORT:8080 -idt $IMAGE`

sudo docker exec $container_id /bin/bash -c "mkdir src/main/resources/private"
sudo docker cp vlanid.conf $container_id:/root/vlan-id-service/src/main/resources/private
sudo docker exec $container_id /bin/bash -c "mvn spring-boot:run -X > log.out 2> log.err" &