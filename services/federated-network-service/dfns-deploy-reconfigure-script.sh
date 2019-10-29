#!/bin/bash
CONTAINER_NAME="federated-network-service"
CONF_FILE_DIR_PATH="./conf-files"
FNS_CONF_FILE_NAME="fns.conf"
DFNS_CONF_FILE_NAME="dfns.conf"
DFNS_DRIVER_FILE_NAME="driver.conf"
DFNS_DRIVER_DIR_PATH=$CONF_FILE_DIR_PATH/"services/dfns"

## Edit fns.conf

ed -s $CONF_FILE_DIR_PATH/$FNS_CONF_FILE_NAME <<!
/^build/d
/^service_names/s,$,\,dfns
w
q
!

## Create and edit services/dfns/driver.conf

mkdir -p $DFNS_DRIVER_DIR_PATH

cp $CONF_FILE_DIR_PATH/$DFNS_CONF_FILE_NAME $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

echo "driver_class_name=cloud.fogbow.fns.core.drivers.dfns.DfnsServiceDriver" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME
echo "" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

#agent_scripts_path=/home/ubuntu/fogbow-components/federated-network-agent/
#federated_network_agent_permission_file_path=src/main/resources/private/dmz-id_rsa
#federated_network_agent_user=ubuntu
#federated_network_agent_private_address=10.11.16.28
#federated_network_agent_address=150.165.15.9
#federated_network_agent_pre_shared_key=neemau6Yix
#host_ip=150.165.15.9


echo "create_tunnel_from_compute_to_agent_script_path=/root/federated-network-service/bin/agent-scripts/dfns/create-tunnel-from-compute-to-agent.sh" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME
echo "agent_scripts_path=/home/ubuntu/fogbow-components/federated-network-agent/" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME
echo "" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

#VANILLA_AGENT_PRIVATE_IP_PATTERN="vanilla_agent_private_ip"
#VANILLA_AGENT_PRIVATE_IP=$(grep $VANILLA_AGENT_PRIVATE_IP_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$FNS_DEPLOY_CONF_FILE_NAME | awk -F "=" '{print $2}')
#echo "host_ip=$VANILLA_AGENT_PRIVATE_IP" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME
#echo "federated_network_agent_private_address=$VANILLA_AGENT_PRIVATE_IP" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

#VANILLA_AGENT_PUBLIC_IP_PATTERN="vanilla_agent_public_ip"
#VANILLA_AGENT_PUBLIC_IP=$(grep $VANILLA_AGENT_PUBLIC_IP_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$FNS_DEPLOY_CONF_FILE_NAME | awk -F "=" '{print $2}')
#echo "federated_network_agent_address=$VANILLA_AGENT_PUBLIC_IP" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

#PERMISSION_FILE_PATH=$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILES_DIR/"vanilla-agent-id_rsa"
#echo "federated_network_agent_permission_file_path=$PERMISSION_FILE_PATH" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

#REMOTE_USER_PATTERN="remote_user"
#REMOTE_USER=$(grep $REMOTE_USER_PATTERN $CONF_FILE_TEMPLATE_DIR_PATH/$FNS_DEPLOY_CONF_FILE_NAME | awk -F "=" '{print $2}')
#echo "federated_network_agent_user=$REMOTE_USER" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

#VPN_PASSWORD_KEY="vpn_password"
#VPN_PASSWORD=$(grep $VPN_PASSWORD_KEY $CONF_FILE_DIR_PATH/$SECRETS_FILE_NAME | awk -F "=" '{print $2}')
#echo "federated_network_agent_pre_shared_key=$VPN_PASSWORD" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME


ed -s $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME <<!
w
q
!

bash fns-deploy-deploy-script.sh
