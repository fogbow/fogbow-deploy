#!/bin/bash

# Add key to provide access from basic-site-machine to dfns-agent-machine

SITE_CONF_FILE_NAME="site.conf"

REMOTE_USER_PATTERN="remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $SITE_CONF_FILE_NAME | awk -F "=" '{print $2}')

AGENT_HOST_PUBLIC_KEY=$(cat dfns-agent-id_rsa.pub)

AUTHORIZED_KEYS_FILE_PATH=/"home"/$REMOTE_USER/".ssh"/"authorized_keys"
grep "$AGENT_HOST_PUBLIC_KEY" $AUTHORIZED_KEYS_FILE_PATH
if [ "$?" -ne "0" ]; then
        echo "" >> $AUTHORIZED_KEYS_FILE_PATH
        echo "$AGENT_HOST_PUBLIC_KEY" >> $AUTHORIZED_KEYS_FILE_PATH
fi
