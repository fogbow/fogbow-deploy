#!/bin/bash

DIR=$(pwd)
BASE_DIR="services/federated-network-agent"

# Get Agent access password
MANAGER_CONFIGURED_FILE_NAME="manager.conf"
MANAGER_CONFIGURED_FILES_DIR=$DIR/"services"/"resource-allocation-service"/"conf-files"

echo "Copying $MANAGER_CONFIGURED_FILES_DIR/$MANAGER_CONFIGURED_FILE_NAME to $BASE_DIR/$MANAGER_CONFIGURED_FILE_NAME"

yes | cp -f $MANAGER_CONFIGURED_FILES_DIR/$MANAGER_CONFIGURED_FILE_NAME $BASE_DIR/$MANAGER_CONFIGURED_FILE_NAME

# Get Manager public key file
MANAGER_CONFIGURED_FILES_DIR=$DIR/"services"/"resource-allocation-service"/"conf-files"
MANAGER_CONFIGURED_FILE=$MANAGER_CONFIGURED_FILES_DIR/"manager.conf"

MANAGER_SSH_PUBLIC_KEY_FILE_PATH_PATTERN="manager_ssh_public_key_file_path"
MANAGER_SSH_PUBLIC_KEY_FILE_NAME=$(grep $MANAGER_SSH_PUBLIC_KEY_FILE_PATH_PATTERN $MANAGER_CONFIGURED_FILE | awk -F "=" '{print $2}' | xargs basename)
MANAGER_SSH_PUBLIC_KEY_FILE_PATH=$MANAGER_CONFIGURED_FILES_DIR/$MANAGER_SSH_PUBLIC_KEY_FILE_NAME

MANAGER_PUBLIC_KEY_FILE_NAME="manager-public-key.pub"

echo "Copying $MANAGER_SSH_PUBLIC_KEY_FILE_PATH to $BASE_DIR/$MANAGER_PUBLIC_KEY_FILE_NAME"

yes | cp -f $MANAGER_SSH_PUBLIC_KEY_FILE_PATH $BASE_DIR/$MANAGER_PUBLIC_KEY_FILE_NAME

# Get hosts.conf file
CONF_FILES_DIR=$DIR/"conf-files"
HOSTS_CONF_FILE_PATH=$CONF_FILES_DIR/"hosts.conf"

echo "Copying $HOSTS_CONF_FILE_PATH to $BASE_DIR directory"

yes | cp -f $HOSTS_CONF_FILE_PATH $BASE_DIR

# Download Agent scripts
echo "Downloading agent scripts"

RENAMED_CREATE_FEDNET_SCRIPT="create-federated-network"
RENAMED_DELETE_FEDNET_SCRIPT="delete-federated-network"

wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-create-federated-network -O $BASE_DIR/$RENAMED_CREATE_FEDNET_SCRIPT

wget -q https://raw.githubusercontent.com/fogbow/federated-network-service/master/bin/agent-scripts/config-delete-federated-network -O $BASE_DIR/$RENAMED_DELETE_FEDNET_SCRIPT

echo "Creating create and delete script to agent docker container"

cat > $BASE_DIR/config-create-federated-network <<EOF
#!/bin/sh

echo "Args: \$1 \$2 \$3 \$4"

docker exec -it strongswan /bin/sh -c "bash $RENAMED_CREATE_FEDNET_SCRIPT \$1 \$2 \$3 \$4"
EOF

cat > $BASE_DIR/config-delete-federated-network <<EOF
#!/bin/sh

echo "Args: \$1 \$2 \$3 \$4"

docker exec -it strongswan /bin/sh -c "bash $RENAMED_DELETE_FEDNET_SCRIPT \$1"
EOF
