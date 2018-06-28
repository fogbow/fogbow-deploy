# Fogbow Playbook

Easy way to deploy the entire fogbow infrastructure.

## Setup

Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

## Configuration

Edit 11 small configuration files. Please, note that is only **necessary** to edit the configuration constants that the line above contains the token **"*# Required*".**

### Hosts

File: [hosts.conf](conf-files/hosts.conf)

The ***dmz_host_private_ip*** configuration constant is the **dmz-host** private network address.

The ***dmz_host_public_ip*** configuration constant is the **dmz-host** public network address.

The ***internal_host_private_ip*** configuration constant is the **internal-host** private network address.

### Behavior configuration

File: [behavior.conf](conf-files/behavior.conf)

To know more about the ***behavior.conf*** constants please see [please-give-me-an-explanation-link](http://www.fogbowcloud.org).

### Cloud configuration

File: [cloud.conf](conf-files/cloud.conf)

To know more about the ***cloud.conf*** constants please see [please-give-me-an-explanation-link](http://www.fogbowcloud.org).

### Fogbow manager configuration

File: [manager.conf](conf-files/manager.conf)

The ***server_port*** configuration constant is the port that the Fogbow Manager component will server requests in the **internal-host**.

The ***manager_ssh_public_key_file_path*** and ***manager_ssh_private_key_file_path*** configuration constants are not required, however if they are not configured the *fogbow-playbook* will generate the keys automatically placing them at the *fogbow-playbook* directory.

To know more about the ***manager.conf*** constants please see [please-give-me-an-explanation-link](http://www.fogbowcloud.org).

### Intercomponent configuration

File: [intercomponent.conf](conf-files/intercomponent.conf)

To know more about the ***intercomponent.conf*** constants please see [please-give-me-an-explanation-link](http://www.fogbowcloud.org).

### Membership configuration

File: [membership.conf](conf-files/membership.conf)

The ***server_port*** configuration constant is the port that the Membership component will server requests in the **internal-host**, note that the Membership service ***server_port*** should be different of the Manager ***server_port***.

To know more about the ***membership.conf*** constants please see [please-give-me-an-explanation-link](http://www.fogbowcloud.org).
