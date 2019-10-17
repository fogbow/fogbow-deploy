#!/bin/bash

# Set file name variables

DEPLOY_DIR="federation"
DIR_PATH=$(pwd)
CONF_FILES_DIR=$DIR_PATH/"conf-files"
APACHE_CONF_FILES_DIR="apache-confs"
HOSTS_CONF_FILE="hosts.conf"
DOMAIN_NAMES_CONF_FILE="domain-names.conf"
ANSIBLE_FILES_DIR=$DIR_PATH/"ansible-playbook"/$DEPLOY_DIR
ANSIBLE_HOSTS_FILE=$ANSIBLE_FILES_DIR/"hosts"
ANSIBLE_CFG_FILE=$ANSIBLE_FILES_DIR/"ansible.cfg"

# Copy configuration files from templates
HOSTS_TEMPLATE_FILE="federation-hosts.conf"
yes | cp -f $CONF_FILES_DIR/$HOSTS_TEMPLATE_FILE $CONF_FILES_DIR/$HOSTS_CONF_FILE
DOMAIN_NAMES_TEMPLATE_FILE="federation-domain-names.conf"
yes | cp -f $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAMES_TEMPLATE_FILE $CONF_FILES_DIR/$APACHE_CONF_FILES_DIR/$DOMAIN_NAMES_CONF_FILE

# Generate content of Ansible hosts file

BASIC_SITE_HOST_IP_PATTERN="basic_site_host_ip"
BASIC_SITE_HOST_IP=$(grep $BASIC_SITE_HOST_IP_PATTERN $CONF_FILES_DIR/$HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Basic site host ip: $BASIC_SITE_HOST_IP"

BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN="basic_site_host_ssh_private_key_file"
BASIC_SITE_PRIVATE_KEY_FILE_PATH=$(grep $BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN $CONF_FILES_DIR/$HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Basic site ssh private key file path: $BASIC_SITE_PRIVATE_KEY_FILE_PATH"

XMPP_HOST_IP_PATTERN="xmpp_host_ip"
XMPP_HOST_IP=$(grep $XMPP_HOST_IP_PATTERN $CONF_FILES_DIR/$HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "XMPP host ip: $XMPP_SITE_HOST_IP"

XMPP_PRIVATE_KEY_FILE_PATH_PATTERN="xmpp_host_ssh_private_key_file"
XMPP_PRIVATE_KEY_FILE_PATH=$(grep $XMPP_PRIVATE_KEY_FILE_PATH_PATTERN $CONF_FILES_DIR/$HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "XMPP ssh private key file path: $XMPP_PRIVATE_KEY_FILE_PATH"

echo "[localhost]" > $ANSIBLE_HOSTS_FILE
echo "127.0.0.1" >> $ANSIBLE_HOSTS_FILE
echo "" >> $ANSIBLE_HOSTS_FILE
echo "[basic-site-machine]" >> $ANSIBLE_HOSTS_FILE
echo $BASIC_SITE_HOST_IP >> $ANSIBLE_HOSTS_FILE
echo "[basic-site-machine:vars]" >> $ANSIBLE_HOSTS_FILE
echo "ansible_ssh_private_key_file=$BASIC_SITE_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE
echo "" >> $ANSIBLE_HOSTS_FILE
echo "[xmpp-machine]" >> $ANSIBLE_HOSTS_FILE
echo $XMPP_HOST_IP >> $ANSIBLE_HOSTS_FILE
echo "[xmpp-machine:vars]" >> $ANSIBLE_HOSTS_FILE
echo "ansible_ssh_private_key_file=$XMPP_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE

# Generate content of Ansible ansible.cfg file

REMOTE_USER_PATTERN="^remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $CONF_FILES_DIR/$HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Remote user: $REMOTE_USER"

echo "[defaults]" > $ANSIBLE_CFG_FILE
echo "inventory = hosts" >> $ANSIBLE_CFG_FILE
echo "remote_user = $REMOTE_USER" >> $ANSIBLE_CFG_FILE
echo "host_key_checking = False" >> $ANSIBLE_CFG_FILE

# Deploy

(cd $ANSIBLE_FILES_DIR && ansible-playbook deploy.yml)

# House keeping

chmod -R go-rw conf-files
chmod -R go-rw services

find ./* -type f -name "secrets" -exec rm {} \;
