#!/bin/bash

DIR_PATH=$(pwd)

HOSTS_CONF_FILE=$DIR_PATH/"conf-files"/"hosts.conf"

DMZ_HOST_PRIVATE_IP_PATTERN="dmz_host_private_ip"
DMZ_HOST_PRIVATE_IP=$(grep $DMZ_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

INTERNAL_HOST_PRIVATE_IP_PATTERN="internal_host_private_ip"
INTERNAL_HOST_PRIVATE_IP=$(grep $INTERNAL_HOST_PRIVATE_IP_PATTERN $HOSTS_CONF_FILE | awk -F "=" '{print $2}')

echo "DMZ host private ip: $DMZ_HOST_PRIVATE_IP"
echo "Internal host private ip: $INTERNAL_HOST_PRIVATE_IP"

ANSIBLE_HOSTS_FILE=$DIR_PATH/"ansible-playbook"/"hosts"

DMZ_HOST_IP_PATTERN="# DMZ VM IP"
sed -i "s/$DMZ_HOST_IP_PATTERN/$DMZ_HOST_PRIVATE_IP/" $ANSIBLE_HOSTS_FILE

INTERNAL_HOST_IP_PATTERN="# Internal VM IP"
sed -i "s/$INTERNAL_HOST_IP_PATTERN/$INTERNAL_HOST_PRIVATE_IP/" $ANSIBLE_HOSTS_FILE

# Ansible ssh private key file path
PRIVATE_KEY_FILE_PATH=$1

echo "Private key file path: $PRIVATE_KEY_FILE_PATH"

PRIVATE_KEY_FILE_PATH_PATTERN="ansible_ssh_private_key_file"
sed -i "s#$PRIVATE_KEY_FILE_PATH_PATTERN=#$PRIVATE_KEY_FILE_PATH_PATTERN=$PRIVATE_KEY_FILE_PATH#g" $ANSIBLE_HOSTS_FILE

DEPLOY_FOGBOW_FILE_PATH="ansible-playbook"/"deploy-fogbow.yml"

ansible-playbook $DEPLOY_FOGBOW_FILE_PATH
