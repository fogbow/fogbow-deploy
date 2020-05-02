#!/bin/bash

WORK_DIR=$(pwd)

# Remove xmpp-server container from earlier installation
sudo docker stop xmpp-server
sudo docker rm xmpp-server

# Create xmpp-server container
sudo docker run -tdi --name "xmpp-server" \
	-p 5269:5269 \
	-p 5347:5347 \
	-v $WORK_DIR/conf-files/xmpp/prosody.cfg.lua:/etc/prosody/prosody.cfg.lua \
	fogbow/xmpp-server:latest

#chmod 644 $CURRENT_DIR_PATH/$CONF_FILE_NAME
#sudo docker cp $CURRENT_DIR_PATH/$CONF_FILE_NAME $CONTAINER_NAME:$CONTAINER_BASE_DIR/$CONF_FILE_NAME
#chmod 600 $CURRENT_DIR_PATH/$CONF_FILE_NAME
#sudo docker exec $CONTAINER_NAME /bin/bash -c "service prosody restart"

# Install IPSEC agent
## Get agent public key
AGENT_HOST_PUBLIC_KEY=$(cat ./conf-files/ipsec/vanilla-agent-id_rsa.pub)
AUTHORIZED_KEYS_FILE_PATH=$WORK_DIR/".ssh/authorized_keys"
## Remove old keys
ed $AUTHORIZED_KEYS_FILE_PATH <<!
g/FNS-vanilla-key/d
w
q
!
## Add new key
echo "" >> $AUTHORIZED_KEYS_FILE_PATH
echo "$AGENT_HOST_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
## Start StrongSwan (IPSEC) service
sudo bash conf-files/ipsec/ipsec-installation.sh
