#!/bin/bash
CONF_FILE_DIR_PATH="services/fogbow-gui/conf-files"
GUI_CONF_FILE_NAME="gui.conf"

AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILE_DIR_PATH/$GUI_CONF_FILE_NAME | awk -F "=" '{print $2}')

if [ $AUTH_TYPE_CLASS == "shibboleth" ]; then
    CONTAINER_NAME="authentication-server"
    AS_CONF_FILE_NAME="as.conf"
    TMP_AS_CONF_FILE_NAME="as.conf.tmp"
    CONTAINER_CONF_FILE_DIR_PATH="/root/authentication-service/src/main/resources/private"
    SHIB_PUBLIC_KEY_FILE_NAME="shibboleth-app.pub"
    RECONFIGURATION_CONF_DIR_PATH="services/reconfiguration/conf-files"

    echo "system_identity_provider_plugin_class=cloud.fogbow.as.core.systemidp.plugins.shibboleth.ShibbolethSystemIdentityProviderPlugin" > $TMP_AS_CONF_FILE_NAME
    echo "shib_public_key_file_name=$CONTAINER_CONF_FILE_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME" >> $TMP_AS_CONF_FILE_NAME

    sudo docker cp $RECONFIGURATION_CONF_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME $CONTAINER_NAME:$CONTAINER_CONF_FILE_DIR_PATH/$SHIB_PUBLIC_KEY_FILE_NAME
    sudo docker cp $TMP_AS_CONF_FILE_NAME $CONTAINER_NAME:$CONTAINER_CONF_FILE_DIR_PATH/$TMP_AS_CONF_FILE_NAME
    sudo docker exec $CONTAINER_NAME /bin/bash -c "./mvnw spring-boot:run -X > log.out 2> log.err" &

    rm $TMP_AS_CONF_FILE_NAME
fi
