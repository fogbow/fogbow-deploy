#!/bin/bash
# This script goal is to generate the Ansible hosts and ansible.cfg files

# Set path variables

SITE_CONF_FILE_PATH="./conf-files/site.conf"
ANSIBLE_FILES_DIR_PATH="./ansible-playbook/dfns-deploy"
ANSIBLE_HOSTS_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"hosts"
ANSIBLE_CFG_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"ansible.cfg"

# Generate content of Ansible hosts file

BASIC_SITE_IP_PATTERN="basic_site_ip"
BASIC_SITE_IP=$(grep $BASIC_SITE_IP_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN="basic_site_ssh_private_key_file"
BASIC_SITE_PRIVATE_KEY_FILE_PATH=$(grep $BASIC_SITE_PRIVATE_KEY_FILE_PATH_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

DFNS_AGENT_PRIVATE_KEY_FILE_PATH_PATTERN="dfns_agent_ssh_private_key_file"
DFNS_AGENT_PRIVATE_KEY_FILE_PATH=$(grep $DFNS_AGENT_PRIVATE_KEY_FILE_PATH_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

DFNS_AGENT_PUBLIC_IP_PATTERN="dfns_agent_public_ip"
DFNS_AGENT_PUBLIC_IP=$(grep $DFNS_AGENT_PUBLIC_IP_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

echo "[localhost]" > $ANSIBLE_HOSTS_FILE_PATH
echo "127.0.0.1" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[basic-site-machine]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $BASIC_SITE_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[basic-site-machine:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$BASIC_SITE_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH
echo "" >> $ANSIBLE_HOSTS_FILE_PATH
echo "[agent-node-$DFNS_AGENT_PUBLIC_IP]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $DFNS_AGENT_PUBLIC_IP >> $ANSIBLE_HOSTS_FILE_PATH
echo "[agent-node-$DFNS_AGENT_PUBLIC_IP:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_ssh_private_key_file=$DFNS_AGENT_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH

# Generate content of Ansible ansible.cfg file

REMOTE_USER_PATTERN="^remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $SITE_CONF_FILE_PATH | awk -F "=" '{print $2}')

echo "[defaults]" > $ANSIBLE_CFG_FILE_PATH
echo "inventory = hosts" >> $ANSIBLE_CFG_FILE_PATH
echo "remote_user = $REMOTE_USER" >> $ANSIBLE_CFG_FILE_PATH
echo "host_key_checking = False" >> $ANSIBLE_CFG_FILE_PATH

# Generate transfer-dfns-install.yml

YML_FILE_NAME="transfer-dfns-install.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "- hosts: agent-node-$DFNS_AGENT_PUBLIC_IP" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      dfns_path: ../../services/dfns-agents" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      install_dir_name: install" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      dfns_remote_path: ~/dfns-agents"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      - name: Copying DFNS install in agent-node-$DFNS_AGENT_PUBLIC_IP" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        copy:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "          src: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "          dest: \"{{ dfns_remote_path }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "          - \"{{ dfns_path }}/{{ install_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME

# Generate add-public-key.yml

YML_FILE_NAME="add-public-key.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "- hosts: agent-node-$DFNS_AGENT_PUBLIC_IP" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      install_dir_name: install" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      dfns_path: \"/home/{{ lookup('config', 'DEFAULT_REMOTE_USER')}}/dfns-agents\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      deploy_script_runner: bash add-public-key.sh"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      - name: Adding public key in agent-node-$DFNS_AGENT_PUBLIC_IP" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        shell: \"{{ deploy_script_runner }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        args:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "          chdir: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "          - \"{{ dfns_path }}/{{ install_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME

# Deploy

(cd $ANSIBLE_FILES_DIR_PATH && ansible-playbook deploy.yml)

# House keeping

chmod -R go-rw conf-files
chmod -R go-rw services
