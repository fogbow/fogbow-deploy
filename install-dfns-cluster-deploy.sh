#!/bin/bash
# This script goal is to generate the Ansible hosts and ansible.cfg files, as well as the spacific .yml files
# for the hosts that form the cluster.

# Set path variables

CLUSTER_CONF_FILE_PATH="./conf-files/cluster.conf"
ANSIBLE_FILES_DIR_PATH="./ansible-playbook/dfns-cluster-deploy"
ANSIBLE_HOSTS_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"hosts"
ANSIBLE_CFG_FILE_PATH=$ANSIBLE_FILES_DIR_PATH/"ansible.cfg"

# Generate content of Ansible hosts file

DFNS_CLUSTER_PRIVATE_KEY_FILE_PATH_PATTERN="dfns_cluster_ssh_private_key_file"
DFNS_CLUSTER_PRIVATE_KEY_FILE_PATH=$(grep $DFNS_CLUSTER_PRIVATE_KEY_FILE_PATH_PATTERN $CLUSTER_CONF_FILE_PATH | awk -F "=" '{print $2}')

DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN="dfns_cluster_public_ips_list"
DFNS_CLUSTER_PUBLIC_IPS_LIST=$(grep $DFNS_CLUSTER_PUBLIC_IPS_LIST_PATTERN $CLUSTER_CONF_FILE_PATH | awk -F "=" '{print $2}')

LOCAL_HOST_ADDRESS=127.0.0.1
echo "[localhost]" >> $ANSIBLE_HOSTS_FILE_PATH
echo $LOCAL_HOST_ADDRESS >> $ANSIBLE_HOSTS_FILE_PATH
echo "localhost ansible_connection=local" >> $ANSIBLE_HOSTS_FILE_PATH

for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
  echo "" >> $ANSIBLE_HOSTS_FILE_PATH
  echo "[agent-node-$i]" >> $ANSIBLE_HOSTS_FILE_PATH
  echo $i >> $ANSIBLE_HOSTS_FILE_PATH
  echo "[agent-node-$i:vars]" >> $ANSIBLE_HOSTS_FILE_PATH
  echo "ansible_ssh_private_key_file=$DFNS_CLUSTER_PRIVATE_KEY_FILE_PATH" >> $ANSIBLE_HOSTS_FILE_PATH
  echo "ansible_python_interpreter=/usr/bin/python3" >> $ANSIBLE_HOSTS_FILE_PATH
done

# Generate install-dependencies.yml

YML_FILE_NAME="install-dependencies.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    echo "- hosts: agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      - name: Installing Docker in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        apt: pkg={{ item }} state=latest update_cache=yes cache_valid_time=3600" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - docker.io" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
done

# Generate remove-previous-installation.yml

