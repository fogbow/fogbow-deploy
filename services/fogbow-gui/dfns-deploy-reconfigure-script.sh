#!/bin/bash

## Edit ../fogbow-gui/api.config.js

API_CONFIG_JS_FILE_NAME="api.config.js"
FNS_MODES=$(grep "fnsModes" $API_CONFIG_JS_FILE_NAME | awk -F "=" '{ print $2 }')
DFNS=$(echo $FNS_MODES | grep dfns)

if [ "S"$DFNS == "S" ]; then
    sed -i "s#]#,'dfns']#"  $API_CONFIG_JS_FILE_NAME
fi

bash gui-deploy-deploy-script.sh
