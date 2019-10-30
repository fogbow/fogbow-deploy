#!/bin/bash

SITE_CONF_FILE_PATH="../conf-files/site.conf"

DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN="dfns_cluster_public_ips_list"
DFNS_CLUSTER_PUBLIC_IPS_LIST=$(grep $DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

OTHERS=""

for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    if [ $i != $1 ]; then
        OTHERS=$OTHERS" "$i
    fi
done

echo $OTHERS

ONOS_SECRET=$2
export ONOS_SECRET

echo [$2][$ONOS_SECRET] > onos.secret.debug

bash ./init_gateway.sh $1 $OTHERS