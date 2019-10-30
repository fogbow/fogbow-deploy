#!/bin/bash

ONOS_CONTAINER_ID=$(sudo docker ps -a | grep onos | awk '{ print $1 }')
if [ cID-$ONOS_CONTAINER_ID != "cID-" ]; then
    sudo docker stop $ONOS_CONTAINER_ID
    sudo docker container rm $ONOS_CONTAINER_ID
    sudo docker system prune -af
    sudo docker container prune -f
fi

sudo apt-get remove openvswitch-common -y
sudo apt-get remove openvswitch-switch -y