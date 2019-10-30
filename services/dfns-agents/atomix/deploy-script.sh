#!/bin/bash

ATOMIX_CONTAINER_ID=$(sudo docker ps -a | grep atomix | awk '{ print $1 }')
if [ cID-$ATOMIX_CONTAINER_ID != "cID-" ]; then
    sudo docker stop $ATOMIX_CONTAINER_ID
    sudo docker container rm $ATOMIX_CONTAINER_ID
    sudo docker system prune -af
    sudo docker container prune -f
fi

SITE_CONF_FILE_PATH="../conf-files/site.conf"

DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN="dfns_cluster_public_ips_list"
DFNS_CLUSTER_PUBLIC_IPS_LIST=$(grep $DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

OTHERS=""

for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    if [ $i != $1 ]; then
        OTHERS=$OTHERS" "$i
    fi
done

echo $OTHERS

bash ./init_atomix_node.sh $1 $OTHERS