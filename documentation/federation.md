## Federation mode configuration customization

Change the working directory to *federation/conf-files*:

```bash
$ cd federation/conf-files
```

Then, edit the configuration files present in this directory, as instructed below.

### Service host customization

File: site.conf

There are seven properties that need to be filled in this file:
* **remote_user**
* **service_host_ip**
* **service_host_ssh_private_key_file**
* **service_host_FQDN**
* **dmz_host_public_ip**
* **dmz_host_private_ip**
* **dmz_host_ssh_private_key_file**

The **remote_user** property should be filled with the user name that is used to access, via ssh, the **service host**
from the **installation host**. Let us assume that this user name is **ubuntu**.

The **service_host_ip** property should be filled with the IP address of the **service host**. For example,
**10.11.1.1**. While the **dmz_host_public_ip** and **dmz_host_private_ip** should be filled in with the
public and the private IP of the **dmz host**, respectively. For example, **100.30.1.1** and **10.11.1.2**.

The **service_host_ssh_private_key_file** and the **dmz_host_ssh_private_key_file** properties should be
filled with the path for the ssh private key generated in S5 of the [infrastructure setup](infrastructure-setup.md).
For example, **~/.ssh/fogbow-deploy**.

Finally, the **service_host_FQDN** property should be filled with the fully qualified domain name (FQDN)
associated with the IP of the **service host**. For example, for the domain **mydomain**, it could be
**fogbow-node.mydomain**.

Considering the example values given above, the content of the *site.conf* file would be:

```bash
$ cat site.conf
# Federation deploy
## Ansible user name on the hosts where the Fogbow node will be deployed (should be the same in all hosts)
remote_user=ubuntu
## Service host configuration (IP, SSH private key to access the service host from the installation host, and FQDN)
service_host_ip=10.11.1.1
service_host_ssh_private_key_file=~/.ssh/fogbow-deploy
service_host_FQN=fogbow-node.mydomain
## DMZ host configuration (IPs and SSH private key to access the DMZ host from the installation host)
dmz_host_public_ip=100.30.1.1
dmz_host_private_ip=10.11.1.2
dmz_host_ssh_private_key_file=~/.ssh/fogbow-deploy
```

### Membership Service (MS) customization

File: ms.conf

This file contains a single property (**members_list**), which is a comma-separated list with the **FQDN**
names of all federation members. It must include the FQDN of the node member that you are deploying. For
example, this file would look like this:

```bash
$ cat ms.conf
# MS configuration
## The list with the FQDN of the nodes that belong to the federation
members_list=fogbow-node.mydomain,fogbow-node.otherdomain,fogbow-node.yetanotherdomain
```

### Authentication Service (AS) customization

File: as.conf

The Authentication Service (AS) allows users of the service provided
by the Fogbow node to use a single login to access multiple clouds. The supported technologies are: LDAP,
Shibboleth-based federation of Identity Providers, OpenStack Keystone, and the CloudStack and OpenNebula
authentication services. Only the properties associated with the chosen technology need to be filled in.

The first property (**authentication_type**) is mandatory, and indicates the technology that
will be used. The valid options are (case sensitive): ldap, shibboleth, openstack, cloudstack, opennebula.
For example, if you choose to use LDAP, then this property should be filled in as follows:

authentication_type=ldap

If you are using LDAP, then three properties need to be filled in. The endpoint of the LDAP
service (**ldap_url**), the LDAP base configuration (**ldap_base**), and the LDAP encryption
type used, if any (**ldap_encrypt_type**). For example:

ldap_url=ldap://ldap.dept.organization.com:389

ldap_base=dc=dept,dc=organization,dc=com

ldap_encrypt_type=md5

If you are using a Shibboleth-based federation of Identity Providers (IdPs), then three properties
need to be filled in. The domain name of the service provider (**domain_service_provider**), the
endpoint of the discovery service of the IdP Shibboleth-based federation (**discovery_service_url**),
and the URL pointing to the metadata of the discovery service (**discovery_service_metadata_url**).
For example:

domain_service_provider=service.provider.com

discovery_service_url=https://discovery.service.com/WAYF

discovery_service_metadata_url=https://federation.organization.com/metadata/federation-metadata.xml

If you are using OpenStack Keystone, CloudStack or the OpenNebula authentication services, then
you simply need to fill in the corresponding property, indicating the endpoint of the required service.
For example:

openstack_keystone_v3_url=http://mycloud.mydomain:5000/v3

Or,

cloudstack_url=http://mycloud.mydomain/client/apidomain:8774

Or,

opennebula_url=http://mycloud.mydomain:2633/RPC2

With the examples given above, assuming the use of LDAP, the **as.conf** file would look like this:

```bash
$ cat as.conf
# AS configuration
## The token generator plugin used by the AS
authentication_type=ldap
## Add plugin specific properties
### LDAP configuration
#### The endpoint of the LDAP service
ldap_url=ldap://ldap.dept.organization.com:389
#### The ldap base configuration
ldap_base=dept,dc=organization,dc=com
#### The LDAP encryption type used (if any)
ldap_encrypt_type=md5
## Shibboleth configuration
### Domain name of the service provider that has been registered with the Shibboleth-based IdP Federation
domain_service_provider=
### Endpoint of the discovery service of the Shibboleth-based IdP Federation
discovery_service_url=
### Endpoint of the metadata service associated to the discovery service
discovery_service_metadata_url=
### Openstack Keystone v3 configuration
#### The endpoint of the keystone service
openstack_keystone_v3_url=
### Cloudstack configuration
#### The endpoint of the cloudstack authentication service
cloudstack_url=
### Opennebula configuration
#### The endpoint of the Opennebula authentication service
opennebula_url=
```

### Clouds customization

A Fogbow node is able to manage multiple clouds. For that, you need to assign a name for each cloud that is
going to be managed by your Fogbow node. For each cloud that you want to manage you need to create a file
inside the directory **conf-files/clouds** with the properties that customizes it. Say you want to manage
two clouds, and you decide to name them **private-cloud** and **public-cloud**. Then, you need to create
files **private-cloud.conf** and **public-cloud.conf** under **conf-files/clouds**. The contents of these
files depend on the technology used by the corresponding clouds. You can find templates for these files,
for the different technologies available, in the directory "../../../common/templates/clouds". Follow the
links below for instructions on how to customize the different cloud orchestration technologies supported.

- [OpenStack](openstack.md) 
- [CloudStack](cloudstack.md) 
- [OpenNebula](opennebula.md) 
- [AWS](aws.md)
- [Azure](azure.md)

### Apache certificates customization

An Apache web server is used to handle HTTPS traffic and give support to Shibboleth authentication. For that,
you need to provide the appropriate certificate for the service's FQDN and the Shibboleth service provider (if
you have chosen Shibboleth as the authentication technology to be used). The required information should be
stored in the files that you find in the **conf-files/certs** directory.

It is mandatory to provide content for the files **site.crt**, **site.key**, and **site.pem**. These files
are related to the certificate for the service FQDN, and contain, respectively, the SSL certificate,
the SSL certificate private key, and the SSL certificate authentication chain.

If you are using Shibboleth for authentication, then, you also must provide the content of
files **shibboleth-service-provider.crt** and **shibboleth-service-provider.key**, which should
contain, respectively, the SSL certificate and the SSL certificate private key for the Shibboleth
service provider running alongside your Fogbow node.

More information on how to configure authentication using Shibboleth-based IdP federations is provided
by the federations themselves. For example, RNP, the Brazilian National Research and Education Network,
supports the [CAFe federation](CAFe-configuration.md).

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)
