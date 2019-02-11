#!/bin/bash

DIR_PATH=$(pwd)

HOSTS_CONF_FILE=$DIR_PATH/"conf-files"/"hosts.conf"

ANSIBLE_FILES_DIR=$DIR_PATH/"ansible-playbook"
ANSIBLE_HOSTS_FILE=$ANSIBLE_FILES_DIR/"hosts"
ANSIBLE_CFG_FILE=$ANSIBLE_FILES_DIR/"ansible.cfg"

DMZ_HOST_PRIVATE_IP_PATTERN="dmz_host_private_ip"
DMZ_HOST_PRIVATE_IP=$(grep $DMZ_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

INTERNAL_HOST_PRIVATE_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_PRIVATE_IP=$(grep $INTERNAL_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "DMZ host private ip: $DMZ_HOST_PRIVATE_IP"
echo "Internal host private ip: $INTERNAL_HOST_PRIVATE_IP"

PATTERN_HELPER="\[dmz-machine\]"
DMZ_HOST_IP_PATTERN=$(grep -A1 $PATTERN_HELPER $ANSIBLE_HOSTS_FILE | tail -n 1)
sed -i "s/$DMZ_HOST_IP_PATTERN/$DMZ_HOST_PRIVATE_IP/" $ANSIBLE_HOSTS_FILE

PATTERN_HELPER="\[internal-machine\]"
INTERNAL_HOST_IP_PATTERN=$(grep -A1 $PATTERN_HELPER $ANSIBLE_HOSTS_FILE | tail -n 1)
sed -i "s/$INTERNAL_HOST_IP_PATTERN/$INTERNAL_HOST_PRIVATE_IP/" $ANSIBLE_HOSTS_FILE

# Ansible ssh private key file path
PRIVATE_KEY_FILE_PATH_PATTERN="ansible_ssh_private_key_file"
PRIVATE_KEY_FILE_PATH=$(grep $PRIVATE_KEY_FILE_PATH_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "Ansible ssh private key file path: $PRIVATE_KEY_FILE_PATH"
sed -i "s#.*$PRIVATE_KEY_FILE_PATH_PATTERN=.*#$PRIVATE_KEY_FILE_PATH_PATTERN=$PRIVATE_KEY_FILE_PATH#g" $ANSIBLE_HOSTS_FILE

# Ansible hosts remote users
REMOTE_HOSTS_USER_PATTERN="remote_hosts_user"
REMOTE_HOSTS_USER=$(grep $REMOTE_HOSTS_USER_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

REMOTE_HOSTS_USER_CFG_PATTERN="remote_user"
echo "Remote hosts user: $REMOTE_HOSTS_USER"
sed -i "s#.*$REMOTE_HOSTS_USER_CFG_PATTERN = .*#$REMOTE_HOSTS_USER_CFG_PATTERN = $REMOTE_HOSTS_USER#g" $ANSIBLE_CFG_FILE

DEPLOY_FOGBOW_FILE_PATH="deploy-fogbow.yml"

(cd ansible-playbook && ansible-playbook $DEPLOY_FOGBOW_FILE_PATH)

chmod -R go-rw conf-files
chmod -R go-rw services

CONF_FILE_PATH=$DIR_PATH/"conf-files"/"secrets"
rm $CONF_FILE_PATH