YML_FILE_NAME="remove-previous-installation.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    echo "- hosts: agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      dfns_agent_dir_name: dfns-agents" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      atomix_dir_name: atomix" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      onos_dir_name: onos"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      utils_dir_name: utils"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      confs_dir_name: conf-files"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      - name: Removing previously installed DFNS agent software (if applied) in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        file:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          state: absent" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          path: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_agent_dir_name }}/{{ atomix_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_agent_dir_name }}/{{ onos_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_agent_dir_name }}/{{ utils_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_agent_dir_name }}/{{ confs_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
done

# Generate transfer-agents-software.yml

YML_FILE_NAME="transfer-agents-software.yml"
FIRST_DFNS_CLUSTER_IP=${DFNS_CLUSTER_PUBLIC_IPS_LIST%% *}
echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    echo "- hosts: agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      dfns_path: ../../services/dfns-agents" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      atomix_dir_name: atomix" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      onos_dir_name: onos"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      utils_dir_name: utils"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      confs_dir_name: conf-files"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      dfns_remote_path: dfns-agents"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    if [ "$i" = "$FIRST_DFNS_CLUSTER_IP" ]; then
      echo "      vlan_id_service_path: ../../services/vlan-id-service"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    fi
    echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      - name: Copying DFNS agents software in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        copy:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          src: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          dest: \"{{ dfns_remote_path }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ atomix_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ onos_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ utils_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ confs_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    if [ "$i" = "$FIRST_DFNS_CLUSTER_IP" ]; then
      echo "          - \"{{ vlan_id_service_path }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    fi
    echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
done

# Generate remove-atomix-container.yml

YML_FILE_NAME="remove-atomix-container.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    echo "- hosts: agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      atomix_dir_name: atomix" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      dfns_path: dfns-agents" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      remove_script_runner: bash remove-script.sh"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      - name: Removing Atomix container in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        shell: \"{{ remove_script_runner }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        args:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          chdir: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ atomix_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
done

# Generate remove-onos-container.yml

YML_FILE_NAME="remove-onos-container.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    echo "- hosts: agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      onos_dir_name: onos" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      dfns_path: dfns-agents" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      remove_script_runner: bash remove-script.sh"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      - name: Removing Onos container in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        shell: \"{{ remove_script_runner }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        args:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          chdir: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ onos_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
done

# Generate deploy-atomix.yml

YML_FILE_NAME="deploy-atomix.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    echo "- hosts: agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      atomix_dir_name: atomix" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      dfns_path: dfns-agents" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      deploy_script_runner: bash deploy-script.sh $i"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      - name: Deploying Atomix in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        shell: \"{{ deploy_script_runner }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        args:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          chdir: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ atomix_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
done

# Generate deploy-onos.yml

YML_FILE_NAME="deploy-onos.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
for i in $DFNS_CLUSTER_PUBLIC_IPS_LIST
do
    echo "- hosts: agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      onos_dir_name: onos" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      dfns_path: dfns-agents" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      onos_secret: \"{{ lookup('env','ONOS_SECRET') }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      deploy_script_runner: bash deploy-script.sh $i {{ onos_secret }}"  >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "      - name: Deploying Onos in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        shell: \"{{ deploy_script_runner }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        args:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          chdir: \"{{ item }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "        with_items:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "          - \"{{ dfns_path }}/{{ onos_dir_name }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
    echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
done

# Generate install-vlan-id-service.yml

YML_FILE_NAME="install-vlan-id-service.yml"

echo "---" > $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "- hosts: localhost" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      service_path: ../../services/vlan-id-service" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      env_composer_runner: bash env-composer.sh" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      - name: Setup confs file" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        shell: \"{{ env_composer_runner }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        args:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "          chdir: \"{{ service_path }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME

FIRST_DFNS_CLUSTER_IP=${DFNS_CLUSTER_PUBLIC_IPS_LIST%% *}
echo "- hosts: agent-node-$FIRST_DFNS_CLUSTER_IP" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  vars:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      deploy_script_path: dfns-agents/vlan-id-service" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      deploy_script_runner: bash deploy-script.sh" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "  tasks:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "      - name: Deploying vlan-id-service in agent-node-$i" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        shell: \"{{ deploy_script_runner }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        become: yes" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "        args:" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "          chdir: \"{{ deploy_script_path }}\"" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME
echo "" >> $ANSIBLE_FILES_DIR_PATH/$YML_FILE_NAME


# Generate content of Ansible ansible.cfg file

REMOTE_USER_PATTERN="^remote_user"
REMOTE_USER=$(grep $REMOTE_USER_PATTERN $CLUSTER_CONF_FILE_PATH | awk -F "=" '{print $2}')

echo "[defaults]" > $ANSIBLE_CFG_FILE_PATH
echo "inventory = hosts" >> $ANSIBLE_CFG_FILE_PATH
echo "remote_user = $REMOTE_USER" >> $ANSIBLE_CFG_FILE_PATH
echo "host_key_checking = False" >> $ANSIBLE_CFG_FILE_PATH

# Copy cluster.conf to services
mkdir -p "services/dfns-agents/conf-files"
cp "./conf-files/cluster.conf" "services/dfns-agents/conf-files/cluster.conf"

# Deploy

ONOS_SECRET=$(pwgen 10 1)
export ONOS_SECRET

(cd $ANSIBLE_FILES_DIR_PATH && ansible-playbook deploy.yml)

# House keeping

chmod -R go-rw conf-files
chmod -R go-rw services
