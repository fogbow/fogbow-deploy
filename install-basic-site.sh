#!/bin/bash

# Set file name variables

DEPLOY_DIR="basic-site"
DIR_PATH=$(pwd)
HOSTS_CONF_FILE=$DIR_PATH/"conf-files"/"hosts.conf"
ANSIBLE_FILES_DIR=$DIR_PATH/"ansible-playbook"/$DEPLOY_DIR
ANSIBLE_HOSTS_FILE=$ANSIBLE_FILES_DIR/"hosts"
ANSIBLE_CFG_FILE=$ANSIBLE_FILES_DIR/"ansible.cfg"

# Generate content of Ansible hosts file

BASIC_SITE_HOST_IP_PATTERN="basic_site_host_ip"
BASIC_SITE_HOST_IP=$(grep $BASIC_SITE_HOST_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Basic site host ip: $BASIC_SITE_HOST_IP"

BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN="basic_site_host_ssh_private_key_file"
BASIC_SITE_PRIVATE_KEY_FILE_PATH=$(grep $BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
echo "Basic site ssh private key file path: $BASIC_SITE_PRIVATE_KEY_FILE_PATH"

echo "[localhost]" > $ANSIBLE_HOSTS_FILE
echo "127.0.0.1" >> $ANSIBLE_HOSTS_FILE
echo "" >> $ANSIBLE_HOSTS_FILE
echo "[basic-site-machine]" >> $ANSIBLE_HOSTS_FILE
echo $BASIC_SITE_HOST_IP >> $ANSIBLE_HOSTS_FILE
echo "[basic-site-machine:vars]" >> $ANSIBLE_HOSTS_FILE
echo "ansible_ssh_private_key_file=$BASIC_SITE_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE

# Generate content of Ansible ansible.cfg file

REMOTE_USER_PATTERN="^remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')
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