#!/bin/bash

sudo docker stop onos_controller
sudo docker container rm onos_controller
sudo docker system prune -af
sudo docker container prune -f
sudo apt-get remove openvswitch-common -y
sudo apt-get remove openvswitch-switch -y

SITE_CONF_FILE_PATH="../conf-files/site.conf"

DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN="dfns_cluster_public_ips_list"
DFNS_CLUSTER_PUBLIC_IPS_LIST=$(grep $DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

OTHERS=""

for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
    if [ $i != $1 ]; then
        OTHERS=$OTHERS" "$i
    fi
do

echo $OTHERS

bash ./init_gateway.sh $1 $OTHERS