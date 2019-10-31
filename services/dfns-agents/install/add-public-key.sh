#!/bin/bash

# key to provide access from basic-site-machine to dfns-agent-machine
AGENT_HOST_PUBLIC_KEY=$(cat dfns-agent-id_rsa.pub)

AUTHORIZED_KEYS_FILE_PATH=/"home"/$REMOTE_USER/".ssh"/"authorized_keys"
grep "$AGENT_HOST_PUBLIC_KEY" $AUTHORIZED_KEYS_FILE_PATH
if [ "$?" -ne "0" ]; then
	echo "$AGENT_HOST_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
fi