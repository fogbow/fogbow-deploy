#!/bin/bash
CONTAINER_NAME="apache-server"
VIRTUAL_HOST_DIR_PATH="/etc/apache2/sites-available"
VIRTUAL_HOST_FILE_NAME="000-default.conf"
TMP_VIRTUAL_HOST_FILE_NAME="000-default.conf.tmp"

sudo docker cp $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_FILE_NAME $TMP_VIRTUAL_HOST_FILE_NAME
sudo chown ubuntu.ubuntu $TMP_VIRTUAL_HOST_FILE_NAME

ed -s $TMP_VIRTUAL_HOST_FILE_NAME <<!
/ms
.,+t+
-
.,+1s,ms,  ,g
-
.,+1s,8083,8084
w
q
!

sudo docker cp $TMP_VIRTUAL_HOST_FILE_NAME $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_FILE_NAME

rm $TMP_VIRTUAL_HOST_FILE_NAME

CONF_FILE_DIR_PATH="services/fogbow-gui/conf-files"
GUI_CONF_FILE_NAME="gui.conf"

AUTH_TYPE_PATTERN="authentication_type"
AUTH_TYPE_CLASS=$(grep $AUTH_TYPE_PATTERN $CONF_FILE_DIR_PATH/$GUI_CONF_FILE_NAME | awk -F "=" '{print $2}')

