#!/bin/bash

SITE_CONF_FILE_PATH="./conf-files/site.conf"

DFNS_AGENTS_NODE_LIST_PATTERN="dfns_agents_public_ips_list"
DFNS_AGENTS_NODE_LIST=$(grep $DFNS_AGENTS_NODE_LIST_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

OTHERS=""

for i in $DFNS_AGENTS_NODE_LIST
    if [ $i != $1 ]; then
        OTHERS=$OTHERS" "$i
    fi
do

echo $OTHERS
