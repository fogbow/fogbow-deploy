#!/bin/bash

DIR=$(pwd)
BASE_DIR="services/federated-network-agent"

# Get Agent access password
MANAGER_CONFIGURED_FILE_NAME="manager.conf"
MANAGER_CONFIGURED_FILES_DIR=$DIR/"services"/"manager-core"/"conf-files"

echo "Copying $MANAGER_CONFIGURED_FILES_DIR/$MANAGER_CONFIGURED_FILE_NAME to $BASE_DIR/$MANAGER_CONFIGURED_FILE_NAME"

yes | cp -f $MANAGER_CONFIGURED_FILES_DIR/$MANAGER_CONFIGURED_FILE_NAME $BASE_DIR/$MANAGER_CONFIGURED_FILE_NAME

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
