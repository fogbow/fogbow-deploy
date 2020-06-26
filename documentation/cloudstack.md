## Configuring a CloudStack cloud

Ask your cloud administrator to create a user account available, giving the URL to access the 
CloudStack Client API (For example, https://compute.mydomain/client/api), so you can set the
values in the properties **cloudstack_api_url** and **cloud_identity_provider_url**, as also
the account user **name**, **password** and resource management **domain**, to respectively
define them in the properties **cloud_user_credentials_username** , 
**cloud_user_credentials_password** and **cloud_user_credentials_domain**.

Along with this, also ask for the following values:
* **Zone ID** - The geographic zone ID corresponding to the datacenter responsible for providing
the resources. Set its value in the **zone_id** property.

* **Default Network ID** - The default network ID for creating private networks. Set its value in
the **default_network_id** property.

* **Network Offering ID** - The network offer ID of the available resources defined by the cloud
administrator for end users. Set its value in the **network_offering_id** property.

Considering the data obtained above, give a **name** to the OpenNebula cloud that you want to make
available through Fogbow, and create a **cloudName**.conf file in the conf-files/clouds directory
with the following content:
```
$ cat clouds/cloudName.conf
cloud_type=cloudstack

cloudstack_api_url=https://compute.mydomain/client/api
zone_id=0d89768b-abf5-651e-b4ab-57902fa12345
default_network_id=f103fb71-0033-4f00-98b6-1409d0r8nmc6
network_offering_id=abc05b4c-6kea-h6j6-a1f9-57f5b2j908f3

cloud_user_credentials_username=username
cloud_user_credentials_password=password
cloud_user_credentials_domain=domain
cloud_identity_provider_url=https://compute.mydomain/client/api
```

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)