#!/bin/bash
DIR=$(pwd)
BASE_DIR="services/federated-network-agent"

# Get Agent access password
GENERAL_CONF_FILE_NAME="general.conf"
CONF_FILES_DIR=$DIR/"conf-files"
echo "Copying $CONF_FILES_DIR/$GENERAL_CONF_FILE_NAME to $BASE_DIR/$GENERAL_CONF_FILE_NAME"
yes | cp -f $CONF_FILES_DIR/$GENERAL_CONF_FILE_NAME $BASE_DIR/$GENERAL_CONF_FILE_NAME

# Get Manager public key file
FOGBOW_PUBLIC_KEY_FILE_NAME="fogbow-id_rsa.pub"
echo "Copying $DIR/$FOGBOW_PUBLIC_KEY_FILE_NAME to $BASE_DIR/$MANAGER_PUBLIC_KEY_FILE_NAME"
yes | cp -f $DIR/$FOGBOW_PUBLIC_KEY_FILE_NAME $BASE_DIR/$MANAGER_PUBLIC_KEY_FILE_NAME

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
