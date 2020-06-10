## Configuring an Azure cloud

To define the cloud resources that will be made available to the federation through Fogbow, you will need to obtain Azure access credentials. To do this Install and run the [Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli?view=azure-cli-latest).

Log in to the Azure CLI with the command:
```
az login
```
The Azure CLI will open a web browser to access your Azure account. Log in, and an access response like the following will be returned:
```
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "3f434676-aabb-11ea-bb37-0242ac130002",
    "id": "7cabb21d-59ee-4a1f-a199-34b99b64a5f1",
    "isDefault": true,
    "managedByTenants": [],
    "name": "Assinatura do Azure 1",
    "state": "Enabled",
    "tenantId": "3f434676-aabb-11ea-bb37-0242ac130002",
    "user": {
      "name": "johnsmith@outlook.com",
      "type": "user"
    }
  }
]
```
Use the value of the **id** to define the property **cloud_user_credentials_subscription_id** and the **tenantId** for the property **cloud_user_credentials_tenant_id**.

To generate and/or obtain the client application ID and create a random authentication password, run the command:
```
az ad sp create-for-rbac --name ServicePrincipalName
```
A response like the following will be returned:
```
{
  "appId": "39e964a0-50bb-4aaf-a134-4b85c6004725",
  "displayName": "ServicePrincipalName",
  "name": "http://ServicePrincipalName",
  "password": "f06af6bc-66d9-4691-adaf-81fc80e6d54d",
  "tenant": "3f434676-aabb-11ea-bb37-0242ac130002"
}
```
Use the **appId** value to define the property **cloud_user_credentials_client_id** and the **password** value to the property **cloud_user_credentials_client_key**.

In addition to the credentials, also provide a default **region** for making requests to a cloud provider at [Azure locations](https://azure.microsoft.com/en-us/global-infrastructure/locations/). For exemple, **default_region_name**=*brazilsouth* (To the Brazil South region) ou **default_region_name**=*eastus* (To the East US region).

Along with this, a list of **publishers** must be filled in to provide **virtual machine images**, such as Ubuntu and Windows Server. For example, **virtual_machine_images_publishers**=*Canonical, MicrosoftWindowsServer*.

You can obtain a list of publishers by region with the following command, using the Azure CLI:
```
az vm image list-publishers --location brazilsouth
```
Finally, create a default **virtual network** to provide access to a shared private network and a default **security group** for that network, making available the names of these resources to the properties **default_virtual_network_name** and **default_resource_group_name** respectively.

Considering the data obtained above, give a **name** to the Azure cloud that you want to make available through Fogbow, and create a **cloudName**.conf file in the conf-files/clouds directory with the following content:
```
$ cat clouds/cloudName.conf
cloud_type=azure

default_virtual_network_name=default-fogbow-virtual-network
default_resource_group_name=default-fogbow-resource-group
default_region_name=brazilsouth
virtual_machine_images_publishers=Canonical,MicrosoftWindowsServer

cloud_user_credentials_subscription_id=7cabb21d-59ee-4a1f-a199-34b99b64a5f1
cloud_user_credentials_client_id=39e964a0-50bb-4aaf-a134-4b85c6004725
cloud_user_credentials_client_key=f06af6bc-66d9-4691-adaf-81fc80e6d54d
cloud_user_credentials_tenant_id=3f434676-aabb-11ea-bb37-0242ac130002
```

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)