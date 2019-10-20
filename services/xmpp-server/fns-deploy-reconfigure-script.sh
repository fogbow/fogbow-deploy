#!/bin/bash
CONTAINER_NAME="xmpp-server"
PROSODY_CFG_FILE_PATH="/etc/prosody/prosody.cfg.lua"
TMP_PROSODY_CFG_FILE_NAME="prosody.cfg.lua.tmp"

sudo docker cp $CONTAINER_NAME:$PROSODY_CFG_FILE_PATH $TMP_PROSODY_CFG_FILE_NAME
sudo chown ubuntu.ubuntu $TMP_PROSODY_CFG_FILE_NAME

ed -s $TMP_PROSODY_CFG_FILE_NAME <<!
/^Component "ras
.,+t+
-
s,ras,fns
w
q
!

sudo docker cp $TMP_PROSODY_CFG_FILE_NAME $CONTAINER_NAME:PROSODY_CFG_FILE_PATH

rm $TMP_PROSODY_CFG_FILE_NAME
