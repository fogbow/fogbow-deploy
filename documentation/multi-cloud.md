## Multi-cloud mode configuration customization

Change the working directory to *multi-cloud/conf-files*:

```bash
$ cd multi-cloud/conf-files
```

Then, edit the configuration files present in this directory, as instructed below.

### Service host customization

File: host.conf

There are four properties that need to be filled in this file:
* **remote_user**
* **service_host_ip**
* **service_host_ssh_private_key_file**
* **service_host_FQDN**

The **remote_user** property should be filled with the user name that is used to access, via ssh, the **service host**
from the **installation host**. Let us assume that this user name is **ubuntu**.

The **service_host_ip** property should be filled with the IP address of the **service host**. For example,
**10.11.1.1**.

The **service_host_ssh_private_key_file** property should be filled with the path for the ssh private key
generated in S5 of the [infrastructure setup](infrastructure-setup.md). For example, **~/.ssh/fogbow-deploy**.

Finally, the **service_host_FQDN** property should be filled with the fully qualified domain name (FQDN)
associated with the IP of the **service host**. For example, for the domain **mydomain**, it could be
**fogbow-node.mydomain**.

Considering the example values given above, the content of the *host.conf* file would be:

```bash
$ cat host.conf
# Multi-cloud deploy
## Ansible user name on the service host (e.g. ubuntu)
remote_user=ubuntu
## Service host configuration (IP, SSH private key to access the service host from the installation host, and FQDN)
service_host_ip=10.11.1.1
service_host_ssh_private_key_file=~/.ssh/fogbow-deploy
service_host_FQDN=fogbow-node.mydomain
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

A Fogbow node is able to manage multiple clouds. Naturally, you can restrict the resources from the cloud
that will be made available through Fogbow. Thus, we will use the term "cloud view" to refer to the resources
of a particular cloud that you make available through Fogbow. Note that you can even provide multiple views
for the same cloud. By developing suitable authorization plugins, you can allow different users to
access different cloud views.

For each cloud view that is going to be managed by your Fogbow node, you need to provide a configuration file,
containing the properties that customizes it. These files are hosted inside the directory **conf-files/clouds**.
Say you want to manage two cloud views, and you decide to name them **private-cloud** and **public-cloud**.
Then, you need to create files **private-cloud.conf** and **public-cloud.conf** under **conf-files/clouds**.

There is a property, called **cloud_type**, which is present in all files and specifies what is the technology
used by the cloud. The values for the supported technologies are: aws, azure, cloudstack, opennebula, and
openstack. The other properties depend on the technology used by the corresponding clouds. You can find
templates for the files, for the different technologies available, in the directory
"../../../common/templates/clouds". Follow the links below for instructions on how to customize the
different cloud orchestration technologies supported.

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