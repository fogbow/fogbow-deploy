#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
CONF_FILE_PATH=$CONF_FILES_DIR/"secrets"
SHARED_INFO_FILE=$CONF_FILES_DIR/"shared.info"

VPN_PASSWORD_PROPERTY="vpn_password"
XMPP_PASSWORD_PROPERTY="xmpp_password"
DB_PASSWORD_PROPERTY="db_password"

touch $CONF_FILE_PATH
chmod 600 $CONF_FILE_PATH

# Fill passwords
GENERATED_PASSWORD=$(pwgen 10 1)
echo "$DB_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $CONF_FILE_PATH

GENERATED_PASSWORD=$(pwgen 10 1)
echo "$VPN_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $CONF_FILE_PATH

GENERATED_PASSWORD=$(pwgen 10 1)
echo "$XMPP_PASSWORD_PROPERTY=$GENERATED_PASSWORD" >> $CONF_FILE_PATH

# Fill XMPP ports
echo "" >> $SHARED_INFO_FILE

xmpp_s2s_port_key="xmpp_s2s_port"
xmpp_s2s_port_value=5269
echo "$xmpp_s2s_port_key=$xmpp_s2s_port_key" >> $SHARED_INFO_FILE

xmpp_c2s_port_key="xmpp_c2s_port"
xmpp_c2s_port_value=5222
echo "$xmpp_c2s_port_key=$xmpp_c2s_port_key" >> $SHARED_INFO_FILE

xmpp_c2c_port_key="xmpp_c2c_port"
xmpp_c2c_port_value=5347
echo "$xmpp_c2c_port_key=$xmpp_c2c_port_key" >> $SHARED_INFO_FILE