if [ "$AUTH_TYPE_CLASS" == "shibboleth" ]; then
    CERTS_DIR_PATH="/etc/ssl/certs"
    SSL_DIR_PATH="/etc/ssl/private"
    BASE_DIR_PATH="services/reconfiguration/conf-files"
    SHIB_CONF_DIR_PATH="/etc/shibboleth"
    SHIB_AUTH_APP_DIR_PATH="/home/ubuntu/shibboleth-authentication-application"
    SECURE_INDEX_PATH="/var/www/secure/index.html"
    VIRTUAL_HOST_SHIB_ENVIRONMENT_80_FILE_NAME="default.conf"
    VIRTUAL_HOST_SHIB_ENVIRONMENT_443_FILE="shibboleth-sp2.conf"
    CONF_SHIB_ENV_ATT_MAP_FILE_NAME="attribute-map.xml"
    CONF_SHIB_ENV_ATT_POLICY_FILE_NAME="attribute-policy.xml"
    CONF_SHIB_ENV_SHIB_XML_FILE_NAME="shibboleth2.xml"
    CONF_SHIB_ENV_INDEX_SECURE_FILE_NAME="index-secure.html"
    SHIB_AUTH_APP_CONF_FILE_NAME="shibboleth-authentication-application.conf"
    SHIB_AUTH_APP_LOG4J_FILE_NAME="log4j.properties"
    AS_PUBLIC_KEY_NAME='authentication_service_public_key.pem'
    SHIB_PRIVATE_KEY_NAME='shibboleth_app.pri'
    SERVICE_PROVIDER_DOMAIN_PATTERN="domain_service_provider"
    SERVICE_PROVIDER_DOMAIN_NAME=$(grep $SERVICE_PROVIDER_DOMAIN_PATTERN $BASE_DIR_PATH/$SHIBBOLETH_CONF_FILE | awk -F "=" '{print $2}')

    sudo docker cp $BASE_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_80_FILE_NAME $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_80_FILE_NAME
    sudo docker cp $BASE_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_443_FILE $CONTAINER_NAME:$VIRTUAL_HOST_DIR_PATH/$VIRTUAL_HOST_SHIB_ENVIRONMENT_443_FILE
    sudo docker cp $BASE_DIR_PATH/$CONF_SHIB_ENV_ATT_MAP_FILE_NAME $CONTAINER_NAME:$SHIB_CONF_DIR_PATH/$CONF_SHIB_ENV_ATT_MAP_FILE_NAME
    sudo docker cp $BASE_DIR_PATH/$CONF_SHIB_ENV_SHIB_XML_FILE_NAME $CONTAINER_NAME:$SHIB_CONF_DIR_PATH/$CONF_SHIB_ENV_SHIB_XML_FILE_NAME
    sudo docker cp $BASE_DIR_PATH/$CONF_SHIB_ENV_ATT_POLICY_FILE_NAME $CONTAINER_NAME:$SHIB_CONF_DIR_PATH/$CONF_SHIB_ENV_ATT_POLICY_FILE_NAME
    sudo docker exec -it $CONTAINER_NAME mkdir -p /var/www/secure
    sudo docker cp $BASE_DIR_PATH/$CONF_SHIB_ENV_INDEX_SECURE_FILE_NAME $CONTAINER_NAME:$SECURE_INDEX_PATH
    sudo docker cp $BASE_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME $CONTAINER_NAME:$SHIB_AUTH_APP_DIR_PATH
    sudo docker cp $BASE_DIR_PATH/$SHIB_AUTH_APP_LOG4J_FILE_NAME $CONTAINER_NAME:$SHIB_AUTH_APP_DIR_PATH
    sudo docker exec -it $CONTAINER_NAME sed "s/#DAEMON_USER=_shibd/DAEMON_USER=root/g" /etc/init.d/shibd

    sudo docker cp $BASE_DIR_PATH/$SERVICE_PROVIDER_CERTIFICATE_FILE_NAME $CONTAINER_NAME:$CERTS_DIR_PATH/$SERVICE_PROVIDER_DOMAIN_NAME.crt
    sudo docker cp $BASE_DIR_PATH/$SERVICE_PROVIDER_CERTIFICATE_KEY_FILE_NAME $CONTAINER_NAME:$SSL_DIR_PATH/$SERVICE_PROVIDER_DOMAIN_NAME.key

    sudo docker cp $SHARED_FOLDER/. $CONTAINER_NAME:$CONTAINER_BASE_DIR/$SHARED_FOLDER

    AS_CONTAINER_NAME="authentication-server"
    AS_CONTAINER_CONF_FILE_DIR_PATH="/root/authentication-service/src/main/resources/private"
    AS_PUB_KEY_FILE_NAME="id_rsa.pub"
    RECONFIGURATION_CONF_DIR_PATH="services/reconfiguration/conf-files"
    sudo docker cp $AS_CONTAINER_NAME:$AS_CONTAINER_CONF_FILE_DIR_PATH/$AS_PUB_KEY_FILE_NAME $BASE_DIR_PATH/$AS_PUB_KEY_FILE_NAME
    sudo docker cp $BASE_DIR_PATH/$AS_PUB_KEY_FILE_NAME $CONTAINER_NAME:$CONTAINER_CONF_FILE_DIR_PATH/$AS_PUB_KEY_FILE_NAME
    SHIB_PRIVATE_KEY_FILE_NAME="shibboleth-app.pri"
    sudo docker cp $BASE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME $CONTAINER_NAME:$CONTAINER_CONF_FILE_DIR_PATH/$SHIB_PRIVATE_KEY_FILE_NAME

    SHIB_AUTH_APP_CONF_FILE_NAME="shibboleth-authentication-application.conf"

    SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN="ship_private_key_path="
    sed -i "s#$SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN#$SHIB_AUTH_APP_SHIB_PRIVATE_KEY_PATTERN$AS_CONTAINER_CONF_FILE_DIR_PATH/$SHIB_PRIVATE_KEY_NAME#" $BASE_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME
    SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN="as_public_key_path"
    sed -i "s#$SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN#$SHIB_AUTH_APP_AS_PUBLIC_KEY_PATTERN$AS_CONTAINER_CONF_FILE_DIR_PATH/$AS_PUB_KEY_FILE_NAME#" $BASE_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME

    CONTAINER_SHIB_APP_CONF_DIR_PATH="/home/ubuntu/shibboleth-authentication-application"
    sudo docker cp $BASE_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME $CONTAINER_NAME:$CONTAINER_SHIB_APP_CONF_DIR_PATH/$SHIB_AUTH_APP_CONF_FILE_NAME

    sudo docker exec $CONTAINER_NAME /bin/bash -c "bash bin/start-shib-app.sh" &
fi

sudo docker exec $CONTAINER_NAME /bin/bash -c "/etc/init.d/apache2 restart"