## Configuration customization

Go to the directory *conf-files* inside *fogbow-deploy* directory.

```bash
$ cd conf-files
```

Then, edit the configuration files present in this directory, as instructed in the following. The templates already
available indicate which fields need to be filled in (Required), and which have default values (Not Required), and,
therefore, are not mandatory. 

However, for the purpose of the installation described in this guide, only some of the Required fields need to
be edited, since some of these fields can be automatically filled in by the installation scripts. In the following,
we just discuss the fields that the installation scripts cannot automatically gather, and, therefore, need to be
filled in by you.

### Installation configuration

#### Hosts configuration

File: hosts.conf

```bash
$ cat hosts.conf
# Required
dmz_host_private_ip=

# Required
dmz_host_public_ip=

# Required
internal_host_private_ip=

# Required
remote_hosts_user=

# Not Required (if not specified, ansible will use the host ssh keys)
ansible_ssh_private_key_file=
```

The ***dmz_host_private_ip*** configuration constant is the **dmz-host** private IP address.

The ***dmz_host_public_ip*** configuration constant is the **dmz-host** public IP address.

The ***internal_host_private_ip*** configuration constant is the **internal-host** private IP address.

The **remote_hosts_user** is the user name that should be used to access the **dmz-host** and the
**internal-host** via ssh. Let us assume that this user name is **ubuntu**.

Considering the example values given in this guide, the content of the *hosts.conf* would be:

```bash
$ cat hosts.conf
# Required
dmz_host_private_ip=10.11.4.2

# Required
dmz_host_public_ip=100.30.1.1

# Required
internal_host_private_ip=10.11.4.3

# Required
remote_hosts_user=ubuntu

# Not Required (if not specified, ansible will use the host ssh keys)
ansible_ssh_private_key_file=
```

#### Messaging service configuration

File: intercomponent.conf

```bash
$ cat intercomponent.conf
# Required
xmpp_jid=

# Required
xmpp_password=

# Not Required
xmpp_server_ip=

# Not Required
xmpp_s2s_port=5269

# Not Required
xmpp_c2s_port=5222

# Not Required
xmpp_c2c_port=5347

# Not Required
xmpp_timeout=
```

This files contains the configuration of the XMPP **messaging-service**. The only field that needs
to be configured is the **xmpp_jid**.

Considering the examples in this guide, the **xmpp_jid** should be set to **myfederation.mycloud.mydomain**. Then,
the *intercomponent.conf* file would look like (recall that empty constants will be automatically configured by the
installation script):

```bash
$ cat intercomponent.conf
# Required
xmpp_jid=myfederation.mycloud.mydomain

# Required
xmpp_password=

# Not Required
xmpp_server_ip=

# Not Required
xmpp_s2s_port=5269

# Not Required
xmpp_c2s_port=5222

# Not Required
xmpp_c2c_port=5347

# Not Required
xmpp_timeout=
```

#### AAA plugins configuration

File: aaa.conf

```bash
$ cat aaa.conf
# Required
token_generator_plugin_class=

# Required
federation_identity_plugin_class=

# Required
authentication_plugin_class=

# Required
authorization_plugin_class=

# Required
local_user_credentials_mapper_plugin_class=
```

This file contains the configuration of the plugins that define how Authentication, Authorization, and Auditing (AAA)
operations are performed at your site.

There are two main ways to implement authentication: through a centralized identity provider service, or through
autonomous independent local identity providers. In both cases, the user interacts with the (local or centralized)
indentity provider through the Fogbow Resource Allocation Service (RAS). Three plugins need to be defined for the
implementation of the authentication of federation users: the token
generator, the federation identity, and the authorization plugins. 

Authorization at the federation level is performed by the authorization plugin. We currently deploy only the default
authorization plugin that allows any authentic federation user to execute all
operations made available by the RAS API. However, before the operation is actually executed in the underlying
cloud, the federation user is mapped to a local user by the mapper plugin. This mapping generates a token that can
be used to access the underlying cloud. Naturally, before executing the requests receive from the RAS, the cloud
middleware authenticates this token, and checks if the token authorizes the requester to perform the operation
embedded in the request.

There are multiple ways to configure the AAA plugins. Detailed information is provided in the links below.

- [LDAP and Openstack](2.3-ldap-on-openstack-aaa.md)
- [Full Openstack](2.3-full-openstack-aaa.md)
- [Shibboleth and Openstack](2.6-shibboleth-on-openstack-aaa.md)

### Interoperability plugins configuration

Now you need to configure the plugins that will allow Fogbow to interact with the underlying cloud. This is done
in the *interoperability.conf* file.

File: interoperability.conf

