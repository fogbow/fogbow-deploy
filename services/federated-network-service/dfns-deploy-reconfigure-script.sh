#!/bin/bash
SERVICE="federated-network-service"
CONTAINER_NAME=$SERVICE
CONF_FILE_DIR_PATH="./conf-files"
SITE_CONF_FILE_NAME="site.conf"
FNS_CONF_FILE_NAME="fns.conf"
DFNS_CONF_FILE_NAME="dfns.conf"
DFNS_DRIVER_FILE_NAME="driver.conf"
DFNS_DRIVER_DIR_PATH=$CONF_FILE_DIR_PATH/"services/dfns"
CONTAINER_BASE_DIR_PATH="/root"/$SERVICE
CONTAINER_CONF_FILES_DIR="src/main/resources/private"

## Edit fns.conf

SERVICE_NAMES=$(grep "^service_names" $CONF_FILE_DIR_PATH/$FNS_CONF_FILE_NAME | awk -F "=" '{ print $2 }')
DFNS=$(echo $SERVICE_NAMES | grep dfns)

if [S$DFNS == S]; then
    sed -i "s/^service_names=.*/service_names=$SERVICE_NAMES,dfns" $CONF_FILE_DIR_PATH/$FNS_CONF_FILE_NAME
fi

## Create and edit services/dfns/driver.conf

mkdir -p $DFNS_DRIVER_DIR_PATH

cp $CONF_FILE_DIR_PATH/$DFNS_CONF_FILE_NAME $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

echo "driver_class_name=cloud.fogbow.fns.core.drivers.dfns.DfnsServiceDriver" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME
echo "create_tunnel_from_compute_to_agent_script_path=/root/federated-network-service/bin/agent-scripts/dfns/create-tunnel-from-compute-to-agent.sh" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME
echo "agent_scripts_path=/home/ubuntu/fogbow-components/federated-network-agent/" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

DFNS_AGENT_PRIVATE_IP_PATTERN="dfns_agent_private_ip"
DFNS_AGENT_PRIVATE_IP=$(grep $DFNS_AGENT_PRIVATE_IP_PATTERN $CONF_FILE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')
echo "federated_network_agent_private_address=$DFNS_AGENT_PRIVATE_IP" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

DFNS_AGENT_PUBLIC_IP_PATTERN="dfns_agent_private_ip"
DFNS_AGENT_PUBLIC_IP=$(grep $DFNS_AGENT_PUBLIC_IP_PATTERN $CONF_FILE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')
echo "federated_network_agent_address=$DFNS_AGENT_PUBLIC_IP" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME
echo "host_ip=$DFNS_AGENT_PUBLIC_IP" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

PERMISSION_FILE_PATH=$CONTAINER_BASE_DIR_PATH/$CONTAINER_CONF_FILES_DIR/"dfns-agent-id_rsa"
echo "federated_network_agent_permission_file_path=$PERMISSION_FILE_PATH" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

REMOTE_USER_PATTERN="remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $CONF_FILE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')
echo "federated_network_agent_user=$REMOTE_USER" >> $DFNS_DRIVER_DIR_PATH/$DFNS_DRIVER_FILE_NAME

# Create dfns agent key pair
AGENT_PRIVATE_KEY_FILE_PATH="./dfns-agent-id_rsa"
AGENT_PUBLIC_KEY_FILE_PATH="./dfns-agent-id_rsa.pub"

ssh-keygen -f $AGENT_PRIVATE_KEY_FILE_PATH -t rsa -b 4096 -C "internal-communication-key" -N ""

sudo docker cp $AGENT_PRIVATE_KEY_FILE_PATH $CONTAINER_NAME:$PERMISSION_FILE_PATH

AGENT_HOST_PUBLIC_KEY=$(cat ./dfns-agent-id_rsa.pub)

AUTHORIZED_KEYS_FILE_NAME="authorized_keys"
AUTHORIZED_KEYS_FILE_PATH=/"home"/$REMOTE_USER/".ssh"/$AUTHORIZED_KEYS_FILE_NAME

DFNS_AGENT_HOST_PRIVATE_KEY_FILE_PATH_PATH_PATTERN="dfns_cluster_ssh_private_key_file"
DFNS_AGENT_HOST_PRIVATE_KEY_FILE_PATH_PATH=$(grep $DFNS_AGENT_HOST_PRIVATE_KEY_FILE_PATH_PATH_PATTERN $CONF_FILE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')
DFNS_AGENT_HOST_PATTERN="dfns_agent_private_ip"
DFNS_AGENT_HOST=$(grep $DFNS_AGENT_HOST_PATTERN $CONF_FILE_DIR_PATH/$SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

scp -i $DFNS_AGENT_HOST_PRIVATE_KEY_FILE_PATH_PATH $REMOTE_USER@$DFNS_AGENT_HOST:$AUTHORIZED_KEYS_FILE_PATH $AUTHORIZED_KEYS_FILE_NAME

grep "$AGENT_HOST_PUBLIC_KEY" $AUTHORIZED_KEYS_FILE_PATH
if [ "$?" -ne "0" ]; then
	echo "$AGENT_HOST_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
	scp -i $DFNS_AGENT_HOST_PRIVATE_KEY_FILE_PATH_PATH $AUTHORIZED_KEYS_FILE_NAME $REMOTE_USER@$DFNS_AGENT_HOST:$AUTHORIZED_KEYS_FILE_PATH
fi

rm $AGENT_PRIVATE_KEY_FILE_PATH $AGENT_PUBLIC_KEY_FILE_PATH $AUTHORIZED_KEYS_FILE_PATH

bash fns-deploy-deploy-script.sh
