#!/bin/bash
CONTAINER_NAME="xmpp-server"
PROSODY_CFG_FILE_PATH="/etc/prosody/prosody.cfg.lua"
ORIGINAL_PROSODY_CFG_FILE_NAME="prosody.cfg.lua"
TMP_PROSODY_CFG_FILE_NAME="prosody.cfg.lua.tmp"

cp $ORIGINAL_PROSODY_CFG_FILE_NAME $TMP_PROSODY_CFG_FILE_NAME

ed -s $TMP_PROSODY_CFG_FILE_NAME <<!
/^Component "ras
.,+t+
-
s,ras,fns
w
q
!

sudo docker cp $TMP_PROSODY_CFG_FILE_NAME $CONTAINER_NAME:$PROSODY_CFG_FILE_PATH

sudo docker exec $CONTAINER_NAME /bin/bash -c "service prosody restart"

rm $TMP_PROSODY_CFG_FILE_NAME
