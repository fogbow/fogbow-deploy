#!/bin/bash

WORK_DIR=$(pwd)

# Remove xmpp-server container from earlier installation
sudo docker stop xmpp-server
sudo docker rm xmpp-server

# Installing XMPP Server (prosody)
## Creating xmpp-server container

sudo docker pull fogbow/xmpp-server:latest
sudo docker run -tdi --name "xmpp-server" \
	-p 5269:5269 \
	-p 5347:5347 \
	fogbow/xmpp-server:latest

## Copying prosody conf file and restart
PROSODY_CONF_FILE_PATH="./conf-files/xmpp/prosody.cfg.lua"
chmod 644 $PROSODY_CONF_FILE_PATH
sudo docker cp $PROSODY_CONF_FILE_PATH xmpp-server:/etc/prosody/prosody.cfg.lua
chmod 600 $PROSODY_CONF_FILE_PATH
sudo docker exec xmpp-server /bin/bash -c "service prosody restart"

# Installing IPSEC agent
## Getting agent public key
AGENT_HOST_PUBLIC_KEY=$(cat ./conf-files/ipsec/vanilla-agent-id_rsa.pub)
AUTHORIZED_KEYS_FILE_PATH=$WORK_DIR/".ssh/authorized_keys"
## Remove old keys
ed $AUTHORIZED_KEYS_FILE_PATH <<!
g/FNS-vanilla-key/d
w
q
!
## Adding new key
echo "" >> $AUTHORIZED_KEYS_FILE_PATH
echo "$AGENT_HOST_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
## Starting StrongSwan (IPSEC) service
sudo bash conf-files/ipsec/ipsec-installation.sh
