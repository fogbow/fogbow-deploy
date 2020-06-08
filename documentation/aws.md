## Configuring an AWS cloud

Ask the cloud administrator to create an Identity and Access Management User, called **IAM user** with administrator permissions, providing the **access key** ID and the **secret access key**.

Together with the IAM user, also request the **region** and **availability zone** of the user account created, including the quota data for the following resources, related to the selected region:
* **Storage quota** - The maximum aggregate amount of storage that can be provisioned in this Region;
* **Elastic IP Addresses quota** - The number of Elastic IP addresses for use with a VPC;
* **Virtual Private Cloud quota** - The total number of VPCs by Region;

Will need to create and configure a **VPC** with a default subnet that provides access to a shared private network and a default security group for that network, as the following [tutorial](vpc-configuration.md).

After creation, make available the **default subnet ID** and the **default security group ID**.

Considering the data obtained above, give a **name** to the AWS cloud that you want to make available through Fogbow, and create a **cloudName**.conf file in the conf-files/clouds directory with the following content:

```
$ cat clouds/cloudName.conf
cloud_type=aws

aws_region_selection_key=sa-east-1
aws_availability_zone_key=sa-east-1a
aws_default_subnet_id_key=subnet-045038cd60e372274
aws_default_security_group_id_key=sg-00bb52aad68c8dadb
aws_storage_quota_key=300
aws_elastic_ip_addresses_quota_key=5
aws_vpc_quota_key=5

cloud_user_credentials_access_key=aws-iam-user-access-key
cloud_user_credentials_secret_access_key=aws-iam-user-secret-access-key
```

####[Back to multi-cloud customization page](multi-cloud.md)

####[Back to federation customization page](federation.md)

####[Back to node configuration customization page](node-configuration.md)

####[Back to main installation page](main.md)