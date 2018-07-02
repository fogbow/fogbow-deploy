Fogbow Playbook
==========
Provides an easy way to deploy the entire fogbow infrastructure.

## Pre-installation

Before performing the installation it is necessary to make some administrative settings.

### Hosts

It is necessary to have two hosts **dmz-host** and **internal-host**, at least the **dmz-host** must have a public IP address.

### Firewall configuration

The **dmz-host** should be at the DMZ (Demilitarized Zone) with the following ports open:

1. XMPP server to server communication port (**Default**: *5327*);
2. Reverse tunnel ssh port range;
3. Reverse tunnel service port range.

### DNS configuration

It is necessary to configure the DNS to enable the **dmz-host** to receive XMPP messages. This DNS entry is the **XMPP ID** a.k.a **member-site-id** of the Fogbow installation. This configuration associates the public IP of the **dmz-host** to its **XMPP ID**.

### Cloud configuration

Fogbow uses a Mapper plugin to map federation users to users that are known in the local cloud. The simplest way to do that is to create a single user in the local cloud that is used to map any federation user that submits requests. The credentials used by this user to get access to resources in the local cloud are used to configure the Mapper plugin (details will be presented later).

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

File: [hosts.conf](conf-files/hosts.conf)

The ***dmz_host_private_ip*** configuration constant is the **dmz-host** private network address.

The ***dmz_host_public_ip*** configuration constant is the **dmz-host** public network address.

The ***internal_host_private_ip*** configuration constant is the **internal-host** private network address.

#### Behavior configuration

File: [behavior.conf](conf-files/behavior.conf)

To know more about the ***behavior.conf*** constants please see [please-give-me-an-explanation-link](http://www.fogbowcloud.org).

After the **behavior.conf** edition is necessary to edit the federation identity, authorization and local user credentials mapper configuration files that were configured in the **behavior.conf**.

#### Federation identity configuration

See the federation identity configuration files list [here](conf-files/behavior-plugins/federation-identity). Please, configure the federation identity used in the **behavior.conf**.

- **LDAP**

File: [ldap-identity-plugin.conf](conf-files/behavior-plugins/federation-identity/ldap-identity-plugin.conf)

To know more about the ***ldap-identity-plugin.conf*** constants please see [configure federation identity](install-configure-fogbow-manager.md#--federation-indentity).

- **Default**

Configuration is not necessary.

#### Authorization configuration

See the authorization configuration files list [here](conf-files/behavior-plugins/authorization). Please, configure the authorization used in the **behavior.conf**.

- **Default**

Configuration is not necessary.

#### Local user credentials mapper configuration

See the local user credentials mapper configuration files list [here](conf-files/behavior-plugins/local-user-credentials-mapper). Please, configure the local user credentials mapper used in the **behavior.conf**.

- **Default**

File: [default_mapper.conf](conf-files/behavior-plugins/local-user-credentials-mapper/default_mapper.conf)

To know more about the ***default_mapper.conf*** constants please see [please-give-me-an-explanation-link](http://www.fogbowcloud.org).

#### Cloud configuration

File: [cloud.conf](conf-files/cloud.conf)

To know more about the ***cloud.conf*** constants please see [configure cloud plugins](install-configure-fogbow-manager.md#--cloud-specific-plugins).

After the **cloud.conf** edition is necessary to edit the cloud type configuration file that was configured in the **cloud.conf**, see the cloud types configuration files list [here](conf-files/cloud-plugins).

- **OpenStack**

File: [openstack.conf](conf-files/cloud-plugins/openstack.conf)

To know more about the ***openstack.conf*** constants please see [configure openstack plugin](install-configure-fogbow-manager.md#--cloud-specific-plugins).

#### Manager configuration

File: [manager.conf](conf-files/manager.conf)

The ***server_port*** configuration constant is the port that the Fogbow Manager component will server requests in the **internal-host**.

The ***manager_ssh_public_key_file_path*** and ***manager_ssh_private_key_file_path*** configuration constants are not required, however if they are not configured the *fogbow-playbook* will generate the keys automatically placing them at the *fogbow-playbook* directory.

To know more about the ***manager.conf*** constants please see [configure manager](install-configure-fogbow-manager.md#configure).

#### Intercomponent configuration

File: [intercomponent.conf](conf-files/intercomponent.conf)

To know more about the ***intercomponent.conf*** constants please see [configure xmpp server](install-configure-xmpp.md#configure).

#### Membership configuration

File: [membership.conf](conf-files/membership.conf)

The ***server_port*** configuration constant is the port that the Membership component will server requests in the **internal-host**, note that the Membership service ***server_port*** should be different of the Manager ***server_port***.

To know more about the ***membership.conf*** constants please see [configure membership](install-configure-fogbow-rendezvous.md#configure).

#### Reverse tunnel configuration

File: [reverse-tunnel.conf](conf-files/reverse-tunnel.conf)

The ***host_key_path*** configuration constant is not required, however if it is not configured the *fogbow-playbook* will use the ***manager_ssh_private_key_file_path***.

For the configuration constants ***reverse_tunnel_port*** and ***reverse_tunnel_http_port*** do not choose the 80 port because this port is used to server the Dashboard front-end in the **dmz-host**.

To know more about the ***reverse-tunnel.conf*** constants please see [configure reverse tunnel](install-configure-reverse-tunnel.md#configure).

### Run

In the *fogbow-playbook* directory:

```bash
bash install.sh
```
