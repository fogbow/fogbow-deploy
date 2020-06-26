## Configuring an OpenNebula cloud

Ask your cloud administrator to create a system user, and provide a URL for accessing the cloud
(for example, http://mycloud.mydomain:2633/RPC2), to set this value in the properties
**opennebula_rpc_endpoint**  and **cloud_identity_provider_url**, as also a **username** and 
**password**, so you can set the values of the **cloud_user_credentials_username** and 
**cloud_user_credentials_password** properties.

Along with this, also ask for the following values:
* **Default Datastore ID** - The default resource ID for creating virtual machine images and 
additional files such as volumes and snapshots. Set its value in the **default_datastore_id** property.

* **Default Network ID** - The default resource ID for creating private networks. Set its value 
in the **default_network_id** property.
```
  Note: Optional property used only for users with administrator permission.
```
* **Default Public Network ID** - The default resource ID for creating public networks, to provide 
public IP addresses. Set its value in the **default_public_network_id** property.

* **Default Reservation Network ID** - The default resource ID for creating private network address 
reservations. Set its value in the **default_reservations_network_id** property.

* **Default Security Group ID** - The default resource ID for creating private network security groups. 
Set its value in the **default_security_group_id** property.

Considering the data obtained above, give a **name** to the OpenNebula cloud that you want to make 
available through Fogbow, and create a **cloudName**.conf file in the conf-files/clouds directory 
with the following content:
```
$ cat clouds/cloudName.conf
cloud_type=opennebula

opennebula_rpc_endpoint=http://mycloud.mydomain:2633/RPC2
default_datastore_id=1
default_network_id=0
default_public_network_id=1
default_reservations_network_id=2
default_security_group_id=0

cloud_user_credentials_username=username
cloud_user_credentials_password=password
cloud_identity_provider_url=http://mycloud.mydomain:2633/RPC2
```

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)