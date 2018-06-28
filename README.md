# Fogbow Playbook
==========

This tutorial provides an easy way to deploy the entire fogbow infrastructure.

## Pre-installation

Before performing the installation it is necessary to make some administrative settings.

### Hosts

It is necessary to have two hosts **dmz-host** and **internal-host**, at least the **dmz-host** must have a public IP address.

### Firewall configuration

The **dmz-host** should be at the DMZ (Demilitarized Zone) with the following ports open:

1. XMPP server to server communication port (**Default**: *5327*);
2. Reverse tunnel ssh port range;
3. Reverse tunnel service port range.

## Installation

### Environment setup

1. Download the *fogbow-playbook* project:

```bash
git clone https://github.com/fogbow/fogbow-playbook.git
```

2. Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

### Fogbow configuration

Go to the directory *conf-files* inside *fogbow-playbook* directory.

```bash
cd fogbow-playbook/conf-files
```

Then, edit the configuration files present in this directory. Please, note that it is only **necessary** to edit the configuration constants that have an annotation **"*# Required*".** in the line above them.

#### Hosts configuration

File: [hosts.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/hosts.conf)

The ***dmz_host_private_ip*** configuration constant is the **dmz-host** private network address.

The ***dmz_host_public_ip*** configuration constant is the **dmz-host** public network address.

The ***internal_host_private_ip*** configuration constant is the **internal-host** private network address.

#### Behavior configuration

File: [behavior.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/behavior.conf)

After the **behavior.conf** edition is necessary to edit the federation identity, authorization and local user credentials mapper configuration files that were configured in the **behavior.conf**.

#### Federation identity 

See the federation identity configuration files list [here](https://github.com/fogbow/fogbow-playbook/tree/master/conf-files/behavior-plugins/federation-identity). Please, configure the federation identity used in the **behavior.conf**.

- **LDAP**

File: [ldap-identity-plugin.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/behavior-plugins/federation-identity/ldap-identity-plugin.conf)

- **Default**

Configuration is not necessary.

#### Authorization 

See the authorization configuration files list [here](https://github.com/fogbow/fogbow-playbook/tree/master/conf-files/behavior-plugins/authorization). Please, configure the authorization used in the **behavior.conf**.

- **Default**

Configuration is not necessary.

#### Local user credentials mapper 

See the local user credentials mapper configuration files list [here](https://github.com/fogbow/fogbow-playbook/tree/master/conf-files/behavior-plugins/local-user-credentials-mapper). Please, configure the local user credentials mapper used in the **behavior.conf**.

- **Default**

File: [default_mapper.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/behavior-plugins/local-user-credentials-mapper/default_mapper.conf)

#### Cloud configuration

File: [cloud.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/cloud.conf)

After the **cloud.conf** edition is necessary to edit the cloud type configuration file that was configured in the **cloud.conf**, see the cloud types configuration files list [here](https://github.com/fogbow/fogbow-playbook/tree/master/conf-files/cloud-plugins).

- **OpenStack**

File: [openstack.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/cloud-plugins/openstack.conf)

#### Manager configuration

File: [manager.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/manager.conf)

The ***server_port*** configuration constant is the port that the Fogbow Manager component will server requests in the **internal-host**.

The ***manager_ssh_public_key_file_path*** and ***manager_ssh_private_key_file_path*** configuration constants are not required, however if they are not configured the *fogbow-playbook* will generate the keys automatically placing them at the *fogbow-playbook* directory.

#### Intercomponent configuration

File: [intercomponent.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/intercomponent.conf)

#### Membership configuration

File: [membership.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/membership.conf)

The ***server_port*** configuration constant is the port that the Membership component will server requests in the **internal-host**, note that the Membership service ***server_port*** should be different of the Manager ***server_port***.

#### Reverse tunnel configuration

File: [reverse-tunnel.conf](https://github.com/fogbow/fogbow-playbook/blob/master/conf-files/reverse-tunnel.conf)

The ***host_key_path*** configuration constant is not required, however if it is not configured the *fogbow-playbook* will use the ***manager_ssh_private_key_file_path***.

For the configuration constants ***reverse_tunnel_port*** and ***reverse_tunnel_http_port*** do not choose the 80 port because this port is used to server the Dashboard front-end in the **dmz-host**.

### Run

In the *fogbow-playbook* directory:

```bash
bash install.sh
```
