#!/bin/bash
CONTAINER_NAME="federated-network-service"
CONF_FILE_DIR_PATH="./conf-files"
FNS_CONF_FILE_NAME="fns.conf"
DFNS_DRIVER_DIR_PATH=$CONF_FILE_DIR_PATH/"services/dfns"
DFSN_DRIVER_DIR_NAME="driver.conf"

mkdir -p $DFNS_DRIVER_DIR_PATH

touch $DFNS_DRIVER_DIR_PATH/$DFSN_DRIVER_DIR_NAME

ed -s $CONF_FILE_DIR_PATH/$FNS_CONF_FILE_NAME <<!
/^build/d
/^service_names/s,$,\,dfns
w
q
!

bash fns-deploy-deploy-script.sh
