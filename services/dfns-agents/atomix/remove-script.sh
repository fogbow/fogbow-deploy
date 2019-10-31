#!/bin/bash

ATOMIX_CONTAINER_ID=$(sudo docker ps -a | grep atomix | awk '{ print $1 }')
if [ cID-$ATOMIX_CONTAINER_ID != "cID-" ]; then
    sudo docker stop $ATOMIX_CONTAINER_ID
    sudo docker container rm $ATOMIX_CONTAINER_ID
    sudo docker system prune -af
    sudo docker container prune -f
fi