```bash
$ cat interoperability.conf
# Required
compute_plugin_class=

# Required
volume_plugin_class=

# Required
network_plugin_class=

# Required
attachment_plugin_class=

# Required
compute_quota_plugin_class=

# Required
image_plugin_class=

# Required
public_ip_plugin_class=
```

Below we describe the configuration steps for the different technologies supported.

- [Openstack](2.4-openstack-configuration.md)
- [Cloudstack](2.4-cloudstack-configuration.md)

### Apache web server

An Apache web server is used to handle HTTPS traffic and give support to Shibboleth authentication. Two files in the *apache-confs* directory need to be edited in every deploy, the certificate-files.conf and the domain-names.conf. Besides that there is another file to configure when the Shibboleth authetication is required.

File: apache=confs/certificate-files.conf

```bash
$ cat apache-confs/certificate-files.conf
# You should provide an absolute path
# Required
SSL_certificate_file_path=

# Required
SSL_certificate_key_file_path=

# Required
SSL_certificate_chain_file_path=
```

Copy the certificate files in the **installation-machine** and edit the *certificates-files.conf* with
the corresponding paths.

File: apache-confs/domain-names.conf

This file contains the DNS names that have been associated to the services. Considering the example values
used in this guide, the content of this file would look like this:

```bash
$ cat apache-confs/domain-names.conf
# Required: Dashboard domain name
dashboard_domain_name=https://dashboard-myfederation-mycloud.mydomain

# Required: Federated Network Service domain name
fns_domain_name=https://fns-myfederation-mycloud.mydomain

# Required: Resource Allocation Service domain name
ras_domain_name=https://ras-myfederation-mycloud.mydomain

# Required: Membership Service domain name
ms_domain_name=https://ms-myfederation-mycloud.mydomain
```

#### Shibboleth module
In case Shibboleth as authentication type then is necessary to configure the required properties of this scenario.

File: apache-confs/shibboleth.conf
```
# This is the domain associated with the Service Provider in the RNP
# This configuration must follow this guide: https://wiki.rnp.br/pages/viewpage.action?pageId=69969868. In the RNP context, this property is called HOSTNAME.
# eg: myserviceprovider.org.br
domain_service_provider=

# This is the certificate associated with the Service Provider in the RNP
# Certificate generated on the Service Provider creation
# This configuration must follow this guide: https://wiki.rnp.br/pages/viewpage.action?pageId=69969868.
certificate_service_provider_path=

# This is the certificate's key associated with the Service Provider in the RNP
# Key generated on the Service Provider creation
# This configuration must follow this guide: https://wiki.rnp.br/pages/viewpage.action?pageId=69969868.
key_service_provider_path=

# Discovery Service url related on the CAFe authentication
discovery_service_url=

# Discovery Service metadata url related on the CAFe authentication
discovery_service_metadata_url=
```

### Membership service configuration

File: ms.conf

```bash
$ cat ms.conf
# Required
server_port=8081

# Required
# List of members
members_list=
```

This files contains the list of **XMPP ID** of all federation members. Its configuration depends on the
federation that is being setup. Below we provide information about some knwon federations.

- [ATMOSPHERE project production federation](2.5-atm-prod-federation-configuration.md)

### GUI

Lastly, you need to configure the authentication mode that will be used by the GUI (dashboard). This is done 
in the *gui-confs/gui.conf* file, and must match your choices when defining the AAA plugins. Currently we
support Shibboleth, LDAP and Openstack. Simply set the *authentication_type* property to either *shibboleth*, *ldap* or *openstack*.

File: gui-confs/gui.conf

```bash
$ cat gui-confs/gui.conf
# Not Required
fogbow_gui_server_port=81

# Required
# Valid options: 
#   - ldap
#   - openstack
#   - shibboleht
authentication_type=
```

## Software installation

Now, you only need to go back to the *fogbow-deploy* directory, and run the installation script.

```bash
$ cd ..
$ bash install.sh
```

Your Fogbow site should be up now. Open a browser and point it to **dashboard.myfederation.mycloud.mydomain**,
log in using the appropriate credentials, and you are ready to manager resources in the cloud federation.

It is a good idea to save a copy of the conf-files directory. This will be useful when updating you site
installation, since most of (if not all) )the information in the configuration files are typically preserved
between successive deployments of a Fogbow site.

### Cloud setup

Before installing Fogbow, it is necessary to setup a few things in the underlying cloud that is
going to be federated. More precisely, it is necessary to ask the cloud administrator to define
resource quotas that will define which and how much resources will be made available
to the federation. The particularities of this step depend on the technology used in the underlying
cloud. Below we provide detailed descriptions for the supported cloud technologies.

- [Openstack setup](2.2-openstack-configuration.md) 