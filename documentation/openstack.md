# Configuration of an Openstack cloud

Ask the cloud administrator to create a project to define the cloud resources that will be made
available to the federation, through Fogbow. Let us assume that this project is called
**fogbow-resources** and has been defined under domain **general**. A new user needs to be created,
and associated with this project. Let us assume that this user is called **fogbow-resources-user**,
and that its password is **userpasswd**. Take note of the real values used in your deploy. 

The project must also have access to a private tenant network (Shared=Yes), and a public external
network (External Network=Yes). (They can be the same network with Shared=Yes and External Network=Yes.)
Let us assume the more general case where these networks are distinct, and assume that the tenant
network is called **provider**, while the external network is called **public**.

The resource quota for the **fogbow-resources** project defines the maximum number of virtual machine 
(VM) instances, volumes, floating IPs, Security Groups, as well as the maximum amount of RAM and
storage that the cloud will provide to users, through Fogbow. For each private network
created and each floating IP assigned to a VM, a new security group is created. Thus, the quota for
security groups should take this into account.

Take the opportunity that you are talking to the cloud administrator to note down some important 
information that you will need when configuring the system. The list below summarizes the required 
information:

* The endpoint of the Nova service (Compute) - let us assume that it is **https://mycloud.mydomain:8774**;
* The endpoint of the Neutron service (Network) - let us assume that it is **https://mycloud.mydomain:9696**;
* The network id of the **provider** network - let us assume that it is **d37b1f87-e17d-4913-8hgj-5f9ebe12345a**
* The network id of the **public** network - let us assume that it is **ec6d73f2-85j4-45ad-aa82-650e675cfaa4**
* The endpoint of the Cinder service (Block Storage) - let us assume that it is **https://mycloud.mydomain:8776**;
* The endpoint of the Glance service (Image) - let us assume that it is **https://mycloud.mydomain:9292**;
* The endpoint of the Keystone service (Identity) - let us assume that it is **https://mycloud.mydomain:5000/v3**;

Let us name "mycloud", the OpenStack cloud that you are going to make available via your Fogbow node.
Then, considering the examples given above, you must create a file called mycloud.conf under the
conf-files/clouds directory with the following content:

```
$ cat clouds/mycloud.conf
cloud_type=openstack

openstack_nova_url=https://mycloud.mydomain:8774
openstack_neutron_url=https://mycloud.mydomain:9696
default_network_id=d37b1f87-e17d-4913-8hgj-5f9ebe12345a
external_gateway_info=ec6d73f2-85j4-45ad-aa82-650e675cfaa4
openstack_cinder_url=https://mycloud.mydomain:8776
openstack_glance_url=https://mycloud.mydomain:9292

cloud_user_credentials_projectname=fogbow-resources
cloud_user_credentials_domain=general
cloud_user_credentials_username=fogbow-resources-user
cloud_user_credentials_password=userpasswd
cloud_identity_provider_url=https://mycloud.mydomain:5000/v3
```

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)