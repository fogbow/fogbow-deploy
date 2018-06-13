#!/bin/bash
DIR_PATH=$(pwd)

IMAGE_NAME="fogbow/dashboard:latest"
CONTAINER_NAME="dashboard"

CONTAINER_BASE_PATH="root/fogbow-dashboard-core"
CONF_FILE_NAME="local_settings.py"
CONTAINER_CONF_FILE_PATH="openstack_dashboard/local"

DASHBOARD_PORT="80"
CONTAINER_PORT="8080"

sudo docker pull $IMAGE_NAME
sudo docker stop $CONTAINER_NAME
sudo docker rm $CONTAINER_NAME

sudo docker run -tdi --name $CONTAINER_NAME \
	-p $DASHBOARD_PORT:$CONTAINER_PORT \
	-v $DIR_PATH/$CONF_FILE_NAME:$CONTAINER_BASE_PATH/$CONTAINER_CONF_FILE_PATH/$CONF_FILE_NAME \
	$IMAGE_NAME

