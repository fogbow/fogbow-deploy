#!/bin/bash
CONF_FILE_DIR_PATH="../fogbow-gui/conf-files"
GUI_CONF_FILE_NAME="gui.conf"

AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILE_DIR_PATH/$GUI_CONF_FILE_NAME | awk -F "=" '{print $2}')

if [ $AUTH_TYPE_CLASS == "shibboleth" ]; then
    AS_CONF_FILE_NAME="as.conf"
    TMP_AS_CONF_FILE_NAME="as.conf.tmp"
    CONF_FILE_DIR_PATH="./conf-files"
    SHIB_PUBLIC_KEY_FILE_NAME="shibboleth-app.pub"
    RECONFIGURATION_CONF_DIR_PATH="../reconfiguration/conf-files"

    cp $CONF_FILE_DIR_PATH/$AS_CONF_FILE_NAME $TMP_AS_CONF_FILE_NAME

    PROVIDER_ID_PATTERN="provider_id"
    PROVIDER_ID=$(grep ^$PROVIDER_ID_PATTERN $TMP_AS_CONF_FILE_NAME | awk -F "=" '{print $2}')
    PUBLIC_KEY_FILE_PATH_PATTERN="public_key_file_path"
    PUBLIC_KEY_FILE_PATH=$(grep ^$PUBLIC_KEY_FILE_PATH_PATTERN $TMP_AS_CONF_FILE_NAME | awk -F "=" '{print $2}')
    PRIVATE_KEY_FILE_PATH_PATTERN="private_key_file_path"
    PRIVATE_KEY_FILE_PATH=$(grep ^$PRIVATE_KEY_FILE_PATH_PATTERN $TMP_AS_CONF_FILE_NAME | awk -F "=" '{print $2}')

    echo "system_identity_provider_plugin_class=cloud.fogbow.as.core.systemidp.plugins.shibboleth.ShibbolethSystemIdentityProviderPlugin" > $TMP_AS_CONF_FILE_NAME
    echo "shib_public_key_file_name=$SHIB_PUBLIC_KEY_FILE_NAME" >> $TMP_AS_CONF_FILE_NAME
    echo "$PROVIDER_ID_PATTERN=$PROVIDER_ID" >> $TMP_AS_CONF_FILE_NAME
    echo "$PUBLIC_KEY_FILE_PATH_PATTERN=$PUBLIC_KEY_FILE_PATH" >> $TMP_AS_CONF_FILE_NAME
    echo "$PRIVATE_KEY_FILE_PATH_PATTERN=$PRIVATE_KEY_FILE_PATH" >> $TMP_AS_CONF_FILE_NAME

    cp $RECONFIGURATION_CONF_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME $CONF_FILE_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME
    cp $TMP_AS_CONF_FILE_NAME $CONF_FILE_DIR_PATH/$AS_CONF_FILE_NAME

    rm $TMP_AS_CONF_FILE_NAME
    bash basic-site-deploy-script.sh
fi
