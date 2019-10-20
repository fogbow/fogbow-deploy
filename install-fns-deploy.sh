#!/bin/bash

# Set path variables

FNS_DEPLOY_CONF_FILE_PATH="./conf-files/fns-deploy.conf"
ANSIBLE_FILES_DIR_PATH="./ansible-playbook/fns-deploy"
ANSIBLE_HOSTS_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"hosts"
ANSIBLE_CFG_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"ansible.cfg"

# Generate content of Ansible hosts file

BASIC_SITE_IP_PATTERN="basic_site_ip"
BASIC_SITE_IP=$(grep $BASIC_SITE_IP_PATTERN $FNS_DEPLOY_CONF_FILE_PATH | awk -F "=" '{print $2}')

BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN="basic_site_ssh_private_key_file"
BASIC_SITE_PRIVATE_KEY_FILE_PATH=$(grep $BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN $FNS_DEPLOY_CONF_FILE_PATH | awk -F "=" '{print $2}')

XMPP_SERVER_IP_PATTERN="xmpp_server_ip"
XMPP_SERVER_IP=$(grep $XMPP_SERVER_IP_PATTERN $FNS_DEPLOY_CONF_FILE_PATH | awk -F "=" '{print $2}')

XMPP_SERVER_PRIVATE_KEY_FILE_PATH_PATTERN="xmpp_server_ssh_private_key_file"
XMPP_SERVER_PRIVATE_KEY_FILE_PATH=$(grep $XMPP_SERVER_PRIVATE_KEY_FILE_PATH_PATTERN $FNS_DEPLOY_CONF_FILE_PATH | awk -F "=" '{print $2}')

VANILLA_AGENT_IP_PATTERN="vanilla_agent_private_ip"
VANILLA_AGENT_IP=$(grep $VANILLA_AGENT_IP_PATTERN $FNS_DEPLOY_CONF_FILE_PATH | awk -F "=" '{print $2}')

VANILLA_AGENT_PRIVATE_KEY_FILE_PATH_PATTERN="vanilla_agent_ssh_private_key_file"
VANILLA_AGENT_PRIVATE_KEY_FILE_PATH=$(grep $VANILLA_AGENT_PRIVATE_KEY_FILE_PATH_PATTERN $FNS_DEPLOY_CONF_FILE_PATH | awk -F "=" '{print $2}')

echo "[localhost]" > $ANSIBLE_HOSTS_FILE_PATH
echo "127.0.0.1" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[basic-site-machine]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $BASIC_SITE_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[basic-site-machine:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$BASIC_SITE_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[xmpp-machine]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $XMPP_SERVER_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[xmpp-machine:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$XMPP_SERVER_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[vanilla-agent-machine]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $VANILLA_AGENT_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[vanilla-agent-machine:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$VANILLA_AGENT_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH

# Generate content of Ansible ansible.cfg file

REMOTE_USER_PATTERN="^remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $FNS_DEPLOY_CONF_FILE_PATH | awk -F "=" '{print $2}')

echo "[defaults]" > $ANSIBLE_CFG_FILE_PATH
echo "inventory = hosts" >> $ANSIBLE_CFG_FILE_PATH
echo "remote_user = $REMOTE_USER" >> $ANSIBLE_CFG_FILE_PATH
echo "host_key_checking = False" >> $ANSIBLE_CFG_FILE_PATH

# Deploy

(cd $ANSIBLE_FILES_DIR_PATH && ansible-playbook deploy.yml)

# House keeping

find . -type f -name "secrets" -exec rm {} \;

chmod -R go-rw conf-files
chmod -R go-rw services
