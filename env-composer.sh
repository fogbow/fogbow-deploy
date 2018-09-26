#!/bin/bash
DIR=$(pwd)
CONF_FILES_DIR=$DIR/"conf-files"
CONF_FILE_PATH=$CONF_FILES_DIR/"general.conf"

PRIVATE_KEY_PROPERTY="private_key_file_path"
PUBLIC_KEY_PROPERTY="public_key_file_path"
DMZ_PRIVATE_KEY_PROPERTY="dmz_private_key_file_path"
DMZ_PUBLIC_KEY_PROPERTY="dmz_public_key_file_path"
VPN_PASSWORD_PROPERTY="vpn_password"
XMPP_PASSWORD_PROPERTY="xmpp_password"
PASSWORD_PROPERTY="password"

DMZ_PRIVATE_KEY_PATH=$(grep $DMZ_PRIVATE_KEY_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
DMZ_PUBLIC_KEY_PATH=$(grep $DMZ_PUBLIC_KEY_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
PRIVATE_KEY_PATH=$(grep $PRIVATE_KEY_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
PUBLIC_KEY_PATH=$(grep $PUBLIC_KEY_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
VPN_PASSWORD_VALUE=$(grep $VPN_PASSWORD_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
XMPP_PASSWORD_VALUE=$(grep $XMPP_PASSWORD_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')
PASSWORD_VALUE=$(grep $PASSWORD_PROPERTY $CONF_FILE_PATH | awk -F "=" '{print $2}')

if [ -z "${PRIVATE_KEY_PATH// }" ] || [ ! -s "${PRIVATE_KEY_PATH// }" ] || [ ! -s "${PUBLIC_KEY_PATH// }" ] || [ ! -s "${PUBLIC_KEY_PATH// }" ]; then
	echo "Cannot identify the manager ssh private key"
	echo "Generating manager ssh private key"

	PRIVATE_KEY_PATH=$DIR/"fogbow-id_rsa"
	PUBLIC_KEY_PATH=$DIR/"fogbow-id_rsa.pub"
	RSA_KEY_PATH=$DIR/"rsa_key.pem"
	
	openssl genrsa -out $RSA_KEY_PATH 2048
	openssl pkcs8 -topk8 -in $RSA_KEY_PATH -out $PRIVATE_KEY_PATH -nocrypt
	openssl rsa -in $PRIVATE_KEY_PATH -outform PEM -pubout -out $PUBLIC_KEY_PATH
	chmod 600 $PRIVATE_KEY_PATH
	rm $RSA_KEY_PATH

	sed -i "s#$PRIVATE_KEY_PROPERTY=.*#$PRIVATE_KEY_PROPERTY=$PRIVATE_KEY_PATH#" $CONF_FILE_PATH
	sed -i "s#$PUBLIC_KEY_PROPERTY=.*#$PUBLIC_KEY_PROPERTY=$PUBLIC_KEY_PATH#" $CONF_FILE_PATH
fi

if [ -z "${DMZ_PRIVATE_KEY_PATH// }" ] || [ ! -s "${DMZ_PRIVATE_KEY_PATH// }" ] || [ ! -s "${DMZ_PUBLIC_KEY_PATH// }" ] || [ ! -s "${DMZ_PUBLIC_KEY_PATH// }" ]; then
	DMZ_PRIVATE_KEY_PATH=$DIR/"dmz-id_rsa"
	DMZ_PUBLIC_KEY_PATH=$DIR/"dmz-id_rsa.pub"

	ssh-keygen -f $DMZ_PRIVATE_KEY_PATH -t rsa -b 4096 -C "internal-communication-key" -N ""

	sed -i "s#.*$DMZ_PRIVATE_KEY_PROPERTY=.*#$DMZ_PRIVATE_KEY_PROPERTY=$DMZ_PRIVATE_KEY_PATH#" $CONF_FILE_PATH
	sed -i "s#.*$DMZ_PUBLIC_KEY_PROPERTY=.*#$DMZ_PUBLIC_KEY_PROPERTY=$DMZ_PUBLIC_KEY_PATH#" $CONF_FILE_PATH
fi

if [ -z ${PASSWORD_VALUE// } ]; then
	GENERATED_PASSWORD=$(pwgen 10 1)
	sed -i "s#$PASSWORD_PROPERTY=.*#$PASSWORD_PROPERTY=$GENERATED_PASSWORD#" $CONF_FILE_PATH
fi

if [ -z ${VPN_PASSWORD_VALUE// } ]; then
	GENERATED_PASSWORD=$(pwgen 10 1)
	sed -i "s#.*$VPN_PASSWORD_PROPERTY=.*#$VPN_PASSWORD_PROPERTY=$GENERATED_PASSWORD#" $CONF_FILE_PATH
fi

if [ -z ${XMPP_PASSWORD_VALUE// } ]; then
	GENERATED_PASSWORD=$(pwgen 10 1)
	sed -i "s#.*$XMPP_PASSWORD_PROPERTY=.*#$XMPP_PASSWORD_PROPERTY=$GENERATED_PASSWORD#" $CONF_FILE_PATH
fi
