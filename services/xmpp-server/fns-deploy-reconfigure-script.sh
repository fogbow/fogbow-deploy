#!/bin/bash
CONTAINER_NAME="xmpp-server"
PROSODY_CFG_FILE_PATH="/etc/prosody/prosody.cfg.lua"
TMP_PROSODY_CFG_FILE_PATH="/etc/prosody/prosody.cfg.lua.tmp"

sudo docker cp $CONTAINER_NAME:$PROSODY_CFG_FILE_PATH $TMP_PROSODY_CFG_FILE_PATH
sudo chown ubuntu.ubuntu $TMP_PROSODY_CFG_FILE_PATH

ed -s $TMP_PROSODY_CFG_FILE_PATH <<!
/^Component "ras
.,+t+
-
s,ras,fns
w
q
!

sudo docker cp $TMP_PROSODY_CFG_FILE_PATH $CONTAINER_NAME:PROSODY_CFG_FILE_PATH

rm $TMP_PROSODY_CFG_FILE_PATH
