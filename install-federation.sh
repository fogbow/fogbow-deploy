#!/bin/bash
# This script goal is to generate the Ansible hosts and ansible.cfg files

# Set path variables

SITE_CONF_FILE_NAME="./federation/conf-files/site.conf"
ANSIBLE_FILES_DIR_PATH="./federation/ansible-playbook"
ANSIBLE_HOSTS_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"hosts"
ANSIBLE_CFG_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"ansible.cfg"

# Generate content of Ansible hosts file

SERVICE_HOST_IP_PATTERN="service_host_ip"
SERVICE_HOST_IP=$(grep $SERVICE_HOST_IP_PATTERN $SITE_CONF_FILE_NAME | cut -d"=" -f2-)
SERVICE_HOST_PRIVATE_KEY_FILE_PATH_PATTERN="service_host_ssh_private_key_file"
SERVICE_HOST_PRIVATE_KEY_FILE_PATH=$(grep $SERVICE_HOST_PRIVATE_KEY_FILE_PATH_PATTERN $SITE_CONF_FILE_NAME | cut -d"=" -f2-)
DMZ_HOST_PRIVATE_IP_PATTERN="dmz_host_private_ip"
DMZ_HOST_PRIVATE_IP=$(grep $DMZ_HOST_PRIVATE_IP_PATTERN $SITE_CONF_FILE_NAME | cut -d"=" -f2-)
DMZ_HOST_PRIVATE_KEY_FILE_PATH_PATTERN="dmz_host_ssh_private_key_file"
DMZ_HOST_PRIVATE_KEY_FILE_PATH=$(grep $DMZ_HOST_PRIVATE_KEY_FILE_PATH_PATTERN $SITE_CONF_FILE_NAME | cut -d"=" -f2-)

echo "[localhost]" > $ANSIBLE_HOSTS_FILE_PATH
echo "127.0.0.1" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[service_host]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $SERVICE_HOST_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[service_host:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$SERVICE_HOST_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[dmz_host]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $DMZ_HOST_PRIVATE_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[dmz_host:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$DMZ_HOST_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH

# Generate content of Ansible ansible.cfg file

REMOTE_USER_PATTERN="^remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $SITE_CONF_FILE_NAME | cut -d"=" -f2-)

echo "[defaults]" > $ANSIBLE_CFG_FILE_PATH
echo "inventory = hosts" >> $ANSIBLE_CFG_FILE_PATH
echo "remote_user = $REMOTE_USER" >> $ANSIBLE_CFG_FILE_PATH
echo "host_key_checking = False" >> $ANSIBLE_CFG_FILE_PATH

# Deploy

(cd $ANSIBLE_FILES_DIR_PATH && ansible-playbook deploy.yml)